import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/album_model.dart';
import '../models/photo_model.dart';

/// Simple service class for all album operations
class AlbumService {
  static final AlbumService _instance = AlbumService._internal();
  factory AlbumService() => _instance;
  AlbumService._internal();

  final Dio _dio = Dio();
  final String baseUrl = 'http://10.0.2.2:5000/api';

  /// Get all albums
  Future<List<AlbumModel>> getAlbums() async {
    try {
      final response = await _dio.get('$baseUrl/albums');
      final albums = response.data['albums'] as List;
      return albums
          .map((json) => AlbumModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      throw Exception('Failed to load albums: $e');
    }
  }

  /// Get single album with photos
  Future<AlbumModel> getAlbum(String id) async {
    try {
      final response = await _dio.get('$baseUrl/albums/$id');
      return AlbumModel.fromJson(
        Map<String, dynamic>.from(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      throw Exception('Failed to load album: $e');
    }
  }

  /// Create new album
  Future<AlbumModel> createAlbum(String name, {String? description}) async {
    try {
      final response = await _dio.post(
        '$baseUrl/albums',
        data: {
          'name': name,
          if (description != null) 'description': description,
        },
      );
      return AlbumModel.fromJson(
        Map<String, dynamic>.from(response.data['album']),
      );
    } catch (e) {
      throw Exception('Failed to create album: $e');
    }
  }

  /// Delete album
  Future<void> deleteAlbum(String id) async {
    try {
      await _dio.delete('$baseUrl/albums/$id');
    } catch (e) {
      throw Exception('Failed to delete album: $e');
    }
  }

  /// Find or create album by location name
  Future<AlbumModel> findOrCreateAlbumByLocation(String locationName) async {
    try {
      final response = await _dio.post(
        '$baseUrl/albums/find-or-create',
        data: {'locationName': locationName},
      );
      return AlbumModel.fromJson(
        Map<String, dynamic>.from(response.data['album']),
      );
    } catch (e) {
      throw Exception('Failed to find/create album: $e');
    }
  }

  /// Upload photo to album
  Future<PhotoModel> uploadPhoto(
    String albumId,
    File photoFile, {
    String? caption,
    double? latitude,
    double? longitude,
    String? placeName,
  }) async {
    try {
      final fileName = photoFile.path.split('/').last;
      final extension = fileName.split('.').last.toLowerCase();

      String mimeType = 'image/jpeg';
      if (extension == 'png') mimeType = 'image/png';
      if (extension == 'gif') mimeType = 'image/gif';
      if (extension == 'webp') mimeType = 'image/webp';

      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          photoFile.path,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
        if (caption != null) 'caption': caption,
        if (latitude != null) 'latitude': latitude.toString(),
        if (longitude != null) 'longitude': longitude.toString(),
        if (placeName != null) 'placeName': placeName,
      });

      final response = await _dio.post(
        '$baseUrl/albums/$albumId/photos',
        data: formData,
      );

      return PhotoModel.fromJson(
        Map<String, dynamic>.from(response.data['photo']),
      );
    } catch (e) {
      throw Exception('Failed to upload photo: $e');
    }
  }

  /// Delete photo from album
  Future<void> deletePhoto(String albumId, String photoId) async {
    try {
      await _dio.delete('$baseUrl/albums/$albumId/photos/$photoId');
    } catch (e) {
      throw Exception('Failed to delete photo: $e');
    }
  }

  /// Get current location
  Future<Position> getCurrentLocation() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) throw Exception('Location services are disabled');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return Geolocator.getCurrentPosition();
  }

  /// Get location name from coordinates
  Future<String?> getLocationName(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return place.locality ??
            place.subAdministrativeArea ??
            place.administrativeArea ??
            'Unknown Location';
      }
    } catch (e) {
      // Geocoding failed
    }
    return null;
  }
}
