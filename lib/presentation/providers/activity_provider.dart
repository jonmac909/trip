import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trippified/data/repositories/activity_repository.dart';
import 'package:trippified/domain/models/activity.dart';

/// Provider for ActivityRepository
final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ActivityRepository();
});

/// Provider for fetching activities
final activitiesProvider =
    FutureProvider.family<List<Activity>, ActivityFilter>((ref, filter) async {
      final repository = ref.watch(activityRepositoryProvider);
      return repository.getActivities(
        cityName: filter.cityName,
        category: filter.category,
        limit: filter.limit,
        offset: filter.offset,
      );
    });

/// Provider for fetching a single activity by ID
final activityByIdProvider = FutureProvider.family<Activity, String>((
  ref,
  activityId,
) async {
  final repository = ref.watch(activityRepositoryProvider);
  return repository.getActivityById(activityId);
});

/// Provider for searching activities
final activitySearchProvider = FutureProvider.family<List<Activity>, String>((
  ref,
  query,
) async {
  if (query.isEmpty) return [];
  final repository = ref.watch(activityRepositoryProvider);
  return repository.searchActivities(query);
});

/// Filter class for activity queries
class ActivityFilter {
  const ActivityFilter({
    this.cityName,
    this.category,
    this.limit = 50,
    this.offset = 0,
  });

  final String? cityName;
  final ActivityCategory? category;
  final int limit;
  final int offset;

  ActivityFilter copyWith({
    String? cityName,
    ActivityCategory? category,
    int? limit,
    int? offset,
  }) {
    return ActivityFilter(
      cityName: cityName ?? this.cityName,
      category: category ?? this.category,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityFilter &&
          runtimeType == other.runtimeType &&
          cityName == other.cityName &&
          category == other.category &&
          limit == other.limit &&
          offset == other.offset;

  @override
  int get hashCode =>
      cityName.hashCode ^ category.hashCode ^ limit.hashCode ^ offset.hashCode;
}

/// Notifier for managing day activities
class DayActivitiesNotifier
    extends StateNotifier<AsyncValue<List<DayActivity>>> {
  DayActivitiesNotifier(this._repository) : super(const AsyncValue.data([]));

  final ActivityRepository _repository;

  /// Add an activity to a day
  Future<DayActivity?> addActivity({
    required String dayId,
    required String activityId,
    required int orderIndex,
    String? startTime,
    String? endTime,
    String? notes,
  }) async {
    try {
      final dayActivity = await _repository.addActivityToDay(
        dayId: dayId,
        activityId: activityId,
        orderIndex: orderIndex,
        startTime: startTime,
        endTime: endTime,
        notes: notes,
      );

      // Update state with new activity
      state = AsyncValue.data([...state.value ?? [], dayActivity]);
      return dayActivity;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Update a day activity
  Future<DayActivity?> updateActivity(DayActivity dayActivity) async {
    try {
      final updated = await _repository.updateDayActivity(dayActivity);

      // Update state
      final activities = state.value ?? [];
      final index = activities.indexWhere((a) => a.id == updated.id);
      if (index >= 0) {
        activities[index] = updated;
        state = AsyncValue.data([...activities]);
      }

      return updated;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Remove an activity from a day
  Future<bool> removeActivity(String dayActivityId) async {
    try {
      await _repository.removeActivityFromDay(dayActivityId);

      // Update state
      final activities = state.value ?? [];
      activities.removeWhere((a) => a.id == dayActivityId);
      state = AsyncValue.data([...activities]);

      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Reorder activities
  Future<bool> reorderActivities(String dayId, List<String> activityIds) async {
    try {
      await _repository.reorderDayActivities(dayId, activityIds);
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Provider for day activities notifier
final dayActivitiesNotifierProvider =
    StateNotifierProvider.family<
      DayActivitiesNotifier,
      AsyncValue<List<DayActivity>>,
      String
    >((ref, dayId) {
      final repository = ref.watch(activityRepositoryProvider);
      return DayActivitiesNotifier(repository);
    });
