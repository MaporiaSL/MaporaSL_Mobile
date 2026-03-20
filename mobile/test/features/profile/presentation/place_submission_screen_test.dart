import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gemified_travel_portfolio/features/profile/data/repositories/profile_repository.dart';
import 'package:gemified_travel_portfolio/features/profile/presentation/place_submission_screen.dart';
import 'package:gemified_travel_portfolio/features/profile/presentation/providers/profile_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late MockProfileRepository repository;

  setUp(() {
    repository = MockProfileRepository();
    when(
      () => repository.submitPlaceContribution(
        placeName: any(named: 'placeName'),
        description: any(named: 'description'),
        category: any(named: 'category'),
        province: any(named: 'province'),
        district: any(named: 'district'),
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        photoPaths: any(named: 'photoPaths'),
      ),
    ).thenAnswer((_) async {});
  });

  Widget buildScreen({
    required Future<({double latitude, double longitude})?> Function(String)
    resolver,
  }) {
    return ProviderScope(
      overrides: [profileRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(
        home: PlaceSubmissionScreen(
          initialPhotoPathsForTesting: const ['a.jpg', 'b.jpg'],
          coordinateResolverForTesting: resolver,
        ),
      ),
    );
  }

  Future<void> fillValidForm(WidgetTester tester) async {
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Place name'),
      'Galle Fort',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Description'),
      'A beautiful and historic place for travelers with scenic walls and nearby attractions.',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Province'),
      'Southern',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'District'),
      'Galle',
    );
  }

  testWidgets('shows geocoding failure message when auto location fails', (
    tester,
  ) async {
    await tester.pumpWidget(buildScreen(resolver: (_) async => null));
    await tester.pumpAndSettle();

    await fillValidForm(tester);

    await tester.tap(
      find.widgetWithText(FilledButton, 'Submit for Review').hitTestable(),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Could not determine location automatically. Refine place/province/district and try again.',
      ),
      findsOneWidget,
    );

    verifyNever(
      () => repository.submitPlaceContribution(
        placeName: any(named: 'placeName'),
        description: any(named: 'description'),
        category: any(named: 'category'),
        province: any(named: 'province'),
        district: any(named: 'district'),
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        photoPaths: any(named: 'photoPaths'),
      ),
    );
  });

  testWidgets('submits using coordinates from resolver', (tester) async {
    await tester.pumpWidget(
      buildScreen(
        resolver: (_) async => (latitude: 6.0329, longitude: 80.2168),
      ),
    );
    await tester.pumpAndSettle();

    await fillValidForm(tester);

    await tester.tap(
      find.widgetWithText(FilledButton, 'Submit for Review').hitTestable(),
    );
    await tester.pumpAndSettle();

    verify(
      () => repository.submitPlaceContribution(
        placeName: 'Galle Fort',
        description: any(named: 'description'),
        category: any(named: 'category'),
        province: 'Southern',
        district: 'Galle',
        latitude: 6.0329,
        longitude: 80.2168,
        photoPaths: any(named: 'photoPaths'),
      ),
    ).called(1);
  });
}
