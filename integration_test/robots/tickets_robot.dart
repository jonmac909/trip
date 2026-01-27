import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:trippified/presentation/screens/trip/smart_tickets_screen.dart';
import 'package:trippified/presentation/screens/profile/my_tickets_screen.dart';

/// Robot for interacting with SmartTicketsScreen in tests
class SmartTicketsRobot {
  SmartTicketsRobot(this.tester);

  final WidgetTester tester;

  // Screen finders
  Finder get screen => find.byType(SmartTicketsScreen);
  Finder get pageTitle => find.text('Smart Tickets');

  // Ticket categories
  Finder get flightsTab => find.text('Flights');
  Finder get hotelsTab => find.text('Hotels');
  Finder get activitiesTab => find.text('Activities');
  Finder get transportTab => find.text('Transport');

  // Ticket cards
  Finder ticketCard(String name) => find.text(name);

  // Empty state
  Finder get emptyState => find.text('No tickets yet');
  Finder get addTicketCta => find.text('Add Ticket');

  // Import options
  Finder get importFromEmail => find.text('Import from Email');
  Finder get scanQrCode => find.text('Scan QR Code');
  Finder get addManually => find.text('Add Manually');

  // Back button
  Finder get backButton => find.byIcon(LucideIcons.arrowLeft);

  // Verifications
  Future<void> verifyScreenDisplayed() async {
    expect(screen, findsOneWidget);
  }

  Future<void> verifyPageTitleDisplayed() async {
    expect(pageTitle, findsOneWidget);
  }

  Future<void> verifyTabsDisplayed() async {
    expect(flightsTab, findsOneWidget);
    expect(hotelsTab, findsOneWidget);
  }

  Future<void> verifyEmptyStateDisplayed() async {
    expect(emptyState, findsOneWidget);
  }

  Future<void> verifyTicketCardDisplayed(String name) async {
    expect(ticketCard(name), findsOneWidget);
  }

  // Actions
  Future<void> tapFlightsTab() async {
    await tester.tap(flightsTab);
    await tester.pumpAndSettle();
  }

  Future<void> tapHotelsTab() async {
    await tester.tap(hotelsTab);
    await tester.pumpAndSettle();
  }

  Future<void> tapActivitiesTab() async {
    await tester.tap(activitiesTab);
    await tester.pumpAndSettle();
  }

  Future<void> tapTransportTab() async {
    await tester.tap(transportTab);
    await tester.pumpAndSettle();
  }

  Future<void> tapTicketCard(String name) async {
    await tester.tap(ticketCard(name));
    await tester.pumpAndSettle();
  }

  Future<void> tapAddTicket() async {
    await tester.tap(addTicketCta);
    await tester.pumpAndSettle();
  }

  Future<void> tapImportFromEmail() async {
    await tester.tap(importFromEmail);
    await tester.pumpAndSettle();
  }

  Future<void> tapScanQrCode() async {
    await tester.tap(scanQrCode);
    await tester.pumpAndSettle();
  }

  Future<void> tapAddManually() async {
    await tester.tap(addManually);
    await tester.pumpAndSettle();
  }

  Future<void> tapBack() async {
    await tester.tap(backButton.first);
    await tester.pumpAndSettle();
  }
}

/// Robot for interacting with MyTicketsScreen in tests
class MyTicketsRobot {
  MyTicketsRobot(this.tester);

  final WidgetTester tester;

  // Screen finders
  Finder get screen => find.byType(MyTicketsScreen);
  Finder get pageTitle => find.text('My Tickets');

  // Filter tabs
  Finder get upcomingTab => find.text('Upcoming');
  Finder get pastTab => find.text('Past');

  // Ticket cards
  Finder ticketCard(String name) => find.text(name);

  // Empty state
  Finder get emptyState => find.text('No tickets yet');
  Finder get emptyHint => find.text('Your travel tickets will appear here');

  // Back button
  Finder get backButton => find.byIcon(LucideIcons.arrowLeft);

  // Verifications
  Future<void> verifyScreenDisplayed() async {
    expect(screen, findsOneWidget);
  }

  Future<void> verifyPageTitleDisplayed() async {
    expect(pageTitle, findsOneWidget);
  }

  Future<void> verifyTabsDisplayed() async {
    expect(upcomingTab, findsOneWidget);
    expect(pastTab, findsOneWidget);
  }

  Future<void> verifyEmptyStateDisplayed() async {
    expect(emptyState, findsOneWidget);
    expect(emptyHint, findsOneWidget);
  }

  Future<void> verifyTicketCardDisplayed(String name) async {
    expect(ticketCard(name), findsOneWidget);
  }

  // Actions
  Future<void> tapUpcomingTab() async {
    await tester.tap(upcomingTab);
    await tester.pumpAndSettle();
  }

  Future<void> tapPastTab() async {
    await tester.tap(pastTab);
    await tester.pumpAndSettle();
  }

  Future<void> tapTicketCard(String name) async {
    await tester.tap(ticketCard(name));
    await tester.pumpAndSettle();
  }

  Future<void> tapBack() async {
    await tester.tap(backButton.first);
    await tester.pumpAndSettle();
  }
}
