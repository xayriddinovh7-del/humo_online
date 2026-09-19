import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import '../storage/secure_storage.dart';

/// Dio HTTP client — barcha API so'rovlar uchun asosiy singleton
class DioClient {
  DioClient._();

  static final DioClient instance = DioClient._();

  late final Dio _dio;
  bool _initialized = false;

  Dio get dio {
    if (!_initialized) _init();
    return _dio;
  }

  void _init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout:
            const Duration(milliseconds: ApiConstants.connectTimeoutMs),
        receiveTimeout:
            const Duration(milliseconds: ApiConstants.receiveTimeoutMs),
        contentType: 'application/json',
        responseType: ResponseType.json,
        headers: {'Accept': 'application/json'},
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(),
      _ErrorInterceptor(),
      if (const bool.fromEnvironment('dart.vm.product') == false)
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => print('[DIO] $obj'),
        ),
    ]);

    _initialized = true;
  }

  /// Upload uchun Dio (uzun timeout)
  Dio get uploadDio {
    if (!_initialized) _init();
    final uploadDio = Dio(_dio.options.copyWith(
      receiveTimeout:
          const Duration(milliseconds: ApiConstants.uploadTimeoutMs),
      sendTimeout:
          const Duration(milliseconds: ApiConstants.uploadTimeoutMs),
    ));
    uploadDio.interceptors.addAll([
      _AuthInterceptor(),
      _ErrorInterceptor(),
    ]);
    return uploadDio;
  }
}

// ─── Auth Interceptor ────────────────────────────────────────────────────────

class _AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await SecureStorageService.instance.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // 401 → refresh tokenni sinab ko'rish
    if (err.response?.statusCode == 401) {
      final refreshToken =
          await SecureStorageService.instance.getRefreshToken();
      if (refreshToken != null) {
        try {
          final refreshResp = await Dio().post(
            '${ApiConstants.baseUrl}${ApiConstants.refreshToken}',
            data: {'refreshToken': refreshToken},
          );
          final respData = refreshResp.data as Map<String, dynamic>;
          final newToken =
              (respData['data'] as Map<String, dynamic>?)?['accessToken']
                  as String?;
          if (newToken != null) {
            await SecureStorageService.instance.saveAccessToken(newToken);
            // So'rovni qayta yuborish
            err.requestOptions.headers['Authorization'] =
                'Bearer $newToken';
            final retryResponse = await DioClient.instance.dio.fetch(
              err.requestOptions,
            );
            handler.resolve(retryResponse);
            return;
          }
        } catch (_) {
          // Refresh ham muvaffaqiyatsiz — barcha tokenlarni o'chirish
          await SecureStorageService.instance.clearAll();
        }
      }
    }
    handler.next(err);
  }
}

// ─── Error Interceptor ───────────────────────────────────────────────────────

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _mapDioError(err);
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        response: err.response,
        type: err.type,
      ),
    );
  }

  AppException _mapDioError(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final data = err.response?.data;
        final message = _extractMessage(data);

        return switch (statusCode) {
          401 => const UnauthorizedException(),
          403 => const ForbiddenException(),
          404 => const NotFoundException(),
          422 => ValidationException(
              message: message,
              errors: _extractErrors(data),
            ),
          _ => ServerException(
              message: message,
              statusCode: statusCode,
            ),
        };

      case DioExceptionType.cancel:
        return const UploadCancelledException();

      default:
        return ServerException(
          message: err.message ?? 'Noma\'lum xatolik',
        );
    }
  }

  String _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ??
          data['error'] as String? ??
          'Server xatoligi yuz berdi';
    }
    return 'Server xatoligi yuz berdi';
  }

  Map<String, List<String>>? _extractErrors(dynamic data) {
    if (data is Map<String, dynamic> && data['errors'] is Map) {
      return (data['errors'] as Map).map(
        (k, v) => MapEntry(
          k.toString(),
          (v as List).map((e) => e.toString()).toList(),
        ),
      );
    }
    return null;
  }
}
