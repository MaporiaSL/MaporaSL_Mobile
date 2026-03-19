import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

/// Utility class for loading and parsing GeoJSON files
class GeoJsonLoader {
  /// Load Sri Lanka district boundaries from local asset
  /// Returns the parsed GeoJSON as a Map
  static Future<Map<String, dynamic>> loadDistrictBoundaries() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/geojson/geoBoundaries-LKA-ADM1_simplified.geojson',
      );

      final Map<String, dynamic> geojson = json.decode(jsonString);

      // Validate GeoJSON structure
      if (!_isValidGeoJSON(geojson)) {
        throw const FormatException('Invalid GeoJSON structure');
      }

      debugPrint('âœ… Loaded ${geojson['features']?.length ?? 0} district boundaries');

      return geojson;
    } catch (e) {
      debugPrint('âŒ Error loading district boundaries: $e');
      rethrow;
    }
  }

  /// Validate GeoJSON structure
  static bool _isValidGeoJSON(Map<String, dynamic> geojson) {
    return geojson.containsKey('type') &&
        geojson['type'] == 'FeatureCollection' &&
        geojson.containsKey('features') &&
        geojson['features'] is List;
  }

  /// Extract district IDs from GeoJSON features
  static List<String> extractDistrictIds(Map<String, dynamic> geojson) {
    final features = geojson['features'] as List?;
    if (features == null) return [];

    return features
        .map((feature) {
          final properties = feature['properties'] as Map<String, dynamic>?;
          return properties?['shapeName']
              as String?; // or 'district_id' depending on structure
        })
        .where((id) => id != null)
        .cast<String>()
        .toList();
  }
}

