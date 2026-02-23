import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import '../../../../features/places/models/place.dart';
import '../../../map/providers/map_provider.dart';

/// Provider to load local places from JSON asset
final localPlacesProvider = FutureProvider<List<Place>>((ref) async {
  try {
    final String response = await rootBundle.loadString('assets/data/curated_places.json');
    final List<dynamic> data = json.decode(response);
    
    final List<Place> places = [];
    for (var item in data) {
      try {
        final Map<String, dynamic> normalized = Map<String, dynamic>.from(item);
        // Map ID
        if (normalized.containsKey('id')) normalized['_id'] = normalized['id'];
        
        // Map District
        if (normalized.containsKey('district')) normalized['districtId'] = normalized['district'];
        
        // Map Rating object
        if (normalized['rating'] is num) {
          normalized['rating'] = {
            'average': (normalized['rating'] as num).toDouble(),
            'reviewCount': normalized['reviewCount'] ?? 0,
          };
        }
        
        places.add(Place.fromJson(normalized));
      } catch (e) {
        // Silent fail for individual malformed items in production
      }
    }
    return places;
  } catch (e) {
    rethrow;
  }
});

/// Distance calculation helper
class DistanceHelper {
  static double calculate(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 - math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) * math.cos(lat2 * p) *
        (1 - math.cos((lon2 - lon1) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a));
  }
}

/// Provider for distances of local places relative to user
final localPlacesWithDistanceProvider = FutureProvider<List<PlaceWithDistance>>((ref) async {
  // Use .future to ensure we have the places list first
  final places = await ref.watch(localPlacesProvider.future);
  
  // Watch location as a value, not a future, so it doesn't block this provider
  final userLocAsync = ref.watch(userLocationProvider.select((v) => v)); // Watch just the value if possible
  
  // Custom logic to get coordinates without blocking the provider's data state
  // This depends on how userLocationProvider is implemented, but if it's a regular provider:
  final userLoc = userLocAsync; 

  final List<PlaceWithDistance> list = places.map((place) {
    double? distance;
    if (userLoc != null) {
      distance = DistanceHelper.calculate(
        userLoc.coordinates.lat.toDouble(),
        userLoc.coordinates.lng.toDouble(),
        place.latitude,
        place.longitude,
      );
    }
    return PlaceWithDistance(place: place, distanceKm: distance);
  }).toList();

  if (userLoc != null) {
    list.sort((a, b) => (a.distanceKm ?? double.infinity).compareTo(b.distanceKm ?? double.infinity));
  }
  return list;
});

class PlaceWithDistance {
  final Place place;
  final double? distanceKm;

  PlaceWithDistance({required this.place, this.distanceKm});
}
