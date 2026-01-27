import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:trippified/presentation/screens/saved/saved_screen.dart';
import 'package:trippified/presentation/screens/saved/trip_hub_drafts_screen.dart';
import 'package:trippified/presentation/screens/saved/tiktok_scan_results_screen.dart';
import 'package:trippified/presentation/screens/saved/saved_city_detail_screen.dart';
import 'package:trippified/presentation/screens/saved/customize_itinerary_screen.dart';
import 'package:trippified/presentation/screens/saved/review_route_screen.dart';
import 'package:trippified/presentation/screens/saved/saved_day_builder_screen.dart';

/// Robot for interacting with SavedScreen in tests
class SavedRobot {
  SavedRobot(this.tester);

  final WidgetTester tester;

  // Screen finders
  Finder get screen => find.byType(SavedScreen);
  Finder get pageTitle => find.text('Saved');

  // Tabs - Note: Order is Itineraries, Places, Links in actual UI
  Finder get itinerariesTab => find.text('Itineraries');
  Finder get placesTab => find.text('Places');
  Finder get linksTab => find.text('Links');

  // Scan TikTok button
  Finder get scanTiktokButton => find.text('Scan TikTok');
  Finder get scanTiktokIcon => find.byIcon(LucideIcons.scan);

  // Empty state
  Finder get emptyStateText => find.text('Nothing saved yet');
  Finder get startExploringCta => find.text('Start Exploring');

  // City blocks
  Finder cityBlock(String cityName) => find.text(cityName);

  // Itinerary cards
  Finder itineraryCard(String title) => find.text(title);

  // Link cards
  Finder linkCard(String title) => find.text(title);

  // Verifications
  Future<void> verifyScreenDisplayed() async {
    expect(screen, findsOneWidget);
  }

  Future<void> verifyPageTitleDisplayed() async {
    expect(pageTitle, findsOneWidget);
  }

  Future<void> verifyTabsDisplayed() async {
    expect(placesTab, findsOneWidget);
    expect(itinerariesTab, findsOneWidget);
    expect(linksTab, findsOneWidget);
  }

  Future<void> verifyEmptyStateDisplayed() async {
    expect(emptyStateText, findsOneWidget);
  }

  Future<void> verifyCityBlockDisplayed(String cityName) async {
    expect(cityBlock(cityName), findsOneWidget);
  }

  Future<void> verifyItineraryCardDisplayed(String title) async {
    expect(itineraryCard(title), findsOneWidget);
  }

  // Actions
  Future<void> tapPlacesTab() async {
    await tester.tap(placesTab);
    await tester.pumpAndSettle();
  }

  Future<void> tapItinerariesTab() async {
    await tester.tap(itinerariesTab);
    await tester.pumpAndSettle();
  }

  Future<void> tapLinksTab() async {
    await tester.tap(linksTab);
    await tester.pumpAndSettle();
  }

  Future<void> tapScanTiktok() async {
    await tester.tap(scanTiktokButton);
    await tester.pumpAndSettle();
  }

  Future<void> tapCityBlock(String cityName) async {
    await tester.tap(cityBlock(cityName));
    await tester.pumpAndSettle();
  }

  Future<void> tapItineraryCard(String title) async {
    await tester.tap(itineraryCard(title));
    await tester.pumpAndSettle();
  }

  Future<void> tapStartExploring() async {
    await tester.tap(startExploringCta);
    await tester.pumpAndSettle();
  }
}

/// Robot for interacting with TripHubDraftsScreen in tests
class TripHubDraftsRobot {
  TripHubDraftsRobot(this.tester);

  final WidgetTester tester;

  // Screen finders
  Finder get screen => find.byType(TripHubDraftsScreen);
  Finder get pageTitle => find.text('Drafts');

  // Draft cards
  Finder draftCard(String title) => find.text(title);

  // Verifications
  Future<void> verifyScreenDisplayed() async {
    expect(screen, findsOneWidget);
  }

  Future<void> verifyPageTitleDisplayed() async {
    expect(pageTitle, findsOneWidget);
  }

  Future<void> verifyDraftCardDisplayed(String title) async {
    expect(draftCard(title), findsOneWidget);
  }

  // Actions
  Future<void> tapDraftCard(String title) async {
    await tester.tap(draftCard(title));
    await tester.pumpAndSettle();
  }
}

/// Robot for interacting with TiktokScanResultsScreen in tests
class TiktokScanResultsRobot {
  TiktokScanResultsRobot(this.tester);

  final WidgetTester tester;

  // Screen finders
  Finder get screen => find.byType(TiktokScanResultsScreen);

  // Loading state
  Finder get scanningHeader => find.text('Scanning...');
  Finder get scanningText => find.text('Scanning for places...');
  Finder get analyzingText => find.text('Analyzing content with AI');

  // Error state
  Finder get tryAgainButton => find.text('Try Again');

  // Empty state
  Finder get scanCompleteHeader => find.text('Scan Complete');
  Finder get noPlacesFound => find.text('No places found');
  Finder get emptyHint =>
      find.text('Try a different URL or upload screenshots');

  // Results state
  Finder foundPlacesHeader(int count) =>
      find.text('Found $count Place${count != 1 ? 's' : ''}');
  Finder placeCard(String name) => find.text(name);

  // Footer CTAs
  Finder get savePlacesCta => find.textContaining('Save');
  Finder savePlacesCountCta(int count) => find.text('Save $count Places');
  Finder get createTripCta => find.text('Create a Trip');

  // Back button
  Finder get backButton => find.byIcon(LucideIcons.arrowLeft);

  // Verifications
  Future<void> verifyScreenDisplayed() async {
    expect(screen, findsOneWidget);
  }

