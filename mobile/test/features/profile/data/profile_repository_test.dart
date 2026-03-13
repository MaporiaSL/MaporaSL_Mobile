import 'package:flutter_test/flutter_test.dart';
import 'package:gemified_travel_portfolio/features/profile/data/datasources/profile_api.dart';
import 'package:gemified_travel_portfolio/features/profile/data/repositories/profile_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileApi extends Mock implements ProfileApi {}

void main() {
  late MockProfileApi api;
  late ProfileRepository repository;

  setUp(() {
    api = MockProfileApi();
    repository = ProfileRepository(api: api);
  });

  test('getUserProfile maps API payload into UserProfile model', () async {
    when(() => api.getUserProfile('u1')).thenAnswer(
      (_) async => {
        'user': {'id': 'u1', 'name': 'Test User', 'email': 'test@example.com', 'avatarUrl': ''},
        'stats': {'totalSubmitted': 3, 'approvedCount': 2, 'approvalRate': 66.7},
        'badges': [],
        'leaderboardRank': 5,
        'impactCount': 12,
      },
    );

    final profile = await repository.getUserProfile('u1');

    expect(profile.id, 'u1');
    expect(profile.name, 'Test User');
    expect(profile.totalSubmitted, 3);
  });

  test('uploadAvatar forwards call to API and returns URL', () async {
    when(() => api.uploadAvatar('u1', '/tmp/avatar.jpg')).thenAnswer(
      (_) async => 'https://storage.googleapis.com/bucket/users/u1/avatars/a.jpg',
    );

    final avatarUrl = await repository.uploadAvatar('u1', '/tmp/avatar.jpg');

    expect(avatarUrl, contains('storage.googleapis.com'));
    verify(() => api.uploadAvatar('u1', '/tmp/avatar.jpg')).called(1);
  });
}
