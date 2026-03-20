import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemified_travel_portfolio/core/services/api_client.dart';
import 'package:gemified_travel_portfolio/features/places/widgets/achievement_card.dart';
import 'package:gemified_travel_portfolio/features/profile/presentation/providers/profile_providers.dart';
import 'package:gemified_travel_portfolio/providers/progress_provider.dart';

class AchievementsViewData {
  final int totalXp;
  final int totalVisits;
  final List<AchievementProgress> achievements;

  const AchievementsViewData({
    required this.totalXp,
    required this.totalVisits,
    required this.achievements,
  });
}

final achievementsViewProvider = FutureProvider<AchievementsViewData>((
  ref,
) async {
  final localProgress = ref.watch(progressProvider);
  final userId = ref.watch(currentUserIdProvider);
  final apiClient = ref.watch(apiClientProvider);

  var totalVisits = localProgress.totalVisits;
  var unlockedDistrictsCount = localProgress.unlockedDistricts.length;
  var totalXp = localProgress.totalXP;

  Map<String, int> visitsByCategory = const {};

  if (userId != null && userId.isNotEmpty) {
    try {
      final progressRes = await apiClient.get('/users/$userId/progress');
      final data = progressRes.data as Map<String, dynamic>;

      totalVisits =
          (data['totalPlacesVisited'] as num?)?.toInt() ?? totalVisits;
      unlockedDistrictsCount =
          (data['unlockedDistricts'] as List?)?.length ??
          unlockedDistrictsCount;

      // Keep local XP as primary fallback, but use server value when present.
      totalXp = (data['xpTotal'] as num?)?.toInt() ?? totalXp;
    } catch (e) {
      debugPrint('Failed to sync /users/:id/progress for achievements: $e');
    }

    // This endpoint exists in some backend variants. Keep it optional.
    try {
      final statsRes = await apiClient.get('/places/users/$userId/stats');
      final stats = statsRes.data as Map<String, dynamic>;

      totalVisits = (stats['totalVisits'] as num?)?.toInt() ?? totalVisits;
      unlockedDistrictsCount =
          (stats['uniqueDistricts'] as num?)?.toInt() ?? unlockedDistrictsCount;

      final rawCategories = stats['visitsByCategory'];
      if (rawCategories is Map<String, dynamic>) {
        visitsByCategory = rawCategories.map(
          (key, value) => MapEntry(key, (value as num).toInt()),
        );
      }
    } catch (e) {
      debugPrint('Optional /places/users/:id/stats unavailable: $e');
    }
  }

  final achievements = PlaceAchievements.definitions.map((definition) {
    final currentProgress = _progressForDefinition(
      definition,
      totalVisits: totalVisits,
      unlockedDistrictsCount: unlockedDistrictsCount,
      visitsByCategory: visitsByCategory,
      fallbackContributions: localProgress.totalPlacesContributed,
    );

    return AchievementProgress(
      id: definition.id,
      definition: definition,
      currentProgress: currentProgress,
      isUnlocked: currentProgress >= definition.threshold,
    );
  }).toList();

  return AchievementsViewData(
    totalXp: totalXp,
    totalVisits: totalVisits,
    achievements: achievements,
  );
});

int _progressForDefinition(
  AchievementDefinition definition, {
  required int totalVisits,
  required int unlockedDistrictsCount,
  required Map<String, int> visitsByCategory,
  required int fallbackContributions,
}) {
  switch (definition.category) {
    case 'visit_count':
      return totalVisits;
    case 'all_districts':
      return unlockedDistrictsCount;
    case 'photos':
      return fallbackContributions;
    default:
      return visitsByCategory[definition.category] ?? 0;
  }
}
