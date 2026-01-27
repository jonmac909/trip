import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:trippified/presentation/screens/features/add_itinerary_screen.dart';
import 'package:trippified/presentation/screens/features/itinerary_detail_screen.dart';
import 'package:trippified/presentation/screens/features/itinerary_stacking_screen.dart';
import 'package:trippified/presentation/screens/itinerary/itinerary_builder_screen.dart';
import 'package:trippified/presentation/screens/explore/itinerary_preview_screen.dart';

/// Robot for interacting with ItineraryBuilderScreen in tests
class ItineraryBuilderRobot {
  ItineraryBuilderRobot(this.tester);

  final WidgetTester tester;

  // Screen finders
  Finder get screen => find.byType(ItineraryBuilderScreen);
  Finder get pageTitle => find.text('Build Itinerary');

  // Day selectors
  Finder daySelector(int day) => find.textContaining('Day $day');

  // Activity cards
  Finder activityCard(String name) => find.text(name);

  // CTAs
  Finder get addActivityCta => find.text('Add Activity');
  Finder get generateCta => find.text('Generate');
  Finder get saveCta => find.text('Save');
  Finder get previewCta => find.text('Preview');

  // Back button
  Finder get backButton => find.byIcon(LucideIcons.arrowLeft);

  // Verifications
  Future<void> verifyScreenDisplayed() async {
    expect(screen, findsOneWidget);
  }

  Future<void> verifyPageTitleDisplayed() async {
    expect(pageTitle, findsOneWidget);
  }

  Future<void> verifyDaySelectorDisplayed(int day) async {
    expect(daySelector(day), findsOneWidget);
  }

  Future<void> verifyActivityCardDisplayed(String name) async {
    expect(activityCard(name), findsOneWidget);
  }

  // Actions
  Future<void> tapDaySelector(int day) async {
    await tester.tap(daySelector(day));
    await tester.pumpAndSettle();
  }

  Future<void> tapAddActivity() async {
    await tester.tap(addActivityCta);
    await tester.pumpAndSettle();
  }

  Future<void> tapGenerate() async {
    await tester.tap(generateCta);
    await tester.pumpAndSettle();
  }

  Future<void> tapSave() async {
    await tester.tap(saveCta);
    await tester.pumpAndSettle();
  }

  Future<void> tapPreview() async {
    await tester.tap(previewCta);
    await tester.pumpAndSettle();
  }

  Future<void> tapBack() async {
    await tester.tap(backButton.first);
    await tester.pumpAndSettle();
  }
}

/// Robot for interacting with ItineraryPreviewScreen in tests
class ItineraryPreviewRobot {
  ItineraryPreviewRobot(this.tester);

  final WidgetTester tester;

  // Screen finders
  Finder get screen => find.byType(ItineraryPreviewScreen);

  // Day timeline
  Finder dayTimeline(int day) => find.textContaining('Day $day');

  // Activity cards
  Finder activityCard(String name) => find.text(name);

  // Map
  Finder get mapView => find.byKey(const Key('itinerary_map'));

  // CTAs
  Finder get startTripCta => find.text('Start Trip');
  Finder get editCta => find.text('Edit');
  Finder get shareCta => find.byIcon(LucideIcons.share2);

  // Back button
  Finder get backButton => find.byIcon(LucideIcons.arrowLeft);

  // Verifications
  Future<void> verifyScreenDisplayed() async {
    expect(screen, findsOneWidget);
  }

  Future<void> verifyDayTimelineDisplayed(int day) async {
    expect(dayTimeline(day), findsOneWidget);
  }

  Future<void> verifyActivityCardDisplayed(String name) async {
    expect(activityCard(name), findsOneWidget);
  }

  // Actions
  Future<void> tapDayTimeline(int day) async {
    await tester.tap(dayTimeline(day));
    await tester.pumpAndSettle();
  }

  Future<void> tapStartTrip() async {
    await tester.tap(startTripCta);
    await tester.pumpAndSettle();
  }

  Future<void> tapEdit() async {
    await tester.tap(editCta);
    await tester.pumpAndSettle();
  }

  Future<void> tapShare() async {
    await tester.tap(shareCta);
    await tester.pumpAndSettle();
  }

  Future<void> tapBack() async {
    await tester.tap(backButton.first);
    await tester.pumpAndSettle();
  }
}

/// Robot for interacting with AddItineraryScreen in tests
class AddItineraryRobot {
  AddItineraryRobot(this.tester);

  final WidgetTester tester;

  // Screen finders
  Finder get screen => find.byType(AddItineraryScreen);
  Finder get pageTitle => find.text('Add Itinerary');

  // Input fields
  Finder get titleInput => find.byKey(const Key('itinerary_title_input'));
  Finder get descriptionInput =>
      find.byKey(const Key('itinerary_description_input'));

