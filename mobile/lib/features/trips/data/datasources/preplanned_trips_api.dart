import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../models/preplanned_trip_model.dart';
import '../models/trip_model.dart';

/// API client for pre-planned (template) trips
class PrePlannedTripsApi {
  final Dio _dio;
  final String baseUrl;

  PrePlannedTripsApi({required Dio dio, String? baseUrl})
    : _dio = dio,
      baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  /// GET /api/preplanned-trips
  Future<List<PrePlannedTripModel>> fetchTemplates({
    String? duration,
    String? type,
    String? startingPoint,
    String? difficulty,
    List<String>? tags,
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      final response = await _dio.get(
        '$baseUrl/api/preplanned-trips',
        queryParameters: {
          if (duration != null) 'duration': duration,
          if (type != null) 'type': type,
          if (startingPoint != null) 'start': startingPoint,
          if (difficulty != null) 'difficulty': difficulty,
          if (tags != null && tags.isNotEmpty) 'tags': tags.join(','),
          'limit': limit,
          'skip': skip,
        },
      );

      final templates =
          response.data['trips'] as List? ?? response.data as List;
      return templates
          .map(
            (json) => PrePlannedTripModel.fromJson(
              Map<String, dynamic>.from(json as Map<String, dynamic>),
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /api/preplanned/:id
  Future<PrePlannedTripModel> fetchTemplateById(String id) async {
    try {
      final response = await _dio.get('$baseUrl/api/preplanned/$id');
      final map = Map<String, dynamic>.from(
        response.data as Map<String, dynamic>,
      );
      return PrePlannedTripModel.fromJson(map);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /api/preplanned/:id/clone
  /// Creates a Travel + Destinations from template
  Future<TripModel> cloneTemplate({
    required String templateId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/preplanned/$templateId/clone',
        data: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );

      final map = Map<String, dynamic>.from(
        response.data as Map<String, dynamic>,
      );
      if (map.containsKey('_id')) map['id'] = map['_id'].toString();
      return TripModel.fromJson(map);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    final message =
        e.response?.data is Map &&
            (e.response!.data as Map).containsKey('error')
        ? e.response!.data['error'].toString()
        : e.message ?? 'Unknown error';
    return Exception('Pre-planned trips error: $message');
  }
}
