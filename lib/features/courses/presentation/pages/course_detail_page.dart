import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/course_entity.dart';
import '../providers/course_provider.dart';

class CourseDetailPage extends ConsumerWidget {
  const CourseDetailPage({super.key, required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modulesAsync = ref.watch(courseModulesProvider(courseId));

    return Scaffold(
      body: modulesAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => CustomErrorWidget(
          message: e.toString(),
          onRetry: () => ref.refresh(courseModulesProvider(courseId)),
        ),
        data: (modules) => CustomScrollView(
          slivers: [
            // Header
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.white54,
                    size: 80,
                  ),
                ),
              ),
            ),

            // Modules list
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: modules.isEmpty
                  ? const SliverToBoxAdapter(
                      child: EmptyStateWidget(
                        title: 'Modullar yo\'q',
                        subtitle: 'Hali hech qanday modul qo\'shilmagan',
                        icon: Icons.layers_outlined,
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _ModuleSection(
                          module: modules[index],
                          moduleIndex: index,
                        ),
                        childCount: modules.length,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Module Section (Accordeon) ───────────────────────────────────────────────

class _ModuleSection extends StatefulWidget {
  const _ModuleSection({
    required this.module,
    required this.moduleIndex,
  });

  final ModuleEntity module;
  final int moduleIndex;

  @override
  State<_ModuleSection> createState() => _ModuleSectionState();
}

class _ModuleSectionState extends State<_ModuleSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _iconTurn;
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: 1,
    );
    _iconTurn = Tween<double>(begin: 0.0, end: 0.5).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Module header
          InkWell(
            onTap: _toggle,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${widget.moduleIndex + 1}',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.module.title,
                          style: AppTextStyles.titleSmall,
                        ),
                        Text(
                          '${widget.module.lessons.length} dars',
                          style: AppTextStyles.caption.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  RotationTransition(
                    turns: _iconTurn,
                    child: const Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                ],
              ),
            ),
          ),

          // Lessons
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _isExpanded
                ? Column(
                    children: widget.module.lessons
                        .map((lesson) => _LessonTile(lesson: lesson))
                        .toList(),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ─── Lesson Tile ─────────────────────────────────────────────────────────────

class _LessonTile extends StatelessWidget {
  const _LessonTile({required this.lesson});

  final LessonEntity lesson;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => context.push('/lessons/${lesson.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Progress/play icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: lesson.isCompleted
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                lesson.isCompleted
                    ? Icons.check_circle_rounded
                    : Icons.play_circle_outline_rounded,
                size: 20,
                color: lesson.isCompleted
                    ? AppColors.success
                    : AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 12,
                          color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        lesson.durationFormatted,
                        style: AppTextStyles.caption.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (lesson.watchedPercent > 0 &&
                          !lesson.isCompleted) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${lesson.watchedPercent}% ko\'rildi',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}
