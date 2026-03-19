import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gemified_travel_portfolio/features/profile/domain/user_profile.dart';
import 'package:gemified_travel_portfolio/features/profile/presentation/profile_screen.dart';
import 'package:gemified_travel_portfolio/features/profile/presentation/providers/profile_providers.dart';

void main() {
  final profile = UserProfile(
    id: 'u1',
    name: 'Tester',
    email: 't@example.com',
    avatarUrl: '',
    bio: '',
    hometownDistrict: 'Colombo',
    preferredLanguage: 'English',
    travelInterests: const [],
    totalSubmitted: 3,
    approvedCount: 1,
    approvalRate: 33.3,
    badges: const [],
    contributedPlaces: const [],
    leaderboardRank: 1,
    impactCount: 3,
  );

  final contributions = [
    ContributedPlace(
      id: '1',
      name: 'Approved Place',
      description: 'd',
      approved: true,
      status: 'approved',
      category: 'other',
      province: 'Western',
      district: 'Colombo',
      submittedAt: DateTime.now().subtract(const Duration(days: 1)),
      photoUrl: '',
      photoUrls: const [],
    ),
    ContributedPlace(
      id: '2',
      name: 'Rejected Place',
      description: 'd',
      approved: false,
      status: 'rejected',
      category: 'other',
      province: 'Western',
      district: 'Colombo',
      submittedAt: DateTime.now(),
      rejectionReason: 'Need better description',
      photoUrl: '',
      photoUrls: const [],
    ),
  ];

  testWidgets('shows contribution filter controls and list', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProfileProvider.overrideWith((ref) async => profile),
          userContributionsProvider.overrideWith((ref) async => contributions),
          topContributorsProvider.overrideWith((ref) async => []),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Contributed Places'), findsOneWidget);
    expect(find.text('Approved'), findsWidgets);
    expect(find.text('Rejected'), findsWidgets);

    await tester.tap(find.text('Rejected').first);
    await tester.pumpAndSettle();

    expect(find.text('Rejected Place'), findsOneWidget);
  });
}
