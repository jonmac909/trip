# User Journey Integration Tests

## Overview

The `user_journeys_test.dart` file contains comprehensive end-to-end tests for all major user flows in the Trippified app. These tests ensure that complete user journeys work correctly from start to finish.

## Test Coverage

### 1. Trippified Flow (Trip Planner)
Tests the complete trip planning journey from country selection to itinerary creation.

**Test Groups:**
- **Complete Trip Setup Journey**
  - Full flow from country selection to itinerary creation
  - CTA enabling when country and trip size selected
  - Multiple country selection
  - Different trip size options

- **Recommended Routes Journey**
  - Navigation to recommended routes after setup
  - Display of route options for selected countries

- **Itinerary Blocks Journey**
  - Entering day builder from city blocks
  - City block interactions

### 2. Day Builder
Tests the detailed day planning and itinerary building features.

**Test Groups:**
- **Overview Tab Journey**
  - Free day status display
  - Generate button functionality
  - Day navigation between multiple days
  - Day labels after generation

- **Itinerary Tab Journey**
  - Tab switching functionality
  - Time bucket display
  - Activity management

- **Day Management Journey**
  - Multiple days per city
  - Adding activities via add button

- **Anchor System Journey**
  - Anchor display in generated days
  - Anchor swap functionality (placeholder for future tests)

### 3. Explore Flow
Tests destination discovery and browsing features.

**Test Groups:**
- **Browse Destinations Journey**
  - Explore screen with tabs
  - Tab switching (Destinations/Itineraries)
  - Search bar functionality

- **View Curated Itineraries Journey**
  - Itinerary display in Itineraries tab

- **Destination Detail Journey**
  - Navigation to destination details
  - Tab navigation (Overview/Cities/Itineraries)

- **City Detail Journey**
  - City detail screen navigation
  - Saving items from city detail

- **Save to Saved Hub Journey**
  - Saving items from explore to saved hub

### 4. Saved Flow
Tests the saved items management and itinerary generation from saved content.

**Test Groups:**
- **View Saved Items Journey**
  - Saved screen with tabs
  - Empty state display
  - Tab switching (Places/Itineraries/Links)

- **Saved by City/Collection Journey**
  - Items grouped by city
  - City detail navigation

- **Generate Itinerary from Saved Items Journey**
  - Create itinerary CTA
  - Customize itinerary flow
  - Route review before finalizing

- **Organize/Remove Saved Items Journey**
  - City detail management

### 5. Social Media Import
Tests the TikTok/Instagram content extraction and import flow.

**Test Groups:**
- **Paste URL Journey**
  - Scan TikTok button display
  - Navigation to scan results

- **TikTok Scan Results Journey**
  - Loading state during scan
  - Error state handling
  - Footer hiding in error state
  - Retry functionality
  - Back navigation

- **Save to Collection Journey**
  - Create Trip CTA in results
  - Saving extracted locations

### Edge Cases and Error Handling
Tests for graceful handling of edge cases and errors.

- Empty trip setup
- Navigation between major sections
- Empty saved state

## Running the Tests

### Run All Tests
```bash
flutter test integration_test/all_tests.dart
```

### Run Only User Journey Tests
```bash
flutter test integration_test/user_journeys_test.dart
```

### Run on Specific Device
```bash
flutter test integration_test/user_journeys_test.dart -d <device-id>
```

### Run on iOS Simulator
```bash
# List available simulators
xcrun simctl list devices available

# Boot a simulator
xcrun simctl boot <simulator-id>

# Run tests
flutter test integration_test/user_journeys_test.dart

# Shutdown simulator
xcrun simctl shutdown all
```

## CI/CD Integration

The tests are automatically run in GitHub Actions on every push and pull request to main branches. The workflow:

1. Boots an iOS simulator (iPhone 15 or fallback)
2. Runs the user journey integration tests
3. Shuts down the simulator
4. Reports results

See `.github/workflows/ios.yml` for the complete CI configuration.

## Test Structure

Tests follow the Robot pattern for maintainability:

```dart
// Arrange
await tester.pumpWidget(createTestApp());
await tester.pumpAndSettle();

// Act
final robot = SomeRobot(tester);
await robot.performAction();

// Assert
await robot.verifyExpectedState();
```

### Robot Classes Used

- `HomeRobot` - Home screen navigation
- `TripSetupRobot` - Trip setup screen
- `RecommendedRoutesRobot` - Route selection
- `DayBuilderRobot` - Day planning
- `ExploreRobot` - Explore tab
- `DestinationDetailRobot` - Destination details
- `CityDetailRobot` - City details
- `SavedRobot` - Saved tab
- `SavedCityDetailRobot` - Saved city details
- `CustomizeItineraryRobot` - Itinerary customization
- `ReviewRouteRobot` - Route review
- `TiktokScanResultsRobot` - Social media scan results

## Adding New Tests

When adding new user journey tests:

1. **Identify the complete user flow** - Start from entry point to final outcome
2. **Create test groups** - Group related test cases
3. **Use descriptive names** - Follow `should {behavior} when {condition}` pattern
4. **Leverage robots** - Use existing robots or extend them
5. **Test happy paths and edge cases** - Cover both success and error scenarios
6. **Update this README** - Document new test coverage

## Test Data Requirements

Some tests require specific test data or mocked responses:

- **Trip data** - Routes with cities and days
- **Explore data** - Destinations, cities, curated itineraries
- **Saved items** - Places saved to collections
- **Social media** - Mock TikTok/Instagram URLs for scanning

See `test_app.dart` for test app configuration and data setup.

## Troubleshooting

### Tests Timeout
- Increase timeout: `flutter test --timeout=10m`
- Check for infinite animations (use `pump()` instead of `pumpAndSettle()`)

### Simulator Issues
- Ensure simulator is booted before running tests
- Use `xcrun simctl list` to verify available simulators
- Try resetting simulator: `xcrun simctl erase <simulator-id>`

### Widget Not Found
- Verify the widget key or text matcher
- Check if widget is in a scrollable view (may need to scroll)
- Ensure proper screen navigation before finding widget

### Flaky Tests
- Add explicit waits with `tester.pumpAndSettle()`
- Check for race conditions with async operations
- Verify test data is properly set up

## Maintenance

These tests should be updated when:
- New features are added to user journeys
- UI flows change (screen order, navigation)
- Critical user paths are modified
- Bugs are discovered in user flows (add regression tests)

## Test Metrics

Current coverage:
- **5 major user journeys** fully tested
- **70+ test cases** covering happy paths and edge cases
- **12+ robot classes** for maintainable test code
- **CI integration** for automated testing

## Future Improvements

Planned test enhancements:
1. Add more anchor system tests when backend is integrated
2. Test collaborative trip editing features
3. Add offline mode testing
4. Test budget tracking features
5. Test live trip mode during travel
6. Add performance benchmarks
7. Test social media import with real API responses (mocked)

## References

- [Flutter Integration Testing](https://docs.flutter.dev/testing/integration-tests)
- [Robot Pattern](https://dev.to/automationhacks/robot-pattern-in-ui-tests-7lh)
- [Testing Best Practices](https://docs.flutter.dev/testing/best-practices)
