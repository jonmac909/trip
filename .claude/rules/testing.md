# Trippified Testing Rules

## MANDATORY - All Code Must Have Tests

### 1. Coverage Requirements

**Minimum Coverage: 80%**

**Critical Paths (100% Required)**
- Authentication flows
- Trip CRUD operations
- Booking/affiliate link generation
- Budget calculations
- Document upload/retrieval
- Expense splitting logic

### 2. Test-Driven Development (TDD)

**Write Tests First**
1. Write failing test
2. Write minimum code to pass
3. Refactor
4. Repeat

```dart
// Step 1: Write the test FIRST
test('should calculate total expenses for a trip', () {
  final expenses = [
    Expense(amount: 100, currency: 'USD'),
    Expense(amount: 50, currency: 'USD'),
  ];

  final total = calculateTotalExpenses(expenses);

  expect(total, equals(150.0));
});

// Step 2: Then implement
double calculateTotalExpenses(List<Expense> expenses) {
  return expenses.fold(0.0, (sum, e) => sum + e.amount);
}
```

### 3. Test File Organization

```
test/
├── unit/                    # Unit tests
│   ├── domain/
│   │   └── usecases/
│   │       └── create_trip_test.dart
│   └── data/
│       └── repositories/
│           └── trip_repository_test.dart
├── widget/                  # Widget tests
│   └── presentation/
│       └── screens/
│           └── trip_setup_screen_test.dart
├── integration/             # Integration tests
│   └── flows/
│       └── trip_creation_flow_test.dart
└── fixtures/                # Test data
    └── trip_fixtures.dart
```

### 4. Naming Conventions

**Test Files**: `{file_name}_test.dart`

**Test Groups**: Describe the unit under test
```dart
void main() {
  group('TripRepository', () {
    group('getTrips', () {
      test('should return empty list when no trips exist', () {});
      test('should return trips for current user only', () {});
      test('should throw UnauthorizedException when not logged in', () {});
    });

    group('createTrip', () {
      test('should create trip with valid input', () {});
      test('should throw ValidationException for empty name', () {});
    });
  });
}
```

**Test Names**: `should {expected behavior} when {condition}`

### 5. Unit Tests

**Test Business Logic in Isolation**
```dart
// test/unit/domain/usecases/calculate_route_test.dart
void main() {
  late CalculateRouteUseCase useCase;
  late MockPlacesRepository mockPlacesRepo;

  setUp(() {
    mockPlacesRepo = MockPlacesRepository();
    useCase = CalculateRouteUseCase(mockPlacesRepo);
  });

  test('should order activities by proximity', () async {
    // Arrange
    final activities = [
      Activity(id: '1', coordinates: LatLng(35.6762, 139.6503)),
      Activity(id: '2', coordinates: LatLng(35.6586, 139.7454)),
      Activity(id: '3', coordinates: LatLng(35.6764, 139.6500)),
    ];

    // Act
    final ordered = await useCase.orderByProximity(activities);

    // Assert
    expect(ordered[0].id, equals('1'));
    expect(ordered[1].id, equals('3')); // Closest to 1
    expect(ordered[2].id, equals('2'));
  });
}
```

### 6. Widget Tests

**Test UI Behavior**
```dart
// test/widget/presentation/screens/trip_setup_screen_test.dart
void main() {
  group('TripSetupScreen', () {
    testWidgets('should enable CTA when country and size selected',
        (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: TripSetupScreen()),
        ),
      );

      // Act - Select country
      await tester.enterText(
        find.byKey(Key('country_input')),
        'Japan',
      );
      await tester.tap(find.text('Japan'));
      await tester.pump();

      // Act - Select trip size
      await tester.tap(find.text('Week-long'));
      await tester.pump();

      // Assert
      final cta = find.byKey(Key('see_routes_cta'));
      expect(tester.widget<ElevatedButton>(cta).enabled, isTrue);
    });

    testWidgets('should disable CTA when no country selected',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: TripSetupScreen()),
        ),
      );

      final cta = find.byKey(Key('see_routes_cta'));
      expect(tester.widget<ElevatedButton>(cta).enabled, isFalse);
    });
  });
}
```

