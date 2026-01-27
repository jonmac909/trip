import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:trippified/presentation/screens/day_builder/day_builder_screen.dart';

/// Robot for interacting with DayBuilderScreen in tests
class DayBuilderRobot {
  DayBuilderRobot(this.tester);

  final WidgetTester tester;

  // Screen finders
  Finder get screen => find.byType(DayBuilderScreen);

  // Tabs - actual UI has 3 tabs: Overview, Itinerary, Bookings
  Finder get overviewTab => find.text('Overview');
  Finder get itineraryTab => find.text('Itinerary');
  Finder get bookingsTab => find.text('Bookings');

  // Day navigation
  Finder dayChip(int day) => find.textContaining('Day $day');
  Finder get freeDayText => find.textContaining('Free day');

  // Auto-fill section
  Finder get autoFillButton => find.text('Auto-fill');
  Finder get generateDayButton => find.text('Generate day');

  // Activity cards
  Finder activityCard(String name) => find.text(name);

  // Time slots
  Finder timeSlot(String time) => find.text(time);

  // Add activity
  Finder get addActivityButton => find.byIcon(LucideIcons.plus);

  // Verifications
  Future<void> verifyScreenDisplayed() async {
    expect(screen, findsOneWidget);
  }

  Future<void> verifyTabsDisplayed() async {
    expect(overviewTab, findsOneWidget);
    expect(itineraryTab, findsOneWidget);
  }

  Future<void> verifyDayChipDisplayed(int day) async {
    expect(dayChip(day), findsOneWidget);
  }

  Future<void> verifyFreeDayTextDisplayed() async {
    // Multiple days may show "Free day" text
    expect(freeDayText, findsWidgets);
  }

  Future<void> verifyAutoFillButtonDisplayed() async {
    expect(autoFillButton, findsOneWidget);
  }

  Future<void> verifyActivityCardDisplayed(String name) async {
    expect(activityCard(name), findsOneWidget);
  }

  // Actions
  Future<void> tapOverviewTab() async {
    await tester.tap(overviewTab);
    await tester.pumpAndSettle();
  }

  Future<void> tapItineraryTab() async {
    await tester.tap(itineraryTab);
    await tester.pumpAndSettle();
  }

  Future<void> tapDayChip(int day) async {
    await tester.tap(dayChip(day));
    await tester.pumpAndSettle();
  }

  Future<void> tapAutoFill() async {
    await tester.tap(autoFillButton);
    await tester.pumpAndSettle();
  }

  Future<void> tapGenerateDay() async {
    await tester.tap(generateDayButton);
    await tester.pumpAndSettle();
  }

  Future<void> tapActivityCard(String name) async {
    await tester.tap(activityCard(name));
    await tester.pumpAndSettle();
  }

  Future<void> tapAddActivity() async {
    await tester.tap(addActivityButton);
    await tester.pumpAndSettle();
  }
}
