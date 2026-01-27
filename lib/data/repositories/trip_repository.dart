import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:trippified/core/errors/exceptions.dart';
import 'package:trippified/core/services/supabase_service.dart';
import 'package:trippified/domain/models/trip.dart';

/// Repository for trip-related data operations
class TripRepository {
  TripRepository({SupabaseClient? client})
    : _client = client ?? SupabaseService.instance.client;

  final SupabaseClient _client;

  /// Get all trips for the current user
  Future<List<Trip>> getTrips() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const UnauthorizedException('User not authenticated');
      }

      final response = await _client
          .from('trips')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Trip.fromJson(json as Map<String, dynamic>)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException('Failed to fetch trips: ${e.message}');
    }
  }

  /// Get a single trip by ID with all related data
  Future<Trip> getTripById(String tripId) async {
    try {
      final response = await _client
          .from('trips')
          .select('''
            *,
            city_blocks (
              *,
              days (
                *,
                day_activities (
                  *,
                  activities (*)
                )
              )
            )
          ''')
          .eq('id', tripId)
          .single();

      return Trip.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw const NotFoundException('Trip not found');
      }
      throw DatabaseException('Failed to fetch trip: ${e.message}');
    }
  }

  /// Create a new trip
  Future<Trip> createTrip({
    required String name,
    DateTime? startDate,
    DateTime? endDate,
    int numberOfTravelers = 1,
    double? totalBudget,
    String budgetCurrency = 'USD',
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const UnauthorizedException('User not authenticated');
      }

      final response = await _client
          .from('trips')
          .insert({
            'user_id': userId,
            'name': name,
            'start_date': startDate?.toIso8601String(),
            'end_date': endDate?.toIso8601String(),
            'number_of_travelers': numberOfTravelers,
            'total_budget': totalBudget,
            'budget_currency': budgetCurrency,
            'status': 'planning',
          })
          .select()
          .single();

      return Trip.fromJson(response);
    } on PostgrestException catch (e) {
      throw DatabaseException('Failed to create trip: ${e.message}');
    }
  }

  /// Update an existing trip
  Future<Trip> updateTrip(Trip trip) async {
    try {
      final response = await _client
          .from('trips')
          .update(trip.toJson())
          .eq('id', trip.id)
          .select()
          .single();

      return Trip.fromJson(response);
    } on PostgrestException catch (e) {
      throw DatabaseException('Failed to update trip: ${e.message}');
    }
  }

  /// Delete a trip
  Future<void> deleteTrip(String tripId) async {
    try {
      await _client.from('trips').delete().eq('id', tripId);
    } on PostgrestException catch (e) {
      throw DatabaseException('Failed to delete trip: ${e.message}');
    }
  }

  /// Add a city block to a trip
  Future<CityBlock> addCityBlock({
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
      final response = await _client
          .from('city_blocks')
          .insert({
            'trip_id': tripId,
            'city_name': cityName,
            'country_name': countryName,
            'order_index': orderIndex,
            'start_date': startDate?.toIso8601String(),
            'end_date': endDate?.toIso8601String(),
            'latitude': latitude,
            'longitude': longitude,
            'place_id': placeId,
            'image_url': imageUrl,
            'allocated_budget': allocatedBudget,
          })
          .select()
          .single();

      return CityBlock.fromJson(response);
    } on PostgrestException catch (e) {
      throw DatabaseException('Failed to add city block: ${e.message}');
    }
  }

  /// Update a city block
  Future<CityBlock> updateCityBlock(CityBlock cityBlock) async {
    try {
      final response = await _client
          .from('city_blocks')
          .update(cityBlock.toJson())
          .eq('id', cityBlock.id)
          .select()
          .single();

      return CityBlock.fromJson(response);
    } on PostgrestException catch (e) {
      throw DatabaseException('Failed to update city block: ${e.message}');
    }
  }

  /// Delete a city block
  Future<void> deleteCityBlock(String cityBlockId) async {
    try {
      await _client.from('city_blocks').delete().eq('id', cityBlockId);
    } on PostgrestException catch (e) {
      throw DatabaseException('Failed to delete city block: ${e.message}');
    }
  }

  /// Add a day to a city block
  Future<Day> addDay({
    required String cityBlockId,
    required int dayNumber,
    required DateTime date,
    String? notes,
  }) async {
    try {
      final response = await _client
          .from('days')
          .insert({
            'city_block_id': cityBlockId,
            'day_number': dayNumber,
            'date': date.toIso8601String(),
            'notes': notes,
          })
          .select()
          .single();

      return Day.fromJson(response);
    } on PostgrestException catch (e) {
      throw DatabaseException('Failed to add day: ${e.message}');
    }
  }

  /// Update a day
  Future<Day> updateDay(Day day) async {
    try {
      final response = await _client
          .from('days')
          .update(day.toJson())
          .eq('id', day.id)
          .select()
          .single();

      return Day.fromJson(response);
    } on PostgrestException catch (e) {
      throw DatabaseException('Failed to update day: ${e.message}');
    }
  }

  /// Get recommended routes for a destination
  Future<List<Map<String, dynamic>>> getRecommendedRoutes(
    String destination,
  ) async {
    try {
      final response = await _client
          .from('recommended_routes')
          .select()
          .ilike('destinations', '%$destination%')
          .eq('is_active', true)
          .order('popularity_score', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      throw DatabaseException(
        'Failed to fetch recommended routes: ${e.message}',
      );
    }
  }
}
