class TripGeoJson {
  final String type;
  final TripGeoJsonProperties properties;
  final List<Map<String, dynamic>> features;

  const TripGeoJson({
    this.type = 'FeatureCollection',
    required this.properties,
    required this.features,
  });

  factory TripGeoJson.fromJson(Map<String, dynamic> json) {
    final propsJson = json['properties'] as Map<String, dynamic>?;
    final featuresJson = json['features'] as List<dynamic>? ?? const [];

    return TripGeoJson(
      type: json['type']?.toString() ?? 'FeatureCollection',
      properties: TripGeoJsonProperties.fromJson(propsJson),
      features: featuresJson.whereType<Map<String, dynamic>>().toList(
        growable: false,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'properties': properties.toJson(),
      'features': features,
    };
  }
}

class TripGeoJsonProperties {
  final int destinationCount;
  final Map<String, dynamic> extra;

  const TripGeoJsonProperties({
    this.destinationCount = 0,
    this.extra = const {},
  });

  factory TripGeoJsonProperties.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const TripGeoJsonProperties();
    }

    final count = json['destinationCount'];
    return TripGeoJsonProperties(destinationCount: _toInt(count), extra: json);
  }

  Map<String, dynamic> toJson() {
    if (extra.isNotEmpty) {
      return {...extra, 'destinationCount': destinationCount};
    }
    return {'destinationCount': destinationCount};
  }
}

class TripBoundary {
  final Map<String, dynamic> data;

  const TripBoundary({required this.data});

  factory TripBoundary.fromJson(Map<String, dynamic> json) {
    return TripBoundary(data: json);
  }

  Map<String, dynamic> toJson() => data;
}

class TripStats {
  final TripStatsGeography geography;
  final Map<String, dynamic> extra;

  const TripStats({required this.geography, this.extra = const {}});

  factory TripStats.fromJson(Map<String, dynamic> json) {
    final geographyJson = json['geography'] as Map<String, dynamic>?;
    return TripStats(
      geography: TripStatsGeography.fromJson(geographyJson),
      extra: json,
    );
  }

  Map<String, dynamic> toJson() => extra;
}

class TripStatsGeography {
  final double routeDistanceKm;

  const TripStatsGeography({this.routeDistanceKm = 0});

  factory TripStatsGeography.fromJson(Map<String, dynamic>? json) {
    return TripStatsGeography(
      routeDistanceKm: _toDouble(json?['routeDistanceKm']),
    );
  }

  Map<String, dynamic> toJson() => {'routeDistanceKm': routeDistanceKm};
}

class DestinationDetail {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final bool visited;
  final String? districtId;
  final String? travelId;

  const DestinationDetail({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.visited = false,
    this.districtId,
    this.travelId,
  });

  factory DestinationDetail.fromJson(Map<String, dynamic> json) {
    return DestinationDetail(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      visited: json['visited'] == true,
      districtId: json['districtId']?.toString(),
      travelId: json['travelId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
    'visited': visited,
    if (districtId != null) 'districtId': districtId,
    if (travelId != null) 'travelId': travelId,
  };
}

class NearbyDestinationsResponse {
  final List<DestinationDetail> destinations;
  final int total;

  const NearbyDestinationsResponse({
    required this.destinations,
    required this.total,
  });

  factory NearbyDestinationsResponse.fromJson(Map<String, dynamic> json) {
    final list = json['destinations'] as List<dynamic>? ?? const [];
    return NearbyDestinationsResponse(
      destinations: list
          .whereType<Map<String, dynamic>>()
          .map(DestinationDetail.fromJson)
          .toList(growable: false),
      total: _toInt(json['total']),
    );
  }

  Map<String, dynamic> toJson() => {
    'destinations': destinations.map((d) => d.toJson()).toList(),
    'total': total,
  };
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _toDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0.0;
}
