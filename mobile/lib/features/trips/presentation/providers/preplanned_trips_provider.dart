import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../data/models/preplanned_trip_model.dart';
import '../../data/models/trip_model.dart';
import '../../data/datasources/preplanned_trips_api.dart';
import '../../data/repositories/preplanned_trips_repository.dart';
import 'trips_provider.dart';

/// Filters for Discover tab
class PreplannedFilters {
  final String? duration;
  final String? type;
  final String? startingPoint;
  final String? difficulty;
  final List<String> tags;

  const PreplannedFilters({
    this.duration,
    this.type,
    this.startingPoint,
    this.difficulty,
    this.tags = const [],
  });

  PreplannedFilters copyWith({
    String? duration,
    String? type,
    String? startingPoint,
    String? difficulty,
    List<String>? tags,
  }) {
    return PreplannedFilters(
      duration: duration ?? this.duration,
      type: type ?? this.type,
      startingPoint: startingPoint ?? this.startingPoint,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
    );
  }
}

/// Provider for filters state
final preplannedFiltersProvider = StateProvider<PreplannedFilters>(
  (ref) => const PreplannedFilters(),
);

/// API provider (reuses Dio from trips)
final preplannedTripsApiProvider = Provider<PrePlannedTripsApi>((ref) {
  final dio = ref.watch(dioProvider);
  return PrePlannedTripsApi(dio: dio);
});

/// Repository provider
final preplannedTripsRepositoryProvider = Provider<PrePlannedTripsRepository>((
  ref,
) {
  final api = ref.watch(preplannedTripsApiProvider);
  return PrePlannedTripsRepository(api);
});

/// Future provider to fetch templates with current filters
final preplannedTripsFutureProvider =
    FutureProvider.autoDispose<List<PrePlannedTripModel>>((ref) async {
      final filters = ref.watch(preplannedFiltersProvider);
      final repo = ref.watch(preplannedTripsRepositoryProvider);
      return repo.fetchTemplates(
        duration: filters.duration,
        type: filters.type,
        startingPoint: filters.startingPoint,
        difficulty: filters.difficulty,
        tags: filters.tags,
      );
    });

/// Start adventure (clone template) helper
final startAdventureProvider =
    FutureProvider.family<TripModel, StartAdventureRequest>((
      ref,
      request,
    ) async {
      final repo = ref.watch(preplannedTripsRepositoryProvider);
      final trip = await repo.cloneTemplate(
        templateId: request.templateId,
        startDate: request.startDate,
        endDate: request.endDate,
      );

      // Insert into trips state so My Journeys reflects immediately
      ref.read(tripsProvider.notifier).addTrip(trip);
      return trip;
    });

class StartAdventureRequest {
  final String templateId;
  final DateTime startDate;
  final DateTime endDate;

  const StartAdventureRequest({
    required this.templateId,
    required this.startDate,
    required this.endDate,
  });
}
