/// Photo location data
class PhotoLocation {
  final double? latitude;
  final double? longitude;
  final String? placeName;

  const PhotoLocation({this.latitude, this.longitude, this.placeName});

  factory PhotoLocation.fromJson(Map<String, dynamic> json) {
    return PhotoLocation(
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      placeName: json['placeName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (placeName != null) 'placeName': placeName,
    };
  }
}

/// Photo model representing a single photo in an album
class PhotoModel {
  final String id;
  final String url;
  final String originalName;
  final String? caption;
  final PhotoLocation? location;
  final DateTime? createdAt;

  const PhotoModel({
    required this.id,
    required this.url,
    required this.originalName,
    this.caption,
    this.location,
    this.createdAt,
  });

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      url: json['url'] as String? ?? '',
      originalName: json['originalName'] as String? ?? '',
      caption: json['caption'] as String?,
      location: json['location'] != null
          ? PhotoLocation.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'originalName': originalName,
      if (caption != null) 'caption': caption,
      if (location != null) 'location': location!.toJson(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  PhotoModel copyWith({
    String? id,
    String? url,
    String? originalName,
    String? caption,
    PhotoLocation? location,
    DateTime? createdAt,
  }) {
    return PhotoModel(
      id: id ?? this.id,
      url: url ?? this.url,
      originalName: originalName ?? this.originalName,
      caption: caption ?? this.caption,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
