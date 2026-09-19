import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/course_remote_datasource.dart';
import '../../domain/entities/course_entity.dart';
import '../../../../core/errors/exceptions.dart';

// ─── State ───────────────────────────────────────────────────────────────────

class CoursesState {
  final List<CourseEntity> courses;
  final bool isLoading;
  final String? error;
  final String selectedCategory;
  final bool hasMore;

  const CoursesState({
    this.courses = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategory = 'Barchasi',
    this.hasMore = true,
  });

  CoursesState copyWith({
    List<CourseEntity>? courses,
    bool? isLoading,
    String? error,
    String? selectedCategory,
    bool? hasMore,
    bool clearError = false,
  }) {
    return CoursesState(
      courses: courses ?? this.courses,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

// ─── Providers ───────────────────────────────────────────────────────────────

final courseRemoteDataSourceProvider =
    Provider<CourseRemoteDataSource>((ref) => CourseRemoteDataSource());

final coursesNotifierProvider =
    NotifierProvider<CoursesNotifier, CoursesState>(() {
  return CoursesNotifier();
});

final selectedCategoryProvider = Provider<String>((ref) => 'Barchasi');

// ─── Course Detail ────────────────────────────────────────────────────────────

final courseModulesProvider =
    FutureProvider.family<List<ModuleEntity>, String>((ref, courseId) async {
  final ds = ref.read(courseRemoteDataSourceProvider);
  return ds.getCourseModules(courseId);
});

final lessonProvider =
    FutureProvider.family<LessonEntity, String>((ref, lessonId) async {
  final ds = ref.read(courseRemoteDataSourceProvider);
  return ds.getLessonById(lessonId);
});

// ─── Notifier ─────────────────────────────────────────────────────────────────

class CoursesNotifier extends Notifier<CoursesState> {
  late CourseRemoteDataSource _dataSource;
  int _currentPage = 1;

  @override
  CoursesState build() {
    _dataSource = ref.read(courseRemoteDataSourceProvider);
    loadCourses();
    return const CoursesState();
  }

  Future<void> loadCourses({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      _currentPage = 1;
      state = state.copyWith(isLoading: true, hasMore: true, clearError: true);
    } else {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    try {
      final courses = await _dataSource.getCourses(
        category: state.selectedCategory == 'Barchasi'
            ? null
            : state.selectedCategory,
        page: _currentPage,
      );

      state = state.copyWith(
        courses: refresh
            ? courses
            : [...state.courses, ...courses],
        isLoading: false,
        hasMore: courses.length >= 20,
      );
      if (courses.isNotEmpty) _currentPage++;
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Kurslarni yuklashda xatolik',
      );
    }
  }

  Future<void> filterByCategory(String category) async {
    if (state.selectedCategory == category) return;
    state = state.copyWith(selectedCategory: category, courses: []);
    await loadCourses(refresh: true);
  }

  Future<void> refresh() => loadCourses(refresh: true);
}
