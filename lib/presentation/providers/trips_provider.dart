import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Model for a saved trip
class SavedTrip {
  const SavedTrip({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.dates,
    required this.daysUntil,
    required this.cityNames,
    required this.countries,
    this.startDate,
    this.endDate,
    this.travelers = 1,
    this.status = TripStatus.upcoming,
  });

  final String id;
  final String title;
  final String imageUrl;
  final String dates;
  final int daysUntil;
  final List<String> cityNames;
  final List<String> countries;
  final DateTime? startDate;
  final DateTime? endDate;
  final int travelers;
  final TripStatus status;

  /// Get the primary country (first one) for display
  String get country => countries.isNotEmpty ? countries.first : '';

  SavedTrip copyWith({
    String? id,
    String? title,
    String? imageUrl,
    String? dates,
    int? daysUntil,
    List<String>? cityNames,
    List<String>? countries,
    DateTime? startDate,
    DateTime? endDate,
    int? travelers,
    TripStatus? status,
  }) {
    return SavedTrip(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      dates: dates ?? this.dates,
      daysUntil: daysUntil ?? this.daysUntil,
      cityNames: cityNames ?? this.cityNames,
      countries: countries ?? this.countries,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      travelers: travelers ?? this.travelers,
      status: status ?? this.status,
    );
  }
}

enum TripStatus { upcoming, draft, past }

/// Notifier for managing trips state
class TripsNotifier extends StateNotifier<List<SavedTrip>> {
  TripsNotifier() : super([]);

  void addTrip(SavedTrip trip) {
    state = [trip, ...state];
  }

  void removeTrip(String tripId) {
    state = state.where((t) => t.id != tripId).toList();
  }

  void insertTrip(int index, SavedTrip trip) {
    final newState = List<SavedTrip>.from(state);
    newState.insert(index.clamp(0, newState.length), trip);
    state = newState;
  }

  void updateTrip(SavedTrip updatedTrip) {
    state = state.map((t) => t.id == updatedTrip.id ? updatedTrip : t).toList();
  }

  SavedTrip? getTripById(String id) {
    try {
      return state.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  List<SavedTrip> getByStatus(TripStatus status) {
    return state.where((t) => t.status == status).toList();
  }
}

/// Provider for trips state
final tripsProvider = StateNotifierProvider<TripsNotifier, List<SavedTrip>>(
  (ref) => TripsNotifier(),
);
