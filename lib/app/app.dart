import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class HumoOnlineApp extends ConsumerStatefulWidget {
  const HumoOnlineApp({super.key});

  @override
  ConsumerState<HumoOnlineApp> createState() => _HumoOnlineAppState();
}

class _HumoOnlineAppState extends ConsumerState<HumoOnlineApp> {
  @override
  void initState() {
    super.initState();
    // Firebase Auth holati o'zgarganda routerni yangilash
    FirebaseAuth.instance.authStateChanges().listen((_) {
      appRouter.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Humo Online',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
