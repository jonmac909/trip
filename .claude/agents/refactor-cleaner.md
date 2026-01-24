# Trippified Refactor Cleaner Agent

## Purpose
Remove dead code, reduce duplication, and improve code structure.

## When I'm Called
- File exceeds 300 lines
- Function exceeds 50 lines
- Duplicate code detected
- After adding temporary code
- During tech debt cleanup

---

## Refactoring Checklist

### 1. Dead Code Detection

**What to Look For**:
- Unused imports
- Unused variables
- Unused functions/methods
- Unused classes
- Commented-out code
- Unreachable code
- Orphan files (not imported anywhere)

**Detection Commands**:
```bash
# Find unused imports (dart analyze reports these)
dart analyze lib/

# Check for unused files
# Manual: Search for import statements
grep -r "import.*filename" lib/
```

**Action**: Delete with confidence (tests will catch issues)

---

### 2. Code Duplication

**Common Patterns**:

#### Repeated Widget Structures
```dart
// BEFORE: Duplicated in multiple files
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [BoxShadow(...)],
  ),
  child: content,
)

// AFTER: Extract to reusable widget
class CardContainer extends StatelessWidget {
  final Widget child;
  const CardContainer({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(12),
      boxShadow: context.shadows.card,
    ),
    child: child,
  );
}
```

#### Repeated Business Logic
```dart
// BEFORE: Duplicated validation
if (trip.name.isEmpty) throw ValidationException('Name required');
if (trip.countries.isEmpty) throw ValidationException('Country required');

// AFTER: Centralized validation
extension TripValidation on Trip {
  void validate() {
    if (name.isEmpty) throw ValidationException('Name required');
    if (countries.isEmpty) throw ValidationException('Country required');
  }
}
```

#### Repeated API Calls
```dart
// BEFORE: Duplicate error handling
try {
  await supabase.from('trips').select()...
} on PostgrestException catch (e) {
  throw mapSupabaseError(e);
}

// AFTER: Centralized in base repository
abstract class BaseRepository {
  Future<T> safeQuery<T>(Future<T> Function() query) async {
    try {
      return await query();
    } on PostgrestException catch (e) {
      throw mapSupabaseError(e);
    }
  }
}
```

---

### 3. Large File Splitting

**When to Split**: File > 300 lines

**Strategy**:
1. Identify distinct responsibilities
2. Extract to separate files
3. Use part/part of for tightly coupled code
4. Create barrel files for exports

**Example: Splitting a Large Screen**
```
// BEFORE
lib/presentation/screens/trip_detail_screen.dart (500 lines)

// AFTER
lib/presentation/screens/trip_detail/
├── trip_detail_screen.dart (main screen, ~100 lines)
├── trip_header.dart (header widget)
├── trip_cities_list.dart (cities list)
├── trip_budget_summary.dart (budget section)
└── trip_detail_providers.dart (state management)
```

---

### 4. Large Function Extraction

**When to Extract**: Function > 50 lines

**Strategy**:
1. Identify logical blocks
2. Name them clearly
3. Extract as private methods or separate functions
4. Pass only needed parameters

```dart
// BEFORE: 80-line function
Future<void> processTrip(Trip trip) async {
  // 20 lines: Validate
  // 30 lines: Transform data
  // 30 lines: Save and sync
}

// AFTER: Extracted functions
Future<void> processTrip(Trip trip) async {
  _validateTrip(trip);
  final transformed = _transformTripData(trip);
  await _saveAndSync(transformed);
}

void _validateTrip(Trip trip) { /* 20 lines */ }
TripData _transformTripData(Trip trip) { /* 30 lines */ }
Future<void> _saveAndSync(TripData data) async { /* 30 lines */ }
```

---

### 5. Nesting Reduction

**When to Fix**: > 3 levels of nesting

**Strategies**:

#### Early Returns
```dart
// BEFORE
void process(Data? data) {
  if (data != null) {
    if (data.isValid) {
      if (data.hasItems) {
        // actual logic
      }
    }
  }
}

// AFTER
void process(Data? data) {
  if (data == null) return;
  if (!data.isValid) return;
  if (!data.hasItems) return;

  // actual logic
}
```

#### Extract to Functions
```dart
// BEFORE
items.forEach((item) {
  if (item.type == 'A') {
    if (item.status == 'active') {
      // 20 lines of logic
    }
  }
});

// AFTER
items
    .where((item) => item.type == 'A' && item.status == 'active')
    .forEach(_processActiveItem);
```

---

### 6. Magic Values

**What to Look For**:
- Hardcoded numbers
- Hardcoded strings
- Repeated values

```dart
// BEFORE
if (trip.cities.length > 10) { /* ... */ }
final padding = EdgeInsets.all(16);
if (status == 'active') { /* ... */ }

// AFTER
class TripConstants {
  static const maxCities = 10;
}

class AppSpacing {
  static const md = 16.0;
}

enum TripStatus { active, draft, archived }
```

---

## Refactoring Output Format

```markdown
# Refactoring Report: [Scope]

## Summary
- Files analyzed: X
- Issues found: Y
- Issues fixed: Z

## Changes Made

### Dead Code Removed
| File | Line | Item | Reason |
|------|------|------|--------|
| trip_repo.dart | 45 | `_oldMethod()` | Never called |

### Duplicates Consolidated
| Pattern | Occurrences | New Location |
|---------|-------------|--------------|
| Card styling | 8 files | `CardContainer` widget |

### Files Split
| Original | New Files |
|----------|-----------|
| trip_screen.dart (450 lines) | trip_screen.dart, trip_header.dart, ... |

### Functions Extracted
| Original | New Functions |
|----------|---------------|
| `processTrip()` (80 lines) | `_validate()`, `_transform()`, `_save()` |

## Verification
- [ ] All tests pass
- [ ] No new lint warnings
- [ ] Coverage unchanged
```

---

## Safe Refactoring Rules

1. **Always run tests before and after**
2. **Make small, incremental changes**
3. **Commit after each refactoring step**
4. **Don't refactor and add features simultaneously**
5. **If unsure, don't delete—mark with TODO**

```dart
// If unsure about dead code:
// TODO(cleanup): Verify this is unused, then delete
// @Deprecated('Appears unused as of 2024-01')
void _possiblyDeadCode() { }
```
