# Trippified Coding Style Rules

## MANDATORY - All Code Must Follow These Standards

### 1. File Organization

**Directory Structure (Clean Architecture)**
```
lib/
├── core/                    # Shared utilities
│   ├── constants/          # App constants, API endpoints
│   ├── errors/             # Exception classes
│   ├── theme/              # Colors, typography, spacing
│   ├── utils/              # Helper functions
│   └── widgets/            # Reusable widgets
├── data/                    # Data layer
│   ├── datasources/        # Remote & local data sources
│   ├── models/             # Data transfer objects
│   └── repositories/       # Repository implementations
├── domain/                  # Business logic
│   ├── entities/           # Core business objects
│   ├── repositories/       # Repository interfaces
│   └── usecases/           # Business logic operations
├── presentation/            # UI layer
│   ├── screens/            # Screen widgets
│   ├── widgets/            # Screen-specific widgets
│   ├── providers/          # State management
│   └── navigation/         # Routes and navigation
└── main.dart               # Entry point
```

### 2. File Size Limits

**HARD LIMITS**
- **Max 300 lines per file** - Split if larger
- **Max 50 lines per function** - Extract if larger
- **Max 3 levels of nesting** - Refactor if deeper

```dart
// FORBIDDEN - Too much nesting
if (condition1) {
  if (condition2) {
    if (condition3) {
      if (condition4) { // TOO DEEP
        // ...
      }
    }
  }
}

// REQUIRED - Early returns
if (!condition1) return;
if (!condition2) return;
if (!condition3) return;
// proceed with logic
```

### 3. Naming Conventions

**Files**
- `snake_case.dart` for all files
- Name matches primary class: `trip_repository.dart` → `TripRepository`

**Classes**
```dart
// PascalCase for classes
class TripRepository {}
class UserPreferences {}
class DayBuilder {}
```

**Variables and Functions**
```dart
// camelCase for variables and functions
final tripName = 'Japan Trip';
void loadTrips() {}
bool isAuthenticated() {}
```

**Constants**
```dart
// camelCase for constants (Dart convention)
const maxTripDays = 30;
const defaultCurrency = 'USD';

// Group in classes for organization
class AppConstants {
  static const maxTripDays = 30;
  static const maxSavedItems = 50;
  static const freeTripsLimit = 2;
}
```

**Private Members**
```dart
// Prefix with underscore
class TripService {
  final _cache = <String, Trip>{};

  void _validateTrip(Trip trip) {}
}
```

### 4. Immutability

**Prefer Immutable Data**
```dart
// REQUIRED: Use final for all local variables
final trips = await repository.getTrips();
final user = auth.currentUser;

// REQUIRED: Use const for compile-time constants
const padding = EdgeInsets.all(16);
const duration = Duration(milliseconds: 300);

// REQUIRED: Immutable models with copyWith
@freezed
class Trip with _$Trip {
  const factory Trip({
    required String id,
    required String name,
    required List<String> countries,
  }) = _Trip;
}
```

### 5. Type Safety

**No Dynamic Types**
```dart
// FORBIDDEN
dynamic data = await fetchData(); // NEVER
var items = []; // Avoid untyped

// REQUIRED
final Trip trip = await fetchTrip();
final List<Activity> items = [];
```

**Null Safety**
```dart
// REQUIRED: Handle nulls explicitly
String? getUserName() => _user?.name;

// Use null-aware operators
final name = user?.name ?? 'Guest';

// Required parameters for non-null
void createTrip({required String name, required List<String> countries}) {}
```

### 6. Documentation

**Public API Documentation**
```dart
/// Repository for managing trip data.
///
/// Handles CRUD operations for trips, including sync with Supabase.
class TripRepository {
  /// Fetches all trips for the current user.
  ///
  /// Returns empty list if no trips exist.
  /// Throws [UnauthorizedException] if user not logged in.
  Future<List<Trip>> getTrips() async {}
}
```

**No Obvious Comments**
```dart
// FORBIDDEN - Obvious comments
int count = 0; // Initialize count to zero

// REQUIRED - Explain WHY, not WHAT
// Cache for 5 minutes to reduce API costs
final cacheExpiry = Duration(minutes: 5);
```

### 7. Error Handling

**Custom Exceptions**
```dart
// Define in core/errors/
class TrippifiedException implements Exception {
  final String message;
  final String? code;
  TrippifiedException(this.message, {this.code});
}

class UnauthorizedException extends TrippifiedException {
  UnauthorizedException([String message = 'Not authenticated'])
      : super(message, code: 'UNAUTHORIZED');
}

class ValidationException extends TrippifiedException {
  ValidationException(String message)
      : super(message, code: 'VALIDATION_ERROR');
}
```

**Always Handle Async Errors**
```dart
// REQUIRED: Try-catch on all async operations
Future<void> loadTrips() async {
  try {
    final trips = await repository.getTrips();
    state = TripsLoaded(trips);
  } on UnauthorizedException {
    state = TripsError('Please log in to view trips');
  } on TrippifiedException catch (e) {
    state = TripsError(e.message);
  } catch (e) {
    state = TripsError('An unexpected error occurred');
    // Log the actual error for debugging
    logger.error('Failed to load trips', error: e);
  }
}
```

### 8. Widget Guidelines

**Stateless When Possible**
```dart
// Prefer StatelessWidget
class TripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback onTap;

  const TripCard({required this.trip, required this.onTap});

  @override
  Widget build(BuildContext context) => // ...
}
```

**Extract Large Builds**
```dart
// FORBIDDEN - Giant build method
@override
Widget build(BuildContext context) {
  return Scaffold(
    // 200 lines of nested widgets...
  );
}

// REQUIRED - Extract to methods or widgets
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: _buildAppBar(),
    body: TripListView(trips: trips),
    bottomNavigationBar: _buildBottomNav(),
  );
}
```

### 9. Import Organization

```dart
// Order: Dart, Flutter, packages, relative
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/trip.dart';
import 'trip_card.dart';
```

### 10. Code Formatting

**Run Before Every Commit**
```bash
dart format .
dart analyze
```

**Line Length: 80 characters** (Dart default)

**Trailing Commas** - Always use for multi-line
```dart
// REQUIRED: Trailing commas
const Trip(
  id: '123',
  name: 'Japan Trip',
  countries: ['Japan'],
);
```
