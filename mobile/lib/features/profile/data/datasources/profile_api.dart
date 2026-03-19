import 'package:dio/dio.dart';

class ProfileApi {
  final Dio _dio;

  ProfileApi({required Dio dio}) : _dio = dio;

  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await _dio.get('/api/profile/$userId');
      if (response.statusCode == 200) return response.data;
      throw Exception('Failed to fetch profile: ${response.statusCode}');
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  Future<List<dynamic>> getUserContributions(String userId) async {
    try {
      final response = await _dio.get('/api/profile/$userId/contributions');
      if (response.statusCode == 200) return response.data['contributions'] ?? [];
      throw Exception('Failed to fetch contributions: ${response.statusCode}');
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error fetching contributions: $e');
    }
  }

  Future<Map<String, dynamic>> updateProfile(
    String userId, {
    String? name,
    String? avatarUrl,
    String? bio,
    String? hometownDistrict,
    String? preferredLanguage,
    List<String>? travelInterests,
  }) async {
    try {
      final payload = <String, dynamic>{
        if (name != null) 'name': name,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (bio != null) 'bio': bio,
        if (hometownDistrict != null) 'hometownDistrict': hometownDistrict,
        if (preferredLanguage != null) 'preferredLanguage': preferredLanguage,
        if (travelInterests != null) 'travelInterests': travelInterests,
      };
      final response = await _dio.post('/api/profile/$userId', data: payload);
      if (response.statusCode == 200) return response.data;
      throw Exception('Failed to update profile: ${response.statusCode}');
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }

  Future<String> uploadAvatar(String userId, String filePath) async {
    try {
      final filename = filePath.split(RegExp(r'[\\/]+')).last;
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(filePath, filename: filename),
      });
      final response = await _dio.post(
        '/api/profile/$userId/avatar',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      if (response.statusCode == 200) return response.data['avatarUrl'] as String;
      throw Exception('Failed to upload avatar: ${response.statusCode}');
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error uploading avatar: $e');
    }
  }

  Future<void> logout() async {
    try {
      final response = await _dio.post('/api/auth/logout');
      if (response.statusCode != 200) throw Exception('Failed to logout: ${response.statusCode}');
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error during logout: $e');
    }
  }

  Future<List<dynamic>> getTopContributors({int limit = 10}) async {
    try {
      final response = await _dio.get('/api/profile/leaderboard/top', queryParameters: {'limit': limit});
      if (response.statusCode == 200) return response.data['topContributors'] ?? [];
      throw Exception('Failed to fetch leaderboard: ${response.statusCode}');
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error fetching leaderboard: $e');
    }
  }

  Future<void> submitPlaceContribution({
    required String placeName,
    required String description,
    required String category,
    required String province,
    required String district,
    required double latitude,
    required double longitude,
    required List<String> photoPaths,
  }) async {
    try {
      final photos = <MultipartFile>[];
      for (final filePath in photoPaths) {
        final filename = filePath.split(RegExp(r'[\\/]+')).last;
        photos.add(await MultipartFile.fromFile(filePath, filename: filename));
      }

      final formData = FormData.fromMap({
        'placeName': placeName,
        'description': description,
        'category': category,
        'province': province,
        'district': district,
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'photos': photos,
      });

      final response = await _dio.post(
        '/api/places/submit',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200 || response.statusCode == 201) return;
      throw Exception('Failed to submit place: ${response.statusCode}');
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error submitting place: $e');
    }
  }

  Future<List<dynamic>> getPendingSubmissions() async {
    try {
      final response = await _dio.get('/api/places/submissions/pending');
      if (response.statusCode == 200) return response.data['submissions'] ?? [];
      throw Exception('Failed to fetch pending submissions: ${response.statusCode}');
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error fetching pending submissions: $e');
    }
  }

  Future<Map<String, dynamic>> reviewSubmission({
    required String submissionId,
    required bool approve,
    String? rejectionReason,
  }) async {
    try {
      final response = await _dio.patch(
        '/api/places/submissions/$submissionId/review',
        data: {
          'status': approve ? 'approved' : 'rejected',
          if (!approve && rejectionReason != null) 'rejectionReason': rejectionReason,
        },
      );
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      throw Exception('Failed to review submission: ${response.statusCode}');
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error reviewing submission: $e');
    }
  }

  Future<Map<String, dynamic>> resubmitRejectedContribution({
    required String submissionId,
    required String placeName,
    required String description,
    required String category,
    required String province,
    required String district,
    required double latitude,
    required double longitude,
    required List<String> photoPaths,
  }) async {
    try {
      final photos = <MultipartFile>[];
      for (final filePath in photoPaths) {
        final filename = filePath.split(RegExp(r'[\\/]+')).last;
        photos.add(await MultipartFile.fromFile(filePath, filename: filename));
      }

      final formData = FormData.fromMap({
        'placeName': placeName,
        'description': description,
        'category': category,
        'province': province,
        'district': district,
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'photos': photos,
      });

      final response = await _dio.patch(
        '/api/places/submissions/$submissionId/resubmit',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      throw Exception('Failed to resubmit contribution: ${response.statusCode}');
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error resubmitting contribution: $e');
    }
  }
}
