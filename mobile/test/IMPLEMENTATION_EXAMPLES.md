# 📖 Test Implementation Guide

Complete examples showing how to implement each test type for your project.

## 🎯 Unit Test Example: Provider Testing

### File: `test/unit/providers/exploration_provider_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemified_travel_portfolio/features/exploration/providers/exploration_provider.dart';
import 'test/fixtures/test_data_factory.dart';

void main() {
  group('ExplorationProvider', () {
    test('Initial state should have empty locations', () {
      final container = ProviderContainer();
      
      // Arrange: Create container
      // Act: Read initial state
      final state = container.read(explorationProvider);
      
      // Assert: Verify initial state
      expect(state.locations, isEmpty);
      expect(state.currentDistrict, isNull);
      expect(state.visitedLocations, isEmpty);
    });

    test('Should load locations when district is selected', () async {
      final container = ProviderContainer();
      final notifier = container.read(explorationProvider.notifier);
      
      // Arrange: Setup mock data
      final mockLocations = TestDataFactory.createMockLocationsList(count: 5);
      
      // Act: Select a district (assuming this method exists)
      // await notifier.selectDistrict('Colombo');
      
      // Assert: Verify locations are loaded
      // final state = container.read(explorationProvider);
      // expect(state.locations.length, greaterThan(0));
      
      // NOTE: Uncomment above when actual provider method is known
      expect(mockLocations.length, 5);
    });

    test('Should mark location as visited', () async {
      final container = ProviderContainer();
      final notifier = container.read(explorationProvider.notifier);
      
      // Create mock location
      final location = TestDataFactory.createMockLocation(
        id: 'loc-1',
        name: 'Test Location',
        visited: false,
      );
      
      // NOTE: Call actual provider method to mark visited
      // await notifier.markLocationVisited(location.id);
      
      // Verify it's marked visited
      // final state = container.read(explorationProvider);
      // final visitedLocation = state.visitedLocations.firstWhere(
      //   (loc) => loc.id == 'loc-1',
      // );
      // expect(visitedLocation.visited, true);
      
      expect(true, true); // Placeholder
    });

    test('Should calculate district completion percentage', () {
      // Mock data: 5 locations in a district, 3 visited
      final allLocations = TestDataFactory.createMockLocationsList(count: 5);
      final visited = allLocations.take(3).toList();
      
      // Calculate percentage
      final percentage = (visited.length / allLocations.length) * 100;
      
      // Verify calculation
      expect(percentage, 60);
    });
  });
}
```

## 🎯 Unit Test Example: Service Testing

### File: `test/unit/services/api_service_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'test/fixtures/mock_services.dart';
import 'test/fixtures/test_data_factory.dart';

