import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode, debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../data/models/place_visit.dart';
import '../data/place_visit_repository.dart';

// ================================================================
// PROVIDERS
// ================================================================

/// Place visit repository provider
final placeVisitRepositoryProvider = Provider.family((ref, String? token) {
  final dio = Dio(
    BaseOptions(
      baseUrl: _resolveApiBaseUrl(),
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ),
    );
  }

  return PlaceVisitRepository(dio, token);
});

String _resolveApiBaseUrl() {
  const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  if (apiBaseUrl.isNotEmpty) return apiBaseUrl;

  if (kIsWeb) return 'http://localhost:5000';

  if (Platform.isAndroid) {
    return 'http://10.0.2.2:5000';
  }

  if (Platform.isIOS) {
    return 'http://127.0.0.1:5000';
  }

  return 'http://localhost:5000';
}

/// Place visit state notifier
final placeVisitProvider =
    StateNotifierProvider.family<PlaceVisitNotifier, PlaceVisitState, String>(
      (ref, userId) => PlaceVisitNotifier(
        ref.watch(
          placeVisitRepositoryProvider('YOUR_TOKEN_HERE'),
        ), // TODO: Get actual token
        userId,
      ),
    );

/// User visit statistics provider
final userVisitStatsProvider = FutureProvider.family((
  ref,
  String userId,
) async {
  final repo = ref.watch(placeVisitRepositoryProvider('YOUR_TOKEN_HERE'));
  return repo.getUserVisitStats(userId);
});

/// Place visit history provider
final placeVisitHistoryProvider = FutureProvider.family((
  ref,
  String placeId,
) async {
  final repo = ref.watch(placeVisitRepositoryProvider('YOUR_TOKEN_HERE'));
  return repo.getVisitHistory(placeId);
});

// ================================================================
// STATE CLASS
// ================================================================

class PlaceVisitState {
  final bool isLoading;
  final bool isVerifying; // GPS and metadata collection in progress
  final String? error;
  final PlaceVisit? lastVisit;
  final List<PlaceVisit> recentVisits; // Recent visits by current user
  final PlaceAchievement? unlockedAchievement;
  final double? verificationProgress; // 0.0-1.0 for metadata collection
  final String? verificationStep; // Current step description

  // Store user coordinates for error display
  final double? userLatitude;
  final double? userLongitude;

  PlaceVisitState({
    this.isLoading = false,
    this.isVerifying = false,
    this.error,
    this.lastVisit,
    this.recentVisits = const [],
    this.unlockedAchievement,
    this.verificationProgress,
    this.verificationStep,
    this.userLatitude,
    this.userLongitude,
  });

  PlaceVisitState copyWith({
    bool? isLoading,
    bool? isVerifying,
    String? error,
    PlaceVisit? lastVisit,
    List<PlaceVisit>? recentVisits,
    PlaceAchievement? unlockedAchievement,
    double? verificationProgress,
    String? verificationStep,
    double? userLatitude,
    double? userLongitude,
  }) {
    return PlaceVisitState(
      isLoading: isLoading ?? this.isLoading,
      isVerifying: isVerifying ?? this.isVerifying,
      error: error ?? this.error,
      lastVisit: lastVisit ?? this.lastVisit,
      recentVisits: recentVisits ?? this.recentVisits,
      unlockedAchievement: unlockedAchievement ?? this.unlockedAchievement,
      verificationProgress: verificationProgress ?? this.verificationProgress,
      verificationStep: verificationStep ?? this.verificationStep,
      userLatitude: userLatitude ?? this.userLatitude,
      userLongitude: userLongitude ?? this.userLongitude,
    );
  }
}

// ================================================================
// STATE NOTIFIER
// ================================================================

class PlaceVisitNotifier extends StateNotifier<PlaceVisitState> {
  final PlaceVisitRepository _repository;
  final String _userId;

  PlaceVisitNotifier(this._repository, this._userId) : super(PlaceVisitState());

