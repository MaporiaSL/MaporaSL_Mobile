import 'photo_model.dart';

/// Album model representing a photo album
class AlbumModel {
  final String id;
  final String name;
  final String? description;
  final String? coverPhotoUrl;
  final List<String> tags;
  final String? districtId;
  final String? provinceId;
  final int photoCount;
  final List<PhotoModel>? photos;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AlbumModel({
    required this.id,
    required this.name,
    this.description,
    this.coverPhotoUrl,
    this.tags = const [],
    this.districtId,
    this.provinceId,
    this.photoCount = 0,
    this.photos,
    this.createdAt,
    this.updatedAt,
  });

  factory AlbumModel.fromJson(Map<String, dynamic> json) {
    return AlbumModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      coverPhotoUrl: json['coverPhotoUrl'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      districtId: json['districtId'] as String?,
      provinceId: json['provinceId'] as String?,
      photoCount: json['photoCount'] as int? ?? 0,
      photos: json['photos'] != null
          ? (json['photos'] as List<dynamic>)
                .map((p) => PhotoModel.fromJson(p as Map<String, dynamic>))
                .toList()
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (coverPhotoUrl != null) 'coverPhotoUrl': coverPhotoUrl,
      'tags': tags,
      if (districtId != null) 'districtId': districtId,
      if (provinceId != null) 'provinceId': provinceId,
      'photoCount': photoCount,
      if (photos != null) 'photos': photos!.map((p) => p.toJson()).toList(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}
