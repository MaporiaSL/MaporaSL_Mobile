import '../datasources/trips_api.dart';
import '../models/trip_model.dart';
import '../models/trip_stats_model.dart';
import '../models/trip_dto.dart';

/// Repository for trip operations
class TripsRepository {
  final TripsApi _api;

  TripsRepository({required TripsApi api}) : _api = api;

  /// Get paginated trips
  Future<List<TripModel>> getTrips({int page = 1, int limit = 20}) async {
    try {
      return await _api.fetchTrips(page: page, limit: limit);
    } catch (e) {
      throw TripException('Failed to load trips: $e');
    }
  }

  /// Get single trip by ID
  Future<TripModel> getTripById(String id) async {
    try {
      return await _api.fetchTripById(id);
    } catch (e) {
      throw TripException('Failed to load trip: $e');
    }
  }

  /// Create new trip
  Future<TripModel> createTrip(CreateTripDto dto) async {
    try {
      return await _api.createTrip(dto);
    } catch (e) {
      throw TripException('Failed to create trip: $e');
    }
  }

  /// Update existing trip
  Future<TripModel> updateTrip(String id, UpdateTripDto dto) async {
    try {
      return await _api.updateTrip(id, dto);
    } catch (e) {
      throw TripException('Failed to update trip: $e');
    }
  }

  /// Delete trip
  Future<void> deleteTrip(String id) async {
    try {
      await _api.deleteTrip(id);
    } catch (e) {
      throw TripException('Failed to delete trip: $e');
    }
  }

  /// Get trip statistics
  Future<TripStatsModel> getStats() async {
    try {
      return await _api.fetchStats();
    } catch (e) {
      throw TripException('Failed to load stats: $e');
    }
  }
}
