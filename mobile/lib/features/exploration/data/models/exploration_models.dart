class ExplorationLocation {
  final String id;
  final String name;
  final String type;
  final double latitude;
  final double longitude;
  final bool visited;
  final String? description;
  final String? category;
  final List<String> photos;

  ExplorationLocation({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.visited,
    this.description,
    this.category,
    this.photos = const [],
  });

  factory ExplorationLocation.fromJson(Map<String, dynamic> json) {
    return ExplorationLocation(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      visited: json['visited'] == true,
      description: json['description']?.toString(),
      category: json['category']?.toString(),
      photos:
          (json['photos'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class DistrictAssignment {
  final String district;
  final String province;
  final int assignedCount;
  final int visitedCount;
  final DateTime? unlockedAt;
  final List<ExplorationLocation> locations;

  DistrictAssignment({
    required this.district,
    required this.province,
    required this.assignedCount,
    required this.visitedCount,
    required this.unlockedAt,
    required this.locations,
  });

  factory DistrictAssignment.fromJson(Map<String, dynamic> json) {
    final locationsRaw = json['locations'] as List<dynamic>? ?? [];
    return DistrictAssignment(
      district: json['district']?.toString() ?? '',
      province: json['province']?.toString() ?? '',
      assignedCount: (json['assignedCount'] as num?)?.toInt() ?? 0,
      visitedCount: (json['visitedCount'] as num?)?.toInt() ?? 0,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.tryParse(json['unlockedAt'].toString())
          : null,
      locations: locationsRaw
          .map(
            (entry) => ExplorationLocation.fromJson(
              Map<String, dynamic>.from(entry as Map),
            ),
          )
          .toList(),
    );
  }
}

class DistrictSummary {
  final String district;
  final String province;
  final int assignedCount;
  final int visitedCount;
  final DateTime? unlockedAt;

  DistrictSummary({
    required this.district,
    required this.province,
    required this.assignedCount,
    required this.visitedCount,
    required this.unlockedAt,
  });

  factory DistrictSummary.fromJson(Map<String, dynamic> json) {
    return DistrictSummary(
      district: json['district']?.toString() ?? '',
      province: json['province']?.toString() ?? '',
      assignedCount: (json['assignedCount'] as num?)?.toInt() ?? 0,
      visitedCount: (json['visitedCount'] as num?)?.toInt() ?? 0,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.tryParse(json['unlockedAt'].toString())
          : null,
    );
  }
}

class LocationSample {
  final double latitude;
  final double longitude;
  final double accuracyMeters;

  LocationSample({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
  });

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'accuracyMeters': accuracyMeters,
  };
}
