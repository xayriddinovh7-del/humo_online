import '../../domain/entities/course_entity.dart';

/// Backend Prisma UUID asosida model
class CourseModel extends CourseEntity {
  const CourseModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    super.thumbnailUrl,
    super.instructorName,
    super.lessonsCount,
    super.studentsCount,
    super.rating,
    super.isEnrolled,
    super.createdAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    final instructor = json['instructor'] as Map<String, dynamic>?;
    return CourseModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      thumbnailUrl: json['thumbnail'] as String?,
      instructorName: instructor?['fullName'] as String?,
      lessonsCount: json['lessonsCount'] as int? ?? 0,
      studentsCount: json['studentsCount'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble(),
      isEnrolled: json['isEnrolled'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'thumbnail': thumbnailUrl,
        'instructorName': instructorName,
        'lessonsCount': lessonsCount,
        'studentsCount': studentsCount,
        'rating': rating,
        'isEnrolled': isEnrolled,
        'createdAt': createdAt?.toIso8601String(),
      };
}

class ModuleModel extends ModuleEntity {
  const ModuleModel({
    required super.id,
    required super.courseId,
    required super.title,
    required super.order,
    super.lessons,
  });

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
      title: json['title'] as String,
      order: json['order'] as int? ?? 0,
      lessons: (json['lessons'] as List<dynamic>?)
              ?.map((l) => LessonModel.fromJson(l as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class LessonModel extends LessonEntity {
  const LessonModel({
    required super.id,
    required super.moduleId,
    required super.title,
    required super.videoUrl,
    required super.durationSeconds,
    required super.order,
    super.isPreview,
    super.watchedPercent,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as String,
      moduleId: json['moduleId'] as String,
      title: json['title'] as String,
      videoUrl: json['videoUrl'] as String? ?? '',
      durationSeconds: json['duration'] as int? ?? 0,
      order: json['order'] as int? ?? 0,
      isPreview: json['isPreview'] as bool? ?? false,
      watchedPercent: json['watchedPct'] as int? ?? 0,
    );
  }
}
