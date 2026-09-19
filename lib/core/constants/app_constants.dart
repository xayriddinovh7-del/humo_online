/// Ilova bo'ylab ishlatiladigan umumiy konstantalar
abstract final class AppConstants {
  // ─── Fayl Yuklash ────────────────────────────────────────────────────────────
  /// Maksimal fayl hajmi (bayt): 100 MB
  /// Bu qiymatni konfiguratsiya orqali o'zgartirish mumkin
  static const int maxFileSizeBytes = 100 * 1024 * 1024; // 100 MB
  static const int maxFileSizeMB = 100;

  /// Bir vaqtda yuklanishi mumkin bo'lgan maksimal fayl soni
  static const int maxFilesPerUpload = 10;

  // ─── Hive Box Nomlari ─────────────────────────────────────────────────────────
  static const String coursesBox = 'courses_box';
  static const String modulesBox = 'modules_box';
  static const String lessonsBox = 'lessons_box';
  static const String progressBox = 'progress_box';
  static const String settingsBox = 'settings_box';

  // ─── Shared Preferences kalitlari ────────────────────────────────────────────
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';
  static const String onboardingKey = 'onboarding_done';

  // ─── Secure Storage kalitlari ────────────────────────────────────────────────
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';

  // ─── Video ───────────────────────────────────────────────────────────────────
  static const List<double> videoSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
  static const double defaultVideoSpeed = 1.0;

  /// Progress saqlanishi uchun minimal foiz farqi (%)
  /// Masalan: 5% o'zgarganda saqlaydi
  static const int progressSaveThreshold = 5;

  // ─── UI ──────────────────────────────────────────────────────────────────────
  static const double pagePadding = 16.0;
  static const double cardRadius = 12.0;
  static const double buttonRadius = 12.0;
  static const double inputRadius = 12.0;

  // ─── Pagination ──────────────────────────────────────────────────────────────
  static const int defaultPageSize = 20;

  // ─── Kategoriyalar ───────────────────────────────────────────────────────────
  static const List<String> courseCategories = [
    'Barchasi',
    'Flutter',
    'Android',
    'iOS',
    'C++',
    'Python',
    'Web',
    'Backend',
    'Design',
  ];

  // ─── Submission holatlar ─────────────────────────────────────────────────────
  static const String statusNotSent = 'not_sent';
  static const String statusSent = 'sent';
  static const String statusChecking = 'checking';
  static const String statusGraded = 'graded';
  static const String statusReturned = 'returned';
}
