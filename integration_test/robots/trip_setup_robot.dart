import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:trippified/presentation/screens/trip_setup/trip_setup_screen.dart';
import 'package:trippified/presentation/screens/trip_setup/recommended_routes_screen.dart';

/// Robot for interacting with TripSetupScreen in tests
class TripSetupRobot {
  TripSetupRobot(this.tester);

  final WidgetTester tester;

  // Screen finders
  Finder get screen => find.byType(TripSetupScreen);
  Finder get pageTitle => find.text('Plan a Trip');

  // Section headers - actual UI text
  Finder get whereToSection => find.text('Where do you want to go?');
  Finder get tripSizeSection => find.text('How long is your trip?');

  // Country input - use text field finder
  Finder get countryInput => find.byType(TextField);
  Finder countryOption(String country) => find.text(country);

  // Trip size options - actual UI text
  Finder get shortTripOption => find.text('Short trip');
  Finder get weekLongOption => find.text('Week-long');
  Finder get longTripOption => find.text('Long or open-ended');

  // CTA - actual button text
  Finder get seeRoutesCta => find.text('See Recommended Routes');

  // Selected country chips
  Finder countryChip(String country) => find.widgetWithText(Chip, country);

  // Verifications
  Future<void> verifyScreenDisplayed() async {
    expect(screen, findsOneWidget);
  }

  Future<void> verifyPageTitleDisplayed() async {
    expect(pageTitle, findsOneWidget);
  }

  Future<void> verifySectionsDisplayed() async {
    expect(whereToSection, findsOneWidget);
    expect(tripSizeSection, findsOneWidget);
  }

  Future<void> verifyTripSizeOptionsDisplayed() async {
    expect(shortTripOption, findsOneWidget);
    expect(weekLongOption, findsOneWidget);
    expect(longTripOption, findsOneWidget);
  }

  Future<void> verifySeeRoutesCtaDisplayed() async {
    expect(seeRoutesCta, findsOneWidget);
  }

  Future<void> verifyCountrySelected(String country) async {
    expect(countryChip(country), findsOneWidget);
  }

  Future<void> verifyAllElementsDisplayed() async {
    await verifyScreenDisplayed();
    await verifyPageTitleDisplayed();
    await verifySectionsDisplayed();
    await verifyTripSizeOptionsDisplayed();
    await verifySeeRoutesCtaDisplayed();
  }

  // Actions
  Future<void> enterCountry(String country) async {
    await tester.enterText(countryInput, country);
    await tester.pumpAndSettle();
  }

  Future<void> selectCountry(String country) async {
    await enterCountry(country);
    await tester.tap(countryOption(country));
    await tester.pumpAndSettle();
  }

  Future<void> selectShortTrip() async {
    await tester.tap(shortTripOption);
    await tester.pumpAndSettle();
  }

  Future<void> selectWeekLong() async {
    await tester.tap(weekLongOption);
    await tester.pumpAndSettle();
  }

  Future<void> selectLongTrip() async {
    await tester.tap(longTripOption);
    await tester.pumpAndSettle();
  }

  Future<void> tapSeeRoutes() async {
    await tester.tap(seeRoutesCta);
    await tester.pumpAndSettle();
  }

  Future<void> setupTrip(String country, String tripSize) async {
    await selectCountry(country);
    switch (tripSize) {
      case 'Short trip':
        await selectShortTrip();
      case 'Week-long':
        await selectWeekLong();
      case 'Long or open-ended':
        await selectLongTrip();
    }
    await tapSeeRoutes();
  }
}

/// Robot for interacting with RecommendedRoutesScreen in tests
class RecommendedRoutesRobot {
  RecommendedRoutesRobot(this.tester);

  final WidgetTester tester;

  // Screen finders
  Finder get screen => find.byType(RecommendedRoutesScreen);
  Finder get pageTitle => find.text('Recommended routes');

  // Route cards
  Finder routeCard(String routeName) => find.text(routeName);

  // CTA
  Finder get createItineraryCta => find.text('Create itinerary');

  // Verifications
  Future<void> verifyScreenDisplayed() async {
    expect(screen, findsOneWidget);
  }

  Future<void> verifyPageTitleDisplayed() async {
    expect(pageTitle, findsOneWidget);
  }

  Future<void> verifyRouteCardDisplayed(String routeName) async {
    expect(routeCard(routeName), findsOneWidget);
  }

  // Actions
  Future<void> selectRoute(String routeName) async {
    await tester.tap(routeCard(routeName));
    await tester.pumpAndSettle();
  }

  Future<void> tapCreateItinerary() async {
    await tester.tap(createItineraryCta);
    await tester.pumpAndSettle();
  }
}
