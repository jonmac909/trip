import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:trippified/presentation/screens/day_builder/day_builder_screen.dart';

import 'test_app.dart';
import 'robots/day_builder_robot.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  initializeTestConfig();

  group('Day Builder Module E2E Tests', () {
    group('DayBuilderScreen Layout', () {
      testWidgets('displays day builder screen', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/trip/japan-trip/day/Tokyo'),
        );
        await tester.pumpAndSettle();

        expect(find.byType(DayBuilderScreen), findsOneWidget);
      });

      testWidgets('displays day builder content', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/trip/japan-trip/day/Tokyo'),
        );
        await tester.pumpAndSettle();

        final dayBuilder = DayBuilderRobot(tester);
        await dayBuilder.verifyScreenDisplayed();
      });

      testWidgets('displays Overview and Itinerary tabs', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/trip/japan-trip/day/Tokyo'),
        );
        await tester.pumpAndSettle();

        final dayBuilder = DayBuilderRobot(tester);
        await dayBuilder.verifyTabsDisplayed();
      });
    });

    group('DayBuilderScreen Tab Navigation', () {
      testWidgets('can switch to Itinerary tab', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/trip/japan-trip/day/Tokyo'),
        );
        await tester.pumpAndSettle();

        final dayBuilder = DayBuilderRobot(tester);
        await dayBuilder.tapItineraryTab();

        expect(dayBuilder.itineraryTab, findsOneWidget);
      });

      testWidgets('can switch back to Overview tab', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/trip/japan-trip/day/Tokyo'),
        );
        await tester.pumpAndSettle();

        final dayBuilder = DayBuilderRobot(tester);
        await dayBuilder.tapItineraryTab();
        await dayBuilder.tapOverviewTab();

        expect(dayBuilder.overviewTab, findsOneWidget);
      });
    });

    group('DayBuilderScreen Day Navigation', () {
      testWidgets('displays day chips', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/trip/japan-trip/day/Tokyo'),
        );
        await tester.pumpAndSettle();

        final dayBuilder = DayBuilderRobot(tester);
        await dayBuilder.verifyDayChipDisplayed(1);
      });

      testWidgets('can navigate between days', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/trip/japan-trip/day/Tokyo'),
        );
        await tester.pumpAndSettle();

        final dayBuilder = DayBuilderRobot(tester);

        // Try to tap day 2 if it exists
        if (dayBuilder.dayChip(2).evaluate().isNotEmpty) {
          await dayBuilder.tapDayChip(2);
          expect(dayBuilder.dayChip(2), findsOneWidget);
        }
      });
    });

    group('DayBuilderScreen Auto-fill', () {
      testWidgets('displays auto-fill button', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/trip/japan-trip/day/Tokyo'),
        );
        await tester.pumpAndSettle();

        final dayBuilder = DayBuilderRobot(tester);
        await dayBuilder.verifyAutoFillButtonDisplayed();
      });
    });

    group('DayBuilderScreen Free Day', () {
      testWidgets('displays free day text for empty days', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/trip/japan-trip/day/Tokyo'),
        );
        await tester.pumpAndSettle();

        final dayBuilder = DayBuilderRobot(tester);
        await dayBuilder.verifyFreeDayTextDisplayed();
      });
    });
  });
}
