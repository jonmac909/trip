import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:trippified/presentation/screens/trip/trip_dashboard_screen.dart';
import 'package:trippified/presentation/screens/trip/smart_tickets_screen.dart';

/// Robot for interacting with TripDashboardScreen in tests
class TripDashboardRobot {
  TripDashboardRobot(this.tester);

  final WidgetTester tester;

  // Screen finders
  Finder get screen => find.byType(TripDashboardScreen);

  // Trip info
  Finder tripTitle(String title) => find.text(title);
  Finder get addDatesText => find.text('Add dates?');

  // Stats
  Finder get citiesStat => find.text('Cities');
  Finder get countriesStat => find.text('Countries');
  Finder get daysStat => find.text('Days');

  // Trip Checklist card (not a tab - it's a tappable card)
  Finder get tripChecklistCard => find.text('Trip Checklist');
  Finder get checklistProgressText => find.textContaining('done');

  // Your Itineraries section
  Finder get yourItinerariesSection => find.text('Your Itineraries');

  // City blocks
  Finder cityBlock(String cityName) => find.textContaining(cityName);
  Finder cityDays(String text) => find.text(text);

  // Checklist items (when checklist is expanded)
  Finder checklistItem(String title) => find.text(title);

  // Checklist sections
  Finder get transportSection => find.text('Transport');
  Finder get accommodationSection => find.text('Accommodation');
  Finder get activitiesSection => find.text('Activities');

  // Add itinerary button
  Finder get addItineraryButton => find.text('Add another itinerary');

  // Edit button (multiple on screen)
  Finder get editButton => find.byIcon(LucideIcons.pencil);

  // Verifications
  Future<void> verifyScreenDisplayed() async {
    expect(screen, findsOneWidget);
  }

  Future<void> verifyTripTitleDisplayed(String title) async {
    expect(tripTitle(title), findsOneWidget);
  }

  Future<void> verifyStatsDisplayed() async {
    expect(citiesStat, findsOneWidget);
    expect(countriesStat, findsOneWidget);
    expect(daysStat, findsOneWidget);
  }

  Future<void> verifyTripChecklistCardDisplayed() async {
    expect(tripChecklistCard, findsOneWidget);
  }

  Future<void> verifyYourItinerariesDisplayed() async {
    expect(yourItinerariesSection, findsOneWidget);
  }

  Future<void> verifyCityBlockDisplayed(String cityName) async {
    expect(cityBlock(cityName), findsWidgets);
  }

  Future<void> verifyChecklistItemDisplayed(String title) async {
    expect(checklistItem(title), findsOneWidget);
  }

  // Actions
  Future<void> tapTripChecklist() async {
    await tester.tap(tripChecklistCard);
    await tester.pumpAndSettle();
  }

  Future<void> tapCityBlock(String cityName) async {
    await tester.tap(cityBlock(cityName).first);
    await tester.pumpAndSettle();
  }

  Future<void> tapAddItinerary() async {
    await tester.tap(addItineraryButton);
    await tester.pumpAndSettle();
  }

  Future<void> toggleChecklistItem(String title) async {
    await tester.tap(checklistItem(title));
    await tester.pumpAndSettle();
  }
}

/// Robot for interacting with SmartTicketsScreen in tests
class SmartTicketsRobot {
  SmartTicketsRobot(this.tester);

  final WidgetTester tester;

  // Screen finders
  Finder get screen => find.byType(SmartTicketsScreen);

  // Header - shows "X Days in CityName" format
  Finder headerTitle(String cityName, int days) =>
      find.text('$days Days in $cityName');
  Finder get editBadge => find.text('Edit');

  // Tabs: Overview, Itinerary, Bookings
  Finder get overviewTab => find.text('Overview');
  Finder get itineraryTab => find.text('Itinerary');
  Finder get bookingsTab => find.text('Bookings');

  // Day tabs
  Finder dayTab(int day) => find.text('Day $day');

  // Ticket cards
  Finder ticketCard(String title) => find.text(title);

  // View button on ticket cards
  Finder get viewButton => find.text('View');

  // Add ticket button
  Finder get addTicketButton => find.text('Add Ticket');

  // Verifications
  Future<void> verifyScreenDisplayed() async {
    expect(screen, findsOneWidget);
  }

  Future<void> verifyHeaderDisplayed(String cityName, int days) async {
    expect(headerTitle(cityName, days), findsOneWidget);
  }

  Future<void> verifyTabsDisplayed() async {
    expect(overviewTab, findsOneWidget);
    expect(itineraryTab, findsOneWidget);
    expect(bookingsTab, findsOneWidget);
  }

  Future<void> verifyTicketCardDisplayed(String title) async {
    expect(ticketCard(title), findsOneWidget);
  }

  Future<void> verifyAddTicketButtonDisplayed() async {
    // Scroll down to find the button which is at the bottom of the list
    await tester.scrollUntilVisible(
      addTicketButton,
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(addTicketButton, findsOneWidget);
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

  Future<void> tapBookingsTab() async {
    await tester.tap(bookingsTab);
    await tester.pumpAndSettle();
  }

  Future<void> tapDayTab(int day) async {
    await tester.tap(dayTab(day));
    await tester.pumpAndSettle();
  }

  Future<void> tapTicketCard(String title) async {
    await tester.tap(ticketCard(title));
    await tester.pumpAndSettle();
  }

  Future<void> tapViewButton() async {
    await tester.tap(viewButton.first);
    await tester.pumpAndSettle();
  }

  Future<void> tapAddTicket() async {
    await tester.tap(addTicketButton);
    await tester.pumpAndSettle();
  }
}
