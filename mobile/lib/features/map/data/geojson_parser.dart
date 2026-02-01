import 'dart:convert';
import 'package:flutter/services.dart';

/// Parses GeoJSON boundary data
class GeoJsonParser {
  /// Load and parse province boundaries from GeoJSON file
  static Future<Map<String, List<List<Offset>>>>
  loadProvinceBoundaries() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/geojson/geoBoundaries-LKA-ADM1_simplified.geojson',
      );
      final Map<String, dynamic> geoJson = jsonDecode(jsonString);
      final features = geoJson['features'] as List<dynamic>;

      final boundaries = <String, List<List<Offset>>>{};

      for (final feature in features) {
        final properties = feature['properties'] as Map<String, dynamic>;
        final shapeName = properties['shapeName'] as String?;
        final geometry = feature['geometry'] as Map<String, dynamic>;

        if (shapeName != null) {
          boundaries[shapeName] = _parseGeometry(geometry);
        }
      }

      return boundaries;
    } catch (e) {
      print('Error loading GeoJSON: $e');
      return {};
    }
  }

  /// Parse geometry coordinates from GeoJSON geometry object
  static List<List<Offset>> _parseGeometry(Map<String, dynamic> geometry) {
    final type = geometry['type'] as String;
    final coordinates = geometry['coordinates'] as List<dynamic>;

    final polygons = <List<Offset>>[];

    if (type == 'Polygon') {
      for (final ring in coordinates) {
        polygons.add(_coordsToOffsets(ring as List<dynamic>));
      }
    } else if (type == 'MultiPolygon') {
      for (final polygon in coordinates) {
        for (final ring in polygon as List<dynamic>) {
          polygons.add(_coordsToOffsets(ring as List<dynamic>));
        }
      }
    }

    return polygons;
  }

  /// Convert [lon, lat] coordinate pairs to Offset objects
  static List<Offset> _coordsToOffsets(List<dynamic> coords) {
    final offsets = <Offset>[];
    for (final coord in coords) {
      final list = coord as List<dynamic>;
      final lon = (list[0] as num).toDouble();
      final lat = (list[1] as num).toDouble();
      offsets.add(Offset(lon, lat));
    }
    return offsets;
  }
}
