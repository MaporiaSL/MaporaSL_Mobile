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
    final ratingData = json['rating'];
    final statsData = json['stats'];

    return Place(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      category: json['category'],
      province: json['province'],
      district: (json['district'] ?? json['districtId'])?.toString(),
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      googleMapsUrl: json['googleMapsUrl'],
      address: json['address'],
      rating: ratingData is Map<String, dynamic>
          ? (ratingData['average'] as num?)?.toDouble()
          : (ratingData as num?)?.toDouble(),
      reviewCount: ratingData is Map<String, dynamic>
          ? (ratingData['reviewCount'] as num?)?.toInt()
          : null,
      photos: List<String>.from(json['photos'] ?? []),
      accessibility: json['accessibility'],
      tags: List<String>.from(json['tags'] ?? []),
      visitCount:
          (json['visitCount'] as num?)?.toInt() ??
          (statsData is Map<String, dynamic>
              ? (statsData['visitCount'] as num?)?.toInt() ?? 0
              : 0),
      isSystemPlace: json['isSystemPlace'] ?? false,
    );
  }
}
