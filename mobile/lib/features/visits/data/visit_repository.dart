import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/config/app_config.dart';
import 'models/visit_model.dart';

class VisitRepository {
  final Dio _dio;
  final String? _token;

  VisitRepository(this._dio, this._token) {
    if (_token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $_token';
    }
  }

  Future<VisitModel> markVisit({
    required String placeId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.post(
        'visits/mark',
        data: {
          'placeId': placeId,
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      return VisitModel.fromJson(response.data['visit']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 && e.response?.data['error'] != null) {
        throw Exception(e.response?.data['error']);
      }
      throw Exception('Failed to record visit: ${e.message}');
    }
  }

  Future<List<VisitModel>> getUserVisits() async {
     try {
      final response = await _dio.get('visits/my-visits');
      return (response.data['visits'] as List)
          .map((json) => VisitModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch visits');
    }
  }
}
