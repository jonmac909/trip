import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trippified/presentation/screens/explore/city_detail_screen.dart';
import 'package:trippified/presentation/screens/explore/destination_detail_screen.dart';
import 'package:trippified/presentation/screens/explore/explore_history_screen.dart';
import 'package:trippified/presentation/screens/explore/itinerary_preview_screen.dart';

import 'robots/explore_robot.dart';
import 'robots/home_robot.dart';
import 'test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  initializeTestConfig();

  group('Explore Module E2E Tests', () {
    group('ExploreScreen Layout', () {
      testWidgets('displays explore screen when navigating to Explore tab', (
        tester,
      ) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        final home = HomeRobot(tester);
        await home.tapExploreTab();

        final explore = ExploreRobot(tester);
        await explore.verifyScreenDisplayed();
      });

      testWidgets('displays search bar', (tester) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        final home = HomeRobot(tester);
        await home.tapExploreTab();

        final explore = ExploreRobot(tester);
        await explore.verifySearchBarDisplayed();
      });

      testWidgets('displays Destinations and Itineraries tabs', (tester) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        final home = HomeRobot(tester);
        await home.tapExploreTab();

        final explore = ExploreRobot(tester);
        await explore.verifyTabsDisplayed();
      });
    });

    group('ExploreScreen Tab Navigation', () {
      testWidgets('can switch to Itineraries tab', (tester) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        final home = HomeRobot(tester);
        await home.tapExploreTab();

        final explore = ExploreRobot(tester);
        await explore.tapItinerariesTab();

        // Verify on Itineraries tab
        expect(explore.itinerariesTab, findsOneWidget);
      });

      testWidgets('can switch back to Destinations tab', (tester) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        final home = HomeRobot(tester);
        await home.tapExploreTab();

        final explore = ExploreRobot(tester);
        await explore.tapItinerariesTab();
        await explore.tapDestinationsTab();

        // Verify back on Destinations tab
        expect(explore.destinationsTab, findsOneWidget);
      });
    });

    group('ExploreHistoryScreen', () {
      testWidgets('navigates to history screen', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/explore/history'),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ExploreHistoryScreen), findsOneWidget);
      });
    });

    group('DestinationDetailScreen', () {
      testWidgets('displays destination detail screen', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/explore/destination/japan'),
        );
        await tester.pumpAndSettle();

        expect(find.byType(DestinationDetailScreen), findsOneWidget);
      });

      testWidgets('displays tabs on destination detail', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/explore/destination/japan'),
        );
        await tester.pumpAndSettle();

        final destDetail = DestinationDetailRobot(tester);
        await destDetail.verifyScreenDisplayed();
      });
    });

    group('CityDetailScreen', () {
      testWidgets('displays city detail screen', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/explore/city/tokyo'),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CityDetailScreen), findsOneWidget);
      });

      testWidgets('displays tabs on city detail', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/explore/city/tokyo'),
        );
        await tester.pumpAndSettle();

        final cityDetail = CityDetailRobot(tester);
        await cityDetail.verifyScreenDisplayed();
      });
    });

    group('ItineraryPreviewScreen', () {
      testWidgets('displays itinerary preview screen', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/explore/itinerary/tokyo-5day'),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ItineraryPreviewScreen), findsOneWidget);
      });

      testWidgets('displays itinerary preview content', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/explore/itinerary/tokyo-5day'),
        );
        await tester.pumpAndSettle();

        final preview = ItineraryPreviewRobot(tester);
        await preview.verifyScreenDisplayed();
      });
    });
  });
}
