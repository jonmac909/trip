import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test helper extensions for WidgetTester
extension WidgetTesterExtensions on WidgetTester {
  /// Pump the widget and wait for all animations to settle
  Future<void> pumpAndSettleWithTimeout({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    await pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      timeout,
    );
  }

  /// Tap a widget and wait for animations to settle
  Future<void> tapAndSettle(Finder finder) async {
    await tap(finder);
    await pumpAndSettle();
  }

  /// Enter text in a text field and wait for animations
  Future<void> enterTextAndSettle(Finder finder, String text) async {
    await enterText(finder, text);
    await pumpAndSettle();
  }

  /// Scroll until a widget is visible
  Future<void> scrollUntilVisible(
    Finder finder, {
    Finder? scrollable,
    double delta = 100,
    int maxScrolls = 50,
  }) async {
    final scrollableFinder = scrollable ?? find.byType(Scrollable).first;

    for (var i = 0; i < maxScrolls; i++) {
      if (finder.evaluate().isNotEmpty) {
        return;
      }
      await drag(scrollableFinder, Offset(0, -delta));
      await pumpAndSettle();
    }
  }

  /// Wait for a specific widget to appear
  Future<bool> waitForWidget(
    Finder finder, {
    Duration timeout = const Duration(seconds: 5),
    Duration interval = const Duration(milliseconds: 100),
  }) async {
    final stopwatch = Stopwatch()..start();
    while (stopwatch.elapsed < timeout) {
      await pump(interval);
      if (finder.evaluate().isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  /// Navigate back
  Future<void> goBack() async {
    final NavigatorState navigator = state(find.byType(Navigator));
    navigator.pop();
    await pumpAndSettle();
  }
}

/// Common finders for Trippified app
class AppFinders {
  // Navigation
  static Finder get bottomNav => find.byType(BottomNavigationBar);
  static Finder bottomNavItem(int index) =>
      find.byKey(Key('bottom_nav_item_$index'));

  // Common buttons
  static Finder buttonWithText(String text) =>
      find.widgetWithText(GestureDetector, text);
  static Finder elevatedButtonWithText(String text) =>
      find.widgetWithText(ElevatedButton, text);

  // Text fields
  static Finder textFieldWithHint(String hint) =>
      find.widgetWithText(TextField, hint);

  // Icons
  static Finder iconButton(IconData icon) =>
      find.widgetWithIcon(IconButton, icon);

  // Tabs
  static Finder tabWithText(String text) => find.widgetWithText(Tab, text);
}

/// Test data generators
class TestData {
  static const mockCountries = ['Japan', 'Thailand', 'Vietnam', 'Indonesia'];
  static const mockCities = ['Tokyo', 'Kyoto', 'Osaka', 'Bangkok', 'Hanoi'];
  static const mockTripSizes = ['Weekend', 'Week-long', 'Two weeks', 'Month+'];

  static Map<String, dynamic> mockTrip({
    String? id,
    String? title,
    List<String>? countries,
  }) {
    return {
      'id': id ?? 'test-trip-1',
      'title': title ?? 'Test Trip',
      'countries': countries ?? ['Japan'],
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  static Map<String, dynamic> mockDestination({
    String? id,
    String? name,
    String? country,
  }) {
    return {
      'id': id ?? 'dest-1',
      'name': name ?? 'Tokyo',
      'country': country ?? 'Japan',
      'image_url': 'https://example.com/tokyo.jpg',
    };
  }

  static Map<String, dynamic> mockCity({
    String? id,
    String? name,
    String? region,
  }) {
    return {
      'id': id ?? 'city-1',
      'name': name ?? 'Tokyo',
      'region': region ?? 'Kanto',
    };
  }
}

/// Screen test helpers
class ScreenTestHelper {
  /// Verify a screen is displayed by checking for expected widgets
  static Future<void> verifyScreenDisplayed(
    WidgetTester tester,
    String screenTitle,
  ) async {
    expect(find.text(screenTitle), findsOneWidget);
  }

  /// Verify navigation to a new screen
  static Future<void> verifyNavigatedTo(
    WidgetTester tester,
    Type screenType,
  ) async {
    await tester.pumpAndSettle();
    expect(find.byType(screenType), findsOneWidget);
  }
}

/// Network image loading helper for tests
/// Replaces network images with placeholders in tests
class TestImageProvider {
  static ImageProvider placeholder() {
    return const AssetImage('assets/images/placeholder.png');
  }
}
