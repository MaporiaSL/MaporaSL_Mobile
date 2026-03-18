import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gemified_travel_portfolio/features/profile/presentation/profile_screen.dart';
import 'package:gemified_travel_portfolio/features/profile/presentation/providers/profile_providers.dart';

void main() {
  testWidgets('shows friendly expired session message (not raw exception)', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProfileProvider.overrideWith((ref) async {
            throw const ProfileLoadException(
              ProfileLoadErrorType.expiredToken,
              'Your session expired. Please sign in again.',
            );
          }),
          userContributionsProvider.overrideWith((ref) async => []),
          topContributorsProvider.overrideWith((ref) async => []),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Session Expired'), findsOneWidget);
    expect(find.textContaining('Sign in again'), findsOneWidget);
    expect(find.textContaining('DioException'), findsNothing);
  });

  testWidgets('shows friendly offline message', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProfileProvider.overrideWith((ref) async {
            throw const ProfileLoadException(
              ProfileLoadErrorType.offline,
              'You appear to be offline. Check your connection and try again.',
            );
          }),
          userContributionsProvider.overrideWith((ref) async => []),
          topContributorsProvider.overrideWith((ref) async => []),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No Internet Connection'), findsOneWidget);
    expect(find.textContaining('Connect to the internet'), findsOneWidget);
    expect(find.textContaining('Exception:'), findsNothing);
  });

  testWidgets('shows sign-in required message for signed-out state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProfileProvider.overrideWith((ref) async {
            throw const ProfileLoadException(
              ProfileLoadErrorType.missingToken,
              'You are not signed in. Please log in to continue.',
            );
          }),
          userContributionsProvider.overrideWith((ref) async => []),
          topContributorsProvider.overrideWith((ref) async => []),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Sign In Required'), findsOneWidget);
    expect(find.text('Sign In Again'), findsOneWidget);
  });
}
