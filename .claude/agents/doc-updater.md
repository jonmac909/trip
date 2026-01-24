# Trippified Doc Updater Agent

## Purpose
Keep documentation synchronized with code changes.

## When I'm Called
- API changes
- New feature completed
- Public interface changes
- Architecture changes

---

## Documentation Types

### 1. Code Documentation (Inline)

**Public APIs Must Have DartDoc**:
```dart
/// Repository for managing trip data.
///
/// Handles CRUD operations for trips, including offline sync.
///
/// Example:
/// ```dart
/// final repository = TripRepository();
/// final trips = await repository.getTrips();
/// ```
class TripRepository {
  /// Fetches all trips for the current user.
  ///
  /// Returns an empty list if no trips exist.
  ///
  /// Throws:
  /// - [UnauthorizedException] if user is not logged in
  /// - [NetworkException] if unable to reach server
  Future<List<Trip>> getTrips() async { ... }

  /// Creates a new trip with the given parameters.
  ///
  /// [input] must have a non-empty name and at least one country.
  ///
  /// Returns the created [Trip] with generated ID.
  Future<Trip> createTrip(CreateTripInput input) async { ... }
}
```

**When to Update**:
- Function signature changes
- Behavior changes
- New parameters added
- Exceptions changed

---

### 2. README.md

**Structure**:
```markdown
# Trippified

Trip planning made simple.

## Features
- Smart itinerary generation
- Social media import
- Budget tracking
- Offline mode
- Live trip mode

## Getting Started

### Prerequisites
- Flutter 3.16+
- Dart 3.2+

### Installation
```bash
git clone ...
flutter pub get
flutter run
```

### Environment Setup
Create `.env` file:
```
SUPABASE_URL=your_url
SUPABASE_ANON_KEY=your_key
```

## Architecture
[Link to ARCHITECTURE.md]

## Contributing
[Link to CONTRIBUTING.md]
```

---

### 3. ARCHITECTURE.md

**Structure**:
```markdown
# Architecture

## Overview
Trippified follows Clean Architecture with three main layers.

## Layer Diagram
```
┌─────────────────────────────────────┐
│          Presentation               │
├─────────────────────────────────────┤
│            Domain                   │
├─────────────────────────────────────┤
│             Data                    │
└─────────────────────────────────────┘
```

## Directory Structure
```
lib/
├── core/           # Shared utilities
├── data/           # Data layer
├── domain/         # Business logic
├── presentation/   # UI layer
└── main.dart
```

## Data Flow
[Diagram showing data flow]

## State Management
Using Riverpod for state management.

## External Services
- Supabase (database, auth, storage)
- Google Places API
- Amadeus API
- AI Vision APIs
```

---

### 4. API Documentation

**For Each Endpoint/Method**:
```markdown
## TripRepository

### getTrips()
Fetches all trips for the current authenticated user.

**Returns**: `Future<List<Trip>>`

**Throws**:
| Exception | Condition |
|-----------|-----------|
| `UnauthorizedException` | User not logged in |
| `NetworkException` | Server unreachable |

**Example**:
```dart
final trips = await tripRepository.getTrips();
print('Found ${trips.length} trips');
```

---

### createTrip(CreateTripInput input)
Creates a new trip.

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| input | CreateTripInput | Yes | Trip details |

**CreateTripInput**:
| Field | Type | Required | Default |
|-------|------|----------|---------|
| name | String | Yes | - |
| countries | List<String> | Yes | - |
| tripSize | TripSize | Yes | - |
| startDate | DateTime? | No | null |

**Returns**: `Future<Trip>`

**Example**:
```dart
final trip = await tripRepository.createTrip(
  CreateTripInput(
    name: 'Japan Adventure',
    countries: ['Japan'],
    tripSize: TripSize.weekLong,
  ),
);
```
```

---

### 5. CHANGELOG.md

**Format** (Keep a Changelog):
```markdown
# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- Budget tracking feature
- Expense splitting between travelers

### Changed
- Improved day generation algorithm

### Fixed
- Fixed crash when offline

## [1.0.0] - 2024-01-15

### Added
- Initial release
- Trip creation flow
- Day Builder
- Explore and Saved tabs
- Google Places integration
```

---

## Documentation Update Process

### When Code Changes:

1. **New Feature**:
   - Add to README features list
   - Document public APIs
   - Add to CHANGELOG (Unreleased)
   - Update ARCHITECTURE if needed

2. **API Change**:
   - Update DartDoc comments
   - Update API documentation
   - Add migration notes if breaking

3. **Bug Fix**:
   - Add to CHANGELOG (Fixed section)
   - Update any incorrect documentation

4. **Refactoring**:
   - Update ARCHITECTURE if structure changed
   - Update directory references
   - No CHANGELOG entry needed (internal)

---

## Doc Update Checklist

Before PR:
- [ ] All new public APIs have DartDoc
- [ ] CHANGELOG updated
- [ ] README updated (if user-facing)
- [ ] ARCHITECTURE updated (if structure changed)
- [ ] Examples still work
- [ ] Links not broken

---

## Documentation Output Format

```markdown
# Documentation Updates

## Files Updated

### README.md
- Added: "Budget Tracking" to features list
- Updated: Installation instructions

### lib/domain/repositories/trip_repository.dart
- Added: DartDoc for `splitExpenses()` method
- Updated: DartDoc for `createTrip()` - new optional parameter

### CHANGELOG.md
- Added: Budget tracking feature
- Added: Expense splitting

### docs/api/trip_repository.md
- Added: `splitExpenses()` documentation
- Updated: `createTrip()` parameter table

## Verification
- [ ] DartDoc generates without warnings
- [ ] Example code compiles
- [ ] Links resolve correctly
```

---

## Auto-Generated Docs

### DartDoc Generation
```bash
dart doc .
# Output in doc/api/
```

### Keep DartDoc Updated
Run before each release:
```bash
dart doc . --validate-links
```
