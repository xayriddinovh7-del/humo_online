import '../entities/user_entity.dart';


/// Auth repository — abstract interfeys
/// Implement: auth_repository_impl.dart
abstract class AuthRepository {
  Future<({UserEntity user, String accessToken, String refreshToken})> login({
    required String email,
    required String password,
  });

  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  });

  Future<void> logout();

  Future<void> forgotPassword({required String email});

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<UserEntity?> getCurrentUser();

  Future<bool> isLoggedIn();
}
