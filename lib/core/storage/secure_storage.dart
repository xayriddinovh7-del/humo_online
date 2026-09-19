import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Web va boshqa platformalarda muammosiz ishlashi uchun JWT tokenlarni SharedPreferences orqali saqlash
class SecureStorageService {
  const SecureStorageService._();

  static const SecureStorageService instance = SecureStorageService._();

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  // --- Access Token ---

  Future<void> saveAccessToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(AppConstants.accessTokenKey, token);
  }

  Future<String?> getAccessToken() async {
    final prefs = await _prefs;
    return prefs.getString(AppConstants.accessTokenKey);
  }

  Future<void> deleteAccessToken() async {
    final prefs = await _prefs;
    await prefs.remove(AppConstants.accessTokenKey);
  }

  // --- Refresh Token ---

  Future<void> saveRefreshToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(AppConstants.refreshTokenKey, token);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await _prefs;
    return prefs.getString(AppConstants.refreshTokenKey);
  }

  Future<void> deleteRefreshToken() async {
    final prefs = await _prefs;
    await prefs.remove(AppConstants.refreshTokenKey);
  }

  // --- User ID ---

  Future<void> saveUserId(String userId) async {
    final prefs = await _prefs;
    await prefs.setString(AppConstants.userIdKey, userId);
  }

  Future<String?> getUserId() async {
    final prefs = await _prefs;
    return prefs.getString(AppConstants.userIdKey);
  }

  // --- Clear All ---

  Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }

  // --- Helpers ---

  Future<bool> isLoggedIn() async {
    try {
      final token = await getAccessToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
