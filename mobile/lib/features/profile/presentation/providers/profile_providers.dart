import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/services/auth_api.dart';
import '../../../../core/services/auth_interceptor.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/local_prefs.dart';
import '../../data/datasources/profile_api.dart';
import '../../data/repositories/profile_repository.dart';
import '../../domain/user_profile.dart';

enum ProfileLoadErrorType {
  authLoading,
  missingToken,
  expiredToken,
  userNotRegistered,
  offline,
  forbidden,
  server,
  unknown,
}

class ProfileLoadException implements Exception {
  final ProfileLoadErrorType type;
  final String message;

  const ProfileLoadException(this.type, this.message);

  factory ProfileLoadException.fromDio(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.error is SocketException) {
      return const ProfileLoadException(
        ProfileLoadErrorType.offline,
        'You appear to be offline. Check your connection and try again.',
      );
    }

    final status = e.response?.statusCode;
    if (status == 401) {
      return const ProfileLoadException(
        ProfileLoadErrorType.expiredToken,
        'Your session expired. Please sign in again.',
      );
    }
    if (status == 403) {
      return const ProfileLoadException(
        ProfileLoadErrorType.forbidden,
        'You do not have access to this profile right now.',
      );
    }
    if (status == 404) {
      return const ProfileLoadException(
        ProfileLoadErrorType.userNotRegistered,
        'We could not find your profile yet. We will create it now.',
      );
    }
    if (status == 409) {
      return const ProfileLoadException(
        ProfileLoadErrorType.userNotRegistered,
        'Your account is partially set up. Please retry profile sync.',
      );
    }
    if (status != null && status >= 500) {
      return const ProfileLoadException(
        ProfileLoadErrorType.server,
        'Our servers are having trouble. Please try again in a moment.',
      );
    }

    return const ProfileLoadException(
      ProfileLoadErrorType.unknown,
      'Something went wrong while loading your profile.',
    );
  }

  @override
  String toString() => message;
}

// Provider for Auth Service
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Provider for Auth API (test seam for bootstrap flow)
final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi();
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

/// Provider for current user ID with debug logging
final currentUserIdProvider = Provider<String?>((ref) {
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;
  final userId = currentUser?.uid;

  if (kDebugMode) {
    debugPrint('[DEBUG] Current User ID: $userId');
    debugPrint('[DEBUG] Current User Email: ${currentUser?.email}');
  }

  // In bypass mode, backend always resolves to the fallback UID.
  // Return the same UID from mobile to avoid 403 userId mismatch.
  if (AppConfig.authBypass) {
    return AppConfig.profileFallbackUserId;
  }

  if (userId != null) return userId;

  return null;
});

final profileBootstrapProvider = FutureProvider<void>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final authApi = ref.watch(authApiProvider);
  final currentUser = authService.currentUser;

  if (!AppConfig.authBypass && currentUser == null) {
    throw const ProfileLoadException(
      ProfileLoadErrorType.missingToken,
      'You are not signed in. Please log in to continue.',
    );
  }

  if (!AppConfig.authBypass && currentUser != null) {
    try {
      final token = await authService.getIdToken();
      if (token == null || token.isEmpty) {
        throw const ProfileLoadException(
          ProfileLoadErrorType.authLoading,
          'Preparing your session. Please retry in a moment.',
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-token-expired') {
        throw const ProfileLoadException(
          ProfileLoadErrorType.expiredToken,
          'Your session expired. Please sign in again.',
        );
      }
      throw const ProfileLoadException(
        ProfileLoadErrorType.missingToken,
        'Could not read your session token. Please sign in again.',
      );
    }
  }

  try {
    await authApi.getMe();
    return;
  } on DioException catch (e) {
    if (e.response?.statusCode != 404) {
      throw ProfileLoadException.fromDio(e);
    }
  } catch (_) {
    throw const ProfileLoadException(
      ProfileLoadErrorType.server,
      'Could not verify your account right now. Please retry.',
    );
  }

  final email = authService.currentUserEmail ?? 'test-user-123@local.test';
  final displayName = authService.currentUserDisplayName;
  final fallbackName = email.split('@').first;
  final district = await LocalPrefs.getHometownDistrict() ?? 'Colombo';

  try {
    await authApi.registerUser(
      email: email,
      name: (displayName == null || displayName.trim().isEmpty)
          ? fallbackName
          : displayName.trim(),
      hometownDistrict: district,
    );
    await LocalPrefs.clearHometownDistrict();
  } on DioException catch (e) {
    throw ProfileLoadException.fromDio(e);
  } catch (_) {
    throw const ProfileLoadException(
      ProfileLoadErrorType.userNotRegistered,
      'Unable to create your profile right now. Please try again.',
    );
  }
});

/// Provider to fetch user profile
/// Usage: ref.watch(userProfileProvider)
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  await ref.watch(profileBootstrapProvider.future);
  final userId = ref.watch(currentUserIdProvider);

  if (kDebugMode) {
    debugPrint('[DEBUG] userProfileProvider - userId: $userId');
  }

  if (userId == null) {
    if (kDebugMode) {
      debugPrint('[ERROR] userId is null - user not authenticated');
    }
    throw const ProfileLoadException(
      ProfileLoadErrorType.missingToken,
      'You are not signed in. Please log in to continue.',
    );
  }

  try {
    final repository = ref.watch(profileRepositoryProvider);
    final profile = await repository.getUserProfile(userId);
    if (kDebugMode) {
      debugPrint('[DEBUG] Profile loaded successfully: ${profile.name}');
    }
    return profile;
  } on DioException catch (e) {
    final mapped = ProfileLoadException.fromDio(e);
    if (kDebugMode) {
      debugPrint('[ERROR] Failed to load profile: $mapped');
    }
    throw mapped;
  } on ProfileLoadException {
    rethrow;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[ERROR] Failed to load profile: $e');
    }
    throw const ProfileLoadException(
      ProfileLoadErrorType.unknown,
      'Unable to load profile. Please try again.',
    );
  }
});

/// Provider to fetch user contributions
/// Usage: ref.watch(userContributionsProvider)
final userContributionsProvider = FutureProvider<List<ContributedPlace>>((ref) async {
  await ref.watch(profileBootstrapProvider.future);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) return [];

  try {
    final repository = ref.watch(profileRepositoryProvider);
    return repository.getUserContributions(userId);
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[ERROR] Failed to load contributions: $e');
    }
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

  /// Upload avatar image file and update profile
  Future<void> uploadAvatar(String filePath) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    try {
      final avatarUrl = await _repository.uploadAvatar(_userId, filePath);
      await _repository.updateProfile(_userId, avatarUrl: avatarUrl);
      state = state.copyWith(isLoading: false, success: true, avatarUrl: avatarUrl);
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        state = state.copyWith(success: false);
      });
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString(), success: false);
    }
  }

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
        if (!mounted) return;
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

  /// Update extended profile details
  Future<void> updateProfileDetails({
    String? name,
    String? bio,
    String? hometownDistrict,
    String? preferredLanguage,
    List<String>? travelInterests,
  }) async {
    state = state.copyWith(isLoading: true, error: null, success: false);

    try {
      await _repository.updateProfile(
        _userId,
        name: name,
        bio: bio,
        hometownDistrict: hometownDistrict,
        preferredLanguage: preferredLanguage,
        travelInterests: travelInterests,
      );

      state = state.copyWith(
        isLoading: false,
        success: true,
        name: name,
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
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
