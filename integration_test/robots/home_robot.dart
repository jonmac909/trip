import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:trippified/core/widgets/app_bottom_nav.dart';
import 'package:trippified/presentation/screens/home/home_screen.dart';

/// Robot for interacting with HomeScreen in tests
class HomeRobot {
  HomeRobot(this.tester);

  final WidgetTester tester;

  // Screen finders
  Finder get screen => find.byType(HomeScreen);
  Finder get bottomNav => find.byType(AppBottomNav);

  // Trips tab finders
  Finder get myTripsTitle => find.text('My Trips');
  Finder get upcomingTab => find.text('Upcoming');
  Finder get draftsTab => find.text('Drafts');
  Finder get pastTab => find.text('Past');
  Finder get wishlistTab => find.text('Wishlist');
  Finder get addTripFab => find.byIcon(LucideIcons.plus);
  Finder get planATripButton => find.text('Plan a Trip');

  // Empty states
  Finder get noTripsYetText => find.text('No trips yet');
  Finder get noDatesNoProblemText => find.text('No dates? No problem.');
  Finder get noPastTripsText => find.text('No past trips');

  // Trip cards
  Finder tripCard(String title) => find.text(title);

  // Bottom nav items - use text finders for custom nav
  Finder get tripsNavItem => find.text('Trips');
  Finder get exploreNavItem => find.text('Explore');
  Finder get savedNavItem => find.text('Saved');
  Finder get profileNavItem => find.text('Profile');

  // Verifications
  Future<void> verifyScreenDisplayed() async {
    expect(screen, findsOneWidget);
  }

  Future<void> verifyBottomNavDisplayed() async {
    // Check for the custom AppBottomNav or its text items
    final hasNav = bottomNav.evaluate().isNotEmpty ||
        tripsNavItem.evaluate().isNotEmpty;
    expect(hasNav, isTrue);
  }

  Future<void> verifyTripsTabDisplayed() async {
    expect(myTripsTitle, findsOneWidget);
    expect(upcomingTab, findsOneWidget);
    expect(draftsTab, findsOneWidget);
    expect(pastTab, findsOneWidget);
    expect(wishlistTab, findsOneWidget);
  }

  Future<void> verifyEmptyUpcomingState() async {
    expect(noTripsYetText, findsOneWidget);
  }

  Future<void> verifyEmptyDraftsState() async {
    expect(noDatesNoProblemText, findsOneWidget);
  }

  Future<void> verifyEmptyPastState() async {
    expect(noPastTripsText, findsOneWidget);
  }

  Future<void> verifyTripCardDisplayed(String title) async {
    expect(tripCard(title), findsOneWidget);
  }

  // Navigation
  Future<void> tapTripsTab() async {
    await tester.tap(tripsNavItem);
    await tester.pumpAndSettle();
  }

  Future<void> tapExploreTab() async {
    await tester.tap(exploreNavItem);
    await tester.pumpAndSettle();
  }

  Future<void> tapSavedTab() async {
    await tester.tap(savedNavItem);
    await tester.pumpAndSettle();
  }

  Future<void> tapProfileTab() async {
    await tester.tap(profileNavItem);
    await tester.pumpAndSettle();
  }

  // Trips tab navigation
  Future<void> tapUpcomingTab() async {
    await tester.tap(upcomingTab);
    await tester.pumpAndSettle();
  }

  Future<void> tapDraftsTab() async {
    await tester.tap(draftsTab);
    await tester.pumpAndSettle();
  }

  Future<void> tapPastTab() async {
    await tester.tap(pastTab);
    await tester.pumpAndSettle();
  }

  Future<void> tapWishlistTab() async {
    await tester.tap(wishlistTab);
    await tester.pumpAndSettle();
  }

  // Actions
  Future<void> tapAddTripFab() async {
    await tester.tap(addTripFab);
    await tester.pumpAndSettle();
  }

  Future<void> tapPlanATrip() async {
    await tester.tap(planATripButton.first);
    await tester.pumpAndSettle();
  }

  Future<void> tapTripCard(String title) async {
    await tester.tap(tripCard(title));
    await tester.pumpAndSettle();
  }
}
