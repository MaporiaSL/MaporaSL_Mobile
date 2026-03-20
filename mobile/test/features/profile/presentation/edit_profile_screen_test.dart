import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gemified_travel_portfolio/core/services/auth_service.dart';
import 'package:gemified_travel_portfolio/features/profile/data/repositories/profile_repository.dart';
import 'package:gemified_travel_portfolio/features/profile/domain/user_profile.dart';
import 'package:gemified_travel_portfolio/features/profile/presentation/edit_profile_screen.dart';
import 'package:gemified_travel_portfolio/features/profile/presentation/providers/profile_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockProfileRepository repository;
  late MockAuthService authService;

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
    unlockedDistrictsCount: 0,
    unlockedProvincesCount: 0,
    totalPlacesVisited: 0,
  );

  setUp(() {
    repository = MockProfileRepository();
    authService = MockAuthService();

    when(() => authService.currentUserEmail).thenReturn('test@example.com');
    when(
      () => authService.sendPasswordResetEmail(any()),
    ).thenAnswer((_) async {});
    when(() => authService.requestEmailChange(any())).thenAnswer((_) async {});
    when(() => authService.deleteCurrentUser()).thenAnswer((_) async {});
    when(() => authService.signOut()).thenAnswer((_) async {});

    when(
      () => repository.deleteAccount(any()),
    ).thenAnswer((_) async => {'message': 'ok'});
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
  });

  testWidgets('shows validation error when name is empty', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWithValue(repository),
          currentUserIdProvider.overrideWithValue('u1'),
          authServiceProvider.overrideWithValue(authService),
        ],
        child: MaterialApp(
          home: EditProfileScreen(initialProfile: initialProfile),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, '');
    await tester.tap(find.text('Save').first);
    await tester.pumpAndSettle();

    expect(find.text('Name cannot be empty'), findsOneWidget);
  });

  testWidgets('calls updateProfile when a valid new name is saved', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWithValue(repository),
          currentUserIdProvider.overrideWithValue('u1'),
          authServiceProvider.overrideWithValue(authService),
        ],
        child: MaterialApp(
          home: EditProfileScreen(initialProfile: initialProfile),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'New Name');
    await tester.tap(find.text('Save').first);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));

    verify(
      () => repository.updateProfile(
        'u1',
        name: 'New Name',
        avatarUrl: any(named: 'avatarUrl'),
        bio: any(named: 'bio'),
        hometownDistrict: any(named: 'hometownDistrict'),
        preferredLanguage: any(named: 'preferredLanguage'),
        travelInterests: any(named: 'travelInterests'),
      ),
    ).called(1);
  });

  testWidgets('change email dialog cancel does not call request', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWithValue(repository),
          currentUserIdProvider.overrideWithValue('u1'),
          authServiceProvider.overrideWithValue(authService),
        ],
        child: MaterialApp(
          home: EditProfileScreen(initialProfile: initialProfile),
        ),
      ),
    );

    await tester.tap(find.text('Change Email'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    verifyNever(() => authService.requestEmailChange(any()));
  });

  testWidgets('change email dialog submit calls request', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWithValue(repository),
          currentUserIdProvider.overrideWithValue('u1'),
          authServiceProvider.overrideWithValue(authService),
        ],
        child: MaterialApp(
          home: EditProfileScreen(initialProfile: initialProfile),
        ),
      ),
    );

    await tester.tap(find.text('Change Email'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'new@mail.com');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    verify(() => authService.requestEmailChange('new@mail.com')).called(1);
  });

  testWidgets('password reset action shows feedback path', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWithValue(repository),
          currentUserIdProvider.overrideWithValue('u1'),
          authServiceProvider.overrideWithValue(authService),
        ],
        child: MaterialApp(
          home: EditProfileScreen(initialProfile: initialProfile),
        ),
      ),
    );

    await tester.tap(find.text('Change Password'));
    await tester.pumpAndSettle();

    verify(
      () => authService.sendPasswordResetEmail('test@example.com'),
    ).called(1);
  });

  testWidgets('delete account cancel does not delete', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWithValue(repository),
          currentUserIdProvider.overrideWithValue('u1'),
          authServiceProvider.overrideWithValue(authService),
        ],
        child: MaterialApp(
          home: EditProfileScreen(initialProfile: initialProfile),
        ),
      ),
    );

    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    verifyNever(() => repository.deleteAccount(any()));
    verifyNever(() => authService.deleteCurrentUser());
  });

  testWidgets('delete account confirm calls cleanup and auth delete', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWithValue(repository),
          currentUserIdProvider.overrideWithValue('u1'),
          authServiceProvider.overrideWithValue(authService),
        ],
        child: MaterialApp(
          routes: {'/login': (_) => const Scaffold(body: Text('login'))},
          home: EditProfileScreen(initialProfile: initialProfile),
        ),
      ),
    );

    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete Account').last);
    await tester.pumpAndSettle();

    verify(() => repository.deleteAccount('u1')).called(1);
    verify(() => authService.deleteCurrentUser()).called(1);
  });

  testWidgets('re-auth required on change email shows dedicated guidance', (
    tester,
  ) async {
    when(
      () => authService.requestEmailChange(any()),
    ).thenThrow(const AuthRecentLoginRequiredException());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWithValue(repository),
          currentUserIdProvider.overrideWithValue('u1'),
          authServiceProvider.overrideWithValue(authService),
        ],
        child: MaterialApp(
          home: EditProfileScreen(initialProfile: initialProfile),
        ),
      ),
    );

    await tester.tap(find.text('Change Email'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'new@mail.com');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(
      find.text('For security, please sign in again and retry this action.'),
      findsOneWidget,
    );
  });
}
