import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// AuthRepository implementatsiyasi
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorage;

  AuthRepositoryImpl({
    AuthRemoteDataSource? remoteDataSource,
    SecureStorageService? secureStorage,
  })  : _remoteDataSource = remoteDataSource ?? AuthRemoteDataSource(),
        _secureStorage = secureStorage ?? SecureStorageService.instance;

  @override
  Future<({UserEntity user, String accessToken, String refreshToken})>
      login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _remoteDataSource.login(
        email: email,
        password: password,
      );
      // Tokenlarni saqlash
      await _secureStorage.saveAccessToken(result.accessToken);
      await _secureStorage.saveRefreshToken(result.refreshToken);
      await _secureStorage.saveUserId(result.user.id);
      return result;
    } on UnauthorizedException {
      throw const WrongCredentialsFailure();
    } on ValidationException catch (e) {
      throw ValidationFailure(message: e.message);
    } on NetworkException {
      throw const NetworkFailure();
    } on AppException catch (e) {
      throw AuthFailure(message: e.message);
    } catch (e) {
      throw const UnknownFailure();
    }
  }

  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final result = await _remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      // Register dan keyin tokenlarni ham saqlaymiz
      await _secureStorage.saveAccessToken(result.accessToken);
      await _secureStorage.saveRefreshToken(result.refreshToken);
      await _secureStorage.saveUserId(result.user.id);
      return result.user;
    } on ValidationException catch (e) {
      throw ValidationFailure(message: e.message, errors: e.errors);
    } on NetworkException {
      throw const NetworkFailure();
    } on AppException catch (e) {
      throw AuthFailure(message: e.message);
    } catch (e) {
      throw const UnknownFailure();
    }
  }

  @override
  Future<void> logout() async {
    await _remoteDataSource.logout();
    await _secureStorage.clearAll();
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await _remoteDataSource.forgotPassword(email: email);
    } on AppException catch (e) {
      throw AuthFailure(message: e.message);
    }
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    // TODO: implement
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final isLoggedIn = await _secureStorage.isLoggedIn();
      if (!isLoggedIn) return null;
      return await _remoteDataSource.getMe();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> isLoggedIn() => _secureStorage.isLoggedIn();
}