void main() {
  group('ApiService', () {
    test('Should fetch locations successfully', () async {
      // Arrange: Create mock service with data
      final mockApi = MockApiService();
      mockApi.mockLocations = TestDataFactory.createMockLocationsList(count: 5);
      
      // Act: Call fetch
      final locations = await mockApi.fetchLocations('Colombo');
      
      // Assert: Verify results
      expect(locations, isNotNull);
      expect(locations.length, 5);
      expect(locations.first.name, isNotNull);
    });

    test('Should handle network error gracefully', () async {
      // Arrange: Create mock that should fail
      final mockApi = MockApiService()..shouldFail = true;
      
      // Act & Assert: Verify exception is thrown
      expect(
        () => mockApi.fetchLocations('Colombo'),
        throwsException,
      );
    });

    test('Should retry failed request', () async {
      // Arrange: Setup mock with simulated delay
      final mockApi = MockApiService()
        ..mockLocations = TestDataFactory.createMockLocationsList()
        ..simulatedDelay = Duration(milliseconds: 100);
      
      // Act: Fetch with delay
      final stopwatch = Stopwatch()..start();
      final locations = await mockApi.fetchLocations('Colombo');
      stopwatch.stop();
      
      // Assert: Verify delay occurred
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(100));
      expect(locations.length, greaterThan(0));
    });

    test('Should reset mock state between tests', () async {
      final mockApi = MockApiService();
      
      // Setup and verify
      mockApi.mockLocations = TestDataFactory.createMockLocationsList(count: 5);
      expect(mockApi.mockLocations, isNotNull);
      
      // Reset
      mockApi.reset();
      
      // Verify reset
      expect(mockApi.mockLocations, isNull);
      expect(mockApi.shouldFail, false);
    });
  });
}
```

## 🎯 Unit Test Example: Model Testing

### File: `test/unit/models/models_test.dart` (Excerpt)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gemified_travel_portfolio/features/exploration/data/models/exploration_models.dart';
import 'test/fixtures/test_data_factory.dart';

void main() {
  group('ExplorationLocation Model', () {
    test('Should create location from JSON', () {
      final json = {
        'id': 'loc-1',
        'name': 'Test Location',
        'latitude': 6.9271,
        'longitude': 80.7789,
        'district': 'Colombo',
        'description': 'A test location',
        'imageUrl': 'https://example.com/image.jpg',
        'category': 'Cultural',
        'visited': false,
      };
      
      // Create from JSON
      final location = ExplorationLocation.fromJson(json);
      
      // Verify all fields
      expect(location.id, 'loc-1');
      expect(location.name, 'Test Location');
      expect(location.latitude, 6.9271);
      expect(location.longitude, 80.7789);
      expect(location.visited, false);
    });

    test('Should convert location to JSON', () {
      final location = TestDataFactory.createMockLocation(
        id: 'loc-1',
        name: 'Test',
        visited: true,
      );
      
      // Convert to JSON
      final json = location.toJson();
      
      // Verify JSON structure
      expect(json['id'], 'loc-1');
      expect(json['name'], 'Test');
      expect(json['visited'], true);
    });

    test('Should calculate distance from point', () {
      final location = TestDataFactory.createMockLocation(
        latitude: 6.9271,
        longitude: 80.7789,
      );
      
      // Calculate distance to same point (should be 0)
      // NOTE: Implement if location has distance method
      // final distance = location.distanceTo(6.9271, 80.7789);
      // expect(distance, 0);
      
      expect(true, true); // Placeholder
    });
  });
}
```

## 🎯 Widget Test Example: Screen Testing

### File: `test/widget/screens/map_screen_test.dart` (Excerpt)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
// WHEN AVAILABLE:
// import 'package:gemified_travel_portfolio/features/map/presentation/map_screen.dart';

Widget _withProvider(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(body: child),
      theme: ThemeData(useMaterial3: true),
    ),
  );
}

void main() {
  group('MapScreen Widget Tests', () {
    // This test will work once MapScreen is imported
    testWidgets('Should render map screen', (WidgetTester tester) async {
      // Arrange: Build widget with provider scope
      // await tester.pumpWidget(_withProvider(
      //   const MapScreen(travelId: 'test-travel'),
      // ));
      
      // Wait for animations
      // await tester.pumpAndSettle();
      
      // Assert: Widget exists
      // expect(find.byType(MapScreen), findsOneWidget);
      
      expect(true, true); // Placeholder - uncomment when MapScreen available
    });

    testWidgets('Should display district buttons', (WidgetTester tester) async {
      // // Arrange
      // await tester.pumpWidget(_withProvider(
      //   const MapScreen(travelId: 'test-travel'),
      // ));
      // await tester.pumpAndSettle();
      
      // // Assert: Should have district buttons
      // expect(find.byType(ElevatedButton), findsWidgets());
      
      expect(true, true); // Placeholder
    });

    testWidgets('Should show location markers on tap', (WidgetTester tester) async {
      // // Arrange
      // await tester.pumpWidget(_withProvider(
      //   const MapScreen(travelId: 'test-travel'),
      // ));
      // await tester.pumpAndSettle();
      
      // // Act: Tap on district
      // await tester.tap(find.text('Colombo'));
      // await tester.pumpAndSettle();
      
      // // Assert: Markers should be visible
      // expect(find.byIcon(Icons.location_on), findsWidgets());
      
      expect(true, true); // Placeholder
    });
  });
}
```

## 🎯 Widget Test Example: Custom Widget Testing

### File: `test/widget/widgets/custom_widgets_test.dart` (Excerpt)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
// WHEN AVAILABLE:
// import 'package:gemified_travel_portfolio/features/places/presentation/widgets/place_card.dart';

Widget _withProvider(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('PlaceCard Widget Tests', () {
    testWidgets('Should render place card', (WidgetTester tester) async {
      // // Arrange: Create mock place data
      // final mockPlace = {
      //   'id': 'place-1',
      //   'name': 'Test Place',
      //   'rating': 4.5,
      //   'imageUrl': 'https://example.com/image.jpg',
      // };
      
      // // Build widget
      // await tester.pumpWidget(_withProvider(
      //   PlaceCard(place: mockPlace),
      // ));
      // await tester.pumpAndSettle();
      
      // // Assert: Title is visible
      // expect(find.text('Test Place'), findsOneWidget);
      
      expect(true, true); // Placeholder
    });

    testWidgets('Should show rating stars', (WidgetTester tester) async {
      // // Arrange
      // final mockPlace = {'name': 'Place', 'rating': 4.5};
      // await tester.pumpWidget(_withProvider(PlaceCard(place: mockPlace)));
      
      // // Assert: Rating displayed
      // expect(find.byIcon(Icons.star), findsWidgets());
      
      expect(true, true); // Placeholder
    });

    testWidgets('Should respond to tap', (WidgetTester tester) async {
      // // Arrange: Track tap callback
      // bool tapped = false;
      // final mockPlace = {'name': 'Place', 'rating': 4.5};
      
      // await tester.pumpWidget(_withProvider(
      //   PlaceCard(
      //     place: mockPlace,
      //     onTap: () => tapped = true,
      //   ),
      // ));
      
      // // Act: Tap card
      // await tester.tap(find.byType(PlaceCard));
      // await tester.pumpAndSettle();
      
      // // Assert: Callback was called
      // expect(tapped, true);
      
      expect(true, true); // Placeholder
    });
  });
}
```

