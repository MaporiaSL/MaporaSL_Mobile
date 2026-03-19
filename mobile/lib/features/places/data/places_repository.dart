import 'package:flutter/foundation.dart';
import 'package:gemified_travel_portfolio/core/services/api_client.dart';
import '../models/place.dart';

class PlacesRepository {
  final ApiClient _apiClient;

  PlacesRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<List<Place>> getPlaces({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
        if (category != null && category.isNotEmpty) 'category': category,
      };

      debugPrint('Fetching places with params: $queryParams');

      final response = await _apiClient.get(
        '/places',
        queryParameters: queryParams,
      );

      debugPrint('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final List<dynamic> placesJson = data['places'] ?? [];
        return placesJson
            .map((json) => Place.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load places: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in getPlaces: $e');
      throw Exception('Error fetching places: $e');
    }
  }

  Future<void> submitPlace({
    required String name,
    required String description,
    required String category,
    required String district,
    required double latitude,
    required double longitude,
    String? address,
    List<String>? tags,
    String? difficulty,
    double? entryFee,
    String? wheelchairAccessible,
  }) async {
    try {
      final payload = {
        'name': name,
        'description': description,
        'category': category,
        'province': 'Sri Lanka', // Default
        'districtId': district,
        'latitude': latitude,
        'longitude': longitude,
        if (address != null) 'address': address,
        if (tags != null) 'tags': tags,
        if (difficulty != null) 'difficulty': difficulty,
        if (entryFee != null) 'entryFee': entryFee,
        if (wheelchairAccessible != null)
          'wheelchairAccessible': wheelchairAccessible,
      };

      debugPrint('Submitting place: $payload');

      final response = await _apiClient.post('/places', data: payload);

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to submit place: ${response.statusCode}');
      }

      debugPrint('Place submitted successfully');
    } catch (e) {
      debugPrint('Error in submitPlace: $e');
      throw Exception('Error submitting place: $e');
    }
  }
}
