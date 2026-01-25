import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/trip_stats_model.dart';
import '../../data/repositories/trips_repository.dart';
import 'trips_provider.dart';

/// Provider for trip statistics
final tripsStatsProvider = FutureProvider<TripStatsModel>((ref) async {
  final repository = ref.watch(tripsRepositoryProvider);

  try {
    return await repository.getStats();
  } catch (e) {
    // Return empty stats on error
    return TripStatsModel.empty();
  }
});
