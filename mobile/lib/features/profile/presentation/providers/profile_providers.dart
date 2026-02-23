import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/services/auth_interceptor.dart';
import '../../data/datasources/profile_api.dart';
import '../../data/repositories/profile_repository.dart';
import '../../domain/user_profile.dart';
import '../../../../core/services/auth_service.dart';

// Provider for Auth Service
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider for Dio instance (for profile API calls)
final profileDioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  )..interceptors.add(AuthInterceptor());

  return dio;
});

/// Provider for ProfileApi
final profileApiProvider = Provider<ProfileApi>((ref) {
  final dio = ref.watch(profileDioProvider);
  return ProfileApi(dio: dio);
});

/// Provider for ProfileRepository
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final api = ref.watch(profileApiProvider);
  return ProfileRepository(api: api);
});

/// Provider for current user ID with logging
final currentUserIdProvider = Provider<String?>((ref) {
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;
  final userId = currentUser?.uid;
  
  print('[DEBUG] Current User ID: $userId');
  print('[DEBUG] Current User Email: ${currentUser?.email}');
  
  // DEVELOPMENT ONLY: Use a test user ID if no user is authenticated
  // Remove this in production!
  final testUserId = userId ?? 'test-user-123'; // Fallback for testing
  
  return testUserId;
});

/// Provider to fetch user profile
/// Usage: ref.watch(userProfileProvider)
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  
  print('[DEBUG] userProfileProvider - userId: $userId');
  
  if (userId == null) {
    print('[ERROR] userId is null - user not authenticated');
    throw Exception('User not authenticated. Please login first.');
  }

  try {
    final repository = ref.watch(profileRepositoryProvider);
    final profile = await repository.getUserProfile(userId);
    print('[DEBUG] Profile loaded successfully: ${profile.name}');
    return profile;
  } catch (e) {
    print('[ERROR] Failed to load profile: $e');
    rethrow;
  }
});

/// Provider to fetch user contributions
/// Usage: ref.watch(userContributionsProvider)
final userContributionsProvider = FutureProvider<List<ContributedPlace>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  
  if (userId == null) return [];

  try {
    final repository = ref.watch(profileRepositoryProvider);
    return repository.getUserContributions(userId);
  } catch (e) {
    print('[ERROR] Failed to load contributions: $e');
    return [];
  }
});

/// State for profile editing
class ProfileEditState {
  final String? name;
  final String? avatarUrl;
  final bool isLoading;
  final String? error;
  final bool success;

  ProfileEditState({
    this.name,
    this.avatarUrl,
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  ProfileEditState copyWith({
    String? name,
    String? avatarUrl,
    bool? isLoading,
    String? error,
    bool? success,
  }) {
    return ProfileEditState(
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      success: success ?? this.success,
    );
  }
}

/// StateNotifier for profile editing
class ProfileEditNotifier extends StateNotifier<ProfileEditState> {
  final ProfileRepository _repository;
  final String _userId;

  ProfileEditNotifier({
    required ProfileRepository repository,
    required String userId,
  })  : _repository = repository,
        _userId = userId,
        super(ProfileEditState());

  /// Update user profile
  Future<void> updateProfile({String? name, String? avatarUrl}) async {
    state = state.copyWith(isLoading: true, error: null, success: false);

    try {
      await _repository.updateProfile(
        _userId,
        name: name,
        avatarUrl: avatarUrl,
      );

      state = state.copyWith(
        isLoading: false,
        success: true,
        name: name,
        avatarUrl: avatarUrl,
      );

      // Clear success message after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        state = state.copyWith(success: false);
      });
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        success: false,
      );
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Reset state
  void reset() {
    state = ProfileEditState();
  }
}

/// Provider for profile editing with auto-disposal
final profileEditProvider = StateNotifierProvider.autoDispose<ProfileEditNotifier, ProfileEditState>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final repository = ref.watch(profileRepositoryProvider);

  if (userId == null) {
    return ProfileEditNotifier(
      repository: repository,
      userId: '',
    );
  }

  return ProfileEditNotifier(
    repository: repository,
    userId: userId,
  );
});

/// Provider to logout user
final logoutProvider = FutureProvider<void>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  await repository.logout();
});

/// Provider for top contributors (leaderboard)
final topContributorsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getTopContributors(limit: 10);
});
