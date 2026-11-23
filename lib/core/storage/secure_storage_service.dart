import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

class SecureStorageService {
  final FlutterSecureStorage _secureStorage;
  SharedPreferences? _prefs;

  SecureStorageService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // --- Auth Tokens ---
  Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(key: AppConstants.keyAuthToken, value: token);
  }

  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: AppConstants.keyAuthToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: AppConstants.keyRefreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: AppConstants.keyRefreshToken);
  }

  // --- User Session ---
  Future<void> saveUserSession(Map<String, dynamic> userMap) async {
    final rawJson = jsonEncode(userMap);
    await _secureStorage.write(key: AppConstants.keyUserSession, value: rawJson);
  }

  Future<Map<String, dynamic>?> getUserSession() async {
    final rawJson = await _secureStorage.read(key: AppConstants.keyUserSession);
    if (rawJson == null || rawJson.isEmpty) return null;
    try {
      return jsonDecode(rawJson) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await getAuthToken();
    final ciSession = await getCiSession();
    return (token != null && token.isNotEmpty) || (ciSession != null && ciSession.isNotEmpty);
  }

  Future<void> clearSession() async {
    await _secureStorage.delete(key: AppConstants.keyAuthToken);
    await _secureStorage.delete(key: AppConstants.keyRefreshToken);
    await _secureStorage.delete(key: AppConstants.keyUserSession);
    await _secureStorage.delete(key: 'winco_session_cookies');
    await _secureStorage.delete(key: 'winco_ci_session');
  }

  // --- CodeIgniter Session Cookies ---
  Future<void> saveSessionCookies(String cookies) async {
    await _secureStorage.write(key: 'winco_session_cookies', value: cookies);
  }

  Future<String?> getSessionCookies() async {
    return await _secureStorage.read(key: 'winco_session_cookies');
  }

  Future<void> saveCiSession(String ciSession) async {
    await _secureStorage.write(key: 'winco_ci_session', value: ciSession);
  }

  Future<String?> getCiSession() async {
    return await _secureStorage.read(key: 'winco_ci_session');
  }

  // --- App Settings (SharedPreferences) ---
  Future<bool> hasCompletedOnboarding() async {
    final prefs = await _preferences;
    return prefs.getBool(AppConstants.keyHasCompletedOnboarding) ?? false;
  }

  Future<void> setOnboardingCompleted() async {
    final prefs = await _preferences;
    await prefs.setBool(AppConstants.keyHasCompletedOnboarding, true);
  }

  Future<void> saveRememberedEmail(String email, bool remember) async {
    final prefs = await _preferences;
    await prefs.setBool(AppConstants.keyIsRememberMeEnabled, remember);
    if (remember) {
      await prefs.setString(AppConstants.keyRememberedEmail, email);
    } else {
      await prefs.remove(AppConstants.keyRememberedEmail);
    }
  }

  Future<String?> getRememberedEmail() async {
    final prefs = await _preferences;
    final remember = prefs.getBool(AppConstants.keyIsRememberMeEnabled) ?? false;
    if (remember) {
      return prefs.getString(AppConstants.keyRememberedEmail);
    }
    return null;
  }

  Future<bool> isRememberMeEnabled() async {
    final prefs = await _preferences;
    return prefs.getBool(AppConstants.keyIsRememberMeEnabled) ?? false;
  }
}

