# 🧪 Test Configuration & Setup Guide

## Prerequisites

Ensure you have the following installed:
- Flutter SDK 3.x+
- Dart SDK 3.x+
- Android SDK / iOS SDK (for running on devices)

## Quick Start

### 1. Install Dependencies
```bash
cd mobile
flutter pub get
```

### 2. Run All Tests
```bash
flutter test
```

### 3. Generate Coverage Report
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Test Commands

### Unit Tests Only
```bash
flutter test test/unit/
```

### Widget Tests Only
```bash
flutter test test/widget/
```

### Integration Tests Only
```bash
flutter test test/integration/
```

### Specific Provider Tests
```bash
flutter test test/unit/providers/exploration_provider_test.dart
```

### Tests Matching Pattern
```bash
flutter test --name="Provider"
```

### Verbose Output
```bash
flutter test --verbose
```

### Watch Mode (Auto-rerun on changes)
```bash
flutter test --watch
```

### Stop on First Failure
```bash
flutter test --fail-fast
```

## Platform-Specific Testing

### Test on Android Emulator
```bash
flutter emulators --launch Pixel_5_API_30
flutter test
```

### Test on iOS Simulator
```bash
open -a Simulator
flutter test
```

### Test on Physical Device
```bash
flutter devices  # List connected devices
flutter test -d <device_id>
```

## Coverage Configuration

### Generate Coverage
```bash
# Install lcov if not present (macOS)
brew install lcov

# Generate coverage report
flutter test --coverage

# View HTML report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Minimum Coverage Threshold
```bash
# Check if coverage meets threshold (90%)
# Add to CI/CD pipeline
COVERAGE=$(grep "line rate" coverage/index.html | grep -oP '(?<=line rate=")[^"]*')
if (( $(echo "$COVERAGE < 0.90" | bc -l) )); then
  echo "Coverage below 90%: $COVERAGE"
  exit 1
fi
```

## CI/CD Integration

### GitHub Actions Example
```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      
      - name: Get dependencies
        run: flutter pub get
      
      - name: Run tests
        run: flutter test --coverage
      
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
```

### GitLab CI Example
```yaml
test:
  image: cirrusci/flutter:latest
  script:
    - flutter pub get
    - flutter test --coverage
  coverage: '/line rate="(\d+(\.\d+)?)"/'
```

## 🔧 Test Configuration Files

### pubspec.yaml Test Dependencies
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_riverpod: ^2.x.x
  mockito: ^5.x.x
  riverpod_generator: ^2.x.x
```

### Analysis Options (analysis_options.yaml)
```yaml
linter:
  rules:
    - test_types_in_equals
    - avoid_empty_else
    - avoid_returning_null_for_future
```

## 📋 Test Naming Conventions

### File Naming
- Unit test: `feature_test.dart`
- Widget test: `widget_name_test.dart`
- Integration test: `user_flow_test.dart`

### Test Group Naming
```dart
group('ClassName', () {
  // Organized by feature
});

group('ClassName Operation', () {
  // Organized by operation
});
```

### Test Case Naming
```dart
test('should do something when condition is met', () {
  // AAA: Arrange, Act, Assert
  // Arrange: Setup
  // Act: Execute
  // Assert: Verify
});
```

## 🎯 Test Organization Best Practices

### Arrange-Act-Assert Pattern
```dart
test('should calculate total cost', () {
  // Arrange
  final visit = Visit(cost: 100);
  
  // Act
  final total = visit.calculateTotal();
  
  // Assert
  expect(total, 100);
});
```

### Using Test Helpers
```dart
import 'package:test/fixtures/test_helpers.dart';
import 'package:test/fixtures/test_data_factory.dart';

void main() {
  group('My Feature', () {
    setUp(() {
      // Common setup for all tests
    });

    tearDown(() {
      // Common cleanup for all tests
    });

    test('should work', () {
      final mockData = TestDataFactory.createMockLocation();
      expect(mockData, isNotNull);
    });
  });
}
```

## 🐛 Debugging Tests

### Enable Logging
```dart
void main() {
  testSetUp(() {
    debugPrintBeginFrameBanner = true;
    debugPrintEndFrameBanner = true;
  });
}
```

### Print Debug Info
```dart
test('debug info', () {
  debugPrint('This info will be printed');
  addTearDown(tester.binding.window.physicalSizeTestValue = Size.zero);
});
```

### Use IDE Debugger
1. Set breakpoint in test
2. Run test in debug mode from IDE
3. Step through code

### Verbose Logging
```bash
flutter test --verbose 2>&1 | tee test_output.log
```

## 📊 Coverage Targets

| Category | Target | Current |
|----------|--------|---------|
| Overall | 80% | 0% |
| Unit Tests | 90% | 0% |
| Widget Tests | 75% | 0% |
| Critical Paths | 100% | 0% |

## ⚡ Performance Optimization

### Test Timeout Configuration
```dart
testWidgetsSetUp((){
  // Sets default timeout for all widget tests
});

testWidgets('name', (WidgetTester tester) {
  // This test has custom timeout
}, timeout: Timeout(Duration(seconds: 30)));
```

### Parallel Testing
```bash
# Run tests in parallel (faster execution)
flutter test --concurrency=4
```

### Skip Slow Tests
```dart
test('slow operation', () {
  // Test implementation
}, skip: true);

// Or conditionally
test('feature X', () {}, skip: isWeb);
```

## 🔍 Common Issues & Solutions

### Issue: Tests timeout
**Solution**: Increase timeout or optimize slow operations
```bash
flutter test --timeout=30s
```

### Issue: Provider not found in test
**Solution**: Wrap widget with ProviderScope
```dart
await tester.pumpWidget(
  ProviderScope(
    child: MaterialApp(home: MyWidget()),
  ),
);
```

### Issue: Mock service not working
**Solution**: Use proper type matching in mocks
```dart
when(mockService.method()).thenAnswer(
  (_) => Future.value(expectedValue)
);
```

### Issue: Widget state not updating
**Solution**: Call pumpAndSettle after interactions
```dart
await tester.tap(find.byType(Button));
await tester.pumpAndSettle(); // Wait for animations
```

## 📚 Resources

- [Flutter Testing Guide](https://flutter.dev/docs/testing)
- [Riverpod Testing](https://riverpod.dev/docs/essentials/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)

## 🚀 Continuous Improvement

1. **Regular Review**: Review test coverage monthly
2. **Refactor Tests**: Keep tests maintainable
3. **Update Mocks**: Keep mocks in sync with real services
4. **Document**: Document complex test scenarios
5. **Measure**: Track test execution times

---

**Last Updated**: March 2026
**Flutter Version**: 3.x+
**Dart Version**: 3.x+
