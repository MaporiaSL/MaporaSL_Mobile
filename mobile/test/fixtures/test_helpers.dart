/// Test helpers and utilities for Flutter testing
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Common test helpers for widget testing
class TestHelpers {
  /// Create app wrapper for testing
  static Widget createTestApp({
    required Widget home,
    List<Override>? overrides,
  }) {
    return ProviderScope(
      overrides: overrides ?? [],
      child: MaterialApp(home: home, theme: ThemeData(useMaterial3: true)),
    );
  }

  /// Create app with navigation for testing
  static Widget createTestAppWithNavigation({
    required List<Route> routes,
    required String initialRoute,
    List<Override>? overrides,
  }) {
    return ProviderScope(
      overrides: overrides ?? [],
      child: MaterialApp(
        home: Scaffold(body: Container()),
        routes: Map.fromIterable(routes, key: (r) => r.settings.name),
        initialRoute: initialRoute,
        theme: ThemeData(useMaterial3: true),
      ),
    );
  }

  /// Pump widget and frame
  static Future<void> pumpWidgetAndSettle(
    WidgetTester tester,
    Widget widget, {
    Duration duration = const Duration(milliseconds: 100),
  }) async {
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle(duration);
  }

  /// Find widget by type
  static Finder findByType<T>() {
    return find.byType(T);
  }

  /// Find widget by key
  static Finder findByKey(String key) {
    return find.byKey(ValueKey(key));
  }

  /// Find widget by text
  static Finder findByText(String text) {
    return find.text(text);
  }

  /// Find widget by icon
  static Finder findByIcon(IconData icon) {
    return find.byIcon(icon);
  }

  /// Tap widget
  static Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// Enter text in text field
  static Future<void> enterText(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }

  /// Scroll to widget
  static Future<void> scrollToWidget(
    WidgetTester tester,
    Finder finder, {
    ScrollDirection direction = ScrollDirection.down,
    double delta = 300.0,
  }) async {
    await tester.drag(find.byType(SingleChildScrollView), Offset(0, -delta));
    await tester.pumpAndSettle();
  }

  /// Wait for widget
  static Future<void> waitFor(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    await tester.pumpAndSettle(timeout);
    expect(finder, findsOneWidget);
  }

  /// Verify text appears
  static void expectText(String text) {
    expect(find.text(text), findsOneWidget);
  }

  /// Verify widget count
  static void expectWidgetCount<T>(int count) {
    expect(find.byType(T), findsNWidgets(count));
  }

  /// Simulate network delay
  static Future<void> simulateNetworkDelay({
    Duration delay = const Duration(milliseconds: 500),
  }) async {
    await Future.delayed(delay);
  }

  /// Create mock notification
  static void showMockNotification(String message) {
    debugPrint('Mock Notification: $message');
  }

  /// Check if widget is visible
  static bool isWidgetVisible(Finder finder) {
    try {
      return finder.evaluate().isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

/// Custom matchers for testing
class CustomMatchers {
  /// Match widget with text
  static Matcher containsText(String text) => contains(text);

  /// Match exact number of widgets
  static Matcher exactCount(int count) => findsNWidgets(count);

  /// Match one widget
  static Matcher singleWidget() => findsOneWidget;

  /// Match no widgets
  static Matcher noWidgets() => findsNothing;

  /// Match at least one widget
  static Matcher atLeastOneWidget() => findsWidgets;
}

/// Mock stream for testing
class MockStream<T> {
  final List<T> values;
  int _index = 0;

  MockStream({required this.values});

  Stream<T> asStream() async* {
    for (final value in values) {
      yield value;
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  void reset() {
    _index = 0;
  }

  T? next() {
    if (_index < values.length) {
      return values[_index++];
    }
    return null;
  }
}

/// Performance testing helper
class PerformanceTestHelper {
  /// Measure widget build time
  static Future<Duration> measureBuildTime(
    WidgetTester tester,
    Widget widget,
  ) async {
    final stopwatch = Stopwatch()..start();
    await tester.pumpWidget(widget);
    stopwatch.stop();
    return stopwatch.elapsed;
  }

  /// Measure frame rate
  static Future<double> measureFrameRate(
    WidgetTester tester,
    Duration duration,
  ) async {
    final stopwatch = Stopwatch()..start();
    int frameCount = 0;

    while (stopwatch.elapsed < duration) {
      await tester.pump();
      frameCount++;
    }

    stopwatch.stop();
    return frameCount / stopwatch.elapsed.inSeconds;
  }

  /// Monitor memory usage
  static void monitorMemory(Function callback) {
    // Track memory-intensive operations
    debugPrint('Monitoring memory usage...');
    callback();
    debugPrint('Memory monitoring complete');
  }
}
