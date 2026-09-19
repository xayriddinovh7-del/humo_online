import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/errors/failures.dart';

// ─── Auth State ──────────────────────────────────────────────────────────────

sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated(this.user);
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

// ─── Providers ───────────────────────────────────────────────────────────────

/// Auth Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

/// Auth Notifier provider
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

// ─── Notifier ────────────────────────────────────────────────────────────────

class AuthNotifier extends Notifier<AuthState> {
  late AuthRepository _repository;

  @override
  AuthState build() {
    _repository = ref.read(authRepositoryProvider);
    _checkAuth();
    return const AuthInitial();
  }

  /// Ilovani ochganda tokenni tekshirish
  Future<void> _checkAuth() async {
    state = const AuthLoading();
    final user = await _repository.getCurrentUser();
    if (user != null) {
      state = AuthAuthenticated(user);
    } else {
      state = const AuthUnauthenticated();
    }
  }

  /// Login
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();
    try {
      final result = await _repository.login(
        email: email,
        password: password,
      );
      state = AuthAuthenticated(result.user);
    } on Failure catch (e) {
      state = AuthError(e.message);
    } catch (e) {
      state = const AuthError('Noma\'lum xatolik yuz berdi');
    }
  }

  /// Register
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = const AuthLoading();
    try {
      await _repository.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      // Register dan keyin login
      await login(email: email, password: password);
    } on Failure catch (e) {
      state = AuthError(e.message);
    } catch (e) {
      state = const AuthError('Ro\'yxatdan o\'tishda xatolik');
    }
  }

  /// Logout
  Future<void> logout() async {
    await _repository.logout();
    state = const AuthUnauthenticated();
  }

  /// Parolni tiklash
  Future<bool> forgotPassword(String email) async {
    try {
      await _repository.forgotPassword(email: email);
      return true;
    } on Failure {
      return false;
    }
  }

  void clearError() {
    if (state is AuthError) {
      state = const AuthUnauthenticated();
    }
  }
}

