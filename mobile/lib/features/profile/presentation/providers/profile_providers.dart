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

class ProfileSetupRequirement {
  final bool requiresSetup;
  final List<String> requiredFields;
  final List<String> optionalFields;

  const ProfileSetupRequirement({
    required this.requiresSetup,
    required this.requiredFields,
    required this.optionalFields,
  });
}

void logProfileTelemetry(
  String event, {
  Map<String, Object?> details = const {},
}) {
  if (!kDebugMode) return;
  debugPrint('[PROFILE_TELEMETRY] $event | $details');
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

String profileActionErrorMessage(Object error) {
  if (error is ProfileLoadException) {
    return error.message;
  }
  if (error is DioException) {
    final status = error.response?.statusCode;
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final fieldErrors = data['fieldErrors'];
      if (fieldErrors is Map && fieldErrors.isNotEmpty) {
        return fieldErrors.values.first.toString();
      }
      if (data['error'] != null) {
        return data['error'].toString();
      }
    }

    if (status == 401) {
      return 'Session expired. Please sign in again.';
    }
    if (status == 403) {
      return 'You do not have permission to perform this action.';
    }
    if (status == 400) {
      return 'Please check your details and try again.';
    }
  }
  return 'Something went wrong. Please try again.';
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

final profileRetryCountProvider = StateProvider<int>((ref) => 0);

final profileSetupRequirementProvider = FutureProvider<ProfileSetupRequirement>((
  ref,
) async {
  final authApi = ref.watch(authApiProvider);
  final data = await authApi.getMe();
  final response = data ?? const <String, dynamic>{};

  final required = (response['requiredFields'] as List?)
          ?.map((e) => e.toString())
          .toList() ??
      const ['name', 'hometownDistrict', 'preferredLanguage'];
  final optional = (response['optionalFields'] as List?)
          ?.map((e) => e.toString())
          .toList() ??
      const ['travelInterests', 'avatarUrl', 'bio'];
  final requiresSetup = response['profileSetupRequired'] == true;

  return ProfileSetupRequirement(
    requiresSetup: requiresSetup,
    requiredFields: required,
    optionalFields: optional,
  );
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
    if (e.response?.statusCode == 401 &&
        !AppConfig.authBypass &&
        currentUser != null) {
      try {
        final refreshed = await authService.getIdToken(forceRefresh: true);
        if (refreshed != null && refreshed.isNotEmpty) {
          await authApi.getMe();
          logProfileTelemetry('bootstrap_get_me_recovered_after_refresh');
          return;
        }
      } on DioException {
        // Continue to standard mapping below.
      } on FirebaseAuthException {
        // Continue to standard mapping below.
      }
    }

    logProfileTelemetry(
      'bootstrap_get_me_failed',
      details: {'statusCode': e.response?.statusCode, 'type': e.type.name},
    );
    if (e.response?.statusCode != 404) {
      throw ProfileLoadException.fromDio(e);
    }
  } catch (_) {
    logProfileTelemetry('bootstrap_get_me_unexpected_error');
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
    logProfileTelemetry(
      'bootstrap_register_failed',
      details: {'statusCode': e.response?.statusCode, 'type': e.type.name},
    );
    throw ProfileLoadException.fromDio(e);
  } catch (_) {
    logProfileTelemetry('bootstrap_register_unexpected_error');
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
    if (e.response?.statusCode == 404 || e.response?.statusCode == 409) {
      // Partial bootstrap edge-case: retry account sync once, then fetch again.
      ref.invalidate(profileBootstrapProvider);
      await ref.read(profileBootstrapProvider.future);
      final repository = ref.watch(profileRepositoryProvider);
      final profile = await repository.getUserProfile(userId);
      return profile;
    }

    final mapped = ProfileLoadException.fromDio(e);
    logProfileTelemetry(
      'profile_fetch_failed',
      details: {'statusCode': e.response?.statusCode, 'type': mapped.type.name},
    );
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
final userContributionsProvider = FutureProvider<List<ContributedPlace>>((
  ref,
) async {
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
  }) : _repository = repository,
       _userId = userId,
       super(ProfileEditState());

  /// Upload avatar image file and update profile
  Future<void> uploadAvatar(String filePath) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    try {
      final avatarUrl = await _repository.uploadAvatar(_userId, filePath);
      await _repository.updateProfile(_userId, avatarUrl: avatarUrl);
      state = state.copyWith(
        isLoading: false,
        success: true,
        avatarUrl: avatarUrl,
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        state = state.copyWith(success: false);
      });
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: profileActionErrorMessage(e),
        success: false,
      );
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
        error: profileActionErrorMessage(e),
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

      state = state.copyWith(isLoading: false, success: true, name: name);

      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        state = state.copyWith(success: false);
      });
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: profileActionErrorMessage(e),
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
final profileEditProvider =
    StateNotifierProvider.autoDispose<ProfileEditNotifier, ProfileEditState>((
      ref,
    ) {
      final userId = ref.watch(currentUserIdProvider);
      final repository = ref.watch(profileRepositoryProvider);

      if (userId == null) {
        return ProfileEditNotifier(repository: repository, userId: '');
      }

      return ProfileEditNotifier(repository: repository, userId: userId);
    });

