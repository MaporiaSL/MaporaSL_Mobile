import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemified_travel_portfolio/core/services/api_client.dart';
import '../models/place.dart';

class PlacesPage {
  final List<Place> places;
  final int currentPage;
  final int totalPages;
  final int totalPlaces;

  const PlacesPage({
    required this.places,
    required this.currentPage,
    required this.totalPages,
    required this.totalPlaces,
  });

  bool get hasMore => currentPage < totalPages;
}

class PlacesRepository {
  final ApiClient _apiClient;

  PlacesRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<List<Place>> getPlaces({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
    String? district,
  }) async {
    final pageData = await getPlacesPage(
      page: page,
      limit: limit,
      search: search,
      category: category,
      district: district,
    );
    return pageData.places;
  }

  Future<PlacesPage> getPlacesPage({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
    String? district,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
        if (category != null && category.isNotEmpty) 'category': category,
        if (district != null && district.isNotEmpty) 'district': district,
      };

      print('------------------------------------------------------------');
      print(r'$$$ [PLACES REPO] FETCHING PLACES...');
      print(r'$$$ [PLACES REPO] PARAMS: ' + queryParams.toString());

      final response = await _apiClient.get(
        '/api/places',
        queryParameters: queryParams,
      );

      print(r'$$$ [PLACES REPO] REQUEST URI: ' + response.requestOptions.uri.toString());
      print(r'$$$ [PLACES REPO] RESPONSE STATUS: ' + response.statusCode.toString());

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        print(r'$$$ [PLACES REPO] RAW API DATA: ' + data.toString());
        
        final List<dynamic> placesJson = data['places'] ?? [];
        print(r'$$$ [PLACES REPO] MAPPED ' + placesJson.length.toString() + ' PLACES FROM JSON.');
        print('------------------------------------------------------------');
        
        final places = placesJson
            .map((json) => Place.fromJson(json as Map<String, dynamic>))
            .toList();

        int parseInt(dynamic value, int fallback) {
          if (value == null) return fallback;
          if (value is num) return value.toInt();
          if (value is String) return int.tryParse(value) ?? fallback;
          return fallback;
        }

        return PlacesPage(
          places: places,
          currentPage: parseInt(data['currentPage'], page),
          totalPages: parseInt(data['totalPages'], page),
          totalPlaces: parseInt(data['totalPlaces'], places.length),
        );
      }

      throw Exception('Failed to load places: ${response.statusCode}');
    } catch (e) {
      print(r'$$$ [PLACES REPO] ERROR IN getPlacesPage: ' + e.toString());
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

      final response = await _apiClient.post('/api/places', data: payload);

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to submit place: ${response.statusCode}');
      }

      debugPrint('Place submitted successfully');
    } catch (e) {
      debugPrint('Error in submitPlace: $e');
      throw Exception('Error submitting place: $e');
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final response = await _apiClient.get('/api/places/stats');
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final List<dynamic> byCategory = data['byCategory'] ?? [];
        return byCategory
            .map((c) => (c['_id'] as String?) ?? 'other')
            .where((c) => c != null)
            .toSet() // Remove duplicates
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error in getCategories: $e');
      return [];
    }
  }
}

final placesRepositoryProvider = Provider<PlacesRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PlacesRepository(apiClient: apiClient);
});
