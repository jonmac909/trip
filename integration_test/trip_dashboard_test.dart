import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:trippified/presentation/screens/trip/trip_dashboard_screen.dart';
import 'package:trippified/presentation/screens/trip/smart_tickets_screen.dart';

import 'test_app.dart';
import 'robots/trip_dashboard_robot.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  initializeTestConfig();

  group('Trip Dashboard Module E2E Tests', () {
    group('TripDashboardScreen Layout', () {
      testWidgets('displays trip dashboard screen', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/trip/japan-trip'),
        );
        await tester.pumpAndSettle();

        expect(find.byType(TripDashboardScreen), findsOneWidget);
      });

      testWidgets('displays trip dashboard content', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/trip/japan-trip'),
        );
        await tester.pumpAndSettle();

        final dashboard = TripDashboardRobot(tester);
        await dashboard.verifyScreenDisplayed();
      });

      testWidgets('displays stats cards', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/trip/japan-trip'),
        );
        await tester.pumpAndSettle();

        final dashboard = TripDashboardRobot(tester);
        await dashboard.verifyStatsDisplayed();
      });

      testWidgets('displays Trip Checklist card', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/trip/japan-trip'),
        );
        await tester.pumpAndSettle();

        final dashboard = TripDashboardRobot(tester);
        await dashboard.verifyTripChecklistCardDisplayed();
      });

      testWidgets('displays Your Itineraries section', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/trip/japan-trip'),
        );
        await tester.pumpAndSettle();

        final dashboard = TripDashboardRobot(tester);
        await dashboard.verifyYourItinerariesDisplayed();
      });
    });

    group('TripDashboardScreen Checklist', () {
      testWidgets('can tap Trip Checklist to expand', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/trip/japan-trip'),
        );
        await tester.pumpAndSettle();

        final dashboard = TripDashboardRobot(tester);
        await dashboard.tapTripChecklist();

        // Checklist sections should be visible
        expect(dashboard.transportSection, findsOneWidget);
      });
    });

    group('SmartTicketsScreen Layout', () {
      testWidgets('displays smart tickets screen', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/trip/japan-trip/tickets'),
        );
        await tester.pumpAndSettle();

        expect(find.byType(SmartTicketsScreen), findsOneWidget);
      });

      testWidgets('displays smart tickets content', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/trip/japan-trip/tickets'),
        );
        await tester.pumpAndSettle();

        final tickets = SmartTicketsRobot(tester);
        await tickets.verifyScreenDisplayed();
      });

      testWidgets('displays tabs', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/trip/japan-trip/tickets'),
        );
        await tester.pumpAndSettle();

        final tickets = SmartTicketsRobot(tester);
        await tickets.verifyTabsDisplayed();
      });

      testWidgets('displays Add Ticket button', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/trip/japan-trip/tickets'),
        );
        await tester.pumpAndSettle();

        final tickets = SmartTicketsRobot(tester);
        await tickets.verifyAddTicketButtonDisplayed();
      });
    });
  });
}
