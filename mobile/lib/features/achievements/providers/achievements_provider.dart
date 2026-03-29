import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemified_travel_portfolio/core/services/api_client.dart';
import 'package:gemified_travel_portfolio/features/places/widgets/achievement_card.dart';
import 'package:gemified_travel_portfolio/features/profile/presentation/providers/profile_providers.dart';
import 'package:gemified_travel_portfolio/features/trips/presentation/providers/trips_provider.dart';
import 'package:gemified_travel_portfolio/providers/progress_provider.dart';

class AchievementsViewData {
  final List<AchievementProgress> achievements;
  final Map<String, List<AchievementProgress>> tracks;
  final int totalTrophyPoints;
  final int totalXp;

  AchievementsViewData({
    required this.achievements,
    required this.tracks,
    required this.totalTrophyPoints,
    required this.totalXp,
  });
}

final achievementsViewProvider = FutureProvider<AchievementsViewData>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final userId = ref.watch(currentUserIdProvider);
  final localProgress = ref.watch(progressProvider);
  final tripsState = ref.watch(tripsProvider);

  if (userId == null || userId.isEmpty) {
    return AchievementsViewData(
      achievements: [],
      tracks: {},
      totalTrophyPoints: 0,
      totalXp: 0,
    );
  }

  Map<String, int> visitsByCategory = {};
  int fallbackContributions = 0;

  try {
    final statsRes = await apiClient.get('/places/users/$userId/stats');
    if (statsRes.data != null) {
      final stats = statsRes.data as Map<String, dynamic>;
      final rawCategories = stats['visitsByCategory'];
      if (rawCategories is Map<String, dynamic>) {
        visitsByCategory = rawCategories.map((key, value) => MapEntry(key, (value as num).toInt()));
      }
      fallbackContributions = (stats['totalPlacesContributed'] as num?)?.toInt() ?? 0;
    }
  } catch (_) {
    // Silently fail, we'll use local/inferred data
  }

  // DEEP SYNC: Infer progress from local trips if server stats are lagging or empty
  final completedTrips = tripsState.trips.where((t) => t.status == 'completed' || t.status == 'done').toList();
  
  // Simulated visit metadata derived from titles/descriptions
  int inferredTotalVisits = 0;
  Map<String, int> inferredByCat = {};
  
  for (final trip in completedTrips) {
    // Every completed mission counts as a visit milestone!
    inferredTotalVisits++;
    
    final fullText = '${trip.title} ${trip.description ?? ''}'.toLowerCase();
    
    // Temples & Culture
    if (fullText.contains('temple') || fullText.contains('kovil') || fullText.contains('vihara') || 
        fullText.contains('shrine') || fullText.contains('heritage') || fullText.contains('culture')) {
      inferredByCat['temples'] = (inferredByCat['temples'] ?? 0) + 1;
    }
    
    // Beaches
    if (fullText.contains('beach') || fullText.contains('coast') || fullText.contains('sand') || 
        fullText.contains('surf') || fullText.contains('ocean') || fullText.contains('bay')) {
      inferredByCat['beaches'] = (inferredByCat['beaches'] ?? 0) + 1;
    }
    
    // Mountains & Hiking
    if (fullText.contains('mountain') || fullText.contains('peak') || fullText.contains('hike') || 
        fullText.contains('hill') || fullText.contains('ella') || fullText.contains('trek')) {
      inferredByCat['mountains'] = (inferredByCat['mountains'] ?? 0) + 1;
    }
    
    // Rural & Villages
    if (fullText.contains('village') || fullText.contains('rural') || fullText.contains('local') || 
        fullText.contains('field') || fullText.contains('homestay')) {
      inferredByCat['villages'] = (inferredByCat['villages'] ?? 0) + 1;
    }
    
    // Wildlife & Parks
    if (fullText.contains('nature') || fullText.contains('wildlife') || fullText.contains('park') || 
        fullText.contains('safari') || fullText.contains('elephant') || fullText.contains('forest')) {
      inferredByCat['wildlife'] = (inferredByCat['wildlife'] ?? 0) + 1;
    }

    // Historical sites
    if (fullText.contains('history') || fullText.contains('ancient') || fullText.contains('ruin') || 
        fullText.contains('museum') || fullText.contains('fort')) {
      inferredByCat['historical'] = (inferredByCat['historical'] ?? 0) + 1;
    }
  }

  // Combine data sources
  // totalVisits is the max of local (Verified) and inferred (Trips history)
  final totalVisits = localProgress.totalVisits > inferredTotalVisits ? localProgress.totalVisits : inferredTotalVisits;
  final unlockedDistrictsCount = localProgress.unlockedDistricts.length;
  final contributions = localProgress.totalPlacesContributed > fallbackContributions 
      ? localProgress.totalPlacesContributed 
      : fallbackContributions;

  final finalAchievements = AchievementDefinition.all.map((definition) {
    int progress = 0;
    switch (definition.category) {
      case 'visit_count':
        progress = totalVisits;
        break;
      case 'all_districts':
        progress = unlockedDistrictsCount;
        break;
      case 'photos':
      case 'reviews':
        progress = contributions;
        break;
      case 'social':
        // Social counts verified visits + completed trips as social footprint
        progress = totalVisits;
        break;
      default:
        // Category progress is max of server stats and inferred stats
        final serverCount = visitsByCategory[definition.category] ?? 0;
        final inferredCount = inferredByCat[definition.category] ?? 0;
        progress = serverCount > inferredCount ? serverCount : inferredCount;
    }

    return AchievementProgress.fromProgress(definition, progress);
  }).toList();

  // Group by track
  final tracks = <String, List<AchievementProgress>>{};
  int totalTrophyPoints = 0;

  for (final achievement in finalAchievements) {
    final track = achievement.definition.track;
    tracks.putIfAbsent(track, () => []).add(achievement);
    totalTrophyPoints += achievement.totalEarnedPoints;
  }

  return AchievementsViewData(
    achievements: finalAchievements,
    tracks: tracks,
    totalTrophyPoints: totalTrophyPoints,
    totalXp: localProgress.totalXP,
  );
});
