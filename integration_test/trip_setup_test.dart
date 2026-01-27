import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:trippified/presentation/screens/trip_setup/recommended_routes_screen.dart';

import 'test_app.dart';
import 'robots/trip_setup_robot.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  initializeTestConfig();

  group('Trip Setup E2E Tests', () {
    group('TripSetupScreen Layout', () {
      testWidgets('displays all trip setup screen elements', (tester) async {
        await tester.pumpWidget(createTripSetupTestApp());
        await tester.pumpAndSettle();

        final tripSetup = TripSetupRobot(tester);
        await tripSetup.verifyScreenDisplayed();
        await tripSetup.verifyPageTitleDisplayed();
        await tripSetup.verifySectionsDisplayed();
      });

      testWidgets('displays trip size options', (tester) async {
        await tester.pumpWidget(createTripSetupTestApp());
        await tester.pumpAndSettle();

        final tripSetup = TripSetupRobot(tester);
        await tripSetup.verifyTripSizeOptionsDisplayed();
      });

      testWidgets('displays See recommended routes CTA', (tester) async {
        await tester.pumpWidget(createTripSetupTestApp());
        await tester.pumpAndSettle();

        final tripSetup = TripSetupRobot(tester);
        await tripSetup.verifySeeRoutesCtaDisplayed();
      });
    });

    group('Country Selection', () {
      testWidgets('can enter country in search field', (tester) async {
        await tester.pumpWidget(createTripSetupTestApp());
        await tester.pumpAndSettle();

        final tripSetup = TripSetupRobot(tester);
        await tripSetup.enterCountry('Japan');

        // Country should be entered
        expect(find.text('Japan'), findsWidgets);
      });
    });

    group('Trip Size Selection', () {
      testWidgets('can select Short trip option', (tester) async {
        await tester.pumpWidget(createTripSetupTestApp());
        await tester.pumpAndSettle();

        final tripSetup = TripSetupRobot(tester);
        await tripSetup.selectShortTrip();

        // Short trip should be visually selected (highlighted)
        expect(find.text('Short trip'), findsOneWidget);
      });

      testWidgets('can select Week-long option', (tester) async {
        await tester.pumpWidget(createTripSetupTestApp());
        await tester.pumpAndSettle();

        final tripSetup = TripSetupRobot(tester);
        await tripSetup.selectWeekLong();

        expect(find.text('Week-long'), findsOneWidget);
      });

      testWidgets('can select Long or open-ended option', (tester) async {
        await tester.pumpWidget(createTripSetupTestApp());
        await tester.pumpAndSettle();

        final tripSetup = TripSetupRobot(tester);
        await tripSetup.selectLongTrip();

        expect(find.text('Long or open-ended'), findsOneWidget);
      });
    });

    group('Trip Setup Sections', () {
      testWidgets('displays "Where do you want to go?" section', (tester) async {
        await tester.pumpWidget(createTripSetupTestApp());
        await tester.pumpAndSettle();

        expect(find.text('Where do you want to go?'), findsOneWidget);
      });

      testWidgets('displays "How long is your trip?" section', (tester) async {
        await tester.pumpWidget(createTripSetupTestApp());
        await tester.pumpAndSettle();

        expect(find.text('How long is your trip?'), findsOneWidget);
      });
    });

    group('Trip Setup Validation', () {
      testWidgets('shows See recommended routes button', (tester) async {
        await tester.pumpWidget(createTripSetupTestApp());
        await tester.pumpAndSettle();

        final tripSetup = TripSetupRobot(tester);
        expect(tripSetup.seeRoutesCta, findsOneWidget);
      });
    });
  });

  group('Recommended Routes E2E Tests', () {
    group('RecommendedRoutesScreen Layout', () {
      testWidgets('displays recommended routes screen', (tester) async {
        // Navigate with countries extra data
        await tester.pumpWidget(createTestApp(initialRoute: '/trip/routes'));
        await tester.pumpAndSettle();

        // Should show the recommended routes screen
        expect(find.byType(RecommendedRoutesScreen), findsOneWidget);
      });
    });
  });
}
