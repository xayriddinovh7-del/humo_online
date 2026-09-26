import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/role_select_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/courses/presentation/pages/courses_page.dart';
import '../../features/courses/presentation/pages/course_detail_page.dart';
import '../../features/video/presentation/pages/video_player_page.dart';
import '../../features/assignments/presentation/pages/assignment_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

/// AuthState o'zgarganda GoRouter ni xabardor qiluvchi listenable
class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(this._ref) {
    _ref.listen(authNotifierProvider, (_, __) {
      notifyListeners();
    });
  }
  final Ref _ref;
}

/// Router provider — authState ga reaktiv
final appRouterProvider = Provider<GoRouter>((ref) {
  final listenable = _AuthStateListenable(ref);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: listenable,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);

      // Auth tekshirilayotgan bo'lsa kutamiz
      if (authState is AuthInitial || authState is AuthLoading) {
        return null;
      }

      final isAuthenticated = authState is AuthAuthenticated;
      final path = state.uri.path;

      // Auth sahifalari (kirish talab qilinmaydi)
      final isPublicRoute = path == '/' ||
          path == '/role-select' ||
          path == '/login' ||
          path == '/register';

      if (!isAuthenticated && !isPublicRoute) {
        return '/';
      }

      if (isAuthenticated && isPublicRoute) {
        return '/courses';
      }

      return null;
    },
    routes: [
      // ─── Splash sahifasi ──────────────────────────────────────────
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),

      // ─── Rol tanlash sahifasi ─────────────────────────────────────
      GoRoute(
        path: '/role-select',
        builder: (context, state) => const RoleSelectPage(),
      ),

      // ─── Login — role query param bilan ──────────────────────────
      // /login?role=student  yoki  /login?role=teacher
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'] ?? 'student';
          return LoginPage(role: role);
        },
      ),

      // ─── Register — role query param bilan ───────────────────────
      // /register?role=student  yoki  /register?role=teacher
      GoRoute(
        path: '/register',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'] ?? 'student';
          return RegisterPage(role: role);
        },
      ),

      // ─── Asosiy sahifalar (Bottom Nav bilan) ─────────────────────
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return Scaffold(
            body: child,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _calculateSelectedIndex(state.uri.path),
              onTap: (index) => _onItemTapped(index, context),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.school_outlined),
                  activeIcon: Icon(Icons.school_rounded),
                  label: 'Kurslar',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Profil',
                ),
              ],
            ),
          );
        },
        routes: [
          GoRoute(
            path: '/courses',
            builder: (context, state) => const CoursesPage(),
            routes: [
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return CourseDetailPage(courseId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),

      // ─── Video va Vazifalar (bottom nav barsiz) ───────────────────
      GoRoute(
        path: '/lessons/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return Scaffold(
            body: Column(
              children: [
                Expanded(
                  flex: 4,
                  child: VideoPlayerPage(
                    lessonId: id,
                    videoUrl:
                        'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
                    title: 'Dars nomi',
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: AssignmentPage(lessonId: id),
                ),
              ],
            ),
          );
        },
      ),
    ],
  );
});

int _calculateSelectedIndex(String location) {
  if (location.startsWith('/courses')) return 0;
  if (location.startsWith('/profile')) return 1;
  return 0;
}

void _onItemTapped(int index, BuildContext context) {
  switch (index) {
    case 0:
      context.go('/courses');
      break;
    case 1:
      context.go('/profile');
      break;
  }
}
