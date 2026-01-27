import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:trippified/presentation/screens/explore/explore_screen.dart';
import 'package:trippified/presentation/screens/explore/explore_history_screen.dart';
import 'package:trippified/presentation/screens/explore/destination_detail_screen.dart';
import 'package:trippified/presentation/screens/explore/city_detail_screen.dart';
import 'package:trippified/presentation/screens/explore/itinerary_preview_screen.dart';

/// Robot for interacting with ExploreScreen in tests
class ExploreRobot {
  ExploreRobot(this.tester);

  final WidgetTester tester;

  // Screen finders
  Finder get screen => find.byType(ExploreScreen);
  Finder get searchBar => find.byIcon(LucideIcons.search);

  // Tabs
  Finder get destinationsTab => find.text('Destinations');
  Finder get itinerariesTab => find.text('Itineraries');

  // See all links
  Finder get seeAllHistory => find.text('See all');

  // Destination cards
  Finder destinationCard(String name) => find.text(name);

  // Itinerary cards
  Finder itineraryCard(String title) => find.text(title);

  // History items
  Finder historyItem(String name) => find.text(name);

  // Verifications
  Future<void> verifyScreenDisplayed() async {
    expect(screen, findsOneWidget);
  }

  Future<void> verifySearchBarDisplayed() async {
    expect(searchBar, findsOneWidget);
  }

  Future<void> verifyTabsDisplayed() async {
    expect(destinationsTab, findsOneWidget);
    expect(itinerariesTab, findsOneWidget);
  }

  Future<void> verifyDestinationCardDisplayed(String name) async {
    expect(destinationCard(name), findsOneWidget);
  }

  Future<void> verifyItineraryCardDisplayed(String title) async {
    expect(itineraryCard(title), findsOneWidget);
  }

  // Actions
  Future<void> tapDestinationsTab() async {
    await tester.tap(destinationsTab);
    await tester.pumpAndSettle();
  }

  Future<void> tapItinerariesTab() async {
    await tester.tap(itinerariesTab);
    await tester.pumpAndSettle();
  }

  Future<void> tapSeeAllHistory() async {
    await tester.tap(seeAllHistory);
    await tester.pumpAndSettle();
  }

  Future<void> tapDestinationCard(String name) async {
    await tester.tap(destinationCard(name));
    await tester.pumpAndSettle();
  }

  Future<void> tapItineraryCard(String title) async {
    await tester.tap(itineraryCard(title));
    await tester.pumpAndSettle();
  }

  Future<void> tapSearchBar() async {
    await tester.tap(searchBar);
    await tester.pumpAndSettle();
  }
}

/// Robot for interacting with ExploreHistoryScreen in tests
class ExploreHistoryRobot {
  ExploreHistoryRobot(this.tester);

  final WidgetTester tester;

  // Screen finders
  Finder get screen => find.byType(ExploreHistoryScreen);
  Finder get pageTitle => find.text('History');

  // History items
  Finder historyItem(String name) => find.text(name);

  // Verifications
  Future<void> verifyScreenDisplayed() async {
    expect(screen, findsOneWidget);
  }

  Future<void> verifyPageTitleDisplayed() async {
    expect(pageTitle, findsOneWidget);
  }

  Future<void> verifyHistoryItemDisplayed(String name) async {
    expect(historyItem(name), findsOneWidget);
  }

  // Actions
  Future<void> tapHistoryItem(String name) async {
    await tester.tap(historyItem(name));
    await tester.pumpAndSettle();
  }
}

/// Robot for interacting with DestinationDetailScreen in tests
class DestinationDetailRobot {
  DestinationDetailRobot(this.tester);

  final WidgetTester tester;

  // Screen finders
  Finder get screen => find.byType(DestinationDetailScreen);

  // Tabs
  Finder get overviewTab => find.text('Overview');
  Finder get citiesTab => find.text('Cities');
  Finder get itinerariesTab => find.text('Itineraries');
  Finder get historyTab => find.text('History');

  // City cards
  Finder cityCard(String name) => find.text(name);

  // Itinerary cards
  Finder itineraryCard(String title) => find.text(title);

