/// Xatolik sinflarining asosi
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException({required this.message, this.statusCode});

  @override
  String toString() => 'AppException(message: $message)';
}

/// Server xatoliklari (Dio DioException dan keladi)
class ServerException extends AppException {
  const ServerException({required super.message, super.statusCode});
}

/// 401 Unauthorized
class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Sessiya muddati tugadi',
  }) : super(statusCode: 401);
}

/// 403 Forbidden
class ForbiddenException extends AppException {
  const ForbiddenException({
    super.message = 'Ruxsat yo\'q',
  }) : super(statusCode: 403);
}

/// 404 Not Found
class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'Topilmadi',
  }) : super(statusCode: 404);
}

/// 422 Validation
class ValidationException extends AppException {
  final Map<String, List<String>>? errors;

  const ValidationException({
    required super.message,
    this.errors,
  }) : super(statusCode: 422);
}

/// Tarmoq bilan bog'liq muammo
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'Internet aloqasi yo\'q. Tarmoqni tekshiring',
  });
}

/// Kesh xatoligi
class CacheException extends AppException {
  const CacheException({
    super.message = 'Mahalliy ma\'lumotlarda xatolik',
  });
}

/// Fayl hajmi limitdan oshib ketdi
class FileSizeException extends AppException {
  final int maxSizeMB;

  FileSizeException({required this.maxSizeMB})
      : super(message: 'Fayl hajmi ${maxSizeMB}MB dan oshmasligi kerak');
}

/// Yuklash bekor qilindi
class UploadCancelledException extends AppException {
  const UploadCancelledException({
    super.message = 'Yuklash bekor qilindi',
  });
}
