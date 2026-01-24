# Trippified TDD Guide Agent

## Purpose
Guide test-driven development by writing tests before implementation.

## When I'm Called
- Before implementing any new feature
- When adding business logic
- When creating new screens/widgets

## TDD Workflow

### 1. Red Phase (Write Failing Test)
```dart
// Write the test FIRST
test('should calculate total expenses in default currency', () {
  // Arrange
  final expenses = [
    Expense(amount: 100, currency: 'USD'),
    Expense(amount: 50, currency: 'EUR'), // Will be converted
  ];
  final calculator = ExpenseCalculator(exchangeRate: {'EUR': 1.1});

  // Act
  final total = calculator.calculateTotal(expenses, 'USD');

  // Assert
  expect(total, equals(155.0)); // 100 + (50 * 1.1)
});
```

### 2. Green Phase (Minimal Implementation)
```dart
// Write JUST ENOUGH code to pass
class ExpenseCalculator {
  final Map<String, double> exchangeRate;

  ExpenseCalculator({required this.exchangeRate});

  double calculateTotal(List<Expense> expenses, String currency) {
    return expenses.fold(0.0, (sum, e) {
      if (e.currency == currency) return sum + e.amount;
      return sum + (e.amount * (exchangeRate[e.currency] ?? 1.0));
    });
  }
}
```

### 3. Refactor Phase
- Clean up code
- Ensure tests still pass
- No new functionality

---

## Test Templates

### Unit Test Template
```dart
void main() {
  group('ClassName', () {
    late ClassName sut; // System Under Test
    late MockDependency mockDep;

    setUp(() {
      mockDep = MockDependency();
      sut = ClassName(mockDep);
    });

    group('methodName', () {
      test('should [expected behavior] when [condition]', () {
        // Arrange
        when(() => mockDep.something()).thenReturn(value);

        // Act
        final result = sut.methodName();

        // Assert
        expect(result, equals(expectedValue));
        verify(() => mockDep.something()).called(1);
      });

      test('should throw [Exception] when [error condition]', () {
        // Arrange
        when(() => mockDep.something()).thenThrow(Exception());

        // Act & Assert
        expect(() => sut.methodName(), throwsA(isA<SpecificException>()));
      });
    });
  });
}
```

### Widget Test Template
```dart
void main() {
  group('WidgetName', () {
    testWidgets('should render [element] when [condition]', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: WidgetName(param: value),
        ),
      );

      // Assert
      expect(find.text('Expected Text'), findsOneWidget);
    });

    testWidgets('should call [callback] when [interaction]', (tester) async {
      // Arrange
      var called = false;
      await tester.pumpWidget(
        MaterialApp(
          home: WidgetName(onTap: () => called = true),
        ),
      );

      // Act
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(called, isTrue);
    });
  });
}
```

### Repository Test Template
```dart
void main() {
  group('TripRepository', () {
    late TripRepository sut;
    late MockSupabaseClient mockSupabase;

    setUp(() {
      mockSupabase = MockSupabaseClient();
      sut = TripRepositoryImpl(mockSupabase);
    });

    group('getTrips', () {
      test('should return list of trips for current user', () async {
        // Arrange
        when(() => mockSupabase.from('trips').select().eq('owner_id', any()))
            .thenAnswer((_) async => [tripJson1, tripJson2]);

        // Act
        final trips = await sut.getTrips();

        // Assert
        expect(trips.length, equals(2));
        expect(trips[0].name, equals('Japan Trip'));
      });

      test('should return empty list when no trips exist', () async {
        // Arrange
        when(() => mockSupabase.from('trips').select().eq('owner_id', any()))
            .thenAnswer((_) async => []);

        // Act
        final trips = await sut.getTrips();

        // Assert
        expect(trips, isEmpty);
      });

      test('should throw UnauthorizedException when not logged in', () async {
        // Arrange
        when(() => mockSupabase.auth.currentUser).thenReturn(null);

        // Act & Assert
        expect(
          () => sut.getTrips(),
          throwsA(isA<UnauthorizedException>()),
        );
      });
    });
  });
}
```

---

## Test Cases by Feature

### Trip Setup
```dart
// Test cases to write BEFORE implementing
group('TripSetupScreen', () {
  // Input validation
  test('should disable CTA when no country selected');
  test('should disable CTA when no trip size selected');
  test('should enable CTA when country and size selected');

  // Country selection
  test('should add country when selected from autocomplete');
  test('should remove country when chip X tapped');
  test('should allow multiple countries');

  // Trip size
  test('should select only one trip size at a time');
  test('should highlight selected trip size');

  // Navigation
  test('should navigate to routes screen when CTA tapped');
  test('should pass selected data to routes screen');
});
```

### Day Builder
```dart
group('DayBuilder', () {
  // Overview tab
  test('should show free days initially');
  test('should generate day when Generate tapped');
  test('should show anchor label after generation');
  test('should show alternatives count');

  // Generation
  test('should select best anchor for city');
  test('should order activities by proximity');
  test('should include 4-5 activities');
  test('should warn if activity is far');

  // Edit
  test('should switch to itinerary tab when Edit tapped');
  test('should allow reordering activities');
  test('should allow removing activities');
  test('should update label when anchor changes');
});
```

### Budget Tracking
```dart
group('BudgetTracking', () {
  // Expense entry
  test('should create expense with required fields');
  test('should validate positive amount');
  test('should default to trip currency');

  // Calculations
  test('should sum expenses in same currency');
  test('should convert expenses to default currency');
  test('should calculate by category');
  test('should calculate by city');

  // Splitting
  test('should divide equally among selected users');
  test('should track who paid');
  test('should show balances');

  // Budget warnings
  test('should warn at 80% of budget');
  test('should warn when over budget');
});
```

---

## Test Quality Checklist

Before submitting tests:

- [ ] Tests are independent (no shared state)
- [ ] Tests are deterministic (same result every time)
- [ ] Tests are fast (<100ms each)
- [ ] Tests have clear names (should...when...)
- [ ] Tests cover happy path
- [ ] Tests cover error cases
- [ ] Tests cover edge cases
- [ ] Mocks are properly configured
- [ ] No flaky assertions (timing, etc.)
- [ ] Coverage target met (80%+)
