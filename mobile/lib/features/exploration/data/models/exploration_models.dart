enum VerificationStatus {
  none,
  verifying,
  passed,
  failed,
}

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
  final VerificationStatus status;
  final String? rejectionReason;

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
    this.status = VerificationStatus.none,
    this.rejectionReason,
  });

  factory ExplorationLocation.fromJson(Map<String, dynamic> json) {
    final visited = json['visited'] == true;
    return ExplorationLocation(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      visited: visited,
      description: json['description']?.toString(),
      category: json['category']?.toString(),
      photos:
          (json['photos'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      status: visited ? VerificationStatus.passed : VerificationStatus.none,
    );
  }

  ExplorationLocation copyWith({
    VerificationStatus? status,
    String? rejectionReason,
    bool? visited,
  }) {
    return ExplorationLocation(
      id: id,
      name: name,
      type: type,
      latitude: latitude,
      longitude: longitude,
      visited: visited ?? this.visited,
      description: description,
      category: category,
      photos: photos,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}

class DistrictAssignment {
  final String district;
  final String province;
  final int assignedCount;
  final int visitedCount;
  final DateTime? unlockedAt;
  final bool isUnlocked;
  final GeoPoint? center;
  final GeoBounds? bounds;
  final List<ExplorationLocation> locations;

  DistrictAssignment({
    required this.district,
    required this.province,
    required this.assignedCount,
    required this.visitedCount,
    required this.unlockedAt,
    required this.isUnlocked,
    this.center,
    this.bounds,
    required this.locations,
  });

  DistrictAssignment copyWith({
    List<ExplorationLocation>? locations,
    int? visitedCount,
    DateTime? unlockedAt,
    bool? isUnlocked,
  }) {
    return DistrictAssignment(
      district: district,
      province: province,
      assignedCount: assignedCount,
      visitedCount: visitedCount ?? this.visitedCount,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      center: center,
      bounds: bounds,
      locations: locations ?? this.locations,
    );
  }

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
      isUnlocked: json['isUnlocked'] == true,
      center: json['center'] is Map<String, dynamic>
          ? GeoPoint.fromJson(Map<String, dynamic>.from(json['center'] as Map))
          : null,
      bounds: json['bounds'] is Map<String, dynamic>
          ? GeoBounds.fromJson(Map<String, dynamic>.from(json['bounds'] as Map))
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

  DistrictAssignment updateLocationStatus(String locationId, VerificationStatus status, String? reason) {
    final updatedLocations = locations.map((loc) {
      if (loc.id == locationId) {
        return loc.copyWith(
          status: status,
          rejectionReason: reason,
          visited: status == VerificationStatus.passed,
        );
      }
      return loc;
    }).toList();
    
    return copyWith(
      locations: updatedLocations,
      visitedCount: updatedLocations.where((l) => l.visited).length,
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

class GeoPoint {
  final double latitude;
  final double longitude;

  const GeoPoint({required this.latitude, required this.longitude});

  factory GeoPoint.fromJson(Map<String, dynamic> json) {
    return GeoPoint(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
    );
  }
}

class GeoBounds {
  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;

  const GeoBounds({
    required this.minLat,
    required this.maxLat,
    required this.minLng,
    required this.maxLng,
  });

  factory GeoBounds.fromJson(Map<String, dynamic> json) {
    return GeoBounds(
      minLat: (json['minLat'] as num?)?.toDouble() ?? 0,
      maxLat: (json['maxLat'] as num?)?.toDouble() ?? 0,
      minLng: (json['minLng'] as num?)?.toDouble() ?? 0,
      maxLng: (json['maxLng'] as num?)?.toDouble() ?? 0,
    );
  }
}
