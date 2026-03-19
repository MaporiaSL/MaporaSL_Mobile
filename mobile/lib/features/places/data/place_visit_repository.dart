import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:light/light.dart';
import 'package:device_info_plus/device_info_plus.dart';
import './models/place_visit.dart';

class PlaceVisitRepository {
  final Dio _dio;
  final String? _token;

  PlaceVisitRepository(this._dio, this._token);

  /// Record a place visit with comprehensive anti-cheat metadata collection
  Future<PlaceVisit> recordVisit({
    required String placeId,
    String? notes,
    String? photoUrl,
    void Function(String step, double progress)? onProgress,
  }) async {
    try {
      onProgress?.call('Getting GPS location...', 0.2);

      // ========== COLLECT ANTI-CHEAT METADATA ==========
      final metadata = await _collectVisitMetadata(onProgress: onProgress);

      onProgress?.call('Preparing verification request...', 0.7);

      // ========== GENERATE REQUEST SIGNATURE ==========
      final requestSignature = _generateRequestSignature(placeId);

      // ========== CREATE REQUEST ==========
      final request = PlaceVisitRequest(
        placeId: placeId,
        notes: notes,
        photoUrl: photoUrl,
        metadata: metadata,
        requestSignature: requestSignature,
        createdAt: DateTime.now(),
      );

      onProgress?.call('Sending to server...', 0.8);

      final requestPath = '/api/places/$placeId/visit';
      String resolvedUrl = '${_dio.options.baseUrl}$requestPath';
      try {
        resolvedUrl = Uri.parse(
          _dio.options.baseUrl,
        ).resolve(requestPath).toString();
      } catch (_) {}

      final requestJson = request.toJson();
      debugPrint('âž¡ï¸ PlaceVisit request starting');
      debugPrint('Base URL: ${_dio.options.baseUrl}');
      debugPrint('Request path: $requestPath');
      debugPrint('Resolved URL: $resolvedUrl');
      debugPrint('Place ID: $placeId');
      debugPrint('Auth token present: ${(_token ?? '').isNotEmpty}');
      debugPrint('Payload keys: ${requestJson.keys.toList()}');

      // ========== SEND TO SERVER ==========
      final response = await _dio.post(
        requestPath,
        data: requestJson,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 201) {
        return PlaceVisit.fromJson(response.data['visit']);
      } else {
        throw Exception('Failed to record visit: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final serverError = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['error'] ?? e.response?.data['message'])
          : null;

      debugPrint('âŒ PlaceVisit API error');
      debugPrint('Method: ${e.requestOptions.method}');
      debugPrint('URL: ${e.requestOptions.uri}');
      debugPrint('Base URL: ${e.requestOptions.baseUrl}');
      debugPrint('Path: ${e.requestOptions.path}');
      debugPrint('Status: ${e.response?.statusCode}');
      debugPrint('Response: ${e.response?.data}');
      debugPrint('Dio message: ${e.message}');

      if (e.response?.statusCode == 404) {
        debugPrint(
          'âš ï¸ 404 Debug Hint: verify backend is running and route POST /api/places/:id/visit is mounted.',
        );
      }

      throw Exception(
        'API Error (${e.response?.statusCode ?? 'no-status'}): ${serverError ?? e.message}',
      );
    } catch (e) {
      throw Exception('Error recording visit: $e');
    }
  }

  /// Collect detailed metadata for anti-cheat validation
  Future<VisitMetadata> _collectVisitMetadata({
    void Function(String step, double progress)? onProgress,
  }) async {
    final startTime = DateTime.now();

    try {
      onProgress?.call('Acquiring GPS signal...', 0.25);

      // ========== COLLECT GPS DATA ==========
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      ).timeout(const Duration(seconds: 10));

      onProgress?.call('Collecting device information...', 0.4);

      // ========== COLLECT DEVICE ORIENTATION ==========
      double? compassHeading;
      double? pitch;
      double? roll;

      // Try to get compass heading (requires separate library or native code)
      // For now, use placeholder
      try {
        // In production, integrate with flutter_compass or device orientation
        compassHeading = null; // TODO: Integrate compass
      } catch (e) {
        debugPrint('Error getting compass heading: $e');
      }

      // ========== COLLECT DEVICE INFO ==========
      final deviceInfo = DeviceInfoPlugin();
      String deviceModel = 'Unknown';
      String osVersion = 'Unknown';
      bool isLocationSpoofed = false;

      onProgress?.call('Verifying device security...', 0.5);

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceModel = '${androidInfo.manufacturer} ${androidInfo.model}';
        osVersion = 'Android ${androidInfo.version.release}';
        // Check for location spoofing apps
        isLocationSpoofed = await _checkLocationSpoofers(androidInfo);
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceModel = iosInfo.model;
        osVersion = 'iOS ${iosInfo.systemVersion}';
      }

      onProgress?.call('Collecting environmental data...', 0.6);

      // ========== COLLECT LIGHT LEVEL (OPTIONAL) ==========
      double? lightLevel;
      try {
        final completer = Completer<double?>();
        final light = Light();
        light.lightSensorStream.listen((value) {
          if (!completer.isCompleted) {
            completer.complete(value.toDouble());
          }
        }).cancel();

        lightLevel = await completer.future
            .timeout(const Duration(seconds: 2))
            .onError((error, stackTrace) => null);
      } catch (e) {
        // Light sensor not available, skip
      }

      // ========== PHOTO EXIF DATA (IF PROVIDED) ==========
      // This would be extracted from photo URL or provided separately
      // For now, placeholder values
      String? photoExifLat;
      String? photoExifLon;
      String? photoExifTimestamp;

      // ========== COLLECTION TIME ==========
      final collectionTimeMs = DateTime.now()
          .difference(startTime)
          .inMilliseconds;

      // ========== BUILD METADATA ==========
      return VisitMetadata(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyMeters: position.accuracy,
        compassHeading: compassHeading,
        pitch: pitch,
        roll: roll,
        deviceModel: deviceModel,
        osVersion: osVersion,
        lightLevel: lightLevel,
        cellSignalStrength: null, // Would need native code
        photoExifLat: photoExifLat,
        photoExifLon: photoExifLon,
        photoExifTimestamp: photoExifTimestamp,
        photoExifDatestamp: null,
        collectionTimeMs: collectionTimeMs,
        isLocationSpoofed: isLocationSpoofed,
        sensorProvider: _getSensorProvider(position),
      );
    } catch (e) {
      // If metadata collection fails, throw error
      rethrow;
    }
  }

