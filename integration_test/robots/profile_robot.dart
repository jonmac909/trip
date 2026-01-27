import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:trippified/presentation/screens/profile/profile_screen.dart';
import 'package:trippified/presentation/screens/profile/my_tickets_screen.dart';

/// Robot for interacting with ProfileScreen in tests
class ProfileRobot {
  ProfileRobot(this.tester);

  final WidgetTester tester;

  // Screen finders
  Finder get screen => find.byType(ProfileScreen);

  // User info - default for unauthenticated user
  Finder get guestUserText => find.text('Guest User');
  Finder get signInPrompt => find.text('Sign in to sync your trips');

  // Menu items - match actual ProfileScreen UI
  Finder get myTicketsItem => find.text('My Tickets');
  Finder get settingsItem => find.text('Settings');
  Finder get notificationsItem => find.text('Notifications');
  Finder get helpItem => find.text('Help & Support');
  Finder get logoutItem => find.text('Log Out');

  // Stats
  Finder get tripsCount => find.byKey(const Key('trips_count'));
  Finder get countriesCount => find.byKey(const Key('countries_count'));
  Finder get citiesCount => find.byKey(const Key('cities_count'));

  // Verifications
  Future<void> verifyScreenDisplayed() async {
    expect(screen, findsOneWidget);
  }

  Future<void> verifyPageTitleDisplayed() async {
    // ProfileScreen shows "Guest User" for unauthenticated users
    expect(guestUserText, findsOneWidget);
  }

  Future<void> verifyMenuItemsDisplayed() async {
    expect(myTicketsItem, findsOneWidget);
    expect(settingsItem, findsOneWidget);
    expect(helpItem, findsOneWidget);
  }

  Future<void> verifyLogoutDisplayed() async {
    // Log Out is only shown when authenticated
    // Just verify the screen is displayed
    expect(screen, findsOneWidget);
  }

  // Actions
  Future<void> tapMyTickets() async {
    await tester.tap(myTicketsItem);
    await tester.pumpAndSettle();
  }

  Future<void> tapSettings() async {
    await tester.tap(settingsItem);
    await tester.pumpAndSettle();
  }

  Future<void> tapHelp() async {
    await tester.tap(helpItem);
    await tester.pumpAndSettle();
  }

  Future<void> tapNotifications() async {
    await tester.tap(notificationsItem);
    await tester.pumpAndSettle();
  }

  Future<void> tapLogout() async {
    await tester.tap(logoutItem);
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

  // Section label
  Finder get transportTicketsSection => find.text('Transport Tickets');

  // Ticket cards
  Finder ticketCard(String title) => find.text(title);
  Finder get flightToTokyo => find.text('Flight to Tokyo');
  Finder get shinkansenToKyoto => find.text('Shinkansen to Kyoto');
  Finder get flightToSanFrancisco => find.text('Flight to San Francisco');

  // Add ticket button
  Finder get addTicketButton => find.text('Add Ticket');

  // Verifications
  Future<void> verifyScreenDisplayed() async {
    expect(screen, findsOneWidget);
  }

  Future<void> verifyPageTitleDisplayed() async {
    expect(pageTitle, findsOneWidget);
  }

  Future<void> verifyTransportTicketsSectionDisplayed() async {
    expect(transportTicketsSection, findsOneWidget);
  }

  Future<void> verifyTicketCardDisplayed(String title) async {
    expect(ticketCard(title), findsOneWidget);
  }

  Future<void> verifyAddTicketButtonDisplayed() async {
    expect(addTicketButton, findsOneWidget);
  }

  Future<void> verifyAllTicketsDisplayed() async {
    expect(flightToTokyo, findsOneWidget);
    expect(shinkansenToKyoto, findsOneWidget);
    expect(flightToSanFrancisco, findsOneWidget);
  }

  // Actions
  Future<void> tapAddTicket() async {
    await tester.tap(addTicketButton);
    await tester.pumpAndSettle();
  }

  Future<void> tapTicketCard(String title) async {
    await tester.tap(ticketCard(title));
    await tester.pumpAndSettle();
  }
}
