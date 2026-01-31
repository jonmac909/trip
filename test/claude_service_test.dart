import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trippified/core/services/claude_service.dart';

void main() {
  setUpAll(() async {
    await dotenv.load(fileName: '.env');
    print('Loaded .env file');
    print('CLAWDBOT_API_URL: ${dotenv.env['CLAWDBOT_API_URL']}');
    print('CLAWDBOT_API_TOKEN present: ${dotenv.env['CLAWDBOT_API_TOKEN']?.isNotEmpty ?? false}');
  });

  group('ClaudeService via Clawdbot', () {
    test('should generate day plans for Bangkok', () async {
      print('Starting Clawdbot API test...');

      final plans = await ClaudeService.instance.generateDayPlans(
        cityName: 'Bangkok',
        totalDays: 2,
        emptyDayNumbers: [1],
      );

      print('Generated ${plans.length} plans');
      for (final plan in plans) {
        print('Day ${plan.dayNumber}: ${plan.themeLabel} - ${plan.activities.length} activities');
        for (final activity in plan.activities) {
          print('  - ${activity.time}: ${activity.name} (${activity.category})');
        }
      }

      expect(plans, isNotEmpty);
      expect(plans.first.activities, isNotEmpty);
    }, timeout: const Timeout(Duration(seconds: 60)));
  });
}
