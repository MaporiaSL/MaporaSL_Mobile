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
  });
}
