import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gemified_travel_portfolio/features/profile/data/repositories/profile_repository.dart';
import 'package:gemified_travel_portfolio/features/profile/domain/user_profile.dart';
import 'package:gemified_travel_portfolio/features/profile/presentation/profile_screen.dart';
import 'package:gemified_travel_portfolio/features/profile/presentation/providers/profile_providers.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('first-time bootstrap path leads to profile success UI', (tester) async {
    final repository = MockProfileRepository();
    var bootstrapCallCount = 0;

    final profile = UserProfile(
      id: 'u1',
      name: 'Bootstrap User',
      email: 'bootstrap@example.com',
      avatarUrl: '',
      bio: 'Traveler',
      hometownDistrict: 'Colombo',
      preferredLanguage: 'English',
      travelInterests: const ['Nature'],
      totalSubmitted: 1,
      approvedCount: 1,
      approvalRate: 100,
      badges: const [],
      contributedPlaces: const [],
      leaderboardRank: 1,
      impactCount: 5,
    );

    when(() => repository.getUserProfile('u1')).thenAnswer((_) async => profile);
    when(() => repository.getUserContributions('u1')).thenAnswer((_) async => []);
    when(() => repository.getTopContributors(limit: any(named: 'limit')))
        .thenAnswer((_) async => []);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserIdProvider.overrideWithValue('u1'),
          profileRepositoryProvider.overrideWithValue(repository),
          profileBootstrapProvider.overrideWith((ref) async {
            bootstrapCallCount += 1;
            await Future<void>.delayed(const Duration(milliseconds: 80));
          }),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );

    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(bootstrapCallCount, greaterThan(0));
    expect(find.text('Bootstrap User'), findsOneWidget);
    expect(find.text('Traveler'), findsOneWidget);
  });
}
