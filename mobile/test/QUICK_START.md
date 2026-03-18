# 🎯 Test Suite - Quick Reference & Troubleshooting

## ✅ Fixed Issues

### Issue 1: ProviderScope Not Found in Widget Tests
**Problem**: Widget tests using Riverpod consumers fail with "No ProviderScope found"
**Solution**: Wrap all test widgets with ProviderScope
```dart
// ✓ Correct
testWidgets('test', (WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: MyConsumerWidget(),
      ),
    ),
  );
});
```

### Issue 2: Wrong Package Name in Imports
**Problem**: Tests import `package:gemified_travel/...` but package is `gemified_travel_portfolio`
**Solution**: Use correct package name
```dart
// ✗ Wrong
import 'package:gemified_travel/features/...';

// ✓ Correct
import 'package:gemified_travel_portfolio/features/...';
```

## 🚀 Running Tests

### Quick Test Run
```bash
cd mobile
flutter test
```

### Run Specific Test Category
```bash
# Unit tests only
flutter test test/unit/

# Widget tests only
flutter test test/widget/

# Integration tests only
flutter test test/integration/
```

### Run Single Test File
```bash
flutter test test/unit/providers/exploration_provider_test.dart
```

### Run With Coverage
```bash
flutter test --coverage
```

## 📝 Test File Structure

All test files follow this pattern:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gemified_travel_portfolio/features/...';  // ← Correct package

void main() {
  group('Feature Name', () {
    test('should do something', () {
      // Arrange - Setup
      // Act - Execute
      // Assert - Verify
      expect(result, expectedValue);
    });
  });
}
```

## 🔧 Widget Test Template

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Helper to wrap widgets
Widget _withProvider(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  testWidgets('Widget test', (WidgetTester tester) async {
    // ✓ IMPORTANT: Wrap widget with _withProvider
    await tester.pumpWidget(_withProvider(
      MyConsumerWidget(),
    ));
    
    await tester.pumpAndSettle();
    expect(find.text('Expected Text'), findsOneWidget);
  });
}
```

## 📚 Available Test Resources

### Test Data Factory
Mock data generators for testing:
```dart
import 'test/fixtures/test_data_factory.dart';

// Create mock location
final location = TestDataFactory.createMockLocation(
  name: 'Test Place',
  visited: true,
);

// Create mock list
final locations = TestDataFactory.createMockLocationsList(count: 5);
```

### Mock Services
Mockable service implementations:
```dart
import 'test/fixtures/mock_services.dart';

// Create mock service
final mockApi = MockApiService();
mockApi.mockLocations = locations;

// Simulate failure
mockApi.shouldFail = true;

// Get results
final result = await mockApi.fetchLocations('Colombo');
```

### Test Helpers
Common widget testing utilities:
```dart
import 'test/fixtures/test_helpers.dart';

// Create test app
TestHelpers.createTestApp(home: MyWidget());

// Find widgets
TestHelpers.findByText('Button');
TestHelpers.findByType<CustomWidget>();

// Interact with widgets
await TestHelpers.tap(tester, find.text('Click'));
await TestHelpers.enterText(tester, find.byKey('input'), 'text');
```

## 🐛 Common Test Issues & Solutions

### Issue: "Bad state: No ProviderScope found"
**Cause**: Widget uses Riverpod but not wrapped in ProviderScope
**Fix**: Use `_withProvider()` wrapper
```dart
await tester.pumpWidget(_withProvider(MyWidget()));
```

### Issue: "Couldn't resolve the package 'gemified_travel'"
**Cause**: Wrong package name in import
**Fix**: Change to `gemified_travel_portfolio`
```dart
import 'package:gemified_travel_portfolio/features/...';
```

### Issue: "Expected: exactly one matching candidate / Actual: Found 0 widgets"
**Cause**: Widget not rendered or text doesn't match
**Fix**: Check widget is pumped, text is exact match, add pumpAndSettle()
```dart
await tester.pumpWidget(...);
await tester.pumpAndSettle();  // ← Add this
expect(find.text('Exact Text'), findsOneWidget);
```

### Issue: Tests timeout
**Cause**: Animations or delays not settling
**Fix**: Use pumpAndSettle() or increase timeout
```dart
await tester.pumpAndSettle();  // ← Wait for animations
// OR
flutter test --timeout=30s
```

## ✨ Best Practices

1. **Always wrap Riverpod widgets**
   ```dart
   ProviderScope(child: MyWidget())
   ```

2. **Use correct package name**
   ```dart
   import 'package:gemified_travel_portfolio/...';
   ```

3. **Follow AAA pattern**
   ```dart
   test('name', () {
     // Arrange - Setup
     // Act - Execute
     // Assert - Verify
   });
   ```

4. **Use good test names**
   ```dart
   test('should show error when email is invalid', () {});
   ```

5. **Settle animations**
   ```dart
   await tester.pumpAndSettle();
   ```

## 📊 Test Coverage Goals

| Category | Target | Command |
|----------|--------|---------|
| Overall | 80%+ | `flutter test --coverage` |
| Critical Paths | 100% | - |
| Unit Tests | 90%+ | `flutter test test/unit/` |
| Widget Tests | 75%+ | `flutter test test/widget/` |

## 🔗 Related Documentation

- [test/README.md](../README.md) - Full test suite overview
- [test/SETUP.md](../SETUP.md) - Detailed setup and configuration
- [Flutter Testing Docs](https://flutter.dev/docs/testing)
- [Riverpod Testing](https://riverpod.dev/docs/essentials/testing)

## 💡 Tips

### Speed up tests
```bash
# Run tests in parallel
flutter test --concurrency=4

# Run only quick tests
flutter test --timeout=5s
```

### Debug failing test
```bash
# Verbose output
flutter test --verbose

# Run single test
flutter test test/unit/providers/exploration_provider_test.dart -v
```

### View coverage report
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # macOS
start coverage/html/index.html # Windows
```

---

**Last Updated**: March 2026
**Package Name**: `gemified_travel_portfolio`
**Framework**: Flutter Test + Riverpod
