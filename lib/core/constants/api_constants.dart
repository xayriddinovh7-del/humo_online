/// API uchun asosiy konstantalar
abstract final class ApiConstants {
  // ─── Base URL ───────────────────────────────────────────────────────────────
  /// Backend URL — Railway deploy dan keyin o'zgartiring
  /// Android emulator uchun: http://10.0.2.2:3000/api/v1
  /// iOS simulator / real device / web uchun: http://127.0.0.1:3000/api/v1
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api/v1',
  );

  // ─── Timeouts ───────────────────────────────────────────────────────────────
  static const int connectTimeoutMs = 30000;
  static const int receiveTimeoutMs = 60000;
  static const int uploadTimeoutMs = 300000; // 5 daqiqa (katta fayllar uchun)

  // ─── Auth Endpoints ──────────────────────────────────────────────────────────
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String getMe = '/auth/me';

  // ─── Courses Endpoints ───────────────────────────────────────────────────────
  static const String courses = '/courses';
  static String courseById(String id) => '/courses/$id';
  static String courseModules(String courseId) => '/courses/$courseId/modules';

  // ─── Lessons Endpoints ───────────────────────────────────────────────────────
  static String lessonById(String id) => '/lessons/$id';
  static String lessonProgress(String lessonId) => '/lessons/$lessonId/progress';

  // ─── Assignments Endpoints ───────────────────────────────────────────────────
  static String assignmentByLesson(String lessonId) =>
      '/assignments/lesson/$lessonId';
  static String assignmentById(String id) => '/assignments/$id';
  static String submitAssignment(String assignmentId) =>
      '/assignments/$assignmentId/submit';

  // ─── Submissions Endpoints ───────────────────────────────────────────────────
  static String submissionById(String id) => '/submissions/$id';
  static String mySubmission(String assignmentId) =>
      '/submissions/my/$assignmentId';

  // ─── Profile Endpoints ───────────────────────────────────────────────────────
  static const String profile = '/profile';
  static const String notifications = '/notifications';
  static const String profileStats = '/profile/stats';
}