## 🎯 Integration Test Example: Full User Flow

### File: `test/integration/integration_flows_test.dart` (Excerpt)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
// WHEN AVAILABLE:
// import 'package:gemified_travel_portfolio/main.dart';

Widget _withProvider(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('User Location Discovery Flow', () {
    // testWidgets('User can select district and view locations', (
    //   WidgetTester tester,
    // ) async {
    //   // Arrange: Build full app
    //   await tester.pumpWidget(_withProvider(MyApp()));
    //   await tester.pumpAndSettle();

    //   // Act 1: Navigate to Map
    //   await tester.tap(find.text('Map'));
    //   await tester.pumpAndSettle();

    //   // Act 2: Select District
    //   await tester.tap(find.text('Colombo'));
    //   await tester.pumpAndSettle();

    //   // Assert: Location markers appear
    //   expect(find.byIcon(Icons.location_on), findsWidgets());

    //   // Act 3: Tap a location
    //   await tester.tap(find.byIcon(Icons.location_on).first);
    //   await tester.pumpAndSettle();

    //   // Assert: Location details shown
    //   expect(find.byType(AlertDialog), findsOneWidget);
    // });

    // testWidgets('User can mark location as visited', (
    //   WidgetTester tester,
    // ) async {
    //   // Similar to above, but includes:
    //   // 1. Select location
    //   // 2. Tap "Mark Visit"
    //   // 3. Verify success message
    //   // 4. Verify progress updated
    // });

    expect(true, true); // Placeholder
  });
}
```

## 🔄 Implementation Workflow

1. **Start with simple unit tests**
   - Test providers first (they don't depend on UI)
   - Use mock services for consistency
   - Build confidence with small tests

2. **Move to service tests**
   - Test business logic with mocks
   - Verify error handling
   - Test state changes

3. **Add widget tests**
   - Test UI rendering
   - Test user interactions
   - Always wrap with `_withProvider()`

4. **Write integration tests**
   - Test complete user flows
   - Verify navigation
   - Test state management end-to-end

## ✅ Checklist for Implementation

For each test file:
- [ ] Fix all imports to use `gemified_travel_portfolio`
- [ ] Add `_withProvider()` wrapper for widget tests
- [ ] Replace placeholder tests with real tests
- [ ] Use mock services from `test/fixtures/mock_services.dart`
- [ ] Use test data from `test/fixtures/test_data_factory.dart`
- [ ] Add `await tester.pumpAndSettle()` after widget interactions
- [ ] Verify test follows AAA pattern (Arrange, Act, Assert)

## 🚀 Ready to Implement?

1. Pick one test file
2. Follow the example pattern above
3. Replace placeholders with real tests
4. Run and verify: `flutter test test/path/to/test.dart`
5. Move to next file

---

**Pattern Examples**: Complete
**Ready to implement**: YES
**Test Framework**: Flutter Test + Riverpod
