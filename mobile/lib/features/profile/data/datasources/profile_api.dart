import 'package:dio/dio.dart';

class ProfileApi {
  final Dio dio;

  ProfileApi({required this.dio});

  /// Fetch complete user profile with stats, badges, rank, and impact metrics
  /// GET /api/profile/:userId
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await dio.get('/profile/$userId');
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to fetch profile: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  /// Fetch all approved contributed places for a user
  /// GET /api/profile/:userId/contributions
  Future<List<dynamic>> getUserContributions(String userId) async {
    try {
      final response = await dio.get('/profile/$userId/contributions');
      if (response.statusCode == 200) {
        return response.data['contributions'] ?? [];
      }
      throw Exception('Failed to fetch contributions: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching contributions: $e');
    }
  }

  /// Update user profile (name, avatar)
  /// POST /api/profile/:userId
  Future<Map<String, dynamic>> updateProfile(
    String userId, {
    String? name,
    String? avatarUrl,
  }) async {
    try {
      final payload = <String, dynamic>{
        if (name != null) 'name': name,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      };

      final response = await dio.post(
        '/profile/$userId',
        data: payload,
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to update profile: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }

  /// Logout user
  /// POST /api/auth/logout
  Future<void> logout() async {
    try {
      final response = await dio.post('/auth/logout');
      if (response.statusCode != 200) {
        throw Exception('Failed to logout: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error during logout: $e');
    }
  }

  /// Get top contributors globally (public endpoint)
  /// GET /api/profile/leaderboard/top
  Future<List<dynamic>> getTopContributors({int limit = 10}) async {
    try {
      final response = await dio.get(
        '/profile/leaderboard/top',
        queryParameters: {'limit': limit},
      );
      if (response.statusCode == 200) {
        return response.data['topContributors'] ?? [];
      }
      throw Exception('Failed to fetch leaderboard: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching leaderboard: $e');
    }
  }
}
