/// Kurs entity — backend UUID ishlatadi
class CourseEntity {
  final String id;
  final String title;
  final String description;
  final String category;
  final String? thumbnailUrl;
  final String? instructorName;
  final int lessonsCount;
  final int studentsCount;
  final double? rating;
  final bool isEnrolled;
  final DateTime? createdAt;

  const CourseEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.thumbnailUrl,
    this.instructorName,
    this.lessonsCount = 0,
    this.studentsCount = 0,
    this.rating,
    this.isEnrolled = false,
    this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Modul entity
class ModuleEntity {
  final String id;
  final String courseId;
  final String title;
  final int order;
  final List<LessonEntity> lessons;

  const ModuleEntity({
    required this.id,
    required this.courseId,
    required this.title,
    required this.order,
    this.lessons = const [],
  });
}

/// Dars entity
class LessonEntity {
  final String id;
  final String moduleId;
  final String title;
  final String videoUrl;
  final int durationSeconds;
  final int order;
  final bool isPreview;
  final int watchedPercent; // 0-100

  const LessonEntity({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.videoUrl,
    required this.durationSeconds,
    required this.order,
    this.isPreview = false,
    this.watchedPercent = 0,
  });

  bool get isCompleted => watchedPercent >= 90;

  String get durationFormatted {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
