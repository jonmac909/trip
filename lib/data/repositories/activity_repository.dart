import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:trippified/core/errors/exceptions.dart';
import 'package:trippified/core/services/supabase_service.dart';
import 'package:trippified/domain/models/activity.dart';

/// Repository for activity-related data operations
class ActivityRepository {
  ActivityRepository({SupabaseClient? client})
    : _client = client ?? SupabaseService.instance.client;

  final SupabaseClient _client;

  /// Get all activities
  Future<List<Activity>> getActivities({
    String? cityName,
    ActivityCategory? category,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = _client.from('activities').select();

      if (cityName != null) {
        query = query.ilike('address', '%$cityName%');
      }

      if (category != null) {
        query = query.eq('category', category.name);
      }

      final response = await query
          .order('rating', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List).map((json) => Activity.fromJson(json as Map<String, dynamic>)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException('Failed to fetch activities: ${e.message}');
    }
  }

  /// Get activity by ID
  Future<Activity> getActivityById(String activityId) async {
    try {
      final response = await _client
          .from('activities')
          .select()
          .eq('id', activityId)
          .single();

      return Activity.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw const NotFoundException('Activity not found');
      }
      throw DatabaseException('Failed to fetch activity: ${e.message}');
    }
  }

  /// Helper to safely cast json map
  Map<String, dynamic>? _safeJsonCast(dynamic value) {
    if (value == null) return null;
    return value as Map<String, dynamic>;
  }

  /// Create a new activity
  Future<Activity> createActivity(Activity activity) async {
    try {
      final response = await _client
          .from('activities')
          .insert(activity.toJson())
          .select()
          .single();

      return Activity.fromJson(response);
    } on PostgrestException catch (e) {
      throw DatabaseException('Failed to create activity: ${e.message}');
    }
  }

  /// Update an activity
  Future<Activity> updateActivity(Activity activity) async {
    try {
      final response = await _client
          .from('activities')
          .update(activity.toJson())
          .eq('id', activity.id)
          .select()
          .single();

      return Activity.fromJson(response);
    } on PostgrestException catch (e) {
      throw DatabaseException('Failed to update activity: ${e.message}');
    }
  }

  /// Delete an activity
  Future<void> deleteActivity(String activityId) async {
    try {
      await _client.from('activities').delete().eq('id', activityId);
    } on PostgrestException catch (e) {
      throw DatabaseException('Failed to delete activity: ${e.message}');
    }
  }

  /// Add an activity to a day
  Future<DayActivity> addActivityToDay({
    required String dayId,
    required String activityId,
    required int orderIndex,
    String? startTime,
    String? endTime,
    String? notes,
  }) async {
    try {
      final response = await _client
          .from('day_activities')
          .insert({
            'day_id': dayId,
            'activity_id': activityId,
            'order_index': orderIndex,
            'start_time': startTime,
            'end_time': endTime,
            'notes': notes,
            'is_completed': false,
          })
          .select('''
        *,
        activities (*)
      ''')
          .single();

      final activityJson = _safeJsonCast(response['activities']);
      final activity = activityJson != null
          ? Activity.fromJson(activityJson)
          : null;

      return DayActivity.fromJson(response as Map<String, dynamic>, activity: activity);
    } on PostgrestException catch (e) {
      throw DatabaseException('Failed to add activity to day: ${e.message}');
    }
  }

  /// Update a day activity
  Future<DayActivity> updateDayActivity(DayActivity dayActivity) async {
    try {
      final response = await _client
          .from('day_activities')
          .update(dayActivity.toJson())
          .eq('id', dayActivity.id)
          .select('''
            *,
            activities (*)
          ''')
          .single();

      final activityJson = _safeJsonCast(response['activities']);
      final activity = activityJson != null
          ? Activity.fromJson(activityJson)
          : null;

      return DayActivity.fromJson(response as Map<String, dynamic>, activity: activity);
    } on PostgrestException catch (e) {
      throw DatabaseException('Failed to update day activity: ${e.message}');
    }
  }

  /// Remove an activity from a day
  Future<void> removeActivityFromDay(String dayActivityId) async {
    try {
      await _client.from('day_activities').delete().eq('id', dayActivityId);
    } on PostgrestException catch (e) {
      throw DatabaseException(
        'Failed to remove activity from day: ${e.message}',
      );
    }
  }

  /// Reorder activities within a day
  Future<void> reorderDayActivities(
    String dayId,
    List<String> activityIds,
  ) async {
    try {
      // Update order_index for each activity
      for (var i = 0; i < activityIds.length; i++) {
        await _client
            .from('day_activities')
            .update({'order_index': i})
            .eq('id', activityIds[i]);
      }
    } on PostgrestException catch (e) {
      throw DatabaseException('Failed to reorder activities: ${e.message}');
    }
  }

  /// Search activities by name or description
  Future<List<Activity>> searchActivities(String query) async {
    try {
      final response = await _client
          .from('activities')
          .select()
          .or('name.ilike.%$query%,description.ilike.%$query%')
          .order('rating', ascending: false)
          .limit(20);

      return (response as List).map((json) => Activity.fromJson(json as Map<String, dynamic>)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException('Failed to search activities: ${e.message}');
    }
  }
}
