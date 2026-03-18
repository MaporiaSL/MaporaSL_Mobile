# 🧪 Gemified Travel Portfolio - Comprehensive Test Suite

Complete testing infrastructure for the Flutter travel portfolio application with unit tests, widget tests, and integration tests.

## 📁 Test Directory Structure

```
test/
├── unit/                          # Unit Tests
│   ├── providers/                 # State management tests
│   │   ├── exploration_provider_test.dart
│   │   ├── visit_provider_test.dart
│   │   ├── auth_provider_test.dart
│   │   ├── map_provider_test.dart
│   │   ├── places_provider_test.dart
│   │   └── progress_provider_test.dart
│   ├── services/                  # Business logic & API tests
│   │   ├── api_service_test.dart
│   │   ├── auth_service_test.dart
│   │   ├── location_service_test.dart
│   │   └── storage_service_test.dart
│   ├── models/                    # Data model tests
│   │   └── models_test.dart
│   └── utils/                     # Utility function tests
│       └── utils_test.dart
├── widget/                        # Widget & UI Tests
│   ├── screens/                   # Screen/Page tests
│   │   ├── map_screen_test.dart
│   │   └── screens_test.dart
│   └── widgets/                   # Custom widget tests
│       └── custom_widgets_test.dart
├── integration/                   # Integration & E2E Tests
│   └── integration_flows_test.dart
└── fixtures/                      # Test data & helpers
    ├── test_data_factory.dart     # Mock data generators
    ├── test_helpers.dart          # Common test utilities
    ├── mock_services.dart         # Mock service implementations
    └── README.md                  # Test fixtures documentation
```

## 🎯 Test Coverage Overview

### ✅ Unit Tests (70+ test cases)

#### Providers (6 test files)
- **ExplorationProvider**: Location loading, selection, progression
- **VisitProvider**: Visit CRUD operations, statistics calculation
- **AuthProvider**: Authentication flows, token management
- **MapProvider**: Map state, zoom, satellite toggle
- **PlacesProvider**: Place management, achievements, XP
- **ProgressProvider**: Level progression, milestone tracking

#### Services (4 test files)
- **ApiService**: HTTP requests, error handling, retries
- **AuthService**: User signup/signin, password reset, token refresh
- **LocationService**: Permission handling, geocoding, tracking
- **StorageService**: Data persistence, caching, encryption

#### Models (5+ test files)
- JSON serialization/deserialization
- Data validation
- Calculation methods
- State immutability

#### Utils (Comprehensive utilities)
- Date/time formatting and parsing
- String validation and manipulation
- Number formatting and calculations
- List operations and filtering
- Input validation

### ✅ Widget Tests (30+ test cases)

#### Screen Tests
- **MapScreen**: District view, markers, satellite toggle
- **HomeScreen**: Profile, progress, districts
- **LoginScreen**: Form validation, error handling
- **VisitsScreen**: List display, filtering, sorting
- **PlacesScreen**: Place cards, details modal, ratings

#### Custom Widget Tests
- **PlaceCard**: Image, ratings, interaction
- **AchievementCard**: Locked/unlocked states, progress
- **VisitStatusBadge**: Status display, color coding
- **DistrictCard**: Completion, statistics
- **LocationMarker**: Animation, state changes
- **CustomButton**: Loading state, disabled state

### ✅ Integration Tests (25+ test cases)

#### User Flows
- Complete authentication (signup → verify → login)
- Location discovery (select district → view locations)
- Place visiting (mark visit → rate → review)
- Achievement system (unlock → level up → share)
- Offline functionality (cache → sync)

### ✅ Test Fixtures & Helpers

#### Data Factories
- `TestDataFactory`: Generate mock locations, visits, users
- `MockApiResponses`: Realistic API response structures
- `MockErrorResponses`: Common error scenarios

#### Test Helpers
- `TestHelpers`: Widget finding, tapping, text entry
- `CustomMatchers`: Assertion utilities
- `PerformanceTestHelper`: Build time, frame rate measurement

#### Mock Services
- `MockApiService`: API simulation
- `MockAuthService`: Authentication simulation
- `MockLocationService`: Location simulation
- `MockStorageService`: Storage simulation
- `MockNotificationService`: Notification simulation

## 🚀 Running Tests

### Run all tests
```bash
flutter test
```

### Run specific test file
```bash
flutter test test/unit/providers/exploration_provider_test.dart
```

### Run tests by pattern
```bash
flutter test --name="Provider"
```

### Run with coverage
```bash
flutter test --coverage
```

### Generate coverage report
```bash
# Using lcov (macOS/Linux)
genhtml coverage/lcov.info -o coverage/html
```

### Run integration tests
```bash
flutter test integration_test/
```

## 📊 Test Statistics

| Category | Files | Test Cases |
|----------|-------|-----------|
| Providers | 6 | 40+ |
| Services | 4 | 30+ |
| Models | 1 | 20+ |
| Utils | 1 | 15+ |
| Screens | 2 | 15+ |
| Widgets | 1 | 15+ |
| Integration | 1 | 25+ |
| **TOTAL** | **16** | **160+** |

