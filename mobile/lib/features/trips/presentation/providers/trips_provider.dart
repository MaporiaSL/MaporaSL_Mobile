import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../data/datasources/trips_api.dart';
import '../../data/repositories/trips_repository.dart';
import '../../data/models/trip_model.dart';
import '../../data/models/trip_dto.dart';

/// State class for trips
class TripsState {
  final List<TripModel> trips;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasMore;

  const TripsState({
    this.trips = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
  });

  TripsState copyWith({
    List<TripModel>? trips,
    bool? isLoading,
    String? error,
    int? currentPage,
    bool? hasMore,
  }) {
    return TripsState(
      trips: trips ?? this.trips,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// State notifier for trips management
class TripsNotifier extends StateNotifier<TripsState> {
  final TripsRepository _repository;

  TripsNotifier({required TripsRepository repository})
    : _repository = repository,
      super(const TripsState());

  /// Load trips (initial load or refresh)
  Future<void> loadTrips({bool refresh = false}) async {
    if (refresh) {
      state = const TripsState(isLoading: true);
    } else if (state.isLoading) {
      return; // Prevent duplicate calls
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final trips = await _repository.getTrips(page: 1);
      state = TripsState(
        trips: trips,
        isLoading: false,
        currentPage: 1,
        hasMore: trips.length >= 20, // If we got full page, there might be more
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Load more trips (pagination)
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;

    final nextPage = state.currentPage + 1;

    try {
      final newTrips = await _repository.getTrips(page: nextPage);

      state = state.copyWith(
        trips: [...state.trips, ...newTrips],
        currentPage: nextPage,
        hasMore: newTrips.length >= 20,
      );
    } catch (e) {
      // Silently fail pagination - user can retry
      state = state.copyWith(error: 'Failed to load more trips');
    }
  }

  /// Create new trip
  Future<void> createTrip(CreateTripDto dto) async {
    try {
      final newTrip = await _repository.createTrip(dto);

      // Add to beginning of list
      state = state.copyWith(trips: [newTrip, ...state.trips]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Update existing trip
  Future<void> updateTrip(String id, UpdateTripDto dto) async {
    try {
      final updatedTrip = await _repository.updateTrip(id, dto);

      // Replace trip in list
      final updatedTrips = state.trips.map((trip) {
        return trip.id == id ? updatedTrip : trip;
      }).toList();

      state = state.copyWith(trips: updatedTrips);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Delete trip
  Future<void> deleteTrip(String id) async {
    try {
      await _repository.deleteTrip(id);

      // Remove from list
      final updatedTrips = state.trips.where((trip) => trip.id != id).toList();
      state = state.copyWith(trips: updatedTrips);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for Dio instance (can be overridden for testing)
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();

  // Add auth interceptor here when Auth0 is integrated
  // dio.interceptors.add(AuthInterceptor());

  return dio;
});

/// Provider for TripsApi
final tripsApiProvider = Provider<TripsApi>((ref) {
  final dio = ref.watch(dioProvider);
  return TripsApi(dio: dio);
});

/// Provider for TripsRepository
final tripsRepositoryProvider = Provider<TripsRepository>((ref) {
  final api = ref.watch(tripsApiProvider);
  return TripsRepository(api: api);
});

/// Main trips provider
final tripsProvider = StateNotifierProvider<TripsNotifier, TripsState>((ref) {
  final repository = ref.watch(tripsRepositoryProvider);
  return TripsNotifier(repository: repository);
});
