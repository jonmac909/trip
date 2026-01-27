import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:trippified/presentation/screens/features/add_itinerary_screen.dart';
import 'package:trippified/presentation/screens/features/itinerary_detail_screen.dart';
import 'package:trippified/presentation/screens/features/itinerary_stacking_screen.dart';
import 'package:trippified/presentation/screens/itinerary/itinerary_builder_screen.dart';
import 'package:trippified/presentation/screens/explore/itinerary_preview_screen.dart';

import 'test_app.dart';
import 'robots/itinerary_robot.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  initializeTestConfig();

  group('Itinerary Module E2E Tests', () {
    group('ItineraryBuilderScreen', () {
      testWidgets('displays itinerary builder screen', (tester) async {
        await tester.pumpWidget(createTestApp(initialRoute: '/trip/builder'));
        await tester.pumpAndSettle();

        expect(find.byType(ItineraryBuilderScreen), findsOneWidget);
      });

      testWidgets('displays itinerary builder content', (tester) async {
        await tester.pumpWidget(createTestApp(initialRoute: '/trip/builder'));
        await tester.pumpAndSettle();

        final builder = ItineraryBuilderRobot(tester);
        await builder.verifyScreenDisplayed();
      });

      testWidgets('has back button', (tester) async {
        await tester.pumpWidget(createTestApp(initialRoute: '/trip/builder'));
        await tester.pumpAndSettle();

        final builder = ItineraryBuilderRobot(tester);
        expect(builder.backButton, findsOneWidget);
      });
    });

    group('ItineraryPreviewScreen', () {
      testWidgets('displays itinerary preview screen', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/explore/itinerary/test-id'),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ItineraryPreviewScreen), findsOneWidget);
      });

      testWidgets('displays itinerary preview content', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/explore/itinerary/test-id'),
        );
        await tester.pumpAndSettle();

        final preview = ItineraryPreviewRobot(tester);
        await preview.verifyScreenDisplayed();
      });

      testWidgets('has back button', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/explore/itinerary/test-id'),
        );
        await tester.pumpAndSettle();

        final preview = ItineraryPreviewRobot(tester);
        expect(preview.backButton, findsOneWidget);
      });
    });

    group('AddItineraryScreen', () {
      testWidgets('displays add itinerary screen', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/features/add-itinerary'),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AddItineraryScreen), findsOneWidget);
      });

      testWidgets('displays add itinerary content', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/features/add-itinerary'),
        );
        await tester.pumpAndSettle();

        final addItinerary = AddItineraryRobot(tester);
        await addItinerary.verifyScreenDisplayed();
      });
    });

    group('ItineraryDetailScreen', () {
      testWidgets('displays itinerary detail screen', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/features/itinerary-detail'),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ItineraryDetailScreen), findsOneWidget);
      });

      testWidgets('displays itinerary detail content', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/features/itinerary-detail'),
        );
        await tester.pumpAndSettle();

        final detail = ItineraryDetailRobot(tester);
        await detail.verifyScreenDisplayed();
      });

      testWidgets('has back button', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/features/itinerary-detail'),
        );
        await tester.pumpAndSettle();

        final detail = ItineraryDetailRobot(tester);
        expect(detail.backButton, findsOneWidget);
      });
    });

    group('ItineraryStackingScreen', () {
      testWidgets('displays itinerary stacking screen', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/features/stacking'),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ItineraryStackingScreen), findsOneWidget);
      });

      testWidgets('displays itinerary stacking content', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/features/stacking'),
        );
        await tester.pumpAndSettle();

        final stacking = ItineraryStackingRobot(tester);
        await stacking.verifyScreenDisplayed();
      });
    });
  });
}
