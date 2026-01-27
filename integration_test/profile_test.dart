import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trippified/presentation/screens/profile/my_tickets_screen.dart';

import 'robots/home_robot.dart';
import 'robots/profile_robot.dart';
import 'test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  initializeTestConfig();

  group('Profile Module E2E Tests', () {
    group('ProfileScreen Layout', () {
      testWidgets('displays profile screen when navigating to Profile tab', (
        tester,
      ) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        final home = HomeRobot(tester);
        await home.tapProfileTab();

        final profile = ProfileRobot(tester);
        await profile.verifyScreenDisplayed();
      });

      testWidgets('displays Profile title', (tester) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        final home = HomeRobot(tester);
        await home.tapProfileTab();

        final profile = ProfileRobot(tester);
        await profile.verifyPageTitleDisplayed();
      });

      testWidgets('displays menu items', (tester) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        final home = HomeRobot(tester);
        await home.tapProfileTab();

        final profile = ProfileRobot(tester);
        await profile.verifyMenuItemsDisplayed();
      });

      testWidgets('displays logout option', (tester) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        final home = HomeRobot(tester);
        await home.tapProfileTab();

        final profile = ProfileRobot(tester);
        await profile.verifyLogoutDisplayed();
      });
    });

    group('ProfileScreen Navigation', () {
      testWidgets('can navigate to My Tickets', (tester) async {
        await tester.pumpWidget(createHomeTestApp());
        await tester.pumpAndSettle();

        final home = HomeRobot(tester);
        await home.tapProfileTab();

        final profile = ProfileRobot(tester);
        await profile.tapMyTickets();

        expect(find.byType(MyTicketsScreen), findsOneWidget);
      });
    });

    group('MyTicketsScreen Layout', () {
      testWidgets('displays my tickets screen', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/profile/tickets'),
        );
        await tester.pumpAndSettle();

        expect(find.byType(MyTicketsScreen), findsOneWidget);
      });

      testWidgets('displays My Tickets title', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/profile/tickets'),
        );
        await tester.pumpAndSettle();

        final tickets = MyTicketsRobot(tester);
        await tickets.verifyPageTitleDisplayed();
      });

      testWidgets('displays Transport Tickets section', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/profile/tickets'),
        );
        await tester.pumpAndSettle();

        final tickets = MyTicketsRobot(tester);
        await tickets.verifyTransportTicketsSectionDisplayed();
      });

      testWidgets('displays Add Ticket button', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/profile/tickets'),
        );
        await tester.pumpAndSettle();

        final tickets = MyTicketsRobot(tester);
        await tickets.verifyAddTicketButtonDisplayed();
      });
    });

    group('MyTicketsScreen Content', () {
      testWidgets('displays ticket cards', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/profile/tickets'),
        );
        await tester.pumpAndSettle();

        final tickets = MyTicketsRobot(tester);
        await tickets.verifyAllTicketsDisplayed();
      });

      testWidgets('displays Flight to Tokyo ticket', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/profile/tickets'),
        );
        await tester.pumpAndSettle();

        final tickets = MyTicketsRobot(tester);
        await tickets.verifyTicketCardDisplayed('Flight to Tokyo');
      });

      testWidgets('displays Shinkansen to Kyoto ticket', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/profile/tickets'),
        );
        await tester.pumpAndSettle();

        final tickets = MyTicketsRobot(tester);
        await tickets.verifyTicketCardDisplayed('Shinkansen to Kyoto');
      });
    });
  });
}