  Future<void> verifyLoadingState() async {
    expect(scanningHeader, findsOneWidget);
    expect(scanningText, findsOneWidget);
    expect(analyzingText, findsOneWidget);
  }

  Future<void> verifyErrorState() async {
    expect(tryAgainButton, findsOneWidget);
  }

  Future<void> verifyEmptyState() async {
    expect(scanCompleteHeader, findsOneWidget);
    expect(noPlacesFound, findsOneWidget);
    expect(emptyHint, findsOneWidget);
  }

  Future<void> verifyFooterHidden() async {
    expect(createTripCta, findsNothing);
  }

  Future<void> verifyFooterDisplayed() async {
    expect(createTripCta, findsOneWidget);
  }

  Future<void> verifyPlaceCardDisplayed(String name) async {
    expect(placeCard(name), findsOneWidget);
  }

  // Actions
  Future<void> tapTryAgain() async {
    await tester.tap(tryAgainButton);
    await tester.pumpAndSettle();
  }

  Future<void> tapCreateTrip() async {
    await tester.tap(createTripCta);
    await tester.pumpAndSettle();
  }

  Future<void> tapBack() async {
    await tester.tap(backButton.first);
    await tester.pumpAndSettle();
  }

  Future<void> tapPlaceCard(String name) async {
    await tester.tap(placeCard(name));
    await tester.pumpAndSettle();
  }
}

/// Robot for interacting with SavedCityDetailScreen in tests
class SavedCityDetailRobot {
  SavedCityDetailRobot(this.tester);

  final WidgetTester tester;

  // Screen finders
  Finder get screen => find.byType(SavedCityDetailScreen);

  // Place cards
  Finder placeCard(String name) => find.text(name);

  // CTA
  Finder get createItineraryCta => find.text('Create itinerary');

  // Verifications
  Future<void> verifyScreenDisplayed() async {
    expect(screen, findsOneWidget);
  }

  Future<void> verifyPlaceCardDisplayed(String name) async {
    expect(placeCard(name), findsOneWidget);
  }

  // Actions
  Future<void> tapPlaceCard(String name) async {
    await tester.tap(placeCard(name));
    await tester.pumpAndSettle();
  }

  Future<void> tapCreateItinerary() async {
    await tester.tap(createItineraryCta);
    await tester.pumpAndSettle();
  }
}

/// Robot for interacting with CustomizeItineraryScreen in tests
class CustomizeItineraryRobot {
  CustomizeItineraryRobot(this.tester);

  final WidgetTester tester;

  // Screen finders
  Finder get screen => find.byType(CustomizeItineraryScreen);
  Finder get pageTitle => find.text('Customize');

  // Day cards
  Finder dayCard(int day) => find.textContaining('Day $day');

  // Place cards
  Finder placeCard(String name) => find.text(name);

  // CTA
  Finder get reviewCta => find.text('Review');
  Finder get saveCta => find.text('Save');

  // Verifications
  Future<void> verifyScreenDisplayed() async {
    expect(screen, findsOneWidget);
  }

  Future<void> verifyDayCardDisplayed(int day) async {
    expect(dayCard(day), findsOneWidget);
  }

  // Actions
  Future<void> tapReview() async {
    await tester.tap(reviewCta);
    await tester.pumpAndSettle();
  }

  Future<void> tapSave() async {
    await tester.tap(saveCta);
    await tester.pumpAndSettle();
  }
}

/// Robot for interacting with ReviewRouteScreen in tests
class ReviewRouteRobot {
  ReviewRouteRobot(this.tester);

  final WidgetTester tester;

  // Screen finders
  Finder get screen => find.byType(ReviewRouteScreen);
  Finder get pageTitle => find.text('Review route');

  // Day timeline
  Finder dayTimeline(int day) => find.textContaining('Day $day');

  // CTA
  Finder get confirmCta => find.text('Confirm');
  Finder get editCta => find.text('Edit');

  // Verifications
  Future<void> verifyScreenDisplayed() async {
    expect(screen, findsOneWidget);
  }

  Future<void> verifyDayTimelineDisplayed(int day) async {
    expect(dayTimeline(day), findsOneWidget);
  }

  // Actions
  Future<void> tapConfirm() async {
    await tester.tap(confirmCta);
    await tester.pumpAndSettle();
  }

  Future<void> tapEdit() async {
    await tester.tap(editCta);
    await tester.pumpAndSettle();
  }
}

/// Robot for interacting with SavedDayBuilderScreen in tests
class SavedDayBuilderRobot {
  SavedDayBuilderRobot(this.tester);

  final WidgetTester tester;

  // Screen finders
  Finder get screen => find.byType(SavedDayBuilderScreen);

  // Day navigation
  Finder dayButton(int day) => find.textContaining('Day $day');

  // Activity cards
  Finder activityCard(String name) => find.text(name);

  // CTA
  Finder get saveCta => find.text('Save');
  Finder get addActivityCta => find.text('Add activity');

  // Verifications
  Future<void> verifyScreenDisplayed() async {
    expect(screen, findsOneWidget);
  }

  Future<void> verifyDayButtonDisplayed(int day) async {
    expect(dayButton(day), findsOneWidget);
  }

  Future<void> verifyActivityCardDisplayed(String name) async {
    expect(activityCard(name), findsOneWidget);
  }

  // Actions
  Future<void> tapDayButton(int day) async {
    await tester.tap(dayButton(day));
    await tester.pumpAndSettle();
  }

  Future<void> tapSave() async {
    await tester.tap(saveCta);
    await tester.pumpAndSettle();
  }

  Future<void> tapAddActivity() async {
    await tester.tap(addActivityCta);
    await tester.pumpAndSettle();
  }
}
