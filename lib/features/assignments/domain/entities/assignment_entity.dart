/// Topshiriq (Uyga vazifa) entity — backend UUID
class AssignmentEntity {
  final String id;
  final String lessonId;
  final String title;
  final String description;
  final DateTime? deadline;
  final int maxScore;

  const AssignmentEntity({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.description,
    this.deadline,
    required this.maxScore,
  });

  bool get isDeadlinePassed =>
      deadline != null && DateTime.now().isAfter(deadline!);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssignmentEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Foydalanuvchining topshiriq javobi (Submission) entity
class SubmissionEntity {
  final String id;
  final String assignmentId;
  final String userId;
  final List<String> fileUrls;
  final String status; // submitted | checking | graded | returned
  final int? score;
  final String? teacherComment;
  final DateTime? submittedAt;

  const SubmissionEntity({
    required this.id,
    required this.assignmentId,
    required this.userId,
    this.fileUrls = const [],
    required this.status,
    this.score,
    this.teacherComment,
    this.submittedAt,
  });
}