  // Duration selector
  Finder durationOption(int days) => find.text('$days days');

  // CTAs
  Finder get createCta => find.text('Create');
  Finder get cancelCta => find.text('Cancel');

  // Verifications
  Future<void> verifyScreenDisplayed() async {
    expect(screen, findsOneWidget);
  }

  Future<void> verifyPageTitleDisplayed() async {
    expect(pageTitle, findsOneWidget);
  }

  // Actions
  Future<void> enterTitle(String title) async {
    await tester.enterText(titleInput, title);
    await tester.pumpAndSettle();
  }

  Future<void> enterDescription(String description) async {
    await tester.enterText(descriptionInput, description);
    await tester.pumpAndSettle();
  }

  Future<void> selectDuration(int days) async {
    await tester.tap(durationOption(days));
    await tester.pumpAndSettle();
  }

  Future<void> tapCreate() async {
    await tester.tap(createCta);
    await tester.pumpAndSettle();
  }

  Future<void> tapCancel() async {
    await tester.tap(cancelCta);
    await tester.pumpAndSettle();
  }
}

/// Robot for interacting with ItineraryDetailScreen in tests
class ItineraryDetailRobot {
  ItineraryDetailRobot(this.tester);

  final WidgetTester tester;

  // Screen finders
  Finder get screen => find.byType(ItineraryDetailScreen);

  // Header info
  Finder get tripTitle => find.byKey(const Key('trip_title'));
  Finder get tripDates => find.byKey(const Key('trip_dates'));
  Finder get tripDuration => find.byKey(const Key('trip_duration'));

  // Day cards
  Finder dayCard(int day) => find.textContaining('Day $day');

  // Activity cards
  Finder activityCard(String name) => find.text(name);

  // Map
  Finder get mapView => find.byKey(const Key('detail_map'));

  // CTAs
  Finder get editCta => find.text('Edit');
  Finder get deleteCta => find.text('Delete');
  Finder get shareCta => find.byIcon(LucideIcons.share2);

  // Back button
  Finder get backButton => find.byIcon(LucideIcons.arrowLeft);

  // Verifications
  Future<void> verifyScreenDisplayed() async {
    expect(screen, findsOneWidget);
  }

  Future<void> verifyDayCardDisplayed(int day) async {
    expect(dayCard(day), findsOneWidget);
  }

  Future<void> verifyActivityCardDisplayed(String name) async {
    expect(activityCard(name), findsOneWidget);
  }

  // Actions
  Future<void> tapDayCard(int day) async {
    await tester.tap(dayCard(day));
    await tester.pumpAndSettle();
  }

  Future<void> tapActivityCard(String name) async {
    await tester.tap(activityCard(name));
    await tester.pumpAndSettle();
  }

  Future<void> tapEdit() async {
    await tester.tap(editCta);
    await tester.pumpAndSettle();
  }

  Future<void> tapDelete() async {
    await tester.tap(deleteCta);
    await tester.pumpAndSettle();
  }

  Future<void> tapShare() async {
    await tester.tap(shareCta);
    await tester.pumpAndSettle();
  }

  Future<void> tapBack() async {
    await tester.tap(backButton.first);
    await tester.pumpAndSettle();
  }
}

/// Robot for interacting with ItineraryStackingScreen in tests
class ItineraryStackingRobot {
  ItineraryStackingRobot(this.tester);

  final WidgetTester tester;

  // Screen finders
  Finder get screen => find.byType(ItineraryStackingScreen);
  Finder get pageTitle => find.text('Stack Itineraries');

  // Itinerary cards
  Finder itineraryCard(String name) => find.text(name);

  // Stack preview
  Finder get stackPreview => find.byKey(const Key('stack_preview'));
  Finder get totalDays => find.byKey(const Key('total_days'));

  // CTAs
  Finder get mergeCta => find.text('Merge');
  Finder get cancelCta => find.text('Cancel');

  // Verifications
  Future<void> verifyScreenDisplayed() async {
    expect(screen, findsOneWidget);
  }

  Future<void> verifyPageTitleDisplayed() async {
    expect(pageTitle, findsOneWidget);
  }

  Future<void> verifyItineraryCardDisplayed(String name) async {
    expect(itineraryCard(name), findsOneWidget);
  }

  // Actions
  Future<void> tapItineraryCard(String name) async {
    await tester.tap(itineraryCard(name));
    await tester.pumpAndSettle();
  }

  Future<void> tapMerge() async {
    await tester.tap(mergeCta);
    await tester.pumpAndSettle();
  }

  Future<void> tapCancel() async {
    await tester.tap(cancelCta);
    await tester.pumpAndSettle();
  }
}
