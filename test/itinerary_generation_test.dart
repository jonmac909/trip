import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trippified/core/services/claude_service.dart';

// Simulates the exact flow from itinerary_builder_screen.dart
void main() {
  setUpAll(() async {
    await dotenv.load(fileName: '.env');
  });

  test('simulate itinerary builder generation flow', () async {
    // Same setup as itinerary_builder_screen
    final cityName = 'Bangkok';
    final totalDays = 7;

    // Simulate _days list with empty activities
    final days = List.generate(totalDays, (i) => {
      'dayNumber': i + 1,
      'activities': <Map<String, dynamic>>[],
    });

    // Find empty days (same logic as screen)
    final emptyDayNumbers = <int>[];
    for (var i = 0; i < days.length; i++) {
      final activities = days[i]['activities'] as List;
      if (activities.isEmpty) {
        emptyDayNumbers.add(i + 1);
      }
    }

    print('Empty days to generate: $emptyDayNumbers');
    expect(emptyDayNumbers, isNotEmpty);

    // Call Claude via Clawdbot
    print('Calling Clawdbot proxy...');
    final generatedPlans = await ClaudeService.instance.generateDayPlans(
      cityName: cityName,
      totalDays: totalDays,
      emptyDayNumbers: emptyDayNumbers,
    );

    print('Got ${generatedPlans.length} plans');

    // Simulate updating state (same loop as screen)
    for (final plan in generatedPlans) {
      final dayIndex = plan.dayNumber - 1;
      print('Processing day ${plan.dayNumber} (index $dayIndex) with ${plan.activities.length} activities');

      if (dayIndex >= 0 && dayIndex < days.length) {
        // Convert activities
        final activities = plan.activities.map((a) => {
          'name': a.name,
          'category': a.category,
          'time': a.time,
          'location': a.location,
          'notes': a.description,
        }).toList();

        // Update the day
        days[dayIndex] = {
          'dayNumber': dayIndex + 1,
          'activities': activities,
        };

        print('Day $dayIndex now has ${activities.length} activities');
      }
    }

    // Verify
    final totalActivities = days.fold<int>(
      0,
      (sum, day) => sum + (day['activities'] as List).length,
    );

    print('Total activities after generation: $totalActivities');
    expect(totalActivities, greaterThan(0));
  }, timeout: const Timeout(Duration(seconds: 120)));
}
