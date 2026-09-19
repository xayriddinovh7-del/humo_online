/// Barcha xatolik turlari uchun sealed class ierarxiyasi
sealed class Failure {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  String toString() => 'Failure(message: $message, statusCode: $statusCode)';
}

// ─── Network Failures ────────────────────────────────────────────────────────

/// Tarmoq bilan bog'liq xatoliklar (ulanish, timeout)
final class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Internet aloqasi mavjud emas'});
}

/// Serverdan kelgan xatolik (4xx, 5xx)
final class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

/// Ruxsatsiz kirish (401)
final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.message = 'Sessiya muddati tugadi. Qayta kiring',
  }) : super(statusCode: 401);
}

/// Taqiqlangan (403)
final class ForbiddenFailure extends Failure {
  const ForbiddenFailure({
    super.message = 'Sizda bu amalga ruxsat yo\'q',
  }) : super(statusCode: 403);
}

/// Topilmadi (404)
final class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'Ma\'lumot topilmadi',
  }) : super(statusCode: 404);
}

/// Validatsiya xatoligi (422)
final class ValidationFailure extends Failure {
  final Map<String, List<String>>? errors;

  const ValidationFailure({
    required super.message,
    this.errors,
  }) : super(statusCode: 422);
}

// ─── File Failures ───────────────────────────────────────────────────────────

/// Fayl juda katta
final class FileSizeFailure extends Failure {
  final int maxSizeMB;

  const FileSizeFailure({required this.maxSizeMB})
      : super(message: 'Fayl hajmi ${maxSizeMB}MB dan oshmasligi kerak');
}

/// Yuklash bekor qilindi
final class UploadCancelledFailure extends Failure {
  const UploadCancelledFailure({
    super.message = 'Yuklash bekor qilindi',
  });
}

/// Yuklashda xatolik
final class UploadFailure extends Failure {
  const UploadFailure({required super.message});
}

// ─── Cache Failures ──────────────────────────────────────────────────────────

/// Kesh xatoligi
final class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Mahalliy ma\'lumotlarni o\'qishda xatolik',
  });
}

// ─── Auth Failures ───────────────────────────────────────────────────────────

/// Login xatoligi
final class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

/// Parol noto'g'ri
final class WrongCredentialsFailure extends Failure {
  const WrongCredentialsFailure({
    super.message = 'Email yoki parol noto\'g\'ri',
  });
}

// ─── Unknown ─────────────────────────────────────────────────────────────────

/// Noma'lum xatolik
final class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'Noma\'lum xatolik yuz berdi. Qayta urinib ko\'ring',
  });
}
