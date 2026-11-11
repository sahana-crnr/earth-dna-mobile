import 'dart:convert';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../storage/token_storage.dart';
import '../../models/user_model.dart';

class AuthService {
  final ApiClient _api = ApiClient();

  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
    String? country,
    String? zipCode,
  }) async {
    final response = await _api.dio.post(
      ApiEndpoints.register,
      data: {
        'fullName': fullName,
        'email': email,
        'password': password,
        'country': country ?? 'USA',
        if (zipCode != null && zipCode.isNotEmpty) 'zipCode': zipCode,
      },
    );

    final data = _api.extractData<Map<String, dynamic>>(response);
    final accessToken = data['accessToken'] as String;
    final refreshToken = data['refreshToken'] as String;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

    await TokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    await TokenStorage.saveUserJson(jsonEncode(user.toJson()));

    return user;
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.dio.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = _api.extractData<Map<String, dynamic>>(response);
    final accessToken = data['accessToken'] as String;
    final refreshToken = data['refreshToken'] as String;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

    await TokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    await TokenStorage.saveUserJson(jsonEncode(user.toJson()));

    return user;
  }

  Future<UserModel?> getProfile() async {
    try {
      final response = await _api.dio.get(ApiEndpoints.profile);
      final data = _api.extractData<Map<String, dynamic>>(response);
      final user = UserModel.fromJson(data);
      await TokenStorage.saveUserJson(jsonEncode(user.toJson()));
      return user;
    } catch (_) {
      return null;
    }
  }

  Future<UserModel> updateProfile({
    String? fullName,
    String? country,
    String? zipCode,
  }) async {
    final payload = <String, dynamic>{};
    if (fullName != null) payload['fullName'] = fullName;
    if (country != null) payload['country'] = country;
    if (zipCode != null) payload['zipCode'] = zipCode;

    final response = await _api.dio.patch(
      ApiEndpoints.profile,
      data: payload,
    );
    final data = _api.extractData<Map<String, dynamic>>(response);
    final user = UserModel.fromJson(data);
    await TokenStorage.saveUserJson(jsonEncode(user.toJson()));
    return user;
  }

  Future<String> forgotPassword({required String email}) async {
    final response = await _api.dio.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
        return (data['data']['message'] as String?) ??
            'Password reset link sent.';
      }
      return (data['message'] as String?) ?? 'Password reset link sent.';
    }
    return 'Password reset link sent.';
  }

  Future<void> logout() async {
    try {
      final refresh = await TokenStorage.getRefreshToken();
      if (refresh != null) {
        await _api.dio.post(
          ApiEndpoints.logout,
          data: {'refreshToken': refresh},
        );
      }
    } catch (_) {}
    await TokenStorage.clearAll();
  }
}

