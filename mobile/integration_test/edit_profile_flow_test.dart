import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:gemified_travel_portfolio/features/profile/data/repositories/profile_repository.dart';
import 'package:gemified_travel_portfolio/features/profile/domain/user_profile.dart';
import 'package:gemified_travel_portfolio/features/profile/presentation/edit_profile_screen.dart';
import 'package:gemified_travel_portfolio/features/profile/presentation/providers/profile_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Edit profile save flow updates extended profile fields', (tester) async {
    final repository = MockProfileRepository();

    final initialProfile = UserProfile(
      id: 'u1',
      name: 'Old Name',
      email: 'test@example.com',
      avatarUrl: '',
      bio: '',
      hometownDistrict: 'Colombo',
      preferredLanguage: 'English',
      travelInterests: const [],
      totalSubmitted: 0,
      approvedCount: 0,
      approvalRate: 0,
      badges: const [],
      contributedPlaces: const [],
      leaderboardRank: 0,
      impactCount: 0,
    );

    when(
      () => repository.updateProfile(
        any(),
        name: any(named: 'name'),
        avatarUrl: any(named: 'avatarUrl'),
        bio: any(named: 'bio'),
        hometownDistrict: any(named: 'hometownDistrict'),
        preferredLanguage: any(named: 'preferredLanguage'),
        travelInterests: any(named: 'travelInterests'),
      ),
    ).thenAnswer((_) async => initialProfile);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWithValue(repository),
          currentUserIdProvider.overrideWithValue('u1'),
        ],
        child: MaterialApp(
          home: EditProfileScreen(initialProfile: initialProfile),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'Integration Name');
    await tester.enterText(find.byType(TextFormField).at(1), 'Loves hiking and culture trails');
    await tester.enterText(find.byType(TextFormField).at(2), 'Galle');
    await tester.tap(find.byType(FilterChip).first);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tamil').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save').first);
    await tester.pumpAndSettle();

    final verification = verify(
      () => repository.updateProfile(
        'u1',
        name: 'Integration Name',
        avatarUrl: any(named: 'avatarUrl'),
        bio: 'Loves hiking and culture trails',
        hometownDistrict: 'Galle',
        preferredLanguage: 'Tamil',
        travelInterests: captureAny(named: 'travelInterests'),
      ),
    );
    verification.called(1);

    final capturedInterests = verification.captured.single as List<String>;

    expect(capturedInterests, isNotEmpty);
  });
}
