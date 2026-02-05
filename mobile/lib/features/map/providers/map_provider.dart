import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import '../models/map_models.dart';
import '../../trips/models/trip_model.dart';
import '../../destinations/models/destination_model.dart';

/// Map state containing current trip, GeoJSON, and UI state
class MapState {
  final Trip? currentTrip;
  final TripGeoJson? tripGeoJson;
  final TripStats? tripStats;
  final List<DestinationDetail> destinations;
  final mapbox.LatLng? userLocation;
  final MapStyle mapStyle;
  final bool isLoading;
  final String? error;
  final double currentZoom;
  final bool showRoute;
  final bool showBoundary;

  MapState({
    this.currentTrip,
    this.tripGeoJson,
    this.tripStats,
    this.destinations = const [],
    this.userLocation,
    this.mapStyle = MapStyle.streets,
    this.isLoading = false,
    this.error,
    this.currentZoom = 7.0,
    this.showRoute = true,
    this.showBoundary = true,
  });

  /// Create copy with updated fields
  MapState copyWith({
    Trip? currentTrip,
    TripGeoJson? tripGeoJson,
    TripStats? tripStats,
    List<DestinationDetail>? destinations,
    mapbox.LatLng? userLocation,
    MapStyle? mapStyle,
    bool? isLoading,
    String? error,
    double? currentZoom,
    bool? showRoute,
    bool? showBoundary,
  }) {
    return MapState(
      currentTrip: currentTrip ?? this.currentTrip,
      tripGeoJson: tripGeoJson ?? this.tripGeoJson,
      tripStats: tripStats ?? this.tripStats,
      destinations: destinations ?? this.destinations,
      userLocation: userLocation ?? this.userLocation,
      mapStyle: mapStyle ?? this.mapStyle,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentZoom: currentZoom ?? this.currentZoom,
      showRoute: showRoute ?? this.showRoute,
      showBoundary: showBoundary ?? this.showBoundary,
    );
  }

  /// Get completion percentage
  int get completionPercentage {
    if (destinations.isEmpty) return 0;
    final visited = destinations.where((d) => d.visited).length;
    return ((visited / destinations.length) * 100).round();
  }

  /// Get total distance from stats
  double get totalDistanceKm => tripStats?.geography.routeDistanceKm ?? 0.0;

  /// Check if map has data to display
  bool get hasData => tripGeoJson != null && destinations.isNotEmpty;
}

/// Available map styles
enum MapStyle {
  streets('mapbox://styles/mapbox/streets-v12'),
  outdoors('mapbox://styles/mapbox/outdoors-v12'),
  satellite('mapbox://styles/mapbox/satellite-v9'),
  satelliteStreets('mapbox://styles/mapbox/satellite-streets-v12'),
  light('mapbox://styles/mapbox/light-v11'),
  dark('mapbox://styles/mapbox/dark-v11');

  final String url;
  const MapStyle(this.url);
}

/// Map state notifier for Riverpod
class MapStateNotifier extends StateNotifier<MapState> {
  MapStateNotifier() : super(MapState());

  /// Set current trip and load GeoJSON
  void setCurrentTrip(Trip trip) {
    state = state.copyWith(
      currentTrip: trip,
      isLoading: true,
    );
  }

  /// Update with loaded GeoJSON data
  void setTripGeoJson(TripGeoJson geoJson) {
    final destinations = _extractDestinations(geoJson);
    state = state.copyWith(
      tripGeoJson: geoJson,
      destinations: destinations,
      isLoading: false,
      error: null,
    );
  }

  /// Update with trip statistics
  void setTripStats(TripStats stats) {
    state = state.copyWith(tripStats: stats);
  }

  /// Update user location
  void setUserLocation(double latitude, double longitude) {
    state = state.copyWith(
      userLocation: mapbox.LatLng(latitude, longitude),
    );
  }

  /// Change map style
  void setMapStyle(MapStyle style) {
    state = state.copyWith(mapStyle: style);
  }

  /// Update zoom level
  void setZoom(double zoom) {
    state = state.copyWith(currentZoom: zoom);
  }

  /// Toggle route visibility
  void toggleRoute(bool visible) {
    state = state.copyWith(showRoute: visible);
  }

  /// Toggle boundary visibility
  void toggleBoundary(bool visible) {
    state = state.copyWith(showBoundary: visible);
  }

  /// Set error message
  void setError(String error) {
    state = state.copyWith(
      error: error,
      isLoading: false,
    );
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Reset to initial state
  void reset() {
    state = MapState();
  }

  /// Extract destinations from GeoJSON features
  List<DestinationDetail> _extractDestinations(TripGeoJson geoJson) {
    final destinations = <DestinationDetail>[];

    for (final feature in geoJson.features) {
      if (feature is Map<String, dynamic>) {
        final geometry = feature['geometry'] as Map<String, dynamic>;
        final properties = feature['properties'] as Map<String, dynamic>;

        // Only process Point features (not routes or boundaries)
        if (geometry['type'] == 'Point' && properties['type'] != 'route') {
          final coords = geometry['coordinates'] as List;
          
          try {
            final destination = DestinationDetail(
              id: properties['id']?.toString() ?? '',
              name: properties['name']?.toString() ?? 'Unknown',
              latitude: coords[1] as double,
              longitude: coords[0] as double,
              visited: properties['visited'] == true,
              districtId: properties['districtId']?.toString(),
              travelId: properties['travelId']?.toString(),
            );
            destinations.add(destination);
          } catch (e) {
            debugPrint('Error parsing destination: $e');
          }
        }
      }
    }

    return destinations;
  }
}

/// Riverpod providers

/// Map state provider
final mapStateProvider = StateNotifierProvider<MapStateNotifier, MapState>(
  (ref) => MapStateNotifier(),
);

/// Get current trip
final currentTripProvider = Provider<Trip?>((ref) {
  return ref.watch(mapStateProvider).currentTrip;
});

/// Get trip GeoJSON
final tripGeoJsonProvider = Provider<TripGeoJson?>((ref) {
  return ref.watch(mapStateProvider).tripGeoJson;
});

/// Get trip statistics
final tripStatsProvider = Provider<TripStats?>((ref) {
  return ref.watch(mapStateProvider).tripStats;
});

/// Get destinations list
final destinationsProvider = Provider<List<DestinationDetail>>((ref) {
  return ref.watch(mapStateProvider).destinations;
});

/// Get user location
final userLocationProvider = Provider<mapbox.LatLng?>((ref) {
  return ref.watch(mapStateProvider).userLocation;
});

/// Get current map style
final mapStyleProvider = Provider<MapStyle>((ref) {
  return ref.watch(mapStateProvider).mapStyle;
});

/// Get completion percentage
final completionPercentageProvider = Provider<int>((ref) {
  return ref.watch(mapStateProvider).completionPercentage;
});

/// Get total distance
final totalDistanceProvider = Provider<double>((ref) {
  return ref.watch(mapStateProvider).totalDistanceKm;
});

/// Get loading state
final mapLoadingProvider = Provider<bool>((ref) {
  return ref.watch(mapStateProvider).isLoading;
});

/// Get error state
final mapErrorProvider = Provider<String?>((ref) {
  return ref.watch(mapStateProvider).error;
});

/// Get route visibility
final showRouteProvider = Provider<bool>((ref) {
  return ref.watch(mapStateProvider).showRoute;
});

/// Get boundary visibility
final showBoundaryProvider = Provider<bool>((ref) {
  return ref.watch(mapStateProvider).showBoundary;
});