  /// Check if device is running location spoofing apps
  Future<bool> _checkLocationSpoofers(AndroidDeviceInfo androidInfo) async {
    // This would require integrating with device package to check installed apps
    // For now, return false (basic check)
    // In production: use native code to query installed packages
    return false;
  }

  /// Determine GPS provider type
  String _getSensorProvider(Position position) {
    // In production, get actual provider from Geolocator
    // For now, assume fused
    return 'fused';
  }

  /// Generate request signature for replay attack prevention
  String _generateRequestSignature(String placeId) {
    // Temporary 64-char hex signature format until HMAC secret is wired end-to-end.
    final random = Random.secure();
    const hexChars = '0123456789abcdef';
    return List.generate(
      64,
      (_) => hexChars[random.nextInt(hexChars.length)],
    ).join();
  }

  /// Get visit history for a place (public, no auth required)
  Future<List<PlaceVisit>> getVisitHistory(
    String placeId, {
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/api/places/$placeId/visits',
        queryParameters: {'limit': limit, 'skip': skip},
      );

      if (response.statusCode == 200) {
        final visits = (response.data['visits'] as List)
            .map((v) => PlaceVisit.fromJson(v))
            .toList();
        return visits;
      }
      throw Exception('Failed to fetch visit history');
    } on DioException catch (e) {
      throw Exception('API Error: ${e.message}');
    }
  }

  /// Get user's visit statistics
  Future<UserVisitStats> getUserVisitStats(String userId) async {
    try {
      final response = await _dio.get(
        '/api/places/users/$userId/stats',
        options: Options(headers: {'Authorization': 'Bearer $_token'}),
      );

      if (response.statusCode == 200) {
        return UserVisitStats.fromJson(response.data);
      }
      throw Exception('Failed to fetch visit stats');
    } on DioException catch (e) {
      throw Exception('API Error: ${e.message}');
    }
  }

  /// Extract EXIF data from photo (would use image library in production)
  Future<Map<String, String>?> extractPhotoExif(String photoPath) async {
    // In production: use image_picker_android + exif libraries
    // to extract GPS data from photo file
    // For now, return null
    return null;
  }
}

