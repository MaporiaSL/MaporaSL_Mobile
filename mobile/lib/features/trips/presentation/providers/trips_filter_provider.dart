import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/trip_model.dart';
import 'trips_provider.dart';

/// Filter options for trips
enum TripFilter { all, active, completed }

extension TripFilterExtension on TripFilter {
  String get label {
    switch (this) {
      case TripFilter.all:
        return 'All';
      case TripFilter.active:
        return 'Active';
      case TripFilter.completed:
        return 'Completed';
    }
  }

  TripStatus? toTripStatus() {
    switch (this) {
      case TripFilter.all:
        return null;
      case TripFilter.active:
        return TripStatus.active;
      case TripFilter.completed:
        return TripStatus.completed;
    }
  }
}

/// Provider for selected filter
final tripFilterProvider = StateProvider<TripFilter>((ref) => TripFilter.all);

/// Provider for search query
final tripSearchProvider = StateProvider<String>((ref) => '');

/// Filtered trips provider combining filter and search
final filteredTripsProvider = Provider<List<TripModel>>((ref) {
  final allTrips = ref.watch(tripsProvider).trips;
  final selectedFilter = ref.watch(tripFilterProvider);
  final searchQuery = ref.watch(tripSearchProvider).toLowerCase();

  return allTrips.where((trip) {
    // Apply search filter
    final matchesSearch =
        searchQuery.isEmpty ||
        trip.title.toLowerCase().contains(searchQuery) ||
        (trip.description?.toLowerCase().contains(searchQuery) ?? false);

    // Apply status filter
    final matchesFilter =
        selectedFilter == TripFilter.all ||
        (selectedFilter == TripFilter.active &&
            trip.status == TripStatus.active) ||
        (selectedFilter == TripFilter.completed &&
            trip.status == TripStatus.completed);

    return matchesSearch && matchesFilter;
  }).toList();
});
