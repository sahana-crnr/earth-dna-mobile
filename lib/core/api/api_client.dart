import 'package:dio/dio.dart';
import 'api_endpoints.dart';
import '../storage/token_storage.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Check for custom host override if set by user
          final customUrl = await TokenStorage.getCustomBaseUrl();
          if (customUrl != null && customUrl.isNotEmpty) {
            options.baseUrl = customUrl;
          }

          // Attach JWT token
          final token = await TokenStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Automatic token refresh on 401 Unauthorized
          if (error.response?.statusCode == 401 &&
              !error.requestOptions.path.contains('/auth/login') &&
              !error.requestOptions.path.contains('/auth/refresh')) {
            final refreshToken = await TokenStorage.getRefreshToken();
            if (refreshToken != null) {
              try {
                final refreshResponse = await dio.post(
                  ApiEndpoints.refresh,
                  data: {'refreshToken': refreshToken},
                );

                if (refreshResponse.statusCode == 200 ||
                    refreshResponse.statusCode == 201) {
                  final data = refreshResponse.data['data'];
                  final newAccess = data['accessToken'];
                  final newRefresh = data['refreshToken'] ?? refreshToken;

                  await TokenStorage.saveTokens(
                    accessToken: newAccess,
                    refreshToken: newRefresh,
                  );

                  // Retry the original failed request with the new access token
                  error.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
                  final retryResponse = await dio.fetch(error.requestOptions);
                  return handler.resolve(retryResponse);
                }
              } catch (_) {
                await TokenStorage.clearAll();
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  // Helper method to extract the backend envelope 'data'
  T extractData<T>(Response response) {
    if (response.data is Map && response.data.containsKey('data')) {
      return response.data['data'] as T;
    }
    return response.data as T;
  }
}

