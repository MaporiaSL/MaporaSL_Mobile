import 'package:dio/dio.dart';
import '../../../core/config/app_config.dart';
import 'models/exploration_models.dart';

class ExplorationApi {
  final Dio _dio;

  ExplorationApi({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConfig.apiBaseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
              ),
            );

  Future<List<DistrictAssignment>> fetchAssignments() async {
    final response = await _dio.get('/api/exploration/assignments');
    final data = response.data as Map<String, dynamic>;
    final list = data['assignments'] as List<dynamic>? ?? [];
    return list
        .map(
          (entry) => DistrictAssignment.fromJson(
            Map<String, dynamic>.from(entry as Map),
          ),
        )
        .toList();
  }

  Future<List<DistrictSummary>> fetchDistricts() async {
    final response = await _dio.get('/api/exploration/districts');
    final data = response.data as Map<String, dynamic>;
    final list = data['districts'] as List<dynamic>? ?? [];
    return list
        .map(
          (entry) => DistrictSummary.fromJson(
            Map<String, dynamic>.from(entry as Map),
          ),
        )
        .toList();
  }

  Future<void> visitLocation({
    required String locationId,
    required List<LocationSample> samples,
  }) async {
    await _dio.post('/api/exploration/visit', data: {
      'locationId': locationId,
      'samples': samples.map((sample) => sample.toJson()).toList(),
    });
  }

  Future<void> rerollAssignments({
    required String reason,
    String? reasonDetail,
  }) async {
    await _dio.post('/api/exploration/reroll', data: {
      'reason': reason,
      if (reasonDetail != null) 'reasonDetail': reasonDetail,
    });
  }
}
