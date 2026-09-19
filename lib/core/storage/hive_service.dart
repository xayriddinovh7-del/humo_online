import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

/// Hive ma'lumotlar bazasini ishga tushirish va boshqarish
class HiveService {
  HiveService._();

  /// Ilovani ishga tushirishda chaqiriladi (main.dart)
  static Future<void> init() async {
    await Hive.initFlutter();
    // Adapter ro'yxatga olish (model yozilganda qo'shiladi)
    // Hive.registerAdapter(CourseModelAdapter());
    // Hive.registerAdapter(LessonModelAdapter());
    await _openBoxes();
  }

  static Future<void> _openBoxes() async {
    await Hive.openBox(AppConstants.coursesBox);
    await Hive.openBox(AppConstants.modulesBox);
    await Hive.openBox(AppConstants.lessonsBox);
    await Hive.openBox(AppConstants.progressBox);
    await Hive.openBox(AppConstants.settingsBox);
  }

  // ─── Box Getters ─────────────────────────────────────────────────────────────

  static Box get coursesBox => Hive.box(AppConstants.coursesBox);
  static Box get modulesBox => Hive.box(AppConstants.modulesBox);
  static Box get lessonsBox => Hive.box(AppConstants.lessonsBox);
  static Box get progressBox => Hive.box(AppConstants.progressBox);
  static Box get settingsBox => Hive.box(AppConstants.settingsBox);

  // ─── Settings Helpers ─────────────────────────────────────────────────────────

  static bool? getBool(String key) =>
      settingsBox.get(key) as bool?;

  static Future<void> setBool(String key, bool value) =>
      settingsBox.put(key, value);

  static String? getString(String key) =>
      settingsBox.get(key) as String?;

  static Future<void> setString(String key, String value) =>
      settingsBox.put(key, value);

  // ─── Cache Helpers ────────────────────────────────────────────────────────────

  static Future<void> clearAll() async {
    await coursesBox.clear();
    await modulesBox.clear();
    await lessonsBox.clear();
    await progressBox.clear();
  }
}
