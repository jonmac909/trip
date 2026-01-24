# Trippified Performance Rules

## Model Selection Guidelines

### When to Use Haiku (Fast, Low Cost)
- Simple code formatting
- Basic refactoring
- Generating boilerplate
- Quick lookups
- Simple bug fixes

### When to Use Sonnet (Balanced)
- Standard feature implementation
- Writing tests
- Code review
- Documentation
- Most day-to-day tasks

### When to Use Opus (Complex Tasks)
- Architectural decisions
- Complex debugging
- Security audits
- Performance optimization
- Multi-file refactoring

---

## App Performance Requirements

### 1. Startup Time

**Target: < 2 seconds to interactive**

**Strategies**
- Lazy load non-essential features
- Defer analytics initialization
- Cache critical data locally
- Use splash screen effectively

```dart
// DO: Lazy load
final exploreProvider = FutureProvider((ref) async {
  // Only loads when Explore tab is accessed
  return ref.watch(exploreRepositoryProvider).getDestinations();
});

// DON'T: Load everything at startup
void main() {
  loadAllTrips(); // Don't do this
  loadAllSavedItems(); // Don't do this
  runApp(App());
}
```

### 2. Frame Rate

**Target: 60 FPS (16ms per frame)**

**Strategies**
- Avoid expensive operations in build()
- Use const constructors
- Implement shouldRebuild properly
- Use RepaintBoundary for complex widgets

```dart
// DO: Const constructors
class TripCard extends StatelessWidget {
  const TripCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return const Padding( // const
      padding: EdgeInsets.all(16), // const
      child: // ...
    );
  }
}

// DO: RepaintBoundary for heavy widgets
RepaintBoundary(
  child: MapView(trip: trip), // Heavy widget isolated
)
```

### 3. Memory Usage

**Target: < 150MB baseline**

**Strategies**
- Dispose controllers and subscriptions
- Use image caching with limits
- Clear old cached data
- Avoid memory leaks in streams

```dart
// DO: Proper disposal
class TripDetailScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> {
  late final StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = tripStream.listen((_) {});
  }

  @override
  void dispose() {
    _subscription.cancel(); // REQUIRED
    super.dispose();
  }
}
```

### 4. Network Performance

**API Call Optimization**
```dart
// DO: Batch requests
Future<void> loadTripData(String tripId) async {
  // Single request with joins
  final data = await supabase
      .from('trips')
      .select('*, cities:city_blocks(*, days(*))')
      .eq('id', tripId)
      .single();
}

// DON'T: Multiple sequential requests
Future<void> loadTripData(String tripId) async {
  final trip = await supabase.from('trips').select().eq('id', tripId);
  final cities = await supabase.from('city_blocks').select().eq('trip_id', tripId);
  final days = await supabase.from('days').select().in_('city_id', cityIds);
}
```

**Caching Strategy**
```dart
class CachedRepository {
  final _cache = <String, CacheEntry>{};
  final _cacheExpiry = const Duration(minutes: 5);

  Future<T> getCached<T>(
    String key,
    Future<T> Function() fetch,
  ) async {
    final entry = _cache[key];
    if (entry != null && !entry.isExpired) {
      return entry.data as T;
    }

    final data = await fetch();
    _cache[key] = CacheEntry(data, DateTime.now().add(_cacheExpiry));
    return data;
  }
}
```

### 5. Database Performance

**Query Optimization**
```dart
// DO: Select only needed fields
final trips = await supabase
    .from('trips')
    .select('id, name, countries') // Only what's needed
    .eq('owner_id', userId);

// DON'T: Select everything
final trips = await supabase
    .from('trips')
    .select('*') // Avoid when possible
    .eq('owner_id', userId);
```

**Pagination**
```dart
// REQUIRED: Always paginate lists
Future<PaginatedResponse<Trip>> getTrips({
  int page = 1,
  int pageSize = 20,
}) async {
  final from = (page - 1) * pageSize;
  final to = from + pageSize - 1;

  final response = await supabase
      .from('trips')
      .select('*', const FetchOptions(count: CountOption.exact))
      .eq('owner_id', userId)
      .range(from, to)
      .order('created_at', ascending: false);

  return PaginatedResponse(
    items: response.data.map((e) => Trip.fromJson(e)).toList(),
    total: response.count ?? 0,
    page: page,
    pageSize: pageSize,
  );
}
```

