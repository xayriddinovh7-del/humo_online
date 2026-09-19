import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/courses/presentation/pages/courses_page.dart';
import '../../features/courses/presentation/pages/course_detail_page.dart';
import '../../features/video/presentation/pages/video_player_page.dart';
import '../../features/assignments/presentation/pages/assignment_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/courses',
  redirect: (context, state) async {
    // Firebase Auth orqali foydalanuvchi tizimga kirganligini tekshirish
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final isAuthRoute = state.uri.path == '/login' || state.uri.path == '/register';

    if (!isLoggedIn && !isAuthRoute) {
      return '/login';
    }

    if (isLoggedIn && isAuthRoute) {
      return '/courses';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    
    // Bottom Navigation Bar bilan ishlaydigan asosiy routelar
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

    // Video va Vazifalar sahifalari (bottom nav barsiz)
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
                  videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
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
