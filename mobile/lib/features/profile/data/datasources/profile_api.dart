import 'package:dio/dio.dart';

class ProfileApi {
  final Dio _dio;

  ProfileApi({required Dio dio}) : _dio = dio;

  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await _dio.get('/api/profile/$userId');
      if (response.statusCode == 200) return response.data;
      throw Exception('Failed to fetch profile: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  Future<List<dynamic>> getUserContributions(String userId) async {
    try {
      final response = await _dio.get('/api/profile/$userId/contributions');
      if (response.statusCode == 200) return response.data['contributions'] ?? [];
      throw Exception('Failed to fetch contributions: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching contributions: $e');
    }
  }

  Future<Map<String, dynamic>> updateProfile(String userId, {String? name, String? avatarUrl}) async {
    try {
      final payload = <String, dynamic>{
        if (name != null) 'name': name,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      };
      final response = await _dio.post('/api/profile/$userId', data: payload);
      if (response.statusCode == 200) return response.data;
      throw Exception('Failed to update profile: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }

  Future<String> uploadAvatar(String userId, String filePath) async {
    try {
      final filename = filePath.split(RegExp(r'[\\/]+')).last;
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(filePath, filename: filename),
      });
      final response = await _dio.post(
        '/api/profile/$userId/avatar',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      if (response.statusCode == 200) return response.data['avatarUrl'] as String;
      throw Exception('Failed to upload avatar: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error uploading avatar: $e');
    }
  }

  Future<void> logout() async {
    try {
      final response = await _dio.post('/api/auth/logout');
      if (response.statusCode != 200) throw Exception('Failed to logout: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error during logout: $e');
    }
  }

  Future<List<dynamic>> getTopContributors({int limit = 10}) async {
    try {
      final response = await _dio.get('/api/profile/leaderboard/top', queryParameters: {'limit': limit});
      if (response.statusCode == 200) return response.data['topContributors'] ?? [];
      throw Exception('Failed to fetch leaderboard: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching leaderboard: $e');
    }
  }
}
