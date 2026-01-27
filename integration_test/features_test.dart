import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:trippified/presentation/screens/features/itinerary_stacking_screen.dart';
import 'package:trippified/presentation/screens/features/day_builder_detail_screen.dart';
import 'package:trippified/presentation/screens/features/itinerary_detail_screen.dart';
import 'package:trippified/presentation/screens/features/add_itinerary_screen.dart';

import 'test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  initializeTestConfig();

  group('Features Module E2E Tests', () {
    group('ItineraryStackingScreen', () {
      testWidgets('displays itinerary stacking screen', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/features/stacking'),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ItineraryStackingScreen), findsOneWidget);
      });

      testWidgets('displays stacking content', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/features/stacking'),
        );
        await tester.pumpAndSettle();

        // Screen should be visible
        expect(find.byType(ItineraryStackingScreen), findsOneWidget);
      });
    });

    group('DayBuilderDetailScreen', () {
      testWidgets('displays day builder detail screen', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/features/day-detail'),
        );
        await tester.pumpAndSettle();

        expect(find.byType(DayBuilderDetailScreen), findsOneWidget);
      });

      testWidgets('displays day builder detail content', (tester) async {
        await tester.pumpWidget(
          createTestApp(initialRoute: '/features/day-detail'),
        );
        await tester.pumpAndSettle();

        // Screen should be visible
        expect(find.byType(DayBuilderDetailScreen), findsOneWidget);
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

        // Screen should be visible
        expect(find.byType(ItineraryDetailScreen), findsOneWidget);
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

        // Screen should be visible
        expect(find.byType(AddItineraryScreen), findsOneWidget);
      });
    });
  });
}
