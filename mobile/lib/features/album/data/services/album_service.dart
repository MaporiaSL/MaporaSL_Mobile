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
}

