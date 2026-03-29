import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemified_travel_portfolio/core/services/api_client.dart';
import 'package:gemified_travel_portfolio/features/places/widgets/achievement_card.dart';
import 'package:gemified_travel_portfolio/features/profile/presentation/providers/profile_providers.dart';
import 'package:gemified_travel_portfolio/providers/progress_provider.dart';

class AchievementsViewData {
  final int totalXp;
  final int totalTrophyPoints;
  final Map<String, List<AchievementProgress>> tracks;

  const AchievementsViewData({
    required this.totalXp,
    required this.totalTrophyPoints,
    required this.tracks,
  });
}

final achievementsViewProvider = FutureProvider<AchievementsViewData>((ref) async {
  final localProgress = ref.watch(progressProvider);
  final userId = ref.watch(currentUserIdProvider);
  final apiClient = ref.watch(apiClientProvider);

  var totalVisits = localProgress.totalVisits;
  var unlockedDistrictsCount = localProgress.unlockedDistricts.length;
  var totalXp = localProgress.totalXP;
  Map<String, int> visitsByCategory = {};

  if (userId != null && userId.isNotEmpty) {
    try {
      final progressRes = await apiClient.get('/users/$userId/progress');
      final data = progressRes.data as Map<String, dynamic>;
      totalVisits = (data['totalPlacesVisited'] as num?)?.toInt() ?? totalVisits;
      unlockedDistrictsCount = (data['unlockedDistricts'] as List?)?.length ?? unlockedDistrictsCount;
      totalXp = (data['xpTotal'] as num?)?.toInt() ?? totalXp;
    } catch (_) {}

    try {
      final statsRes = await apiClient.get('/places/users/$userId/stats');
      final stats = statsRes.data as Map<String, dynamic>;
      final rawCategories = stats['visitsByCategory'];
      if (rawCategories is Map<String, dynamic>) {
        visitsByCategory = rawCategories.map((key, value) => MapEntry(key, (value as num).toInt()));
      }
    } catch (_) {}
  }

  int totalTrophyPoints = 0;
  final Map<String, List<AchievementProgress>> tracksData = {
    'Pioneer': [],
    'Naturalist': [],
    'Devotee': [],
    'Chronicler': [],
  };

  for (final definition in PlaceAchievements.definitions) {
    final currentProgress = _progressForDefinition(
      definition,
      totalVisits: totalVisits,
      unlockedDistrictsCount: unlockedDistrictsCount,
      visitsByCategory: visitsByCategory,
      fallbackContributions: localProgress.totalPlacesContributed,
    );

    int currentTier = -1;
    for (int i = 0; i < definition.tiers.length; i++) {
      if (currentProgress >= definition.tiers[i]) {
        currentTier = i;
        totalTrophyPoints += definition.tierRewards[i];
      } else {
        break;
      }
    }

    final ap = AchievementProgress(
      id: definition.id,
      definition: definition,
      currentProgress: currentProgress,
      currentTier: currentTier,
    );

    if (tracksData.containsKey(definition.track)) {
      tracksData[definition.track]!.add(ap);
    }
  }

  return AchievementsViewData(
    totalXp: totalXp,
    totalTrophyPoints: totalTrophyPoints,
    tracks: tracksData,
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
    case 'visit_count': return totalVisits;
    case 'all_districts': return unlockedDistrictsCount;
    case 'photos': return fallbackContributions;
    default: return visitsByCategory[definition.category] ?? 0;
  }
}
