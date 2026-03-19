import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Model for user progress information
class UserProgress {
  final int totalXP;
  final int currentLevel;
  final int xpToNextLevel;
  final List<String> completedAchievements;
  final List<String> unlockedDistricts;
  final List<String> unlockedProvinces;
  final int totalVisits;
  final int totalPlacesContributed;

  UserProgress({
    required this.totalXP,
    required this.currentLevel,
    required this.xpToNextLevel,
    required this.completedAchievements,
    required this.unlockedDistricts,
    required this.unlockedProvinces,
    required this.totalVisits,
    required this.totalPlacesContributed,
  });

  /// Calculate progress to next level as percentage (0-100)
  int get progressPercentage {
    if (xpToNextLevel <= 0) return 100;
    final xpEarned = _xpForLevel(currentLevel + 1) - totalXP;
    return ((xpEarned / xpToNextLevel) * 100).toInt().clamp(0, 100);
  }

  /// Helper to calculate XP needed for a level
  static int _xpForLevel(int level) {
    // Simple formula: 100 XP per level
    return level * 100;
  }

  UserProgress copyWith({
    int? totalXP,
    int? currentLevel,
    int? xpToNextLevel,
    List<String>? completedAchievements,
    List<String>? unlockedDistricts,
    List<String>? unlockedProvinces,
    int? totalVisits,
    int? totalPlacesContributed,
  }) {
    return UserProgress(
      totalXP: totalXP ?? this.totalXP,
      currentLevel: currentLevel ?? this.currentLevel,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
      completedAchievements:
          completedAchievements ?? this.completedAchievements,
      unlockedDistricts: unlockedDistricts ?? this.unlockedDistricts,
      unlockedProvinces: unlockedProvinces ?? this.unlockedProvinces,
      totalVisits: totalVisits ?? this.totalVisits,
      totalPlacesContributed:
          totalPlacesContributed ?? this.totalPlacesContributed,
    );
  }
}

/// State notifier for managing user progress
class ProgressNotifier extends StateNotifier<UserProgress> {
  ProgressNotifier()
      : super(UserProgress(
          totalXP: 0,
          currentLevel: 1,
          xpToNextLevel: 100,
          completedAchievements: [],
          unlockedDistricts: [],
          unlockedProvinces: [],
          totalVisits: 0,
          totalPlacesContributed: 0,
        ));

  /// Add XP to user progress
  void addXP(int xpAmount) {
    final newXP = state.totalXP + xpAmount;
    final newLevel = (newXP ~/ 100) + 1;
    final nextLevelXP = newLevel * 100;
    final xpRemaining = nextLevelXP - newXP;

    state = state.copyWith(
      totalXP: newXP,
      currentLevel: newLevel,
      xpToNextLevel: xpRemaining,
    );
  }

  /// Mark achievement as completed
  void unlockAchievement(String achievementId) {
    if (!state.completedAchievements.contains(achievementId)) {
      state = state.copyWith(
        completedAchievements: [
          ...state.completedAchievements,
          achievementId,
        ],
      );
    }
  }

  /// Unlock a district
  void unlockDistrict(String districtId) {
    if (!state.unlockedDistricts.contains(districtId)) {
      state = state.copyWith(
        unlockedDistricts: [
          ...state.unlockedDistricts,
          districtId,
        ],
      );
    }
  }

  /// Unlock a province
  void unlockProvince(String provinceId) {
    if (!state.unlockedProvinces.contains(provinceId)) {
      state = state.copyWith(
        unlockedProvinces: [
          ...state.unlockedProvinces,
          provinceId,
        ],
      );
    }
  }

  /// Record a visit
  void recordVisit() {
    state = state.copyWith(
      totalVisits: state.totalVisits + 1,
    );
  }

  /// Record a place contribution
  void recordPlaceContribution() {
    state = state.copyWith(
      totalPlacesContributed: state.totalPlacesContributed + 1,
    );
  }

  /// Reset progress (for test/dev purposes)
  void resetProgress() {
    state = UserProgress(
      totalXP: 0,
      currentLevel: 1,
      xpToNextLevel: 100,
      completedAchievements: [],
      unlockedDistricts: [],
      unlockedProvinces: [],
      totalVisits: 0,
      totalPlacesContributed: 0,
    );
  }
}

/// Riverpod provider for user progress
final progressProvider = StateNotifierProvider<ProgressNotifier, UserProgress>(
  (ref) => ProgressNotifier(),
);
