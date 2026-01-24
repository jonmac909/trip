# Trippified E2E Runner Agent

## Purpose
Create and run end-to-end integration tests for critical user flows.

## When I'm Called
- Completing a user flow
- Before release
- After major refactoring

---

## Critical Flows to Test

### 1. Authentication Flow
```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow', () {
    testWidgets('should complete Google sign-in', (tester) async {
      await tester.pumpWidget(TrippifiedApp());
      await tester.pumpAndSettle();

      // Verify on login screen
      expect(find.text('Welcome to Trippified'), findsOneWidget);

      // Tap Google sign-in
      await tester.tap(find.byKey(Key('google_sign_in')));
      await tester.pumpAndSettle();

      // Verify redirected to home (mock auth for tests)
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should handle sign-out', (tester) async {
      // Setup: Already logged in
      await tester.pumpWidget(TrippifiedApp(initialUser: mockUser));
      await tester.pumpAndSettle();

      // Navigate to profile
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      // Tap sign out
      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();

      // Confirm
      await tester.tap(find.text('Yes, sign out'));
      await tester.pumpAndSettle();

      // Verify on login screen
      expect(find.text('Welcome to Trippified'), findsOneWidget);
    });
  });
}
```

### 2. Trip Creation Flow
```dart
group('Trip Creation Flow', () {
  testWidgets('should create trip from setup to itinerary blocks',
      (tester) async {
    await tester.pumpWidget(TrippifiedApp(initialUser: mockUser));
    await tester.pumpAndSettle();

    // Step 1: Start new trip
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Step 2: Trip Setup - Add country
    await tester.enterText(find.byKey(Key('country_input')), 'Japan');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Japan').last);
    await tester.pumpAndSettle();

    // Verify chip added
    expect(find.text('Japan'), findsNWidgets(2)); // Input + chip

    // Step 3: Select trip size
    await tester.tap(find.text('Week-long'));
    await tester.pumpAndSettle();

    // Step 4: Proceed
    await tester.tap(find.text('See recommended routes'));
    await tester.pumpAndSettle();

    // Verify on routes screen
    expect(find.text('Recommended routes'), findsOneWidget);

    // Step 5: Select route
    await tester.tap(find.text('Tokyo → Kyoto'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create itinerary'));
    await tester.pumpAndSettle();

    // Verify on itinerary blocks screen
    expect(find.text('Your itinerary'), findsOneWidget);
    expect(find.text('Tokyo'), findsOneWidget);
    expect(find.text('Kyoto'), findsOneWidget);
  });
});
```

### 3. Day Builder Flow
```dart
group('Day Builder Flow', () {
  testWidgets('should generate and edit day itinerary', (tester) async {
    // Setup: Trip already created
    await tester.pumpWidget(
      TrippifiedApp(initialUser: mockUser, initialTrip: mockTrip),
    );
    await tester.pumpAndSettle();

    // Navigate to trip
    await tester.tap(find.text('Japan Trip'));
    await tester.pumpAndSettle();

    // Enter Day Builder
    await tester.tap(find.text('Tokyo · 4 days'));
    await tester.pumpAndSettle();

    // Verify Overview tab
    expect(find.text('Day 1 — Free day'), findsOneWidget);
    expect(find.text('Generate'), findsWidgets);

    // Generate Day 1
    await tester.tap(find.text('Generate').first);
    await tester.pumpAndSettle();

    // Verify generated
    expect(find.textContaining('Day 1 —'), findsOneWidget);
    expect(find.text('Free day'), findsNothing); // Changed from Free day

    // Tap Edit
    await tester.tap(find.text('Edit').first);
    await tester.pumpAndSettle();

    // Verify on Itinerary tab
    expect(find.text('Itinerary'), findsOneWidget);
    expect(find.text('Morning'), findsOneWidget);
  });
});
```

### 4. Budget Tracking Flow
```dart
group('Budget Tracking Flow', () {
  testWidgets('should add and view expenses', (tester) async {
    await tester.pumpWidget(
      TrippifiedApp(initialUser: mockUser, initialTrip: mockTrip),
    );
    await tester.pumpAndSettle();

    // Navigate to trip budget
    await tester.tap(find.text('Japan Trip'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.account_balance_wallet));
    await tester.pumpAndSettle();

    // Set budget
    await tester.tap(find.text('Set Budget'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(Key('budget_input')), '2000');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Add expense
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(Key('amount_input')), '50');
    await tester.tap(find.text('Food'));
    await tester.enterText(find.byKey(Key('description_input')), 'Sushi dinner');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify expense added
    expect(find.text('Sushi dinner'), findsOneWidget);
    expect(find.text('\$50'), findsOneWidget);
    expect(find.textContaining('\$1,950 remaining'), findsOneWidget);
  });
});
```

### 5. Offline Mode Flow
```dart
group('Offline Mode Flow', () {
  testWidgets('should access trip offline', (tester) async {
    await tester.pumpWidget(
      TrippifiedApp(initialUser: mockUser, initialTrip: mockTrip),
    );
    await tester.pumpAndSettle();

    // Download trip
    await tester.tap(find.text('Japan Trip'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.download));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Download for Offline'));
    await tester.pumpAndSettle();

    // Wait for download
    await tester.pump(Duration(seconds: 2));
    expect(find.text('Downloaded'), findsOneWidget);

    // Simulate offline
    await mockNetworkOffline();

    // Navigate away and back
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Japan Trip'));
    await tester.pumpAndSettle();

    // Verify still accessible
    expect(find.text('Tokyo'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_off), findsOneWidget); // Offline indicator
  });
});
```

---

## Test Setup

### Test Configuration
```dart
// integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trippified/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Reset app state
    await clearTestData();
    // Setup mock services
    setupMockServices();
  });

  tearDown(() async {
    // Cleanup
    await clearTestData();
  });

  // Include test groups
  authenticationTests();
  tripCreationTests();
  dayBuilderTests();
  budgetTrackingTests();
  offlineModeTests();
}
```

### Running E2E Tests
```bash
# Run all integration tests
flutter test integration_test/

# Run specific test file
flutter test integration_test/trip_creation_test.dart

# Run on real device
flutter drive \
  --driver=test_driver/integration_driver.dart \
  --target=integration_test/app_test.dart

# Run on specific device
flutter drive \
  --driver=test_driver/integration_driver.dart \
  --target=integration_test/app_test.dart \
  -d "iPhone 14"
```

---

## E2E Test Checklist

Before release:

- [ ] Authentication (sign in, sign out, token refresh)
- [ ] Trip creation (full flow)
- [ ] Day Builder (generate, edit)
- [ ] Explore (browse, save)
- [ ] Saved items (view, create itinerary from saved)
- [ ] Budget (set budget, add expense, view summary)
- [ ] Documents (upload, view, delete)
- [ ] Offline mode (download, access offline)
- [ ] Live trip mode (today view, check-in)
- [ ] Collaboration (share trip, edit as collaborator)

---

## Test Output Format

```markdown
# E2E Test Results

## Summary
- Total: X tests
- Passed: Y
- Failed: Z
- Skipped: W

## Failed Tests

### test_name
**File**: integration_test/file_test.dart:123
**Error**: Description
**Screenshot**: [link]
**Steps to reproduce**:
1. ...
2. ...

## Flaky Tests
- test_name (failed 1/5 runs)

## Performance Notes
- Trip creation flow: 3.2s average
- Day generation: 1.8s average
```
