import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_client.dart';
import '../models/timeline_event.dart';

class TimelineService {
  final ApiClient _apiClient;

  TimelineService(this._apiClient);

  Future<List<TimelineEvent>> getUserTimeline(String userId) async {
    try {
      final response = await _apiClient.get('/users/$userId/timeline');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['timeline'] ?? [];
        return data
            .map((json) => TimelineEvent.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load timeline events');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error parsing timeline: $e');
    }
  }
}

final timelineServiceProvider = Provider<TimelineService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TimelineService(apiClient);
});
