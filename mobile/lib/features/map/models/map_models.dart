/// Map models for trip data, GeoJSON, and statistics

/// Trip model
class Trip {
  final String id;
  final String name;
  final String? description;
  final List<Destination>? destinations;

  Trip({
    required this.id,
    required this.name,
    this.description,
    this.destinations,
  });

  Trip copyWith({
    String? id,
    String? name,
    String? description,
    List<Destination>? destinations,
  }) {
    return Trip(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      destinations: destinations ?? this.destinations,
    );
  }
}

/// Destination model
class Destination {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String? district;
  final String? description;
  final DateTime? visitedDate;

  Destination({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.district,
    this.description,
    this.visitedDate,
  });

  Destination copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    String? district,
    String? description,
    DateTime? visitedDate,
  }) {
    return Destination(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      district: district ?? this.district,
      description: description ?? this.description,
      visitedDate: visitedDate ?? this.visitedDate,
    );
  }
}

/// GeoJSON representation of trip
class TripGeoJson {
  final String type;
  final List<GeoJsonFeature> features;

  TripGeoJson({required this.type, required this.features});

  factory TripGeoJson.fromJson(Map<String, dynamic> json) {
    final features =
        (json['features'] as List?)
            ?.map((f) => GeoJsonFeature.fromJson(f as Map<String, dynamic>))
            .toList() ??
        [];
    return TripGeoJson(
      type: json['type'] as String? ?? 'FeatureCollection',
      features: features,
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'features': features.map((f) => f.toJson()).toList()};
  }
}

/// Individual GeoJSON feature
class GeoJsonFeature {
  final String type;
  final Map<String, dynamic> properties;
  final GeoJsonGeometry geometry;

  GeoJsonFeature({
    required this.type,
    required this.properties,
    required this.geometry,
  });

