import '../../../core/services/api_client.dart';
import 'models/visit_model.dart';

class VisitRepository {
  final ApiClient _client;

  VisitRepository(this._client);

  Future<VisitModel> markVisit({
    required String placeId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _client.post(
        '/api/visits/mark',
        data: {
          'placeId': placeId,
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      return VisitModel.fromJson(response.data['visit']);
    } catch (e) {
      throw Exception('Failed to record visit: $e');
    }
  }

  Future<List<VisitModel>> getUserVisits() async {
     try {
      final response = await _client.get('/api/visits/my-visits');
      return (response.data['visits'] as List)
          .map((json) => VisitModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch visits');
    }
  }
}
