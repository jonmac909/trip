import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trippified/data/repositories/trip_repository.dart';
import 'package:trippified/domain/models/trip.dart';

/// Provider for TripRepository
final tripRepositoryProvider = Provider<TripRepository>((ref) {
  return TripRepository();
});

/// Provider for fetching user's trips
final tripsProvider = FutureProvider<List<Trip>>((ref) async {
  final repository = ref.watch(tripRepositoryProvider);
  return repository.getTrips();
});

/// Provider for fetching a single trip by ID
final tripByIdProvider = FutureProvider.family<Trip, String>((
  ref,
  tripId,
) async {
  final repository = ref.watch(tripRepositoryProvider);
  return repository.getTripById(tripId);
});

/// Provider for recommended routes
final recommendedRoutesProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      destination,
    ) async {
      final repository = ref.watch(tripRepositoryProvider);
      return repository.getRecommendedRoutes(destination);
    });

/// Notifier for managing trip creation/update operations
class TripNotifier extends StateNotifier<AsyncValue<Trip?>> {
  TripNotifier(this._repository) : super(const AsyncValue.data(null));

  final TripRepository _repository;

  /// Create a new trip
  Future<Trip?> createTrip({
    required String name,
    DateTime? startDate,
    DateTime? endDate,
    int numberOfTravelers = 1,
    double? totalBudget,
    String budgetCurrency = 'USD',
  }) async {
    state = const AsyncValue.loading();
    try {
      final trip = await _repository.createTrip(
        name: name,
        startDate: startDate,
        endDate: endDate,
        numberOfTravelers: numberOfTravelers,
        totalBudget: totalBudget,
        budgetCurrency: budgetCurrency,
      );
      state = AsyncValue.data(trip);
      return trip;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Update an existing trip
  Future<Trip?> updateTrip(Trip trip) async {
    state = const AsyncValue.loading();
    try {
      final updatedTrip = await _repository.updateTrip(trip);
      state = AsyncValue.data(updatedTrip);
      return updatedTrip;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Delete a trip
  Future<bool> deleteTrip(String tripId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteTrip(tripId);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Add a city block to a trip
  Future<CityBlock?> addCityBlock({
    required String tripId,
    required String cityName,
    required String countryName,
    required int orderIndex,
    DateTime? startDate,
    DateTime? endDate,
    double? latitude,
    double? longitude,
    String? placeId,
    String? imageUrl,
    double? allocatedBudget,
  }) async {
    try {
      return await _repository.addCityBlock(
        tripId: tripId,
        cityName: cityName,
        countryName: countryName,
        orderIndex: orderIndex,
        startDate: startDate,
        endDate: endDate,
        latitude: latitude,
        longitude: longitude,
        placeId: placeId,
        imageUrl: imageUrl,
        allocatedBudget: allocatedBudget,
      );
    } catch (e) {
      return null;
    }
  }
}

/// Provider for trip notifier
final tripNotifierProvider =
    StateNotifierProvider<TripNotifier, AsyncValue<Trip?>>((ref) {
      final repository = ref.watch(tripRepositoryProvider);
      return TripNotifier(repository);
    });
