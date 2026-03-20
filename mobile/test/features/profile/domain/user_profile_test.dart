import 'package:flutter_test/flutter_test.dart';
import 'package:gemified_travel_portfolio/features/profile/domain/user_profile.dart';

void main() {
  test('parses new profile stats fields from json', () {
    final profile = UserProfile.fromJson({
      'user': {
        'id': 'u1',
        'name': 'Alice',
        'email': 'a@example.com',
        'avatarUrl': '',
        'bio': '',
        'hometownDistrict': 'Colombo',
        'preferredLanguage': 'English',
        'travelInterests': ['Food'],
      },
      'stats': {
        'totalSubmitted': 5,
        'approvedCount': 3,
        'approvalRate': 60.0,
        'unlockedDistrictsCount': 8,
        'unlockedProvincesCount': 3,
        'totalPlacesVisited': 21,
      },
      'badges': [],
      'leaderboardRank': 2,
      'impactCount': 9,
    });

    expect(profile.unlockedDistrictsCount, 8);
    expect(profile.unlockedProvincesCount, 3);
    expect(profile.totalPlacesVisited, 21);
    expect(profile.totalSubmitted, 5);
    expect(profile.approvedCount, 3);
  });
}
