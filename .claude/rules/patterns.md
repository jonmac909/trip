# Trippified Code Patterns

## MANDATORY - Use These Patterns Consistently

### 1. API Response Pattern

**Standard Response Format**
```dart
// For single item
class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool success;

  ApiResponse.success(this.data) : error = null, success = true;
  ApiResponse.failure(this.error) : data = null, success = false;
}

// For lists with pagination
class PaginatedResponse<T> {
  final List<T> items;
  final int total;
  final int page;
  final int pageSize;
  final bool hasMore;

  PaginatedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  }) : hasMore = (page * pageSize) < total;
}
```

### 2. Repository Pattern

**Interface in Domain Layer**
```dart
// lib/domain/repositories/trip_repository.dart
abstract class TripRepository {
  Future<List<Trip>> getTrips();
  Future<Trip> getTripById(String id);
  Future<Trip> createTrip(CreateTripInput input);
  Future<Trip> updateTrip(String id, UpdateTripInput input);
  Future<void> deleteTrip(String id);
}
```

**Implementation in Data Layer**
```dart
// lib/data/repositories/trip_repository_impl.dart
class TripRepositoryImpl implements TripRepository {
  final SupabaseClient _supabase;
  final TripLocalDataSource _localDataSource;

  TripRepositoryImpl(this._supabase, this._localDataSource);

  @override
  Future<List<Trip>> getTrips() async {
    try {
      final response = await _supabase
          .from('trips')
          .select()
          .eq('owner_id', _supabase.auth.currentUser!.id)
          .order('created_at', ascending: false);

      final trips = (response as List)
          .map((json) => TripModel.fromJson(json).toEntity())
          .toList();

      // Cache locally
      await _localDataSource.cacheTrips(trips);

      return trips;
    } on PostgrestException catch (e) {
      throw TrippifiedException('Failed to load trips: ${e.message}');
    }
  }
}
```

### 3. Use Case Pattern

**One Use Case Per Operation**
```dart
// lib/domain/usecases/create_trip.dart
class CreateTripUseCase {
  final TripRepository _repository;
  final AnalyticsService _analytics;

  CreateTripUseCase(this._repository, this._analytics);

  Future<Trip> execute(CreateTripInput input) async {
    // Validate
    _validate(input);

    // Execute
    final trip = await _repository.createTrip(input);

    // Side effects
    _analytics.trackTripCreated(trip.id, input.countries);

    return trip;
  }

  void _validate(CreateTripInput input) {
    if (input.name.trim().isEmpty) {
      throw ValidationException('Trip name is required');
    }
    if (input.countries.isEmpty) {
      throw ValidationException('Select at least one country');
    }
  }
}
```

### 4. State Management Pattern (Riverpod)

**Provider Structure**
```dart
// State
@freezed
class TripsState with _$TripsState {
  const factory TripsState.initial() = _Initial;
  const factory TripsState.loading() = _Loading;
  const factory TripsState.loaded(List<Trip> trips) = _Loaded;
  const factory TripsState.error(String message) = _Error;
}

// Notifier
class TripsNotifier extends StateNotifier<TripsState> {
  final GetTripsUseCase _getTrips;
  final CreateTripUseCase _createTrip;

  TripsNotifier(this._getTrips, this._createTrip) : super(const TripsState.initial());

  Future<void> loadTrips() async {
    state = const TripsState.loading();
    try {
      final trips = await _getTrips.execute();
      state = TripsState.loaded(trips);
    } on TrippifiedException catch (e) {
      state = TripsState.error(e.message);
    }
  }

  Future<void> createTrip(CreateTripInput input) async {
    try {
      await _createTrip.execute(input);
      await loadTrips(); // Refresh list
    } on TrippifiedException catch (e) {
      state = TripsState.error(e.message);
    }
  }
}

// Provider
final tripsProvider = StateNotifierProvider<TripsNotifier, TripsState>((ref) {
  return TripsNotifier(
    ref.watch(getTripsUseCaseProvider),
    ref.watch(createTripUseCaseProvider),
  );
});
```

### 5. Error Handling Pattern

**Exception Hierarchy**
```dart
// Base exception
class TrippifiedException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  TrippifiedException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'TrippifiedException: $message (code: $code)';
}

// Specific exceptions
class NetworkException extends TrippifiedException {
  NetworkException([String message = 'Network error'])
      : super(message, code: 'NETWORK_ERROR');
}

class UnauthorizedException extends TrippifiedException {
  UnauthorizedException([String message = 'Not authenticated'])
      : super(message, code: 'UNAUTHORIZED');
}

class ValidationException extends TrippifiedException {
  final Map<String, String>? fieldErrors;

  ValidationException(String message, {this.fieldErrors})
      : super(message, code: 'VALIDATION_ERROR');
}

class NotFoundException extends TrippifiedException {
  NotFoundException(String resource)
      : super('$resource not found', code: 'NOT_FOUND');
}
```

