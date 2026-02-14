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
}
