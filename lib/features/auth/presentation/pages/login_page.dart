import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  final String role; // 'student' yoki 'teacher'
  const LoginPage({super.key, this.role = 'student'});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authNotifierProvider.notifier).login(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthLoading;
    final isTeacher = widget.role == 'teacher';
    final roleLabel = isTeacher ? 'Ustoz' : "O'quvchi";
    final roleIcon = isTeacher ? Icons.school_rounded : Icons.person_rounded;
    final gradientColors = isTeacher
        ? [const Color(0xFFFF2DAF), const Color(0xFF7B10E6)]
        : [const Color(0xFF0023E7), const Color(0xFF7B10E6)];

    // Xatolikni snackbar bilan ko'rsatish
    ref.listen(authNotifierProvider, (prev, next) {
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(authNotifierProvider.notifier).clearError();
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
          onPressed: () => context.canPop() ? context.pop() : context.go('/role-select'),
        ),
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF111111), Color(0xFF12185A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Decorate circles
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7B10E6).withOpacity(0.4),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF7B10E6).withOpacity(0.5), blurRadius: 60)
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0023E7).withOpacity(0.4),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF0023E7).withOpacity(0.5), blurRadius: 60)
                ],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.3),
                            Colors.white.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, -10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ─── Logo va Sarlavha ─────────────────────────────────────
                            Center(
                              child: Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: gradientColors.first.withOpacity(0.4),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(28),
                                  child: Image.asset(
                                    'assets/images/logo.jpg',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            Text(
                              '$roleLabel sifatida kirish 👋',
                              style: AppTextStyles.displayMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "$roleLabel hisobingizga kiring",
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // ─── Login ───────────────────────────────────────────────
                            AppTextField(
                              label: 'Login',
                              hint: 'Loginni kiriting',
                              controller: _emailCtrl,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              prefixIcon: const Icon(Icons.person_outline, size: 20),
                              isGlass: true,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Login kiriting';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // ─── Parol ───────────────────────────────────────────────
                            AppTextField(
                              label: 'Parol',
                              hint: '••••••••',
                              controller: _passwordCtrl,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                              isGlass: true,
                              onSubmitted: (_) => _onLogin(),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Parol kiriting';
                                if (v.length < 6) return 'Parol kamida 6 ta belgi';
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),

                            // ─── Parolni Tiklash ─────────────────────────────────────
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => context.push('/forgot-password'),
                                style: ButtonStyle(
                                  overlayColor: WidgetStateProperty.resolveWith(
                                    (states) {
                                      if (states.contains(WidgetState.pressed)) {
                                        return Colors.pinkAccent.withOpacity(0.3);
                                      }
                                      if (states.contains(WidgetState.hovered)) {
                                        return Colors.pinkAccent.withOpacity(0.1);
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                child: Text(
                                  'Parolni unutdingizmi?',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // ─── Kirish Tugmasi ──────────────────────────────────────
                            AppButton(
                              label: 'Kirish',
                              type: AppButtonType.glass,
                              onPressed: isLoading ? null : _onLogin,
                              isLoading: isLoading,
                            ),
                            const SizedBox(height: 24),

                            // ─── Register havolasi ───────────────────────────────────
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Hisobingiz yo\'qmi? ',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                                InkWell(
                                  onTap: () => context.push('/register'),
                                  borderRadius: BorderRadius.circular(4),
                                  splashColor: Colors.pinkAccent.withOpacity(0.3),
                                  highlightColor: Colors.pinkAccent.withOpacity(0.1),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                                    child: Text(
                                      'Ro\'yxatdan o\'ting',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
