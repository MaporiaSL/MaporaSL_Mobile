import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gemified_travel_portfolio/features/profile/data/datasources/profile_api.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class FakeMultipartFile extends Fake implements MultipartFile {}

class FakeMediaType extends Fake implements MediaType {}

void main() {
  late MockDio dio;
  late ProfileApi api;

  setUp(() {
    dio = MockDio();
    api = ProfileApi(dio: dio);
    registerFallbackValue(FormData());
    registerFallbackValue(const Options());
    registerFallbackValue(FakeMultipartFile());
    registerFallbackValue(FakeMediaType());
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

      await api.submitPlaceContribution(
        placeName: 'Sample Place',
        description: 'This is a valid description with more than fifty characters for submission.',
        category: 'other',
        province: 'Western',
        district: 'Colombo',
        latitude: 6.9271,
        longitude: 79.8612,
        photoPaths: const [
          'test/resources/photo1.jpg',
          'test/resources/photo2.jpg',
        ],
      );

      verify(
        () => dio.post(
          '/api/places/submit',
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).called(1);
    });
  });
}
