# Trippified Test Plan

> Comprehensive testing strategy for the Trippified mobile app

## Table of Contents
- [Overview](#overview)
- [Test Types](#test-types)
- [Coverage Matrix](#coverage-matrix)
- [Maestro E2E Flows](#maestro-e2e-flows)
- [Flutter Integration Tests](#flutter-integration-tests)
- [Manual Test Checklist](#manual-test-checklist)
- [Running Tests](#running-tests)
- [Known Issues](#known-issues)

---

## Overview

### Test Architecture
```
tests/
├── unit/                    # Dart unit tests (lib behavior)
├── integration_test/        # Flutter integration tests (widget + navigation)
│   ├── robots/              # Page Object Model robots
│   ├── helpers/             # Test utilities
│   └── *_test.dart          # Test files by module
└── .maestro/                # Maestro E2E flows (YAML)
    └── flows/               # Individual flow files
```

### Testing Pyramid
| Level | Tool | Purpose | Speed |
|-------|------|---------|-------|
| E2E | Maestro | Full user journeys on simulator | Slow |
| Integration | Flutter Test | Screen behavior + navigation | Medium |
| Unit | Dart Test | Business logic, models, services | Fast |

---

## Test Types

### 1. Maestro E2E Tests
- Run on real iOS Simulator or Android Emulator
- Test complete user journeys across screens
- Validate visual state and UI interactions
- Located in `.maestro/flows/`

### 2. Flutter Integration Tests
- Run headless via `flutter test integration_test/`
- Test individual screens and their interactions
- Use Robot pattern (Page Object Model)
- Located in `integration_test/`

### 3. Unit Tests
- Test models, services, and business logic
- Located in `test/`

---

## Coverage Matrix

### Screens & Test Coverage

| Screen | Integration Test | Maestro Flow | Manual Test |
|--------|-----------------|--------------|-------------|
| **Auth Module** ||||
| SplashScreen | ✅ auth_test.dart | ✅ 01_splash_to_home | ✅ |
| LoginScreen | ✅ auth_test.dart | ✅ 01_splash_to_home | ✅ |
| **Home Module** ||||
| HomeScreen | ✅ home_test.dart | ✅ 02_home_navigation | ✅ |
| Trips Tab (Upcoming/Drafts/Past/Wishlist) | ✅ home_test.dart | ✅ 02_home_navigation | ✅ |
| **Trip Setup Module** ||||
| TripSetupScreen | ✅ trip_setup_test.dart | ✅ 03_create_trip | ✅ |
| RecommendedRoutesScreen | ✅ trip_setup_test.dart | ✅ 03_create_trip | ✅ |
| **Trip Module** ||||
| TripDashboardScreen | ✅ trip_dashboard_test.dart | ✅ 07_trip_detail | ✅ |
| SmartTicketsScreen | ✅ tickets_test.dart | ⬜ | ✅ |
| DayBuilderScreen | ✅ day_builder_test.dart | ✅ 07_trip_detail | ✅ |
| **Explore Module** ||||
| ExploreScreen | ✅ explore_test.dart | ✅ 04_explore_scan | ✅ |
| ExploreHistoryScreen | ✅ explore_history_test.dart | ⬜ | ✅ |
| DestinationDetailScreen | ⬜ | ⬜ | ✅ |
| CityDetailScreen | ⬜ | ⬜ | ✅ |
| ItineraryPreviewScreen | ✅ itinerary_test.dart | ✅ 08_itinerary_flow | ✅ |
| **Saved Module** ||||
| SavedScreen | ✅ saved_test.dart | ✅ 05_saved_items | ✅ |
| TiktokScanResultsScreen | ✅ saved_test.dart | ✅ 04_explore_scan | ✅ |
| SavedCityDetailScreen | ✅ saved_test.dart | ⬜ | ✅ |
| CustomizeItineraryScreen | ✅ saved_test.dart | ⬜ | ✅ |
| ReviewRouteScreen | ✅ saved_test.dart | ⬜ | ✅ |
| SavedDayBuilderScreen | ✅ saved_test.dart | ⬜ | ✅ |
| TripHubDraftsScreen | ✅ saved_test.dart | ⬜ | ✅ |
| **Profile Module** ||||
| ProfileScreen | ✅ profile_test.dart | ✅ 06_profile_settings | ✅ |
| MyTicketsScreen | ✅ tickets_test.dart | ✅ 06_profile_settings | ✅ |
| **Features Module** ||||
| AddItineraryScreen | ✅ itinerary_test.dart | ⬜ | ✅ |
| ItineraryDetailScreen | ✅ itinerary_test.dart | ⬜ | ✅ |
| ItineraryStackingScreen | ✅ itinerary_test.dart | ⬜ | ✅ |
| DayBuilderDetailScreen | ⬜ features_test.dart | ⬜ | ✅ |
| **Itinerary Module** ||||
| ItineraryBuilderScreen | ✅ itinerary_test.dart | ⬜ | ✅ |

### Critical User Journeys

| Journey | Covered By | Priority |
|---------|-----------|----------|
| New user → Skip auth → Home | 01_splash_to_home.yaml | P0 |
| Create new trip (multi-city) | 03_create_trip.yaml | P0 |
| Scan TikTok/Instagram URL | 04_explore_scan.yaml | P0 |
| Save places from scan | 05_saved_items.yaml | P0 |
| View trip dashboard | 07_trip_detail.yaml | P0 |
| Build daily itinerary | 07_trip_detail.yaml | P1 |
| Navigate bottom tabs | 02_home_navigation.yaml | P1 |
| View/manage wishlist | 09_wishlist.yaml | P2 |
| Demo mode (offline) | 10_offline_mode.yaml | P2 |

---

## Maestro E2E Flows

### Flow Files (`.maestro/flows/`)

| File | Description | Tags |
|------|-------------|------|
| `01_splash_to_home.yaml` | App launch → auth skip → home | smoke, critical |
| `02_home_navigation.yaml` | Bottom nav + trip tabs | smoke, regression |
| `03_create_trip.yaml` | Full trip creation wizard | critical, regression |
| `04_explore_scan.yaml` | URL scanning for places | critical, regression |
| `05_saved_items.yaml` | Saved places management | regression |
| `06_profile_settings.yaml` | Profile + settings access | smoke, regression |
| `07_trip_detail.yaml` | Trip dashboard + day builder | critical, regression |
| `08_itinerary_flow.yaml` | AI itinerary generation | critical, regression |
| `09_wishlist.yaml` | Wishlist add/manage | regression |
| `10_offline_mode.yaml` | Demo mode without network | regression |

### Running Maestro

```bash
# Install Maestro CLI
curl -Ls "https://get.maestro.mobile.dev" | bash

# Run single flow
maestro test .maestro/flows/01_splash_to_home.yaml

# Run all flows
maestro test .maestro/flows/

# Run by tag
maestro test .maestro/flows/ --include-tags=smoke
maestro test .maestro/flows/ --include-tags=critical
```

---

## Flutter Integration Tests

### Test Files (`integration_test/`)

| File | Module | Tests |
|------|--------|-------|
| `auth_test.dart` | Auth | Splash, Login screens |
| `home_test.dart` | Home | Home screen, tabs, navigation |
| `trip_setup_test.dart` | Trip Setup | Setup wizard, routes |
| `trip_dashboard_test.dart` | Trip | Dashboard, city blocks |
| `day_builder_test.dart` | Trip | Day timeline, activities |
| `explore_test.dart` | Explore | Search, destinations |
| `explore_history_test.dart` | Explore | Scan history |
| `saved_test.dart` | Saved | Places, itineraries, links |
| `profile_test.dart` | Profile | Profile screen, settings |
| `features_test.dart` | Features | Feature screens |
| `itinerary_test.dart` | Itinerary | Builder, preview, detail |
| `tickets_test.dart` | Tickets | Smart tickets, my tickets |
| `all_tests.dart` | All | Runs all test files |

### Robot Pattern

Each screen has a corresponding robot in `integration_test/robots/`:

```dart
// Example usage
final home = HomeRobot(tester);
await home.verifyScreenDisplayed();
await home.tapExploreTab();
await home.verifyTripCardDisplayed('Japan Adventure');
```

### Running Integration Tests

```bash
# Run all integration tests
flutter test integration_test/

# Run specific test file
flutter test integration_test/home_test.dart

# Run on specific device
flutter test integration_test/ -d <DEVICE_ID>

# Run with verbose output
flutter test integration_test/ --reporter expanded
```

---

## Manual Test Checklist

### Pre-Release Smoke Tests

#### Authentication
- [ ] App launches to splash screen
- [ ] "Continue without account" works
- [ ] Login with email works (if implemented)
- [ ] Social login works (if implemented)

#### Home Screen
- [ ] Bottom navigation works (all 4 tabs)
- [ ] Trip tabs work (Upcoming, Drafts, Past, Wishlist)
- [ ] Trip cards display correctly
- [ ] FAB opens trip setup
- [ ] Countdown badges show correct days

#### Trip Creation
- [ ] Can add single destination
- [ ] Can add multiple destinations
- [ ] Autocomplete suggestions appear
- [ ] Can select dates / flexible option
- [ ] Recommended routes display
- [ ] Can complete trip creation

#### Content Scanning
- [ ] Can paste TikTok URL
- [ ] Scanning animation plays
- [ ] Places are extracted correctly
- [ ] Can save places from results
- [ ] Error states display correctly
- [ ] Can try again on failure

#### Saved Items
- [ ] Places tab shows saved places
- [ ] Itineraries tab shows itineraries
- [ ] Links tab shows scanned links
- [ ] Swipe to delete works
- [ ] Can tap to view details

#### Trip Dashboard
- [ ] Trip info displays correctly
- [ ] City blocks show
- [ ] Can tap day to open day builder
- [ ] Can access smart tickets
- [ ] Map displays correctly

#### Day Builder
- [ ] Timeline displays
- [ ] Activities show in correct order
- [ ] Can add new activity
- [ ] Can reorder activities (drag)
- [ ] Can delete activities

#### Profile
- [ ] Profile info displays
- [ ] My Tickets accessible
- [ ] Settings accessible
- [ ] Free tier limits show (if applicable)

### Device-Specific Tests

#### iOS
- [ ] Safe area insets respected
- [ ] Gestures work (swipe back)
- [ ] Apple Maps loads correctly
- [ ] Keyboard dismisses properly

#### Android
- [ ] Back button works
- [ ] Status bar colors correct
- [ ] Material transitions smooth

### Edge Cases

- [ ] No network → Demo mode works
- [ ] Long destination names truncate
- [ ] Empty states display correctly
- [ ] Pull to refresh works
- [ ] Rotation doesn't crash (if supported)
- [ ] App backgrounding/foregrounding

---

## Running Tests

### Quick Reference

```bash
# Unit tests
flutter test

# Integration tests (all)
flutter test integration_test/

# Integration tests (specific)
flutter test integration_test/home_test.dart

# Maestro E2E (all)
maestro test .maestro/flows/

# Maestro E2E (smoke only)
maestro test .maestro/flows/ --include-tags=smoke

# Maestro E2E (single flow)
maestro test .maestro/flows/03_create_trip.yaml

# Format + analyze before testing
dart format . && dart analyze
```

### CI Pipeline (Suggested)

```yaml
# .github/workflows/test.yml
jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter test

  integration-tests:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter test integration_test/

  maestro-tests:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: mobile-dev-inc/action-maestro-cloud@v1
        with:
          api-key: ${{ secrets.MAESTRO_CLOUD_API_KEY }}
          app-file: build/ios/iphonesimulator/Runner.app
```

---

## Known Issues

### AnimationController.repeat() Issue
Screens with `AnimationController.repeat()` (like scan results pulse animation) cause `pumpAndSettle()` to hang indefinitely. 

**Workaround:** Use `pump(Duration)` instead:
```dart
await tester.pump();
await tester.pump(const Duration(seconds: 1));
```

### Mock Data Dependencies
Integration tests rely on mock data configured in `createHomeTestApp()`. If mock data changes, tests may fail.

### Maestro Element IDs
Some Maestro flows use element IDs (`id: "add_trip_fab"`) that must be added to widgets via `Key('add_trip_fab')` for reliable targeting.

---

## Test Maintenance

### Adding New Tests

1. Create robot in `integration_test/robots/<screen>_robot.dart`
2. Export in `integration_test/robots/robots.dart`
3. Create test file `integration_test/<module>_test.dart`
4. Add to `all_tests.dart` if needed
5. Create Maestro flow if it's a critical journey

### Updating Coverage

When adding new screens:
1. Update this document's coverage matrix
2. Add integration test
3. Add Maestro flow if critical path
4. Add to manual checklist if needed

---

*Last updated: January 2025*
