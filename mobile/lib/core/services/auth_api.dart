import 'package:dio/dio.dart';
import '../config/app_config.dart';

class AuthApi {
  final Dio _dio;

  AuthApi({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConfig.apiBaseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
              ),
            );

  Future<Map<String, dynamic>?> getMe() async {
    final response = await _dio.get('/api/auth/me');
    return response.data as Map<String, dynamic>;
  }

  Future<void> registerUser({
    required String email,
    required String name,
    required String hometownDistrict,
  }) async {
    await _dio.post('/api/auth/register', data: {
      'email': email,
      'name': name,
      'hometownDistrict': hometownDistrict,
    });
  }
}
