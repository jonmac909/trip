/// Main test runner for all E2E tests
///
/// Run with: flutter test integration_test/all_tests.dart
/// Or for specific device: flutter test integration_test/all_tests.dart -d <device>
library;

import 'auth_test.dart' as auth;
import 'home_test.dart' as home;
import 'trip_setup_test.dart' as trip_setup;
import 'explore_test.dart' as explore;
import 'saved_test.dart' as saved;
import 'profile_test.dart' as profile;
import 'trip_dashboard_test.dart' as trip_dashboard;
import 'day_builder_test.dart' as day_builder;
import 'features_test.dart' as features;
import 'user_journeys_test.dart' as user_journeys;

void main() {
  // Auth module tests (Splash, Login)
  auth.main();

  // Home screen tests
  home.main();

  // Trip setup module tests
  trip_setup.main();

  // Explore module tests
  explore.main();

  // Saved module tests
  saved.main();

  // Profile module tests
  profile.main();

  // Trip dashboard module tests
  trip_dashboard.main();

  // Day builder module tests
  day_builder.main();

  // Features module tests
  features.main();

  // Comprehensive user journey tests
  user_journeys.main();
}
