import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:trippified/presentation/screens/trip/smart_tickets_screen.dart';
import 'package:trippified/presentation/screens/profile/my_tickets_screen.dart';

import 'test_app.dart';
import 'robots/tickets_robot.dart';
import 'robots/home_robot.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  initializeTestConfig();

  group('Tickets Module E2E Tests', () {
    group('SmartTicketsScreen', () {
      testWidgets('displays smart tickets screen', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/trip/test-trip/tickets'),
        );
        await tester.pumpAndSettle();

        expect(find.byType(SmartTicketsScreen), findsOneWidget);
      });

      testWidgets('displays smart tickets content', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/trip/test-trip/tickets'),
        );
        await tester.pumpAndSettle();

        final tickets = SmartTicketsRobot(tester);
        await tickets.verifyScreenDisplayed();
      });

      testWidgets('has back button', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/trip/test-trip/tickets'),
        );
        await tester.pumpAndSettle();

        final tickets = SmartTicketsRobot(tester);
        expect(tickets.backButton, findsOneWidget);
      });

      testWidgets('shows empty state when no tickets', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/trip/test-trip/tickets'),
        );
        await tester.pumpAndSettle();

        final tickets = SmartTicketsRobot(tester);
        await tickets.verifyEmptyStateDisplayed();
      });
    });

    group('MyTicketsScreen', () {
      testWidgets('displays my tickets screen', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/profile/tickets'),
        );
        await tester.pumpAndSettle();

        expect(find.byType(MyTicketsScreen), findsOneWidget);
      });

      testWidgets('displays my tickets content', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/profile/tickets'),
        );
        await tester.pumpAndSettle();

        final tickets = MyTicketsRobot(tester);
        await tickets.verifyScreenDisplayed();
      });

      testWidgets('has back button', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/profile/tickets'),
        );
        await tester.pumpAndSettle();

        final tickets = MyTicketsRobot(tester);
        expect(tickets.backButton, findsOneWidget);
      });

      testWidgets('shows empty state when no tickets', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/profile/tickets'),
        );
        await tester.pumpAndSettle();

        final tickets = MyTicketsRobot(tester);
        await tickets.verifyEmptyStateDisplayed();
      });

      testWidgets('can navigate from profile', (tester) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        final home = HomeRobot(tester);
        await home.tapProfileTab();

        // Look for My Tickets option in profile
        expect(find.text('My Tickets'), findsOneWidget);
      });
    });
  });
}
