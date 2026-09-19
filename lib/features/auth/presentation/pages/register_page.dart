import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ro\'yxatdan o\'tish',
                  style: AppTextStyles.displayMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Platformaga qo\'shilish uchun ma\'lumotlaringizni kiriting',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),

                AppTextField(
                  label: 'To\'liq ism',
                  hint: 'Ism Familiya',
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ismingizni kiriting';
                    if (v.length < 2) return 'Ism kamida 2 ta harf';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'Email',
                  hint: 'example@email.com',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email kiriting';
                    if (!v.contains('@')) return 'Email noto\'g\'ri format';
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
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Text(
                        'Kirish',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
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
    );
  }
}
