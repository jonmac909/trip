import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:trippified/presentation/screens/explore/explore_history_screen.dart';

/// Robot for interacting with ExploreHistoryScreen in tests
class ExploreHistoryRobot {
  ExploreHistoryRobot(this.tester);

  final WidgetTester tester;

  // Screen finders
  Finder get screen => find.byType(ExploreHistoryScreen);
  Finder get pageTitle => find.text('History');

  // History items
  Finder historyItem(String title) => find.text(title);
  Finder historyItemByUrl(String url) => find.textContaining(url);

  // Empty state
  Finder get emptyState => find.text('No scan history');
  Finder get emptyHint => find.text('Your scanned links will appear here');

  // Clear history
  Finder get clearAllButton => find.text('Clear All');
  Finder get clearConfirmButton => find.text('Clear');
  Finder get clearCancelButton => find.text('Cancel');

  // Back button
  Finder get backButton => find.byIcon(LucideIcons.arrowLeft);

  // Verifications
  Future<void> verifyScreenDisplayed() async {
    expect(screen, findsOneWidget);
  }

  Future<void> verifyPageTitleDisplayed() async {
    expect(pageTitle, findsOneWidget);
  }

  Future<void> verifyEmptyStateDisplayed() async {
    expect(emptyState, findsOneWidget);
    expect(emptyHint, findsOneWidget);
  }

  Future<void> verifyHistoryItemDisplayed(String title) async {
    expect(historyItem(title), findsOneWidget);
  }

  // Actions
  Future<void> tapHistoryItem(String title) async {
    await tester.tap(historyItem(title));
    await tester.pumpAndSettle();
  }

  Future<void> tapClearAll() async {
    await tester.tap(clearAllButton);
    await tester.pumpAndSettle();
  }

  Future<void> confirmClear() async {
    await tester.tap(clearConfirmButton);
    await tester.pumpAndSettle();
  }

  Future<void> cancelClear() async {
    await tester.tap(clearCancelButton);
    await tester.pumpAndSettle();
  }

  Future<void> tapBack() async {
    await tester.tap(backButton.first);
    await tester.pumpAndSettle();
  }

  /// Swipe to delete a history item
  Future<void> swipeToDelete(String title) async {
    await tester.drag(historyItem(title), const Offset(-200, 0));
    await tester.pumpAndSettle();
  }
}
