import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../models/trip_model.dart';
import '../models/trip_stats_model.dart';
import '../models/trip_dto.dart';

/// API client for trips endpoints
class TripsApi {
  final Dio _dio;
  final String baseUrl;

  TripsApi({
    required Dio dio,
    // For Android emulator: 10.0.2.2 maps to host machine's localhost
    // For iOS simulator: localhost works
    // For physical device: use your computer's IP address
    String? baseUrl,
  })  : _dio = dio,
        baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  /// Fetch paginated list of trips
  /// GET /api/travel?skip=0&limit=20
  Future<List<TripModel>> fetchTrips({int page = 1, int limit = 20}) async {
    try {
      final skip = (page - 1) * limit;
      final response = await _dio.get(
        '$baseUrl/api/travel',
        queryParameters: {'skip': skip, 'limit': limit},
      );

      final travels = response.data['travels'] as List;
      return travels.map((json) {
        // Convert MongoDB _id to id field
        final map = Map<String, dynamic>.from(json as Map<String, dynamic>);
        if (map.containsKey('_id')) {
          map['id'] = map['_id'].toString();
        }
        return TripModel.fromJson(map);
      }).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Fetch single trip by ID
  /// GET /api/travel/:id
  Future<TripModel> fetchTripById(String id) async {
    try {
      final response = await _dio.get('$baseUrl/api/travel/$id');
      final map = Map<String, dynamic>.from(
        response.data['travel'] as Map<String, dynamic>,
      );
      if (map.containsKey('_id')) {
        map['id'] = map['_id'].toString();
      }
      return TripModel.fromJson(map);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create new trip
  /// POST /api/travel
  Future<TripModel> createTrip(CreateTripDto dto) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/travel',
        data: dto.toJson(),
      );
      final map = Map<String, dynamic>.from(
        response.data['travel'] as Map<String, dynamic>,
      );
      if (map.containsKey('_id')) {
        map['id'] = map['_id'].toString();
      }
      return TripModel.fromJson(map);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update existing trip
  /// PATCH /api/travel/:id
  Future<TripModel> updateTrip(String id, UpdateTripDto dto) async {
    try {
      final response = await _dio.patch(
        '$baseUrl/api/travel/$id',
        data: dto.toJson(),
      );
      final map = Map<String, dynamic>.from(
        response.data['travel'] as Map<String, dynamic>,
      );
      if (map.containsKey('_id')) {
        map['id'] = map['_id'].toString();
      }
      return TripModel.fromJson(map);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete trip
  /// DELETE /api/travel/:id
  Future<void> deleteTrip(String id) async {
    try {
      await _dio.delete('$baseUrl/api/travel/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Fetch trip statistics (calculated client-side for now)
  /// TODO: Replace with backend endpoint when available
  Future<TripStatsModel> fetchStats() async {
    try {
      // Fetch all trips to calculate stats
      final trips = await fetchTrips(limit: 1000);

      int totalDestinations = 0;
      int totalVisited = 0;

      for (final trip in trips) {
        totalDestinations += trip.destinationCount;
        totalVisited += trip.visitedCount;
      }

      final completionRate = totalDestinations > 0
          ? totalVisited / totalDestinations
          : 0.0;

      return TripStatsModel(
        totalTrips: trips.length,
        totalDestinations: totalDestinations,
        totalVisited: totalVisited,
        completionRate: completionRate,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle Dio errors and convert to user-friendly messages
  Exception _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TripException('Connection timeout. Please check your internet.');

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data['message'] ?? e.message;

        switch (statusCode) {
          case 400:
            return TripException('Invalid request: $message');
          case 401:
            return TripException('Authentication required. Please log in.');
          case 403:
            return TripException(
              'You do not have permission to perform this action.',
            );
          case 404:
            return TripException('Trip not found.');
          case 500:
            return TripException('Server error. Please try again later.');
          default:
            return TripException('Request failed: $message');
        }

      case DioExceptionType.cancel:
        return TripException('Request cancelled.');

      case DioExceptionType.unknown:
        if (e.error.toString().contains('SocketException')) {
          return TripException('No internet connection.');
        }
        return TripException('An unexpected error occurred.');

      default:
        return TripException('Failed to connect to server.');
    }
  }
}

/// Custom exception for trip operations
class TripException implements Exception {
  final String message;

  TripException(this.message);

  @override
  String toString() => message;
}
