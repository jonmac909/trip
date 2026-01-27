import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:trippified/presentation/screens/explore/explore_history_screen.dart';

import 'test_app.dart';
import 'robots/explore_history_robot.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  initializeTestConfig();

  group('Explore History E2E Tests', () {
    group('ExploreHistoryScreen Layout', () {
      testWidgets('displays explore history screen', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/explore/history'),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ExploreHistoryScreen), findsOneWidget);
      });

      testWidgets('displays explore history content', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/explore/history'),
        );
        await tester.pumpAndSettle();

        final history = ExploreHistoryRobot(tester);
        await history.verifyScreenDisplayed();
      });

      testWidgets('displays page title', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/explore/history'),
        );
        await tester.pumpAndSettle();

        final history = ExploreHistoryRobot(tester);
        await history.verifyPageTitleDisplayed();
      });

      testWidgets('has back button', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/explore/history'),
        );
        await tester.pumpAndSettle();

        final history = ExploreHistoryRobot(tester);
        expect(history.backButton, findsOneWidget);
      });
    });

    group('Empty State', () {
      testWidgets('shows empty state when no history', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/explore/history'),
        );
        await tester.pumpAndSettle();

        final history = ExploreHistoryRobot(tester);
        await history.verifyEmptyStateDisplayed();
      });
    });

    group('Back Navigation', () {
      testWidgets('back button navigates back', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/explore/history'),
        );
        await tester.pumpAndSettle();

        final history = ExploreHistoryRobot(tester);
        await history.tapBack();

        // Should navigate back (screen no longer visible)
        expect(find.byType(ExploreHistoryScreen), findsNothing);
      });
    });
  });
}
