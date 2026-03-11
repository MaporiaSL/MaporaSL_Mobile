import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gemified_travel_portfolio/features/profile/data/repositories/profile_repository.dart';
import 'package:gemified_travel_portfolio/features/profile/domain/user_profile.dart';
import 'package:gemified_travel_portfolio/features/profile/presentation/edit_profile_screen.dart';
import 'package:gemified_travel_portfolio/features/profile/presentation/providers/profile_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late MockProfileRepository repository;

  final initialProfile = UserProfile(
    id: 'u1',
    name: 'Old Name',
    email: 'test@example.com',
    avatarUrl: '',
    totalSubmitted: 0,
    approvedCount: 0,
    approvalRate: 0,
    badges: const [],
    contributedPlaces: const [],
    leaderboardRank: 0,
    impactCount: 0,
  );

  setUp(() {
    repository = MockProfileRepository();
    when(
      () => repository.updateProfile(
        any(),
        name: any(named: 'name'),
        avatarUrl: any(named: 'avatarUrl'),
      ),
    ).thenAnswer((_) async => initialProfile);
  });

  testWidgets('shows validation error when name is empty', (tester) async {
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

    await tester.enterText(find.byType(TextFormField).first, '');
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(find.text('Name cannot be empty'), findsOneWidget);
  });

  testWidgets('calls updateProfile when a valid new name is saved', (tester) async {
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

    await tester.enterText(find.byType(TextFormField).first, 'New Name');
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    verify(
      () => repository.updateProfile(
        'u1',
        name: 'New Name',
        avatarUrl: any(named: 'avatarUrl'),
      ),
    ).called(1);
  });
}
