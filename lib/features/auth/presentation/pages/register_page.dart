import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  final String role;
  const RegisterPage({super.key, this.role = 'student'});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authNotifierProvider.notifier).register(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          passwordConfirmation: _confirmPasswordCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthLoading;
    final isTeacher = widget.role == 'teacher';
    final roleLabel = isTeacher ? 'Ustoz' : "O'quvchi";

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
            top: 50,
            right: -50,
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
            bottom: -50,
            left: -100,
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
                                      color: const Color(0xFF7B10E6).withOpacity(0.4),
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
                              "$roleLabel sifatida ro'yxatdan o'tish",
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
                              "$roleLabel hisobini yarating",
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 32),

                            AppTextField(
                              label: 'To\'liq ism',
                              hint: 'Ism Familiya',
                              controller: _nameCtrl,
                              textInputAction: TextInputAction.next,
                              prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                              isGlass: true,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Ismingizni kiriting';
                                if (v.length < 2) return 'Ism kamida 2 ta harf';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

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

                            AppTextField(
                              label: 'Parol',
                              hint: 'Kamida 8 ta belgi',
                              controller: _passwordCtrl,
                              obscureText: true,
                              textInputAction: TextInputAction.next,
                              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                              isGlass: true,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Parol kiriting';
                                if (v.length < 8) return 'Parol kamida 8 ta belgi bo\'lsin';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            AppTextField(
                              label: 'Parolni tasdiqlang',
                              hint: '••••••••',
                              controller: _confirmPasswordCtrl,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                              isGlass: true,
                              onSubmitted: (_) => _onRegister(),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Parolni tasdiqlang';
                                }
                                if (v != _passwordCtrl.text) {
                                  return 'Parollar mos kelmadi';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),

                            AppButton(
                              label: 'Ro\'yxatdan o\'tish',
                              type: AppButtonType.glass,
                              onPressed: isLoading ? null : _onRegister,
                              isLoading: isLoading,
                            ),
                            const SizedBox(height: 16),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Hisobingiz bormi? ',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                                InkWell(
                                  onTap: () => context.pop(),
                                  borderRadius: BorderRadius.circular(4),
                                  splashColor: Colors.pinkAccent.withOpacity(0.3),
                                  highlightColor: Colors.pinkAccent.withOpacity(0.1),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                                    child: Text(
                                      'Kirish',
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