**Error Mapping**
```dart
// Map Supabase errors to app exceptions
TrippifiedException mapSupabaseError(PostgrestException e) {
  switch (e.code) {
    case '42501':
      return UnauthorizedException('Permission denied');
    case '23505':
      return ValidationException('Duplicate entry');
    case 'PGRST116':
      return NotFoundException('Resource');
    default:
      return TrippifiedException('Database error', originalError: e);
  }
}
```

### 6. Model Pattern

**Data Model (with JSON serialization)**
```dart
// lib/data/models/trip_model.dart
@JsonSerializable()
class TripModel {
  final String id;
  final String name;
  final List<String> countries;
  @JsonKey(name: 'trip_size')
  final String tripSize;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  TripModel({
    required this.id,
    required this.name,
    required this.countries,
    required this.tripSize,
    required this.createdAt,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) =>
      _$TripModelFromJson(json);

  Map<String, dynamic> toJson() => _$TripModelToJson(this);

  Trip toEntity() => Trip(
    id: id,
    name: name,
    countries: countries,
    tripSize: TripSize.fromString(tripSize),
    createdAt: createdAt,
  );

  factory TripModel.fromEntity(Trip entity) => TripModel(
    id: entity.id,
    name: entity.name,
    countries: entity.countries,
    tripSize: entity.tripSize.value,
    createdAt: entity.createdAt,
  );
}
```

**Domain Entity (immutable)**
```dart
// lib/domain/entities/trip.dart
@freezed
class Trip with _$Trip {
  const factory Trip({
    required String id,
    required String name,
    required List<String> countries,
    required TripSize tripSize,
    required DateTime createdAt,
    @Default([]) List<CityBlock> cities,
  }) = _Trip;
}
```

### 7. Dependency Injection Pattern

**Provider Registration**
```dart
// lib/core/di/providers.dart

// Data sources
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Repositories
final tripRepositoryProvider = Provider<TripRepository>((ref) {
  return TripRepositoryImpl(
    ref.watch(supabaseProvider),
    ref.watch(tripLocalDataSourceProvider),
  );
});

// Use cases
final getTripsUseCaseProvider = Provider<GetTripsUseCase>((ref) {
  return GetTripsUseCase(ref.watch(tripRepositoryProvider));
});

final createTripUseCaseProvider = Provider<CreateTripUseCase>((ref) {
  return CreateTripUseCase(
    ref.watch(tripRepositoryProvider),
    ref.watch(analyticsServiceProvider),
  );
});
```

### 8. Widget Pattern

**Screen Widget**
```dart
class TripSetupScreen extends ConsumerWidget {
  const TripSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tripSetupProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tell us about your trip')),
      body: state.when(
        initial: () => _buildForm(ref),
        loading: () => const LoadingIndicator(),
        error: (message) => ErrorView(message: message),
      ),
    );
  }

  Widget _buildForm(WidgetRef ref) {
    return Column(
      children: [
        const CountrySelector(),
        const SizedBox(height: 24),
        const TripSizeSelector(),
        const Spacer(),
        const SeeRoutesCta(),
      ],
    );
  }
}
```

### 9. Supabase Query Patterns

**Select with Relationships**
```dart
// Get trip with cities
final trip = await supabase
    .from('trips')
    .select('''
      *,
      cities:city_blocks(
        *,
        days(*)
      )
    ''')
    .eq('id', tripId)
    .single();
```

**Upsert**
```dart
await supabase.from('trips').upsert({
  'id': trip.id,
  'name': trip.name,
  'updated_at': DateTime.now().toIso8601String(),
});
```

**Real-time Subscription**
```dart
final subscription = supabase
    .from('trips')
    .stream(primaryKey: ['id'])
    .eq('owner_id', userId)
    .listen((data) {
      // Handle updates
    });
```

### 10. Async Pattern

**AsyncValue with Riverpod**
```dart
final tripProvider = FutureProvider.family<Trip, String>((ref, tripId) async {
  final repository = ref.watch(tripRepositoryProvider);
  return repository.getTripById(tripId);
});

// In widget
ref.watch(tripProvider(tripId)).when(
  data: (trip) => TripView(trip: trip),
  loading: () => const LoadingIndicator(),
  error: (e, _) => ErrorView(message: e.toString()),
);
```
