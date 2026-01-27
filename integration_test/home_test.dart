import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:trippified/presentation/screens/trip_setup/trip_setup_screen.dart';

import 'test_app.dart';
import 'robots/home_robot.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  initializeTestConfig();

  group('Home Screen E2E Tests', () {
    group('Home Screen Layout', () {
      testWidgets('displays home screen with bottom navigation', (
        tester,
      ) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        final home = HomeRobot(tester);
        await home.verifyScreenDisplayed();
        await home.verifyBottomNavDisplayed();
      });

      testWidgets('displays trips tab with tabs', (tester) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        final home = HomeRobot(tester);
        await home.verifyTripsTabDisplayed();
      });

      testWidgets('displays My Trips title', (tester) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        final home = HomeRobot(tester);
        expect(home.myTripsTitle, findsOneWidget);
      });

      testWidgets('displays FAB to add trip', (tester) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        final home = HomeRobot(tester);
        expect(home.addTripFab, findsOneWidget);
      });
    });

    group('Bottom Navigation', () {
      testWidgets('can navigate to Explore tab', (tester) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        final home = HomeRobot(tester);
        await home.tapExploreTab();

        // Verify Explore tab is selected
        expect(home.exploreNavItem, findsOneWidget);
      });

      testWidgets('can navigate to Saved tab', (tester) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        final home = HomeRobot(tester);
        await home.tapSavedTab();

        // Verify Saved tab is selected
        expect(home.savedNavItem, findsOneWidget);
      });

      testWidgets('can navigate to Profile tab', (tester) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        final home = HomeRobot(tester);
        await home.tapProfileTab();

        // Verify Profile tab is selected
        expect(home.profileNavItem, findsOneWidget);
      });

      testWidgets('can navigate back to Trips tab', (tester) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        final home = HomeRobot(tester);

        // Navigate away
        await home.tapExploreTab();

        // Navigate back
        await home.tapTripsTab();

        // Verify Trips tab is visible
        expect(home.myTripsTitle, findsOneWidget);
      });
    });

    group('Trips Tab Navigation', () {
      testWidgets('can switch to Drafts tab', (tester) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        final home = HomeRobot(tester);
        await home.tapDraftsTab();

        // Verify Drafts empty state
        await home.verifyEmptyDraftsState();
      });

      testWidgets('can switch to Past tab', (tester) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        final home = HomeRobot(tester);
        await home.tapPastTab();

        // Verify Past empty state
        await home.verifyEmptyPastState();
      });

      testWidgets('can switch to Wishlist tab', (tester) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        final home = HomeRobot(tester);
        await home.tapWishlistTab();

        // Wishlist should have "Add a place" input
        expect(find.text('Add a place to your wishlist...'), findsOneWidget);
      });

      testWidgets('can switch back to Upcoming tab', (tester) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        final home = HomeRobot(tester);

        // Switch to Drafts then back
        await home.tapDraftsTab();
        await home.tapUpcomingTab();

        // Verify back on Upcoming
        expect(home.upcomingTab, findsOneWidget);
      });
    });

    group('Trip Cards', () {
      testWidgets('displays mock trip cards in Upcoming tab', (tester) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        final home = HomeRobot(tester);

        // Mock data should show these trips
        await home.verifyTripCardDisplayed('Japan Adventure');
        await home.verifyTripCardDisplayed('Europe Trip');
      });

      testWidgets('trip card shows countdown badge', (tester) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        // Should show "In X days" badge
        expect(find.textContaining('In'), findsWidgets);
        expect(find.textContaining('days'), findsWidgets);
      });

      testWidgets('trip card shows city route', (tester) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        // Japan trip should show Tokyo → Kyoto → Osaka
        expect(find.text('Tokyo'), findsOneWidget);
        expect(find.text('Kyoto'), findsOneWidget);
        expect(find.text('Osaka'), findsOneWidget);
      });
    });

    group('Wishlist Tab', () {
      testWidgets('displays wishlist places', (tester) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        final home = HomeRobot(tester);
        await home.tapWishlistTab();

        // Mock wishlist data should show
        expect(find.text('Santorini, Greece'), findsOneWidget);
        expect(find.text('Bali, Indonesia'), findsOneWidget);
      });

      testWidgets('displays Plan a Trip CTA in wishlist', (tester) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        final home = HomeRobot(tester);
        await home.tapWishlistTab();

        expect(home.planATripButton, findsWidgets);
      });
    });

    group('Navigation Actions', () {
      testWidgets('FAB navigates to trip setup', (tester) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        final home = HomeRobot(tester);
        await home.tapAddTripFab();

        // Should navigate to trip setup
        expect(find.byType(TripSetupScreen), findsOneWidget);
      });

      testWidgets('Plan a Trip button navigates to trip setup', (tester) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        final home = HomeRobot(tester);
        await home.tapWishlistTab();
        await home.tapPlanATrip();

        // Should navigate to trip setup
        expect(find.byType(TripSetupScreen), findsOneWidget);
      });
    });

    group('Empty States', () {
      testWidgets('Drafts tab shows empty state', (tester) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        final home = HomeRobot(tester);
        await home.tapDraftsTab();

        expect(find.text('No dates? No problem.'), findsOneWidget);
        expect(
          find.text("Store your trip ideas here until you're ready to plan."),
          findsOneWidget,
        );
      });

      testWidgets('Past tab shows empty state', (tester) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        final home = HomeRobot(tester);
        await home.tapPastTab();

        expect(find.text('No past trips'), findsOneWidget);
        expect(
          find.text('Your completed trips will appear here'),
          findsOneWidget,
        );
      });
    });
  });
}
