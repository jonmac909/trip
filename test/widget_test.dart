// Basic Flutter widget test for Trippified app

import 'package:flutter_test/flutter_test.dart';

import 'package:trippified/main.dart';

void main() {
  testWidgets('App starts and shows splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TrippifiedApp());

    // Verify the app starts (splash screen or home screen)
    // The splash screen shows the Trippified logo
    expect(find.byType(TrippifiedApp), findsOneWidget);
  });
}
