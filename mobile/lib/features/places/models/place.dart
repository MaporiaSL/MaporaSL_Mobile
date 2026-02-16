class Place {
  final String id;
  final String name;
  final String? description;
  final String? category;
  final String? province;
  final String? district;
  final double latitude;
  final double longitude;
  final String? googleMapsUrl;
  final String? address;
  final double? rating;
  final int? reviewCount;
  final List<String> photos;
  final Map<String, dynamic>? accessibility;
  final List<String> tags;
  final int visitCount;
  final bool isSystemPlace;

  Place({
    required this.id,
    required this.name,
    this.description,
    this.category,
    this.province,
    this.district,
    required this.latitude,
    required this.longitude,
    this.googleMapsUrl,
    this.address,
    this.rating,
    this.reviewCount,
    this.photos = const [],
    this.accessibility,
    this.tags = const [],
    this.visitCount = 0,
    this.isSystemPlace = false,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      category: json['category'],
      province: json['province'],
      district: json['districtId'], // Mapped from backend Schema
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      googleMapsUrl: json['googleMapsUrl'],
      address: json['address'],
      rating: json['rating'] != null ? (json['rating']['average'] ?? 0.0).toDouble() : null,
      reviewCount: json['rating'] != null ? (json['rating']['count'] ?? 0) : null,
      photos: List<String>.from(json['photos'] ?? []),
      accessibility: json['accessibility'],
      tags: List<String>.from(json['tags'] ?? []),
      visitCount: json['visitCount'] ?? 0,
      isSystemPlace: json['isSystemPlace'] ?? false,
    );
  }
}
