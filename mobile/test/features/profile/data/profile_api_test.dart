import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gemified_travel_portfolio/features/profile/data/datasources/profile_api.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late ProfileApi api;

  setUp(() {
    dio = MockDio();
    api = ProfileApi(dio: dio);
    registerFallbackValue(FormData());
    registerFallbackValue(const Options());
  });

  group('ProfileApi', () {
    test('getUserProfile returns response data when status is 200', () async {
      when(() => dio.get('/api/profile/u1')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/profile/u1'),
          statusCode: 200,
          data: {
            'user': {'id': 'u1', 'name': 'Test', 'email': 'test@example.com', 'avatarUrl': ''},
            'stats': {'totalSubmitted': 0, 'approvedCount': 0, 'approvalRate': 0},
            'badges': [],
            'leaderboardRank': 0,
            'impactCount': 0,
          },
        ),
      );

      final data = await api.getUserProfile('u1');

      expect(data['user']['id'], 'u1');
      verify(() => dio.get('/api/profile/u1')).called(1);
    });

    test('updateProfile sends expected payload', () async {
      when(() => dio.post('/api/profile/u1', data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/profile/u1'),
          statusCode: 200,
          data: {
            'user': {'id': 'u1', 'name': 'Updated Name', 'email': 'test@example.com', 'avatarUrl': ''},
          },
        ),
      );

      final result = await api.updateProfile('u1', name: 'Updated Name');

      expect(result['user']['name'], 'Updated Name');
      verify(() => dio.post('/api/profile/u1', data: {'name': 'Updated Name'})).called(1);
    });

    test('submitPlaceContribution posts multipart payload to places submit endpoint', () async {
      when(
        () => dio.post(
          '/api/places/submit',
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/places/submit'),
          statusCode: 201,
          data: {'message': 'ok'},
        ),
      );

      final tempDir = await Directory.systemTemp.createTemp('profile_api_test');
      final photo1 = File('${tempDir.path}/photo1.jpg')..writeAsBytesSync([1, 2, 3, 4]);
      final photo2 = File('${tempDir.path}/photo2.jpg')..writeAsBytesSync([5, 6, 7, 8]);

      await api.submitPlaceContribution(
        placeName: 'Sample Place',
        description: 'This is a valid description with more than fifty characters for submission.',
        category: 'other',
        province: 'Western',
        district: 'Colombo',
        latitude: 6.9271,
        longitude: 79.8612,
        photoPaths: [
          photo1.path,
          photo2.path,
        ],
      );

      verify(
        () => dio.post(
          '/api/places/submit',
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).called(1);

      await tempDir.delete(recursive: true);
    });
  });
}