/// Provider to logout user
final logoutProvider = FutureProvider<void>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  await repository.logout();
});

/// Provider for top contributors (leaderboard)
final topContributorsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getTopContributors(limit: 10);
});

class PlaceSubmissionState {
  final bool isSubmitting;
  final String? error;
  final bool success;

  const PlaceSubmissionState({
    this.isSubmitting = false,
    this.error,
    this.success = false,
  });

  PlaceSubmissionState copyWith({
    bool? isSubmitting,
    String? error,
    bool? success,
  }) {
    return PlaceSubmissionState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      success: success ?? this.success,
    );
  }
}

class PlaceSubmissionNotifier extends StateNotifier<PlaceSubmissionState> {
  PlaceSubmissionNotifier({required ProfileRepository repository})
    : _repository = repository,
      super(const PlaceSubmissionState());

  final ProfileRepository _repository;

  Future<void> submit({
    required String placeName,
    required String description,
    required String category,
    required String province,
    required String district,
    required double latitude,
    required double longitude,
    required List<String> photoPaths,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null, success: false);
    try {
      await _repository.submitPlaceContribution(
        placeName: placeName,
        description: description,
        category: category,
        province: province,
        district: district,
        latitude: latitude,
        longitude: longitude,
        photoPaths: photoPaths,
      );
      state = state.copyWith(isSubmitting: false, error: null, success: true);
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: profileActionErrorMessage(e),
        success: false,
      );
    }
  }

  void clear() {
    state = const PlaceSubmissionState();
  }
}

final placeSubmissionProvider =
    StateNotifierProvider.autoDispose<
      PlaceSubmissionNotifier,
      PlaceSubmissionState
    >((ref) {
      final repository = ref.watch(profileRepositoryProvider);
      return PlaceSubmissionNotifier(repository: repository);
    });

final pendingSubmissionsProvider = FutureProvider<List<ContributedPlace>>((
  ref,
) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getPendingSubmissions();
});

class ModerationActionState {
  final bool isWorking;
  final String? error;
  final bool success;

  const ModerationActionState({
    this.isWorking = false,
    this.error,
    this.success = false,
  });

  ModerationActionState copyWith({
    bool? isWorking,
    String? error,
    bool? success,
  }) {
    return ModerationActionState(
      isWorking: isWorking ?? this.isWorking,
      error: error,
      success: success ?? this.success,
    );
  }
}

class ModerationActionNotifier extends StateNotifier<ModerationActionState> {
  ModerationActionNotifier(this._repository)
    : super(const ModerationActionState());

  final ProfileRepository _repository;

  Future<void> review({
    required String submissionId,
    required bool approve,
    String? rejectionReason,
  }) async {
    state = state.copyWith(isWorking: true, error: null, success: false);
    try {
      await _repository.reviewSubmission(
        submissionId: submissionId,
        approve: approve,
        rejectionReason: rejectionReason,
      );
      state = state.copyWith(isWorking: false, error: null, success: true);
    } catch (e) {
      state = state.copyWith(
        isWorking: false,
        error: profileActionErrorMessage(e),
        success: false,
      );
    }
  }

  void clear() {
    state = const ModerationActionState();
  }
}

final moderationActionProvider =
    StateNotifierProvider.autoDispose<
      ModerationActionNotifier,
      ModerationActionState
    >((ref) {
      final repository = ref.watch(profileRepositoryProvider);
      return ModerationActionNotifier(repository);
    });

class ResubmitState {
  final bool isSubmitting;
  final String? error;
  final bool success;

  const ResubmitState({
    this.isSubmitting = false,
    this.error,
    this.success = false,
  });

  ResubmitState copyWith({bool? isSubmitting, String? error, bool? success}) {
    return ResubmitState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      success: success ?? this.success,
    );
  }
}

class ResubmitNotifier extends StateNotifier<ResubmitState> {
  ResubmitNotifier(this._repository) : super(const ResubmitState());

  final ProfileRepository _repository;

  Future<void> resubmit({
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
    state = state.copyWith(isSubmitting: true, error: null, success: false);
    try {
      await _repository.resubmitRejectedContribution(
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
      state = state.copyWith(isSubmitting: false, error: null, success: true);
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: profileActionErrorMessage(e),
        success: false,
      );
    }
  }

  void clear() {
    state = const ResubmitState();
  }
}

final resubmitProvider =
    StateNotifierProvider.autoDispose<ResubmitNotifier, ResubmitState>((ref) {
      final repository = ref.watch(profileRepositoryProvider);
      return ResubmitNotifier(repository);
    });
