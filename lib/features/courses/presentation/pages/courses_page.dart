import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/custom_error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/course_entity.dart';
import '../providers/course_provider.dart';

class CoursesPage extends ConsumerStatefulWidget {
  const CoursesPage({super.key});

  @override
  ConsumerState<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends ConsumerState<CoursesPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      ref.read(coursesNotifierProvider.notifier).loadCourses();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(coursesNotifierProvider);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            floating: true,
            snap: true,
            title: const Text('Kurslar'),
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded),
                onPressed: () {}, // TODO: search
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: _CategoryFilter(
                selected: state.selectedCategory,
                onSelected: (cat) => ref
                    .read(coursesNotifierProvider.notifier)
                    .filterByCategory(cat),
              ),
            ),
          ),
        ],
        body: RefreshIndicator(
          onRefresh: () =>
              ref.read(coursesNotifierProvider.notifier).refresh(),
          child: _buildBody(state),
        ),
      ),
    );
  }

  Widget _buildBody(CoursesState state) {
    if (state.isLoading && state.courses.isEmpty) {
      return const CourseListShimmer();
    }

    if (state.error != null && state.courses.isEmpty) {
      return CustomErrorWidget(
        message: state.error!,
        onRetry: () =>
            ref.read(coursesNotifierProvider.notifier).refresh(),
      );
    }

    if (state.courses.isEmpty) {
      return const EmptyStateWidget(
        title: 'Kurslar topilmadi',
        subtitle: 'Boshqa kategoriyani sinab ko\'ring',
        icon: Icons.school_outlined,
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppConstants.pagePadding),
      itemCount: state.courses.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.courses.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _CourseCard(course: state.courses[index]),
        );
      },
    );
  }
}

// ─── Category Filter ─────────────────────────────────────────────────────────

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: AppConstants.courseCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = AppConstants.courseCategories[i];
          final isSelected = cat == selected;
          return FilterChip(
            label: Text(cat),
            selected: isSelected,
            onSelected: (_) => onSelected(cat),
            showCheckmark: false,
            selectedColor: AppColors.primary,
            labelStyle: AppTextStyles.labelMedium.copyWith(
              color: isSelected ? Colors.white : null,
            ),
          );
        },
      ),
    );
  }
}

// ─── Course Card ─────────────────────────────────────────────────────────────

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course});

  final CourseEntity course;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => context.push('/courses/${course.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          boxShadow: theme.brightness == Brightness.dark
              ? AppColors.cardShadowDark
              : AppColors.cardShadowLight,
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppConstants.cardRadius),
                bottomLeft: Radius.circular(AppConstants.cardRadius),
              ),
              child: course.thumbnailUrl != null
                  ? CachedNetworkImage(
                      imageUrl: course.thumbnailUrl!,
                      width: 110,
                      height: 90,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 110,
                        height: 90,
                        color: AppColors.primarySurface,
                        child: const Icon(Icons.play_circle_outline_rounded,
                            color: AppColors.primary, size: 32),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 110,
                        height: 90,
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,
                        ),
                        child: const Icon(Icons.school_rounded,
                            color: Colors.white, size: 32),
                      ),
                    )
                  : Container(
                      width: 110,
                      height: 90,
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                      ),
                      child: const Icon(Icons.school_rounded,
                          color: Colors.white, size: 32),
                    ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        course.category,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      course.title,
                      style: AppTextStyles.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.play_lesson_outlined,
                            size: 14, color: AppColors.textSecondaryLight),
                        const SizedBox(width: 4),
                        Text(
                          '${course.lessonsCount} dars',
                          style: AppTextStyles.caption.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (course.rating != null) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.star_rounded,
                              size: 14, color: AppColors.accent),
                          const SizedBox(width: 2),
                          Text(
                            course.rating!.toStringAsFixed(1),
                            style: AppTextStyles.caption.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Arrow
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
