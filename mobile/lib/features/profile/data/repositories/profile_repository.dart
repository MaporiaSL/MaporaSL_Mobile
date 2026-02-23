import '../datasources/profile_api.dart';
import '../../domain/user_profile.dart';

class ProfileRepository {
  final ProfileApi api;

  ProfileRepository({required this.api});

  /// Fetch user profile with all stats and badges
  Future<UserProfile> getUserProfile(String userId) async {
    try {
      final data = await api.getUserProfile(userId);
      return UserProfile.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch all approved contributed places
  Future<List<ContributedPlace>> getUserContributions(String userId) async {
    try {
      final data = await api.getUserContributions(userId);
      return (data as List)
          .map((place) => ContributedPlace.fromJson(place))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Update user name or avatar
  Future<UserProfile> updateProfile(
    String userId, {
    String? name,
    String? avatarUrl,
  }) async {
    try {
      final data = await api.updateProfile(
        userId,
        name: name,
        avatarUrl: avatarUrl,
      );
      return UserProfile.fromJson(data['user'] ?? {});
    } catch (e) {
      rethrow;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await api.logout();
    } catch (e) {
      rethrow;
    }
  }

  /// Get top contributors for leaderboard
  Future<List<Map<String, dynamic>>> getTopContributors({int limit = 10}) async {
    try {
      final data = await api.getTopContributors(limit: limit);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      rethrow;
    }
  }
}