  // Verifications
  Future<void> verifyScreenDisplayed() async {
    expect(screen, findsOneWidget);
  }

  Future<void> verifyTabsDisplayed() async {
    expect(overviewTab, findsOneWidget);
    expect(citiesTab, findsOneWidget);
    expect(itinerariesTab, findsOneWidget);
  }

  Future<void> verifyCityCardDisplayed(String name) async {
    expect(cityCard(name), findsOneWidget);
  }

  // Actions
  Future<void> tapOverviewTab() async {
    await tester.tap(overviewTab);
    await tester.pumpAndSettle();
  }

  Future<void> tapCitiesTab() async {
    await tester.tap(citiesTab);
    await tester.pumpAndSettle();
  }

  Future<void> tapItinerariesTab() async {
    await tester.tap(itinerariesTab);
    await tester.pumpAndSettle();
  }

  Future<void> tapHistoryTab() async {
    await tester.tap(historyTab);
    await tester.pumpAndSettle();
  }

  Future<void> tapCityCard(String name) async {
    await tester.tap(cityCard(name));
    await tester.pumpAndSettle();
  }
}

/// Robot for interacting with CityDetailScreen in tests
class CityDetailRobot {
  CityDetailRobot(this.tester);

  final WidgetTester tester;

  // Screen finders
  Finder get screen => find.byType(CityDetailScreen);

  // Tabs
  Finder get overviewTab => find.text('Overview');
  Finder get thingsToDoTab => find.text('Things to do');
  Finder get itinerariesTab => find.text('Itineraries');

  // Place cards
  Finder placeCard(String name) => find.text(name);

  // Save button
  Finder get saveButton => find.byIcon(LucideIcons.heart);
  Finder get savedButton => find.byIcon(LucideIcons.heartHandshake);

  // Verifications
  Future<void> verifyScreenDisplayed() async {
    expect(screen, findsOneWidget);
  }

  Future<void> verifyTabsDisplayed() async {
    expect(overviewTab, findsOneWidget);
    expect(thingsToDoTab, findsOneWidget);
    expect(itinerariesTab, findsOneWidget);
  }

  Future<void> verifyPlaceCardDisplayed(String name) async {
    expect(placeCard(name), findsOneWidget);
  }

  // Actions
  Future<void> tapOverviewTab() async {
    await tester.tap(overviewTab);
    await tester.pumpAndSettle();
  }

  Future<void> tapThingsToDoTab() async {
    await tester.tap(thingsToDoTab);
    await tester.pumpAndSettle();
  }

  Future<void> tapItinerariesTab() async {
    await tester.tap(itinerariesTab);
    await tester.pumpAndSettle();
  }

  Future<void> tapPlaceCard(String name) async {
    await tester.tap(placeCard(name));
    await tester.pumpAndSettle();
  }

  Future<void> tapSaveButton() async {
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
  }
}

/// Robot for interacting with ItineraryPreviewScreen in tests
class ItineraryPreviewRobot {
  ItineraryPreviewRobot(this.tester);

  final WidgetTester tester;

  // Screen finders
  Finder get screen => find.byType(ItineraryPreviewScreen);

  // Day cards
  Finder dayCard(int day) => find.textContaining('Day $day');

  // CTA
  Finder get saveItineraryCta => find.text('Save itinerary');
  Finder get customizeCta => find.text('Customize');

  // Verifications
  Future<void> verifyScreenDisplayed() async {
    expect(screen, findsOneWidget);
  }

  Future<void> verifyDayCardDisplayed(int day) async {
    expect(dayCard(day), findsOneWidget);
  }

  Future<void> verifySaveCtaDisplayed() async {
    expect(saveItineraryCta, findsOneWidget);
  }

  // Actions
  Future<void> tapDayCard(int day) async {
    await tester.tap(dayCard(day));
    await tester.pumpAndSettle();
  }

  Future<void> tapSaveItinerary() async {
    await tester.tap(saveItineraryCta);
    await tester.pumpAndSettle();
  }

  Future<void> tapCustomize() async {
    await tester.tap(customizeCta);
    await tester.pumpAndSettle();
  }
}
