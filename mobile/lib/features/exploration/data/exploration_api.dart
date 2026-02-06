import '../../../core/services/api_client.dart';
import 'models/exploration_models.dart';

class ExplorationApi {
  final ApiClient _client;

  ExplorationApi({ApiClient? client}) : _client = client ?? ApiClient();

  Future<List<DistrictAssignment>> fetchAssignments() async {
    final response = await _client.get('/api/exploration/assignments');
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
    final response = await _client.get('/api/exploration/districts');
    final data = response.data as Map<String, dynamic>;
    final list = data['districts'] as List<dynamic>? ?? [];
    return list
        .map(
          (entry) =>
              DistrictSummary.fromJson(Map<String, dynamic>.from(entry as Map)),
        )
        .toList();
  }

  Future<void> visitLocation({
    required String locationId,
    required List<LocationSample> samples,
  }) async {
    await _client.post(
      '/api/exploration/visit',
      data: {
        'locationId': locationId,
        'samples': samples.map((sample) => sample.toJson()).toList(),
      },
    );
  }

  Future<void> rerollAssignments({
    required String reason,
    String? reasonDetail,
  }) async {
    await _client.post(
      '/api/exploration/reroll',
      data: {
        'reason': reason,
        if (reasonDetail != null) 'reasonDetail': reasonDetail,
      },
    );
  }
}
