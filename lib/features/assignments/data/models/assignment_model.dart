import '../../domain/entities/assignment_entity.dart';

class AssignmentModel extends AssignmentEntity {
  const AssignmentModel({
    required super.id,
    required super.lessonId,
    required super.title,
    required super.description,
    super.deadline,
    required super.maxScore,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['id'] as String,
      lessonId: json['lessonId'] as String,
      title: json['title'] as String,
      description: json['desc'] as String? ?? '',
      deadline: json['deadline'] != null
          ? DateTime.tryParse(json['deadline'] as String)
          : null,
      maxScore: json['maxScore'] as int? ?? 100,
    );
  }
}

class SubmissionModel extends SubmissionEntity {
  const SubmissionModel({
    required super.id,
    required super.assignmentId,
    required super.userId,
    super.fileUrls,
    required super.status,
    super.score,
    super.teacherComment,
    super.submittedAt,
  });

  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    return SubmissionModel(
      id: json['id'] as String,
      assignmentId: json['assignmentId'] as String,
      userId: json['userId'] as String,
      fileUrls: (json['fileUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      status: json['status'] as String? ?? 'submitted',
      score: json['score'] as int?,
      teacherComment: json['feedback'] as String?,
      submittedAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}
