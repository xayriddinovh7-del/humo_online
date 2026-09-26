import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

/// Auth uchun remote data source (Express + JWT backend orqali)
class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource({Dio? dio})
      : _dio = dio ?? DioClient.instance.dio;

  /// Login — POST /api/v1/auth/login
  /// Backend javob: { success, data: { user, accessToken, refreshToken }, message }
  Future<({UserModel user, String accessToken, String refreshToken})> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      return (
        user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errBody = e.response?.data as Map<String, dynamic>?;
      final message = (errBody?['error'] as Map<String, dynamic>?)?['message']
          as String? ??
          'Login xatoligi';

      if (statusCode == 401) {
        throw const UnauthorizedException(message: 'Login yoki parol xato');
      }
      throw ServerException(message: message, statusCode: statusCode);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(message: 'Login xatoligi: $e');
    }
  }

  /// Register — POST /api/v1/auth/register
  /// Backend: { fullName, email, password }
  /// Javob: { success, data: { user, accessToken, refreshToken }, message }
  Future<({UserModel user, String accessToken, String refreshToken})> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    if (password != passwordConfirmation) {
      throw const ValidationException(message: 'Parollar mos emas');
    }

    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'fullName': name,
          'email': email,
          'password': password,
        },
      );
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      return (
        user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errBody = e.response?.data as Map<String, dynamic>?;
      final errObj = errBody?['error'] as Map<String, dynamic>?;
      final message = errObj?['message'] as String? ?? 'Ro\'yxatdan o\'tishda xatolik';
      final code = errObj?['code'] as String?;

      if (code == 'EMAIL_EXISTS') {
        throw const ValidationException(message: 'Bu login allaqachon ro\'yxatdan o\'tgan');
      }
      if (code == 'VALIDATION_ERROR') {
        throw ValidationException(message: message);
      }
      throw ServerException(message: message, statusCode: statusCode);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(message: 'Ro\'yxatdan o\'tishda xatolik: $e');
    }
  }

  /// Logout — faqat local token tozalash (backend logout endpointi yo'q)
  Future<void> logout() async {
    // Backend stateless JWT — logout faqat client tomonida token o'chirish
  }

  /// Parolni tiklash — backend hali implement qilinmagan
  Future<void> forgotPassword({required String email}) async {
    try {
      await _dio.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
      );
    } on DioException catch (e) {
      final errBody = e.response?.data as Map<String, dynamic>?;
      final message = (errBody?['error'] as Map<String, dynamic>?)?['message']
          as String? ??
          'Parolni tiklash xati yuborilmadi';
      throw ServerException(message: message, statusCode: e.response?.statusCode);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(message: 'Xatolik yuz berdi: $e');
    }
  }

  /// Joriy foydalanuvchini olish — POST /api/v1/auth/refresh bilan token yangilanib
  /// keyin GET /api/v1/auth/me orqali profil olinadi.
  /// Agar /me endpoint yo'q bo'lsa, refresh token orqali userId decode qilinadi.
  Future<UserModel> getMe() async {
    try {
      final response = await _dio.get(ApiConstants.getMe);
      final body = response.data as Map<String, dynamic>;
      return UserModel.fromJson(body['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const UnauthorizedException(message: 'Foydalanuvchi tizimga kirmagan');
      }
      final errBody = e.response?.data as Map<String, dynamic>?;
      final message = (errBody?['error'] as Map<String, dynamic>?)?['message']
          as String? ??
          'Profilni yuklashda xatolik';
      throw ServerException(message: message);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(message: 'Profilni yuklashda xatolik: $e');
    }
  }
}
