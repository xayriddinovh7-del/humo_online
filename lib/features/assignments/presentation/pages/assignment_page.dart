import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/assignment_entity.dart';
import '../providers/upload_provider.dart';
import '../widgets/submission_status_chip.dart';

class AssignmentPage extends ConsumerWidget {
  const AssignmentPage({super.key, required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentAsync = ref.watch(assignmentProvider(lessonId));

    return Scaffold(
      appBar: AppBar(title: const Text('Uyga vazifa')),
      body: assignmentAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => CustomErrorWidget(
          message: e.toString(),
          onRetry: () => ref.refresh(assignmentProvider(lessonId)),
        ),
        data: (assignment) {
          final submissionAsync = ref.watch(submissionProvider(assignment.id));
          return submissionAsync.when(
            loading: () => const LoadingWidget(),
            error: (e, _) => CustomErrorWidget(
              message: e.toString(),
              onRetry: () => ref.refresh(submissionProvider(assignment.id)),
            ),
            data: (submission) => _AssignmentContent(
              assignment: assignment,
              submission: submission,
            ),
          );
        },
      ),
    );
  }
}

class _AssignmentContent extends ConsumerWidget {
  const _AssignmentContent({
    required this.assignment,
    this.submission,
  });

  final AssignmentEntity assignment;
  final SubmissionEntity? submission;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final uploadState = ref.watch(uploadNotifierProvider);
    final uploadNotifier = ref.read(uploadNotifierProvider.notifier);

    // Agar serverdan yangi submission kelgan bo'lsa (yoki yuklash tugagan bo'lsa)
    final currentSubmission = uploadState.submission ?? submission;
    final status = currentSubmission?.status ?? 'not_sent';
    final canUpload = !assignment.isDeadlinePassed && status != 'graded';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header Info ──────────────────────────────────────────────────
          Text(
            assignment.title,
            style: AppTextStyles.headlineMedium,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SubmissionStatusChip(status: status),
              Text(
                'Max ball: ${assignment.maxScore}',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.event_rounded,
                size: 16,
                color: assignment.isDeadlinePassed
                    ? AppColors.error
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                'Deadline: ${assignment.deadline.toString().substring(0, 16)}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: assignment.isDeadlinePassed
                      ? AppColors.error
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight:
                      assignment.isDeadlinePassed ? FontWeight.bold : null,
                ),
              ),
            ],
          ),
          const Divider(height: 32),

          // ─── Description ──────────────────────────────────────────────────
          Text(
            'Topshiriq ta\'rifi',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            assignment.description,
            style: AppTextStyles.bodyMedium,
          ),
          const Divider(height: 32),

          // ─── Teacher Comment (Agar qaytarilgan yoki baholangan bo'lsa) ────
          if (currentSubmission?.teacherComment != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.comment_rounded,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'O\'qituvchi izohi:',
                        style: AppTextStyles.labelMedium
                            .copyWith(color: AppColors.primary),
                      ),
                      const Spacer(),
                      if (currentSubmission?.score != null)
                        Text(
                          'Ball: ${currentSubmission!.score}',
                          style: AppTextStyles.labelLarge
                              .copyWith(color: AppColors.primary),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentSubmission!.teacherComment!,
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // ─── Yuklangan Fayllar (Serverdagi) ───────────────────────────────
          if (currentSubmission != null &&
              currentSubmission.fileUrls.isNotEmpty) ...[
            Text(
              'Yuklangan fayllar',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 12),
            ...currentSubmission.fileUrls
                .map((url) => _ServerFileTile(url: url)),
            const SizedBox(height: 24),
          ],

          // ─── Upload Area ──────────────────────────────────────────────────
          if (canUpload) ...[
            Text(
              currentSubmission != null
                  ? 'Fayllarni almashtirish'
                  : 'Fayl yuklash',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 12),

            // Error xabar
            if (uploadState.status == UploadStatus.error &&
                uploadState.errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  uploadState.errorMessage!,
                  style:
                      AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                ),
              ),

            // Tanlangan fayllar ro'yxati
            if (uploadState.selectedFiles.isNotEmpty &&
                uploadState.status != UploadStatus.success)
              ...uploadState.selectedFiles.map((f) => _LocalFileTile(
                    file: f,
                    isUploading: uploadState.status == UploadStatus.uploading,
                    onRemove: () => uploadNotifier.removeFile(f),
                  )),

            const SizedBox(height: 16),

            // Progress Bar
            if (uploadState.status == UploadStatus.uploading) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Yuklanmoqda...'),
                      Text(
                          '${(uploadState.progress * 100).toStringAsFixed(1)}%'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: uploadState.progress,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: 'Bekor qilish',
                    onPressed: () => uploadNotifier.cancelUpload(),
                    type: AppButtonType.outlined,
                  ),
                ],
              ),
            ] else ...[
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Fayl tanlash',
                      onPressed: () => uploadNotifier.pickFiles(),
                      type: AppButtonType.secondary,
                      prefixIcon: const Icon(Icons.attach_file_rounded),
                    ),
                  ),
                  if (uploadState.selectedFiles.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: 'Yuborish',
                        onPressed: () =>
                            uploadNotifier.uploadFiles(assignment.id),
                        type: AppButtonType.primary,
                        prefixIcon: const Icon(Icons.cloud_upload_rounded),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ] else if (assignment.isDeadlinePassed) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_clock_rounded, color: AppColors.error),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Deadline o\'tganligi sababli fayl yuklash yopilgan.',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ServerFileTile extends StatelessWidget {
  const _ServerFileTile({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    final fileName = url.split('/').last;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
            color:
                Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.file_present_rounded, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              fileName,
              style: AppTextStyles.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () {}, // TODO: Faylni yuklab olish
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _LocalFileTile extends StatelessWidget {
  const _LocalFileTile({
    required this.file,
    required this.isUploading,
    required this.onRemove,
  });

  final PlatformFile file;
  final bool isUploading;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final fileName = file.name;
    final sizeInBytes = file.lengthSync() ?? 0;
    final fileSize = (sizeInBytes / 1024 / 1024).toStringAsFixed(2);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: AppTextStyles.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$fileSize MB',
                  style: AppTextStyles.caption.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (!isUploading)
            IconButton(
              icon: const Icon(Icons.close_rounded, color: AppColors.error),
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
