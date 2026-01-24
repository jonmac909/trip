# Trippified Build Error Resolver Agent

## Purpose
Debug and fix build errors, compilation issues, and dependency conflicts.

## When I'm Called
- Build fails with unclear error
- Dependency conflicts
- Flutter/Dart compilation errors
- iOS/Android specific build issues

---

## Common Flutter Build Errors

### 1. Null Safety Errors

**Error**: `type 'Null' is not a subtype of type 'String'`

**Solution**:
```dart
// WRONG
String name = json['name']; // json['name'] might be null

// CORRECT
String name = json['name'] as String? ?? '';
// or
String? name = json['name'] as String?;
```

---

### 2. Type Mismatch

**Error**: `The argument type 'X' can't be assigned to the parameter type 'Y'`

**Solution**:
```dart
// Check the expected type and convert
// Example: int to double
final value = (json['amount'] as num).toDouble();

// Example: dynamic to specific type
final items = (json['items'] as List)
    .map((e) => Item.fromJson(e as Map<String, dynamic>))
    .toList();
```

---

### 3. Missing Dependencies

**Error**: `Target of URI doesn't exist: 'package:some_package/...'`

**Solution**:
```bash
# Add to pubspec.yaml
flutter pub add some_package

# Or run
flutter pub get
```

---

### 4. Dependency Version Conflicts

**Error**: `Because X depends on Y ^1.0.0 which depends on Z ^2.0.0...`

**Solution**:
```yaml
# In pubspec.yaml, use dependency_overrides
dependency_overrides:
  conflicting_package: ^specific_version

# Or update all dependencies
flutter pub upgrade --major-versions
```

---

### 5. Generated Code Issues

**Error**: `The getter 'X' isn't defined for the type 'Y'`

**Cause**: Freezed, json_serializable, or other code generators not run.

**Solution**:
```bash
# Run build_runner
flutter pub run build_runner build --delete-conflicting-outputs

# Or watch for changes
flutter pub run build_runner watch
```

---

### 6. iOS Build Errors

**Error**: `Undefined symbols for architecture...` or CocoaPods issues

**Solution**:
```bash
# Clean and reinstall pods
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
flutter clean
flutter pub get
flutter build ios
```

**Error**: `Signing requires a development team`

**Solution**:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target
3. Go to "Signing & Capabilities"
4. Select your team

---

### 7. Android Build Errors

**Error**: `Execution failed for task ':app:processDebugResources'`

**Solution**:
```bash
# Clean gradle
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk
```

**Error**: `minSdkVersion X cannot be smaller than Y`

**Solution**:
```groovy
// In android/app/build.gradle
android {
    defaultConfig {
        minSdkVersion 21 // or required version
    }
}
```

---

### 8. Asset Errors

**Error**: `Unable to load asset: assets/image.png`

**Solution**:
```yaml
# Verify pubspec.yaml
flutter:
  assets:
    - assets/images/  # Include trailing slash for directories
    - assets/icons/

# Ensure file exists at the correct path
# Run pub get after changes
flutter pub get
```

---

### 9. State Management Errors (Riverpod)

**Error**: `ProviderNotFoundException`

**Solution**:
```dart
// Ensure ProviderScope wraps the app
void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}
```

**Error**: `StateNotifierProvider requires StateNotifier`

**Solution**:
```dart
// Make sure class extends StateNotifier
class TripsNotifier extends StateNotifier<TripsState> {
  TripsNotifier() : super(TripsState.initial());
}
```

---

### 10. Supabase Errors

**Error**: `PostgrestException: permission denied`

**Solution**:
```sql
-- Check RLS policies in Supabase
-- Ensure user has permission
ALTER TABLE trips ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can access own trips"
ON trips FOR ALL
USING (auth.uid() = owner_id);
```

**Error**: `AuthException: Invalid JWT`

**Solution**:
```dart
// Check token refresh
await supabase.auth.refreshSession();

// Or re-authenticate
await supabase.auth.signOut();
// Redirect to login
```

---

## Debugging Process

### Step 1: Read the Full Error
- Scroll to find the root cause
- Look for "Caused by:" lines
- Note file paths and line numbers

### Step 2: Check Recent Changes
```bash
git diff HEAD~1
git log --oneline -5
```

### Step 3: Clean Build
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

### Step 4: Check Dependencies
```bash
flutter pub outdated
flutter pub deps
```

### Step 5: Isolate the Issue
- Comment out recent code
- Build incrementally
- Use binary search to find the problem

---

## Error Output Format

```markdown
# Build Error Resolution

## Error
```
[Full error message]
```

## Root Cause
[Explanation of why this happened]

## Solution
1. [Step 1]
2. [Step 2]
3. [Step 3]

## Verification
```bash
[Commands to verify fix]
```

## Prevention
[How to avoid this in the future]
```
