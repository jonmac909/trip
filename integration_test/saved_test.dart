import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trippified/presentation/screens/saved/customize_itinerary_screen.dart';
import 'package:trippified/presentation/screens/saved/review_route_screen.dart';
import 'package:trippified/presentation/screens/saved/saved_city_detail_screen.dart';
import 'package:trippified/presentation/screens/saved/saved_day_builder_screen.dart';
import 'package:trippified/presentation/screens/saved/tiktok_scan_results_screen.dart';
import 'package:trippified/presentation/screens/saved/trip_hub_drafts_screen.dart';

import 'robots/home_robot.dart';
import 'robots/saved_robot.dart';
import 'test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  initializeTestConfig();

  group('Saved Module E2E Tests', () {
    group('SavedScreen Layout', () {
      testWidgets('displays saved screen when navigating to Saved tab', (
        tester,
      ) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        final home = HomeRobot(tester);
        await home.tapSavedTab();

        final saved = SavedRobot(tester);
        await saved.verifyScreenDisplayed();
      });

      testWidgets('displays Saved title', (tester) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        final home = HomeRobot(tester);
        await home.tapSavedTab();

        final saved = SavedRobot(tester);
        await saved.verifyPageTitleDisplayed();
      });

      testWidgets('displays Places, Itineraries, Links tabs', (tester) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        final home = HomeRobot(tester);
        await home.tapSavedTab();

        final saved = SavedRobot(tester);
        await saved.verifyTabsDisplayed();
      });
    });

    group('SavedScreen Tab Navigation', () {
      testWidgets('can switch to Itineraries tab', (tester) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        final home = HomeRobot(tester);
        await home.tapSavedTab();

        final saved = SavedRobot(tester);
        await saved.tapItinerariesTab();

        expect(saved.itinerariesTab, findsOneWidget);
      });

      testWidgets('can switch to Links tab', (tester) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        final home = HomeRobot(tester);
        await home.tapSavedTab();

        final saved = SavedRobot(tester);
        await saved.tapLinksTab();

        expect(saved.linksTab, findsOneWidget);
      });

      testWidgets('can switch back to Places tab', (tester) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        final home = HomeRobot(tester);
        await home.tapSavedTab();

        final saved = SavedRobot(tester);
        await saved.tapItinerariesTab();
        await saved.tapPlacesTab();

        expect(saved.placesTab, findsOneWidget);
      });
    });

    group('TripHubDraftsScreen', () {
      testWidgets('displays drafts screen', (tester) async {
        await tester.pumpWidget(createTestApp(initialRoute: '/saved/drafts'));
        await tester.pumpAndSettle();

        expect(find.byType(TripHubDraftsScreen), findsOneWidget);
      });

      testWidgets('displays drafts content', (tester) async {
        await tester.pumpWidget(createTestApp(initialRoute: '/saved/drafts'));
        await tester.pumpAndSettle();

        final drafts = TripHubDraftsRobot(tester);
        await drafts.verifyScreenDisplayed();
      });
    });

    group('TiktokScanResultsScreen', () {
      // Note: The scan screen has an AnimationController.repeat() pulse
      // animation during loading, so pumpAndSettle will never complete
      // while in loading state. We use pump() with duration instead.

      testWidgets('displays scan results screen', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/saved/scan-results'),
        );
        // Pump enough frames for the async scan to complete (error state)
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.byType(TiktokScanResultsScreen), findsOneWidget);
      });

      testWidgets('shows loading state initially with URL', (tester) async {
        await tester.pumpWidget(
          createScanResultsTestApp(
            url: 'https://www.tiktok.com/@test/video/123',
          ),
        );
        // Only pump one frame to catch loading state
        await tester.pump();

        final scan = TiktokScanResultsRobot(tester);
        await scan.verifyScreenDisplayed();
        await scan.verifyLoadingState();
      });

      testWidgets('shows error state when no input provided', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/saved/scan-results'),
        );
        // Pump enough for the async error to fire
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        final scan = TiktokScanResultsRobot(tester);
        await scan.verifyScreenDisplayed();
        await scan.verifyErrorState();
      });

      testWidgets('hides footer on error state', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/saved/scan-results'),
        );
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        final scan = TiktokScanResultsRobot(tester);
        await scan.verifyFooterHidden();
      });

      testWidgets('shows Try Again button on error', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/saved/scan-results'),
        );
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        final scan = TiktokScanResultsRobot(tester);
        expect(scan.tryAgainButton, findsOneWidget);
      });

      testWidgets('back button is present in error state', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/saved/scan-results'),
        );
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        final scan = TiktokScanResultsRobot(tester);
        expect(scan.backButton, findsOneWidget);
      });

      testWidgets('back button is present in loading state', (tester) async {
        await tester.pumpWidget(
          createScanResultsTestApp(
            url: 'https://www.tiktok.com/@test/video/123',
          ),
        );
        await tester.pump();

        final scan = TiktokScanResultsRobot(tester);
        expect(scan.backButton, findsOneWidget);
      });
    });

    group('SavedCityDetailScreen', () {
      testWidgets('displays saved city detail screen', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/saved/city/tokyo'),
        );
        await tester.pumpAndSettle();

        expect(find.byType(SavedCityDetailScreen), findsOneWidget);
      });

      testWidgets('displays saved city detail content', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/saved/city/tokyo'),
        );
        await tester.pumpAndSettle();

        final cityDetail = SavedCityDetailRobot(tester);
        await cityDetail.verifyScreenDisplayed();
      });
    });

    group('CustomizeItineraryScreen', () {
      testWidgets('displays customize itinerary screen', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/saved/customize/tokyo-5day'),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CustomizeItineraryScreen), findsOneWidget);
      });

      testWidgets('displays customize itinerary content', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/saved/customize/tokyo-5day'),
        );
        await tester.pumpAndSettle();

        final customize = CustomizeItineraryRobot(tester);
        await customize.verifyScreenDisplayed();
      });
    });

    group('ReviewRouteScreen', () {
      testWidgets('displays review route screen', (tester) async {
        await tester.pumpWidget(createTestApp(initialRoute: '/saved/review'));
        await tester.pumpAndSettle();

        expect(find.byType(ReviewRouteScreen), findsOneWidget);
      });

      testWidgets('displays review route content', (tester) async {
        await tester.pumpWidget(createTestApp(initialRoute: '/saved/review'));
        await tester.pumpAndSettle();

        final review = ReviewRouteRobot(tester);
        await review.verifyScreenDisplayed();
      });
    });

    group('SavedDayBuilderScreen', () {
      testWidgets('displays saved day builder screen', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/saved/day-builder'),
        );
        await tester.pumpAndSettle();

        expect(find.byType(SavedDayBuilderScreen), findsOneWidget);
      });

      testWidgets('displays saved day builder content', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/saved/day-builder'),
        );
        await tester.pumpAndSettle();

        final dayBuilder = SavedDayBuilderRobot(tester);
        await dayBuilder.verifyScreenDisplayed();
      });
    });
  });
}
