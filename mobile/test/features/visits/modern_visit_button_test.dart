import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemified_travel_portfolio/features/visits/presentation/widgets/modern_visit_button.dart';
import 'package:dio/dio.dart';

// Mock Dio Provider since we don't want real API calls in widget tests
final mockDioProvider = Provider<Dio>((ref) => Dio());

void main() {
  group('ModernVisitButton Widget Tests', () {
    testWidgets('displays "Mark Visit" when isVisited is false', (
      WidgetTester tester,
    ) async {
      bool buttonTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ModernVisitButton(
                isVisited: false,
                onTap: () {
                  buttonTapped = true;
                },
              ),
            ),
          ),
        ),
      );

      // Verify the initial state
      expect(find.text('Mark Visit'), findsOneWidget);
      expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
      expect(find.text('Visited'), findsNothing);

      // Tap the button
      await tester.tap(find.byType(ModernVisitButton));
      await tester.pump();

      // Verify the tap was registered
      expect(buttonTapped, isTrue);
    });

    testWidgets('displays "Visited" and check icon when isVisited is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ModernVisitButton(isVisited: true, onTap: () {}),
            ),
          ),
        ),
      );

      // Verify the visited state
      expect(find.text('Visited'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      expect(find.text('Mark Visit'), findsNothing);
    });
  });
}