### 7. Integration Tests

**Test Critical User Flows**
```dart
// test/integration/flows/trip_creation_flow_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Trip Creation Flow', () {
    testWidgets('should create trip from setup to day builder',
        (tester) async {
      // Setup
      await tester.pumpWidget(TrippifiedApp());
      await tester.pumpAndSettle();

      // Navigate to trip creation
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Fill trip setup
      await tester.enterText(find.byKey(Key('country_input')), 'Japan');
      await tester.tap(find.text('Japan'));
      await tester.tap(find.text('Week-long'));
      await tester.tap(find.text('See recommended routes'));
      await tester.pumpAndSettle();

      // Select route
      await tester.tap(find.text('Tokyo → Kyoto'));
      await tester.tap(find.text('Create itinerary'));
      await tester.pumpAndSettle();

      // Verify on itinerary blocks screen
      expect(find.text('Tokyo'), findsOneWidget);
      expect(find.text('Kyoto'), findsOneWidget);

      // Enter day builder
      await tester.tap(find.text('Tokyo'));
      await tester.pumpAndSettle();

      // Verify day builder
      expect(find.text('Day 1 — Free day'), findsOneWidget);
    });
  });
}
```

### 8. Mocking

**Use Mocktail for Mocks**
```dart
import 'package:mocktail/mocktail.dart';

class MockTripRepository extends Mock implements TripRepository {}
class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockTripRepository mockRepo;

  setUp(() {
    mockRepo = MockTripRepository();
  });

  test('should handle repository error', () async {
    // Arrange
    when(() => mockRepo.getTrips())
        .thenThrow(TrippifiedException('Network error'));

    // Act & Assert
    expect(
      () => useCase.execute(),
      throwsA(isA<TrippifiedException>()),
    );
  });
}
```

### 9. Test Fixtures

**Create Reusable Test Data**
```dart
// test/fixtures/trip_fixtures.dart
class TripFixtures {
  static Trip singleCountryTrip() => Trip(
    id: 'test-trip-1',
    name: 'Japan Adventure',
    countries: ['Japan'],
    tripSize: TripSize.weekLong,
    cities: [
      CityBlock(city: 'Tokyo', dayCount: 4),
      CityBlock(city: 'Kyoto', dayCount: 3),
    ],
  );

  static Trip multiCountryTrip() => Trip(
    id: 'test-trip-2',
    name: 'Asia Tour',
    countries: ['Japan', 'Thailand'],
    tripSize: TripSize.long,
    cities: [
      CityBlock(city: 'Tokyo', dayCount: 4),
      CityBlock(city: 'Bangkok', dayCount: 3),
    ],
  );

  static List<Expense> sampleExpenses() => [
    Expense(amount: 50, category: ExpenseCategory.food),
    Expense(amount: 100, category: ExpenseCategory.transport),
    Expense(amount: 200, category: ExpenseCategory.accommodation),
  ];
}
```

### 10. Test Commands

**Run All Tests**
```bash
flutter test
```

**Run with Coverage**
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

**Run Specific Test**
```bash
flutter test test/unit/domain/usecases/create_trip_test.dart
```

**Run Integration Tests**
```bash
flutter test integration_test/
```

### 11. Pre-Commit Test Hook

Tests must pass before committing:
```bash
# .githooks/pre-commit
#!/bin/bash
flutter test || exit 1
```

### 12. Edge Cases to Test

**Always Test**
- Empty inputs
- Null values (where nullable)
- Boundary conditions (max trips, max days)
- Network failures
- Auth expiration
- Invalid data from API
- Offline mode behavior
- Concurrent modifications
