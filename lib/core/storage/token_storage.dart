import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _keyAccessToken = 'earthdna_access_token';
  static const String _keyRefreshToken = 'earthdna_refresh_token';
  static const String _keyUserJson = 'earthdna_user_json';
  static const String _keyCustomBaseUrl = 'earthdna_custom_base_url';

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, accessToken);
    await prefs.setString(_keyRefreshToken, refreshToken);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }

  static Future<void> saveUserJson(String jsonString) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserJson, jsonString);
  }

  static Future<String?> getUserJson() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserJson);
  }

  static Future<void> saveCustomBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCustomBaseUrl, url);
  }

  static Future<String?> getCustomBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCustomBaseUrl);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyUserJson);
  }
}

