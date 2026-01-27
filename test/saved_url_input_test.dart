import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:trippified/core/theme/app_theme.dart';
import 'package:trippified/presentation/screens/saved/saved_screen.dart';

void main() {
  group('SavedScreen URL Input', () {
    Widget createSavedScreenApp() {
      final router = GoRouter(
        initialLocation: '/saved',
        routes: [
          ShellRoute(
            builder: (context, state, child) => Scaffold(
              body: child,
              bottomNavigationBar: const SizedBox(height: 50),
            ),
            routes: [
              GoRoute(
                path: '/saved',
                builder: (context, state) => const SavedScreen(),
              ),
              GoRoute(
                path: '/saved/scan-results',
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Scan Results')),
                ),
              ),
            ],
          ),
        ],
      );

      return ProviderScope(
        child: MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: router,
        ),
      );
    }

    testWidgets('displays a TextField for URL input', (tester) async {
      await tester.pumpWidget(createSavedScreenApp());
      await tester.pumpAndSettle();

      // Verify a TextField exists with the hint text
      expect(
        find.widgetWithText(TextField, 'Paste TikTok or Instagram URL'),
        findsOneWidget,
      );
    });

    testWidgets('TextField accepts typed text', (tester) async {
      await tester.pumpWidget(createSavedScreenApp());
      await tester.pumpAndSettle();

      // Find the TextField
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      // Tap to focus
      await tester.tap(textField);
      await tester.pump();

      // Type a URL
      await tester.enterText(
        textField,
        'https://www.tiktok.com/@user/video/123',
      );
      await tester.pump();

      // Verify text appears
      expect(
        find.text('https://www.tiktok.com/@user/video/123'),
        findsOneWidget,
      );
    });

    testWidgets('clear button appears when text is entered', (tester) async {
      await tester.pumpWidget(createSavedScreenApp());
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);

      // Enter text
      await tester.tap(textField);
      await tester.pump();
      await tester.enterText(
        textField,
        'https://www.tiktok.com/@test',
      );
      await tester.pump();

      // Verify clear button (X icon) appears
      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('clear button clears the text', (tester) async {
      await tester.pumpWidget(createSavedScreenApp());
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);

      // Enter text
      await tester.tap(textField);
      await tester.pump();
      await tester.enterText(
        textField,
        'https://www.tiktok.com/@test',
      );
      await tester.pump();

      // Tap clear button
      final clearButton = find.byType(IconButton);
      await tester.tap(clearButton);
      await tester.pump();

      // Verify text is cleared
      expect(
        find.text('https://www.tiktok.com/@test'),
        findsNothing,
      );
    });

    testWidgets('Import button shows snackbar when no URL entered',
        (tester) async {
      await tester.pumpWidget(createSavedScreenApp());
      await tester.pumpAndSettle();

      // Tap Import without entering URL
      final importButton = find.text('Import');
      expect(importButton, findsOneWidget);
      await tester.tap(importButton);
      await tester.pump();

      // Verify snackbar appears
      expect(
        find.text('Paste a TikTok or Instagram URL first'),
        findsOneWidget,
      );
    });

    testWidgets('Import button navigates when URL is entered',
        (tester) async {
      await tester.pumpWidget(createSavedScreenApp());
      await tester.pumpAndSettle();

      // Enter a URL
      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pump();
      await tester.enterText(
        textField,
        'https://www.tiktok.com/@user/video/123',
      );
      await tester.pump();

      // Tap Import
      final importButton = find.text('Import');
      await tester.tap(importButton);
      await tester.pumpAndSettle();

      // Should navigate to scan results
      expect(find.text('Scan Results'), findsOneWidget);
    });
  });
}
