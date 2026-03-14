import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:gemified_travel_portfolio/core/config/app_config.dart';
import '../data/models/place_visit.dart';
import '../data/place_visit_repository.dart';

// ================================================================
// PROVIDERS
// ================================================================

/// Place visit repository provider
final placeVisitRepositoryProvider = Provider.family((ref, String? token) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
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
  final int currentStepIndex; // Checklist index 0-4

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
    this.currentStepIndex = -1,
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
    int? currentStepIndex,
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
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
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
      verificationStep: 'Initializing security handshake...',
      currentStepIndex: 0,
      userLatitude: null,
      userLongitude: null,
    );

    String? errorMessage;
    try {
      debugPrint('ðŸš€ Starting PlaceVisit recording for $placeId');
      // Call repository to record visit (includes anti-cheat validation)
      final visit = await _repository.recordVisit(
        placeId: placeId,
        notes: notes,
        photoUrl: photoUrl,
        onProgress: (step, progress) {
          int? stepIndex;
          if (step.contains('Permission') || step.contains('signal') || step.contains('GPS')) stepIndex = 1; // Maps to Boundary Check since permissions are fast
          if (step.contains('device') || step.contains('security')) stepIndex = 2;
          if (step.contains('environmental')) stepIndex = 3;
          if (step.contains('Preparing') || step.contains('Sending') || step.contains('server')) stepIndex = 4;

          state = state.copyWith(
            verificationProgress: progress,
            verificationStep: step,
            currentStepIndex: stepIndex ?? state.currentStepIndex,
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
              badgeEmoji: 'ðŸ†',
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
        currentStepIndex: 5,
      );

      // Show success message
      debugPrint('âœ… Visit recorded successfully: $placeName');
      if (achievement != null) {
        debugPrint('ðŸ† Achievement unlocked: ${achievement.title}');
      }

      // If validation was suspicious but approved, show warning
      if (visit.validation.status == 'suspicious' && visit.validation.isValid) {
        state = state.copyWith(
          error:
              'âš ï¸ Visit recorded with warnings (${visit.validation.flaggedReason})',
        );
      }

      // If validation failed, set error
      if (!visit.validation.isValid) {
        state = state.copyWith(error: visit.validation.displayMessage);
      }
    } catch (e) {
      debugPrint('âŒ Error recording visit: $e');
      errorMessage = 'Failed to record visit: $e';
    } finally {
      debugPrint('ðŸ Finishing PlaceVisit for $placeId');
      state = state.copyWith(
        isVerifying: false,
        error: errorMessage,
        verificationProgress: errorMessage == null ? 1.0 : null,
        currentStepIndex: errorMessage == null ? 5 : state.currentStepIndex,
      );
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
      return 'âœ… Visit verified safely';
    }

    if (!isValid) {
      switch (flaggedReason) {
        case 'low_accuracy':
          return 'ðŸ“ GPS accuracy too low. Try moving around to get a better signal.';
        case 'outside_geofence':
          return 'âš ï¸ You are too far from the place. Move closer to within 200m.';
        case 'wrong_heading':
          return 'ðŸ‘€ Face towards the place for verification.';
        case 'photo_location_mismatch':
          return 'ðŸ“· Photo location doesn\'t match place coordinates.';
        case 'location_spoofing_detected':
          return 'ðŸš« Location spoofing detected. Use real location.';
        case 'impossible_speed':
          return 'ðŸš— Impossible travel speed detected (teleporting?).';
        case 'rate_limited':
          return 'â±ï¸ You visited this place recently. Please try again later.';
        case 'invalid_signature':
          return 'ðŸ” Verification request signature failed. Please retry.';
        case 'missing_signature':
          return 'ðŸ” Verification signature missing. Please retry.';
        default:
          return invalidReason ?? 'Visit could not be verified';
      }
    }

    if (status == 'suspicious') {
      return 'âš ï¸ Visit recorded with warnings: $flaggedReason';
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

