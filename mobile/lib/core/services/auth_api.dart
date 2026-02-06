import 'api_client.dart';

class AuthApi {
  final ApiClient _client;

  AuthApi({ApiClient? client}) : _client = client ?? ApiClient();

  Future<Map<String, dynamic>?> getMe() async {
    final response = await _client.get('/api/auth/me');
    return response.data as Map<String, dynamic>;
  }

  Future<void> registerUser({
    required String email,
    required String name,
    required String hometownDistrict,
  }) async {
    await _client.post(
      '/api/auth/register',
      data: {
        'email': email,
        'name': name,
        'hometownDistrict': hometownDistrict,
      },
    );
  }
}
