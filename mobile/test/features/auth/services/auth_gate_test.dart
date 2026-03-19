import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gemified_travel_portfolio/core/services/auth_service.dart';
import 'package:gemified_travel_portfolio/features/auth/services/auth_gate.dart';
import 'package:gemified_travel_portfolio/features/profile/presentation/providers/profile_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {}

class MockUser extends Mock implements User {}

class MockUserInfo extends Mock implements UserInfo {}

void main() {
  late MockAuthService authService;

  Widget buildAuthGate({
    required Stream<User?> authStream,
    required AsyncValue<ProfileSetupRequirement> setupState,
  }) {
    when(() => authService.authStateChanges()).thenAnswer((_) => authStream);
    when(() => authService.signOut()).thenAnswer((_) async {});

    return ProviderScope(
      overrides: [
        authServiceProvider.overrideWithValue(authService),
        profileSetupRequirementProvider.overrideWith((ref) async {
          return setupState.value ??
              const ProfileSetupRequirement(
                requiresSetup: false,
                requiredFields: [],
                optionalFields: [],
              );
        }),
      ],
      child: MaterialApp(
        home: AuthGate(
          loginBuilder: () => const Text('LOGIN_VIEW'),
          homeBuilder: () => const Text('HOME_VIEW'),
          setupBuilder: (_, __) => const Text('SETUP_VIEW'),
        ),
      ),
    );
  }

  setUp(() {
    authService = MockAuthService();
  });

  testWidgets('shows login when unauthenticated', (tester) async {
    await tester.pumpWidget(
      buildAuthGate(
        authStream: Stream<User?>.value(null),
        setupState: const AsyncData(
          ProfileSetupRequirement(
            requiresSetup: false,
            requiredFields: [],
            optionalFields: [],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('LOGIN_VIEW'), findsOneWidget);
  });

  testWidgets('shows setup wizard when authenticated and setup required', (
    tester,
  ) async {
    final user = MockUser();
    when(() => user.emailVerified).thenReturn(true);
    when(() => user.providerData).thenReturn(const <UserInfo>[]);

    await tester.pumpWidget(
      buildAuthGate(
        authStream: Stream<User?>.value(user),
        setupState: const AsyncData(
          ProfileSetupRequirement(
            requiresSetup: true,
            requiredFields: ['name'],
            optionalFields: ['bio'],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('SETUP_VIEW'), findsOneWidget);
  });

  testWidgets('shows home when authenticated and setup complete', (
    tester,
  ) async {
    final user = MockUser();
    when(() => user.emailVerified).thenReturn(true);
    when(() => user.providerData).thenReturn(const <UserInfo>[]);

    await tester.pumpWidget(
      buildAuthGate(
        authStream: Stream<User?>.value(user),
        setupState: const AsyncData(
          ProfileSetupRequirement(
            requiresSetup: false,
            requiredFields: [],
            optionalFields: [],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('HOME_VIEW'), findsOneWidget);
  });
}