  factory GeoJsonFeature.fromJson(Map<String, dynamic> json) {
    return GeoJsonFeature(
      type: json['type'] as String? ?? 'Feature',
      properties: json['properties'] as Map<String, dynamic>? ?? {},
      geometry: GeoJsonGeometry.fromJson(
        json['geometry'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'properties': properties,
      'geometry': geometry.toJson(),
    };
  }
}

/// GeoJSON geometry
class GeoJsonGeometry {
  final String type;
  final dynamic coordinates;

  GeoJsonGeometry({required this.type, required this.coordinates});

  factory GeoJsonGeometry.fromJson(Map<String, dynamic> json) {
    return GeoJsonGeometry(
      type: json['type'] as String? ?? 'Point',
      coordinates: json['coordinates'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'coordinates': coordinates};
  }
}

/// Trip statistics
class TripStats {
  final String travelId;
  final String? travelName;
  final DestinationStats destinations;
  final GeographyStats geography;
  final MediaStats media;
  final TimelineStats timeline;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TripStats({
    required this.travelId,
    required this.destinations,
    required this.geography,
    required this.media,
    required this.timeline,
    this.travelName,
    this.createdAt,
    this.updatedAt,
  });

  factory TripStats.fromJson(Map<String, dynamic> json) {
    return TripStats(
      travelId: json['travelId'] as String? ?? '',
      travelName: json['travelName'] as String?,
      destinations: DestinationStats.fromJson(
        json['destinations'] as Map<String, dynamic>? ?? {},
      ),
      geography: GeographyStats.fromJson(
        json['geography'] as Map<String, dynamic>? ?? {},
      ),
      media: MediaStats.fromJson(json['media'] as Map<String, dynamic>? ?? {}),
      timeline: TimelineStats.fromJson(
        json['timeline'] as Map<String, dynamic>? ?? {},
      ),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'travelId': travelId,
      'travelName': travelName,
      'destinations': destinations.toJson(),
      'geography': geography.toJson(),
      'media': media.toJson(),
      'timeline': timeline.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  int get completionPercentage => destinations.completionPercentage;
}

class DestinationStats {
  final int total;
  final int visited;
  final int unvisited;
  final int completionPercentage;

  DestinationStats({
    required this.total,
    required this.visited,
    required this.unvisited,
    required this.completionPercentage,
  });

  factory DestinationStats.fromJson(Map<String, dynamic> json) {
    return DestinationStats(
      total: (json['total'] as num?)?.toInt() ?? 0,
      visited: (json['visited'] as num?)?.toInt() ?? 0,
      unvisited: (json['unvisited'] as num?)?.toInt() ?? 0,
      completionPercentage:
          (json['completionPercentage'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'visited': visited,
      'unvisited': unvisited,
      'completionPercentage': completionPercentage,
    };
  }
}

class GeographyStats {
  final double routeDistanceKm;
  final double boundaryAreaKm2;
  final GeoPoint? centerPoint;
  final GeoBounds? bounds;

  GeographyStats({
    required this.routeDistanceKm,
    required this.boundaryAreaKm2,
    this.centerPoint,
    this.bounds,
  });

  factory GeographyStats.fromJson(Map<String, dynamic> json) {
    return GeographyStats(
      routeDistanceKm: (json['routeDistanceKm'] as num?)?.toDouble() ?? 0.0,
      boundaryAreaKm2: (json['boundaryAreaKm2'] as num?)?.toDouble() ?? 0.0,
      centerPoint: json['centerPoint'] is Map<String, dynamic>
          ? GeoPoint.fromJson(json['centerPoint'] as Map<String, dynamic>)
          : null,
      bounds: json['bounds'] is Map<String, dynamic>
          ? GeoBounds.fromJson(json['bounds'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'routeDistanceKm': routeDistanceKm,
      'boundaryAreaKm2': boundaryAreaKm2,
      'centerPoint': centerPoint?.toJson(),
      'bounds': bounds?.toJson(),
    };
  }
}

class MediaStats {
  final int totalPhotos;
  final double averagePhotosPerDestination;

  MediaStats({
    required this.totalPhotos,
    required this.averagePhotosPerDestination,
  });

  factory MediaStats.fromJson(Map<String, dynamic> json) {
    return MediaStats(
      totalPhotos: (json['totalPhotos'] as num?)?.toInt() ?? 0,
      averagePhotosPerDestination:
          (json['averagePhotosPerDestination'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPhotos': totalPhotos,
      'averagePhotosPerDestination': averagePhotosPerDestination,
    };
  }
}

class TimelineStats {
  final DateTime? startDate;
  final DateTime? endDate;
  final int? durationDays;
  final DateTime? firstVisit;
  final DateTime? lastVisit;

  TimelineStats({
    this.startDate,
    this.endDate,
    this.durationDays,
    this.firstVisit,
    this.lastVisit,
  });

  factory TimelineStats.fromJson(Map<String, dynamic> json) {
    return TimelineStats(
      startDate: _parseDate(json['startDate']),
      endDate: _parseDate(json['endDate']),
      durationDays: (json['durationDays'] as num?)?.toInt(),
      firstVisit: _parseDate(json['firstVisit']),
      lastVisit: _parseDate(json['lastVisit']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'durationDays': durationDays,
      'firstVisit': firstVisit?.toIso8601String(),
      'lastVisit': lastVisit?.toIso8601String(),
    };
  }
}

class GeoPoint {
  final double latitude;
  final double longitude;

  GeoPoint({required this.latitude, required this.longitude});

  factory GeoPoint.fromJson(Map<String, dynamic> json) {
    return GeoPoint(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'latitude': latitude, 'longitude': longitude};
  }
}

class GeoBounds {
  final double swLat;
  final double swLng;
  final double neLat;
  final double neLng;

  GeoBounds({
    required this.swLat,
    required this.swLng,
    required this.neLat,
    required this.neLng,
  });

  factory GeoBounds.fromJson(Map<String, dynamic> json) {
    return GeoBounds(
      swLat: (json['swLat'] as num?)?.toDouble() ?? 0.0,
      swLng: (json['swLng'] as num?)?.toDouble() ?? 0.0,
      neLat: (json['neLat'] as num?)?.toDouble() ?? 0.0,
      neLng: (json['neLng'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'swLat': swLat, 'swLng': swLng, 'neLat': neLat, 'neLng': neLng};
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}

/// Trip boundary GeoJSON feature
class TripBoundary {
  final String type;
  final Map<String, dynamic> properties;
  final GeoJsonGeometry geometry;

  TripBoundary({
    required this.type,
    required this.properties,
    required this.geometry,
  });

  factory TripBoundary.fromJson(Map<String, dynamic> json) {
    return TripBoundary(
      type: json['type'] as String? ?? 'Feature',
      properties: json['properties'] as Map<String, dynamic>? ?? {},
      geometry: GeoJsonGeometry.fromJson(
        json['geometry'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'properties': properties,
      'geometry': geometry.toJson(),
    };
  }
}

class NearbyDestinationsResponse {
  final Map<String, dynamic> query;
  final int count;
  final List<NearbyDestinationResult> results;
  final TripGeoJson geojson;

  NearbyDestinationsResponse({
    required this.query,
    required this.count,
    required this.results,
    required this.geojson,
  });

  factory NearbyDestinationsResponse.fromJson(Map<String, dynamic> json) {
    final results =
        (json['results'] as List?)
            ?.map(
              (r) =>
                  NearbyDestinationResult.fromJson(r as Map<String, dynamic>),
            )
            .toList() ??
        [];

    return NearbyDestinationsResponse(
      query: json['query'] as Map<String, dynamic>? ?? {},
      count: (json['count'] as num?)?.toInt() ?? results.length,
      results: results,
      geojson: TripGeoJson.fromJson(
        json['geojson'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class NearbyDestinationResult {
  final Map<String, dynamic> destination;
  final double distanceKm;
  final double? bearing;

  NearbyDestinationResult({
    required this.destination,
    required this.distanceKm,
    this.bearing,
  });

  factory NearbyDestinationResult.fromJson(Map<String, dynamic> json) {
    return NearbyDestinationResult(
      destination: json['destination'] as Map<String, dynamic>? ?? {},
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
      bearing: (json['bearing'] as num?)?.toDouble(),
    );
  }
}

/// Map style configuration
class MapStyleConfig {
  final String name;
  final String url;
  final String description;

  MapStyleConfig({
    required this.name,
    required this.url,
    required this.description,
  });
}
