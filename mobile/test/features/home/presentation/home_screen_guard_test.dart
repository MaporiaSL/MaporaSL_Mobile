import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gemified_travel_portfolio/features/home/presentation/home_screen.dart';
import 'package:gemified_travel_portfolio/features/profile/presentation/first_time_profile_setup_screen.dart';
import 'package:gemified_travel_portfolio/features/profile/presentation/providers/profile_providers.dart';

void main() {
  Widget buildHomeWithGuard(
    Future<CoreNavigationGuardState> Function(ProviderRef<Object?> ref)
    resolver,
  ) {
    return ProviderScope(
      overrides: [coreNavigationGuardProvider.overrideWith(resolver)],
      child: const MaterialApp(home: HomeScreen()),
    );
  }

  testWidgets('shows loading while guard is resolving', (tester) async {
    await tester.pumpWidget(
      buildHomeWithGuard((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return const CoreNavigationGuardState.allowed();
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
}