### 6. Image Performance

**Image Loading**
```dart
// DO: Use cached_network_image
CachedNetworkImage(
  imageUrl: activity.photoUrl,
  placeholder: (_, __) => const Shimmer(),
  errorWidget: (_, __, ___) => const PlaceholderImage(),
  memCacheHeight: 200, // Limit memory cache size
)

// DO: Resize images before upload
Future<File> resizeImage(File image) async {
  final bytes = await image.readAsBytes();
  final decoded = img.decodeImage(bytes)!;
  final resized = img.copyResize(decoded, width: 800);
  return File(image.path)..writeAsBytesSync(img.encodeJpg(resized, quality: 80));
}
```

### 7. List Performance

**ListView Optimization**
```dart
// DO: Use ListView.builder for long lists
ListView.builder(
  itemCount: trips.length,
  itemBuilder: (context, index) => TripCard(trip: trips[index]),
)

// DO: Use itemExtent when items have fixed height
ListView.builder(
  itemCount: trips.length,
  itemExtent: 120, // Fixed height improves performance
  itemBuilder: (context, index) => TripCard(trip: trips[index]),
)

// DON'T: Use ListView with children for long lists
ListView(
  children: trips.map((t) => TripCard(trip: t)).toList(), // Bad for long lists
)
```

### 8. Animation Performance

```dart
// DO: Use AnimatedBuilder for complex animations
AnimatedBuilder(
  animation: _controller,
  builder: (context, child) {
    return Transform.scale(
      scale: _animation.value,
      child: child, // Child is not rebuilt
    );
  },
  child: const ExpensiveWidget(), // Built once
)

// DO: Use physics-based animations
final animation = SpringSimulation(
  const SpringDescription(mass: 1, stiffness: 100, damping: 10),
  0, 1, 0,
);
```

### 9. Background Processing

**Expensive Operations**
```dart
// DO: Use isolates for heavy computation
Future<List<Activity>> optimizeRoute(List<Activity> activities) async {
  return compute(_optimizeRouteIsolate, activities);
}

List<Activity> _optimizeRouteIsolate(List<Activity> activities) {
  // Heavy computation here
  return optimizedActivities;
}
```

### 10. Battery Optimization

**Location Services**
```dart
// DO: Use significant location changes, not continuous
final locationSettings = AppleSettings(
  accuracy: LocationAccuracy.balanced, // Not high
  activityType: ActivityType.other,
  pauseLocationUpdatesAutomatically: true,
  distanceFilter: 100, // Only update every 100m
);

// DO: Stop location when not needed
void dispose() {
  _locationSubscription?.cancel();
  super.dispose();
}
```

### 11. Offline Performance

**Local Storage Strategy**
```dart
// Use Hive for fast local storage
@HiveType(typeId: 0)
class TripCache extends HiveObject {
  @HiveField(0)
  final String tripJson;

  @HiveField(1)
  final DateTime cachedAt;
}

// Sync strategy
Future<List<Trip>> getTrips() async {
  // Try cache first
  final cached = await _localSource.getTrips();
  if (cached.isNotEmpty && _isOnline == false) {
    return cached;
  }

  // Fetch fresh and cache
  final fresh = await _remoteSource.getTrips();
  await _localSource.cacheTrips(fresh);
  return fresh;
}
```

### 12. Monitoring

**Performance Tracking**
```dart
// Track slow operations
Future<T> trackPerformance<T>(
  String operation,
  Future<T> Function() action,
) async {
  final stopwatch = Stopwatch()..start();
  try {
    return await action();
  } finally {
    stopwatch.stop();
    if (stopwatch.elapsedMilliseconds > 1000) {
      analytics.trackSlowOperation(operation, stopwatch.elapsedMilliseconds);
    }
  }
}
```