  /// Record a visit to a place
  /// Collects anti-cheat metadata and verifies location authenticity
  Future<void> recordVisit({
    required String placeId,
    required String placeName,
    String? notes,
    String? photoUrl,
    required double placeLatitude,
    required double placeLongitude,
  }) async {
    state = state.copyWith(
      isVerifying: true,
      error: null,
      verificationProgress: 0.1,
      verificationStep: 'Requesting location permissions...',
      userLatitude: null,
      userLongitude: null,
    );

    try {
      // Call repository to record visit (includes anti-cheat validation)
      final visit = await _repository.recordVisit(
        placeId: placeId,
        notes: notes,
        photoUrl: photoUrl,
        onProgress: (step, progress) {
          state = state.copyWith(
            verificationProgress: progress,
            verificationStep: step,
          );
        },
      );

      state = state.copyWith(
        verificationProgress: 0.9,
        verificationStep: 'Processing verification...',
      );

      // Store user coordinates from the visit response
      final userLat = visit.userCoordinates?.latitude;
      final userLng = visit.userCoordinates?.longitude;

      // Check if achievement was unlocked
      final achievement = visit.achievementId != null
          ? PlaceAchievement(
              id: visit.achievementId ?? '',
              userId: _userId,
              title: visit.achievementTitle ?? '',
              description: 'Achievement unlocked!',
              badgeEmoji: '🏆',
              category: 'all_districts',
              threshold: 1,
              currentProgress: 1,
              isUnlocked: true,
              unlockedAt: DateTime.now(),
              rewards: 100,
            )
          : null;

      state = state.copyWith(
        isVerifying: false,
        lastVisit: visit,
        unlockedAchievement: achievement,
        verificationProgress: 1.0,
        error: null,
        userLatitude: userLat,
        userLongitude: userLng,
      );

      // Show success message
      print('✅ Visit recorded successfully: $placeName');
      if (achievement != null) {
        print('🏆 Achievement unlocked: ${achievement.title}');
      }

      // If validation was suspicious but approved, show warning
      if (visit.validation.status == 'suspicious' && visit.validation.isValid) {
        state = state.copyWith(
          error:
              '⚠️ Visit recorded with warnings (${visit.validation.flaggedReason})',
        );
      }

      // If validation failed, set error
      if (!visit.validation.isValid) {
        state = state.copyWith(error: visit.validation.displayMessage);
      }
    } catch (e) {
      state = state.copyWith(
        isVerifying: false,
        error: 'Failed to record visit: $e',
        verificationProgress: null,
      );
      print('❌ Error recording visit: $e');
      rethrow;
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Cancel ongoing verification
  void cancelVerification() {
    state = state.copyWith(isVerifying: false, verificationProgress: null);
  }

  /// Load user's recent visits
  Future<void> loadRecentVisits() async {
    state = state.copyWith(isLoading: true);
    try {
      // TODO: Implement fetching user's recent visits
      // final visits = await _repository.getUserRecentVisits(_userId);
      // state = state.copyWith(recentVisits: visits, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load recent visits: $e',
        isLoading: false,
      );
    }
  }
}

// ================================================================
// VALIDATION MESSAGE HELPER
// ================================================================

extension ValidationDisplayMessage on PlaceVisitValidation {
  String get displayMessage {
    if (isValid && status == 'approved') {
      return '✅ Visit verified safely';
    }

    if (!isValid) {
      switch (flaggedReason) {
        case 'low_accuracy':
          return '📍 GPS accuracy too low. Try moving around to get a better signal.';
        case 'outside_geofence':
          return '⚠️ You are too far from the place. Move closer to within 200m.';
        case 'wrong_heading':
          return '👀 Face towards the place for verification.';
        case 'photo_location_mismatch':
          return '📷 Photo location doesn\'t match place coordinates.';
        case 'location_spoofing_detected':
          return '🚫 Location spoofing detected. Use real location.';
        case 'impossible_speed':
          return '🚗 Impossible travel speed detected (teleporting?).';
        case 'rate_limited':
          return '⏱️ You visited this place recently. Please try again later.';
        case 'invalid_signature':
          return '🔐 Verification request signature failed. Please retry.';
        case 'missing_signature':
          return '🔐 Verification signature missing. Please retry.';
        default:
          return invalidReason ?? 'Visit could not be verified';
      }
    }

    if (status == 'suspicious') {
      return '⚠️ Visit recorded with warnings: $flaggedReason';
    }

    return 'Visit status unknown';
  }
}

// ================================================================
// ACHIEVEMENT DISPLAY EXTENSIONS
// ================================================================

extension AchievementDisplay on PlaceAchievement {
  String get progressText => '$currentProgress / $threshold';

  double get progressPercentValue =>
      (currentProgress / threshold).clamp(0, 1).toDouble();

  bool get isNearlyUnlocked => currentProgress >= (threshold * 0.8);
}