## 🔧 Using Test Fixtures

### Using Mock Data Factory

```dart
import 'package:test/fixtures/test_data_factory.dart';

// Create mock location
final location = TestDataFactory.createMockLocation(
  name: 'Galle Face Hotel',
  visited: true,
);

// Create mock visit
final visit = TestDataFactory.createMockVisit(
  placeName: 'Colombo National Museum',
  rating: 5.0,
);

// Create list of mock data
final locations = TestDataFactory.createMockLocationsList(count: 10);
```

### Using Test Helpers

```dart
import 'package:test/fixtures/test_helpers.dart';

testWidgets('Example widget test', (WidgetTester tester) async {
  // Create test widget
  await TestHelpers.pumpWidgetAndSettle(
    tester,
    TestHelpers.createTestApp(home: MyWidget()),
  );

  // Find and interact with widgets
  await TestHelpers.tap(tester, TestHelpers.findByText('Button'));
  await TestHelpers.enterText(
    tester,
    TestHelpers.findByKey('input'),
    'test@example.com',
  );

  // Verify results
  TestHelpers.expectText('Success');
});
```

### Using Mock Services

```dart
import 'package:test/fixtures/mock_services.dart';

void main() {
  test('Test with mock API', () async {
    final mockApi = MockApiService();
    mockApi.mockLocations = TestDataFactory.createMockLocationsList();
    
    final locations = await mockApi.fetchLocations('Colombo');
    expect(locations.length, 5);
  });

  test('Test API failure', () async {
    final mockApi = MockApiService()..shouldFail = true;
    
    expect(
      () => mockApi.fetchLocations('Colombo'),
      throwsException,
    );
  });
}
```

## 📝 Writing New Tests

### Unit Test Template

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FeatureName', () {
    test('should do something', () {
      // Setup
      final mockData = TestDataFactory.createMockLocation();
      
      // Execute
      final result = mockData.someMethod();
      
      // Verify
      expect(result, expectedValue);
    });
  });
}
```

### Widget Test Template

```dart
void main() {
  testWidgets('Widget should render', (WidgetTester tester) async {
    // Setup
    await tester.pumpWidget(
      TestHelpers.createTestApp(home: MyWidget()),
    );

    // Verify
    expect(find.byType(MyWidget), findsOneWidget);
    expect(find.text('Expected Text'), findsOneWidget);

    // Interact
    await tester.tap(find.byIcon(Icons.button));
    await tester.pumpAndSettle();

    // Verify result
    expect(find.text('New Text'), findsOneWidget);
  });
}
```

### Integration Test Template

```dart
void main() {
  group('User Journey', () {
    testWidgets('Complete flow', (WidgetTester tester) async {
      // Build app
      await tester.pumpWidget(MyApp());

      // Step 1: Login
      await TestHelpers.tap(tester, find.text('Login'));
      // ... more steps

      // Step 2: Navigate
      await TestHelpers.tap(tester, find.text('Map'));
      
      // Step 3: Verify complete state
      expect(find.text('Success'), findsOneWidget);
    });
  });
}
```

## 🔄 Continuous Integration

### Running tests in CI/CD pipeline

```yaml
# Example GitHub Actions workflow
- name: Run Tests
  run: flutter test

- name: Generate Coverage
  run: flutter test --coverage

- name: Upload Coverage
  uses: codecov/codecov-action@v3
  with:
    files: ./coverage/lcov.info
```

## 🎓 Best Practices

1. **Isolation**: Each test should be independent and not rely on other tests
2. **Mocking**: Use mock services to isolate units being tested
3. **Clarity**: Use descriptive test names that explain what's being tested
4. **Coverage**: Aim for >80% code coverage
5. **Performance**: Keep individual tests fast (<100ms)
6. **Cleanup**: Reset mocks and state between tests
7. **Assertions**: Use specific assertions rather than generic ones

## 🐛 Debugging Tests

### Run test with debugging
```bash
flutter test --verbose
```

### Run single test to debug
```bash
flutter test test/unit/providers/exploration_provider_test.dart -v
```

### Enable breakpoints in IDE
- Set breakpoint in test
- Run test in debug mode from IDE

## 📚 Resource Links

- [Flutter Testing Documentation](https://flutter.dev/docs/testing)
- [Flutter Riverpod Testing](https://riverpod.dev/docs/essentials/testing)
- [Flutter Widget Testing](https://flutter.dev/docs/testing/testing-overview#widget-tests)

## 👥 Contributing Tests

When adding new features:
1. Write tests first (TDD approach)
2. Ensure 80%+ coverage for new code
3. Update this README with new test categories
4. Run all tests before submitting PR

## 📞 Support

For test-related questions or issues:
- Check existing test examples in this directory
- Review mock service implementations
- See test_helpers.dart for common utilities

---

**Last Updated**: March 2026
**Test Framework**: Flutter Test + Riverpod Testing
**Coverage Target**: >80%
