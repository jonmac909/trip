import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:trippified/presentation/screens/splash/splash_screen.dart';

/// Robot for interacting with SplashScreen in tests
class SplashRobot {
  SplashRobot(this.tester);

  final WidgetTester tester;

  // Finders
  Finder get screen => find.byType(SplashScreen);
  Finder get title => find.text('Unveil The\nTravel Wonders');
  Finder get brandName => find.text('TRIPPIFIED');
  Finder get description =>
      find.text('Take the first step into\nan unforgettable journey');
  Finder get exploreNowButton => find.text('Explore Now');

  // Verifications
  Future<void> verifyScreenDisplayed() async {
    expect(screen, findsOneWidget);
  }

  Future<void> verifyTitleDisplayed() async {
    expect(title, findsOneWidget);
  }

  Future<void> verifyBrandNameDisplayed() async {
    expect(brandName, findsOneWidget);
  }

  Future<void> verifyDescriptionDisplayed() async {
    expect(description, findsOneWidget);
  }

  Future<void> verifyExploreNowButtonDisplayed() async {
    // Scroll to make button visible if needed
    final scrollable = find.byType(Scrollable);
    if (scrollable.evaluate().isNotEmpty) {
      await tester.scrollUntilVisible(
        exploreNowButton,
        100,
        scrollable: scrollable.first,
      );
      await tester.pumpAndSettle();
    }
    expect(exploreNowButton, findsOneWidget);
  }

  Future<void> verifyAllElementsDisplayed() async {
    await verifyScreenDisplayed();
    await verifyTitleDisplayed();
    await verifyBrandNameDisplayed();
    await verifyDescriptionDisplayed();
    await verifyExploreNowButtonDisplayed();
  }

  // Actions
  Future<void> tapExploreNow() async {
    // Scroll to make button visible if needed
    final scrollable = find.byType(Scrollable);
    if (scrollable.evaluate().isNotEmpty) {
      await tester.scrollUntilVisible(
        exploreNowButton,
        100,
        scrollable: scrollable.first,
      );
      await tester.pumpAndSettle();
    }
    await tester.tap(exploreNowButton);
    await tester.pumpAndSettle();
  }
}
