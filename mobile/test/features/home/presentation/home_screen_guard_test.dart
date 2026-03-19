import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gemified_travel_portfolio/features/auth/services/auth_gate.dart';
import 'package:gemified_travel_portfolio/features/home/presentation/home_screen.dart';
import 'package:gemified_travel_portfolio/features/home/widgets/bottom_nav_bar.dart';
import 'package:gemified_travel_portfolio/features/profile/presentation/first_time_profile_setup_screen.dart';
import 'package:gemified_travel_portfolio/features/profile/presentation/providers/profile_providers.dart';

void main() {
  Widget buildHomeWithGuard(
    Future<CoreNavigationGuardState> Function(
      FutureProviderRef<CoreNavigationGuardState> ref,
    )
    resolver,
  ) {
    return ProviderScope(
      overrides: [coreNavigationGuardProvider.overrideWith(resolver)],
      child: const MaterialApp(home: HomeScreen()),
    );
  }

  testWidgets('shows loading while guard is resolving', (tester) async {
    final completer = Completer<CoreNavigationGuardState>();
    await tester.pumpWidget(
      buildHomeWithGuard((_) async {
        return completer.future;
      }),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows error state with retry action on guard failure', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildHomeWithGuard((_) async {
        throw Exception('guard failed');
      }),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Unable to verify profile setup right now.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(OutlinedButton, 'Retry'), findsOneWidget);
  });

  testWidgets('routes to setup screen when setup is required', (tester) async {
    await tester.pumpWidget(
      buildHomeWithGuard(
        (_) async => const CoreNavigationGuardState.needsSetup(
          requiredFields: ['name', 'hometownDistrict', 'preferredLanguage'],
          optionalFields: ['travelInterests', 'avatarUrl', 'bio'],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FirstTimeProfileSetupScreen), findsOneWidget);
    expect(find.text('Complete Your Profile'), findsOneWidget);
  });

  testWidgets('routes to auth gate when sign-in is required', (tester) async {
    await tester.pumpWidget(
      buildHomeWithGuard(
        (_) async => const CoreNavigationGuardState.needsSignIn(
          message: 'Please sign in to continue.',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AuthGate), findsOneWidget);
  });

  testWidgets('shows blocked state message when access is denied', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildHomeWithGuard(
        (_) async => const CoreNavigationGuardState.blocked(
          message: 'Access blocked until setup is complete.',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Access blocked until setup is complete.'),
      findsOneWidget,
    );
  });

  testWidgets('shows core app tabs when guard allows access', (tester) async {
    await tester.pumpWidget(
      buildHomeWithGuard((_) async => const CoreNavigationGuardState.allowed()),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BottomNavBar), findsOneWidget);
    expect(find.byIcon(Icons.map), findsOneWidget);
    expect(find.byIcon(Icons.photo_album), findsOneWidget);
    expect(find.byIcon(Icons.travel_explore), findsOneWidget);
    expect(find.byIcon(Icons.history), findsOneWidget);
    expect(find.byIcon(Icons.store), findsOneWidget);
  });
}
