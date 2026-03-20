import '../datasources/profile_api.dart';
import '../../domain/user_profile.dart';

class PagedContributions {
  final List<ContributedPlace> items;
  final bool hasMore;
  final int page;
  final int limit;
  final int total;

  const PagedContributions({
    required this.items,
    required this.hasMore,
    required this.page,
    required this.limit,
    required this.total,
  });
}

class PagedTopContributors {
  final List<Map<String, dynamic>> items;
  final bool hasMore;
  final int page;
  final int limit;
  final int total;

  const PagedTopContributors({
    required this.items,
    required this.hasMore,
    required this.page,
    required this.limit,
    required this.total,
  });
}

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
      return data.map((place) => ContributedPlace.fromJson(place)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<PagedContributions> getUserContributionsPage(
    String userId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final data = await api.getUserContributionsPage(
        userId,
        page: page,
        limit: limit,
      );
      final items = (data['contributions'] as List? ?? const [])
          .map((place) => ContributedPlace.fromJson(place))
          .toList();
      return PagedContributions(
        items: items,
        hasMore: data['hasMore'] == true,
        page: data['page'] is int ? data['page'] as int : page,
        limit: data['limit'] is int ? data['limit'] as int : limit,
        total: data['total'] is int ? data['total'] as int : items.length,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Update user name or avatar
  Future<UserProfile> updateProfile(
    String userId, {
    String? name,
    String? avatarUrl,
    String? bio,
    String? hometownDistrict,
    String? preferredLanguage,
    List<String>? travelInterests,
    bool? completeSetup,
  }) async {
    try {
      final data = await api.updateProfile(
        userId,
        name: name,
        avatarUrl: avatarUrl,
        bio: bio,
        hometownDistrict: hometownDistrict,
        preferredLanguage: preferredLanguage,
        travelInterests: travelInterests,
        completeSetup: completeSetup,
      );
      return UserProfile.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Upload a profile avatar from a local file path
  Future<String> uploadAvatar(String userId, String filePath) async {
    try {
      return await api.uploadAvatar(userId, filePath);
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
  Future<List<Map<String, dynamic>>> getTopContributors({
    int limit = 10,
  }) async {
    try {
      final data = await api.getTopContributors(limit: limit);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<PagedTopContributors> getTopContributorsPage({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final data = await api.getTopContributorsPage(page: page, limit: limit);
      final items = List<Map<String, dynamic>>.from(
        data['topContributors'] as List? ?? const [],
      );
      return PagedTopContributors(
        items: items,
        hasMore: data['hasMore'] == true,
        page: data['page'] is int ? data['page'] as int : page,
        limit: data['limit'] is int ? data['limit'] as int : limit,
        total: data['total'] is int ? data['total'] as int : items.length,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> submitPlaceContribution({
    required String placeName,
    required String description,
    required String category,
    required String province,
    required String district,
    required double latitude,
    required double longitude,
    required List<String> photoPaths,
  }) async {
    try {
      await api.submitPlaceContribution(
        placeName: placeName,
        description: description,
        category: category,
        province: province,
        district: district,
        latitude: latitude,
        longitude: longitude,
        photoPaths: photoPaths,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ContributedPlace>> getPendingSubmissions() async {
    try {
      final data = await api.getPendingSubmissions();
      return data.map((item) => ContributedPlace.fromJson(item)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> reviewSubmission({
    required String submissionId,
    required bool approve,
    String? rejectionReason,
  }) async {
    try {
      return await api.reviewSubmission(
        submissionId: submissionId,
        approve: approve,
        rejectionReason: rejectionReason,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resubmitRejectedContribution({
    required String submissionId,
    required String placeName,
    required String description,
    required String category,
    required String province,
    required String district,
    required double latitude,
    required double longitude,
    List<String> photoPaths = const [],
  }) async {
    try {
      await api.resubmitRejectedContribution(
        submissionId: submissionId,
        placeName: placeName,
        description: description,
        category: category,
        province: province,
        district: district,
        latitude: latitude,
        longitude: longitude,
        photoPaths: photoPaths,
      );
    } catch (e) {
      rethrow;
    }
  }
}
