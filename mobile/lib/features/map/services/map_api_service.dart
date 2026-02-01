import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/api_client.dart';
import '../models/map_models.dart';

/// Map API service for fetching map data
class MapApiService {
  final ApiClient _apiClient;

  MapApiService(this._apiClient);

  /// Get trip as GeoJSON
  /// GET /api/travel/:travelId/geojson
  Future<TripGeoJson> getTravelGeoJson(
    String travelId, {
    bool includeRoute = true,
    bool includeBoundary = true,
  }) async {
    try {
      final response = await _apiClient.get(
        '/api/travel/$travelId/geojson',
        queryParameters: {
          'includeRoute': includeRoute,
          'includeBoundary': includeBoundary,
        },
      );

      final geoJson = TripGeoJson.fromJson(response.data);
      return geoJson;
    } catch (e) {
      throw Exception('Failed to fetch trip GeoJSON: $e');
    }
  }

  /// Get trip boundary polygon
  /// GET /api/travel/:travelId/boundary
  Future<TripBoundary> getTravelBoundary(String travelId) async {
    try {
      final response = await _apiClient.get('/api/travel/$travelId/boundary');
      return TripBoundary.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch trip boundary: $e');
    }
  }

  /// Get trip statistics
  /// GET /api/travel/:travelId/stats
  Future<TripStats> getTravelStats(String travelId) async {
    try {
      final response = await _apiClient.get('/api/travel/$travelId/stats');
      return TripStats.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch trip stats: $e');
    }
  }

  /// Get elevation/terrain data
  /// GET /api/travel/:travelId/terrain
  Future<Map<String, dynamic>> getTravelTerrain(String travelId) async {
    try {
      final response = await _apiClient.get('/api/travel/$travelId/terrain');
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch terrain data: $e');
    }
  }

  /// Find destinations nearby a location
  /// GET /api/destinations/nearby
  Future<NearbyDestinationsResponse> findNearbyDestinations(
    double latitude,
    double longitude, {
    double radiusKm = 10,
    String? travelId,
  }) async {
    try {
      final response = await _apiClient.get(
        '/api/destinations/nearby',
        queryParameters: {
          'lat': latitude,
          'lng': longitude,
          'radius': radiusKm,
          if (travelId != null) 'travelId': travelId,
        },
      );

      return NearbyDestinationsResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to find nearby destinations: $e');
    }
  }

  /// Find destinations within bounds
  /// GET /api/destinations/within-bounds
  Future<TripGeoJson> findDestinationsWithinBounds(
    double swLat,
    double swLng,
    double neLat,
    double neLng, {
    String? travelId,
  }) async {
    try {
      final response = await _apiClient.get(
        '/api/destinations/within-bounds',
        queryParameters: {
          'swLat': swLat,
          'swLng': swLng,
          'neLat': neLat,
          'neLng': neLng,
          if (travelId != null) 'travelId': travelId,
        },
      );

      return TripGeoJson.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to find destinations within bounds: $e');
    }
  }
}

/// Riverpod provider for map API service
final mapApiServiceProvider = Provider<MapApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MapApiService(apiClient);
});

/// Fetch trip GeoJSON
final tripGeoJsonFutureProvider = FutureProvider.family<TripGeoJson, String>((
  ref,
  travelId,
) {
  final mapApi = ref.watch(mapApiServiceProvider);
  return mapApi.getTravelGeoJson(travelId);
});

/// Fetch trip boundary
final tripBoundaryFutureProvider = FutureProvider.family<TripBoundary, String>((
  ref,
  travelId,
) {
  final mapApi = ref.watch(mapApiServiceProvider);
  return mapApi.getTravelBoundary(travelId);
});

/// Fetch trip statistics
final tripStatsFutureProvider = FutureProvider.family<TripStats, String>((
  ref,
  travelId,
) {
  final mapApi = ref.watch(mapApiServiceProvider);
  return mapApi.getTravelStats(travelId);
});

/// Fetch nearby destinations
final nearbyDestinationsFutureProvider =
    FutureProvider.family<
      NearbyDestinationsResponse,
      ({double latitude, double longitude, double radiusKm})
    >((ref, params) {
      final mapApi = ref.watch(mapApiServiceProvider);
      return mapApi.findNearbyDestinations(
        params.latitude,
        params.longitude,
        radiusKm: params.radiusKm,
      );
    });

/// Fetch destinations in bounds
final destinationsInBoundsFutureProvider =
    FutureProvider.family<
      TripGeoJson,
      ({double swLat, double swLng, double neLat, double neLng})
    >((ref, bounds) {
      final mapApi = ref.watch(mapApiServiceProvider);
      return mapApi.findDestinationsWithinBounds(
        bounds.swLat,
        bounds.swLng,
        bounds.neLat,
        bounds.neLng,
      );
    });
