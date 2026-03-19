import 'api_client.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthApi {
  final ApiClient _client;

  AuthApi({ApiClient? client}) : _client = client ?? ApiClient();

  Future<T> _runWithAuthRetry<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 &&
          FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.currentUser!.getIdToken(true);
        return operation();
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getMe() async {
    final response = await _runWithAuthRetry(() => _client.get('/api/auth/me'));
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>?> registerUser({
    required String email,
    required String name,
    required String hometownDistrict,
    String? preferredLanguage,
    List<String>? travelInterests,
  }) async {
    final response = await _runWithAuthRetry(
      () => _client.post(
        '/api/auth/register',
        data: {
          'email': email,
          'name': name,
          'hometownDistrict': hometownDistrict,
          if (preferredLanguage != null) 'preferredLanguage': preferredLanguage,
          if (travelInterests != null) 'travelInterests': travelInterests,
        },
      ),
    );
    return response.data as Map<String, dynamic>?;
  }
}
