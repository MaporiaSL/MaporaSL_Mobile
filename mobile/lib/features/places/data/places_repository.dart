import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gemified_travel_portfolio/core/config/app_config.dart';
import '../models/place.dart';

class PlacesRepository {
  final String baseUrl;

  PlacesRepository({String? baseUrl}) 
      : baseUrl = baseUrl ?? '${AppConfig.apiBaseUrl}/api';

  Future<List<Place>> getPlaces({
    int page = 1, 
    int limit = 20, 
    String? search, 
    String? category
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
        if (category != null && category.isNotEmpty) 'category': category,
      };

      final uri = Uri.parse('$baseUrl/places').replace(queryParameters: queryParams);
      debugPrint('Fetching places from: $uri');
      
      final response = await http.get(uri);
      debugPrint('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> placesJson = data['places'];
        return placesJson.map((json) => Place.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load places: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in getPlaces: $e');
      throw Exception('Error fetching places: $e');
    }
  }
}

