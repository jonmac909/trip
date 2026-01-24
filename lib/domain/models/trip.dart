import 'package:trippified/domain/models/activity.dart';

/// Trip model representing a user's planned trip
class Trip {
  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      coverImageUrl: json['cover_image_url'] as String?,
      status: TripStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TripStatus.planning,
      ),
      numberOfTravelers: json['number_of_travelers'] as int? ?? 1,
      totalBudget: (json['total_budget'] as num?)?.toDouble(),
      budgetCurrency: json['budget_currency'] as String? ?? 'USD',
      isOfflineEnabled: json['is_offline_enabled'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
  const Trip({
    required this.id,
    required this.userId,
    required this.name,
    this.startDate,
    this.endDate,
    this.coverImageUrl,
    this.status = TripStatus.planning,
    this.numberOfTravelers = 1,
    this.totalBudget,
    this.budgetCurrency = 'USD',
    this.isOfflineEnabled = false,
    this.createdAt,
    this.updatedAt,
    this.cityBlocks = const [],
  });

  final String id;
  final String userId;
  final String name;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? coverImageUrl;
  final TripStatus status;
  final int numberOfTravelers;
  final double? totalBudget;
  final String budgetCurrency;
  final bool isOfflineEnabled;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<CityBlock> cityBlocks;

  /// Calculate total trip days
  int? get totalDays {
    if (startDate == null || endDate == null) return null;
    return endDate!.difference(startDate!).inDays + 1;
  }

  /// Check if trip is in the past
  bool get isPast {
    if (endDate == null) return false;
    return endDate!.isBefore(DateTime.now());
  }

  /// Check if trip is currently active
  bool get isActive {
    if (startDate == null || endDate == null) return false;
    final now = DateTime.now();
    return now.isAfter(startDate!) &&
        now.isBefore(endDate!.add(const Duration(days: 1)));
  }

  Trip copyWith({
    String? id,
    String? userId,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    String? coverImageUrl,
    TripStatus? status,
    int? numberOfTravelers,
    double? totalBudget,
    String? budgetCurrency,
    bool? isOfflineEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<CityBlock>? cityBlocks,
  }) {
    return Trip(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      status: status ?? this.status,
      numberOfTravelers: numberOfTravelers ?? this.numberOfTravelers,
      totalBudget: totalBudget ?? this.totalBudget,
      budgetCurrency: budgetCurrency ?? this.budgetCurrency,
      isOfflineEnabled: isOfflineEnabled ?? this.isOfflineEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cityBlocks: cityBlocks ?? this.cityBlocks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'cover_image_url': coverImageUrl,
      'status': status.name,
      'number_of_travelers': numberOfTravelers,
      'total_budget': totalBudget,
      'budget_currency': budgetCurrency,
      'is_offline_enabled': isOfflineEnabled,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

/// Trip status enum
enum TripStatus { planning, confirmed, inProgress, completed, cancelled }

/// City block within a trip (a destination within the trip)
class CityBlock {
  factory CityBlock.fromJson(Map<String, dynamic> json) {
    return CityBlock(
      id: json['id'] as String,
      tripId: json['trip_id'] as String,
      cityName: json['city_name'] as String,
      countryName: json['country_name'] as String,
      orderIndex: json['order_index'] as int,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      placeId: json['place_id'] as String?,
      imageUrl: json['image_url'] as String?,
      allocatedBudget: (json['allocated_budget'] as num?)?.toDouble(),
    );
  }
  const CityBlock({
    required this.id,
    required this.tripId,
    required this.cityName,
    required this.countryName,
    required this.orderIndex,
    this.startDate,
    this.endDate,
    this.latitude,
    this.longitude,
    this.placeId,
    this.imageUrl,
    this.allocatedBudget,
    this.days = const [],
  });

  final String id;
  final String tripId;
  final String cityName;
  final String countryName;
  final int orderIndex;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? latitude;
  final double? longitude;
  final String? placeId;
  final String? imageUrl;
  final double? allocatedBudget;
  final List<Day> days;

  int? get numberOfDays {
    if (startDate == null || endDate == null) return null;
    return endDate!.difference(startDate!).inDays + 1;
  }

  CityBlock copyWith({
    String? id,
    String? tripId,
    String? cityName,
    String? countryName,
    int? orderIndex,
    DateTime? startDate,
    DateTime? endDate,
    double? latitude,
    double? longitude,
    String? placeId,
    String? imageUrl,
    double? allocatedBudget,
    List<Day>? days,
  }) {
    return CityBlock(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      cityName: cityName ?? this.cityName,
      countryName: countryName ?? this.countryName,
      orderIndex: orderIndex ?? this.orderIndex,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      placeId: placeId ?? this.placeId,
      imageUrl: imageUrl ?? this.imageUrl,
      allocatedBudget: allocatedBudget ?? this.allocatedBudget,
      days: days ?? this.days,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
    };
  }
}

/// A day within a city block
class Day {
  factory Day.fromJson(Map<String, dynamic> json) {
    return Day(
      id: json['id'] as String,
      cityBlockId: json['city_block_id'] as String,
      dayNumber: json['day_number'] as int,
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String?,
    );
  }
  const Day({
    required this.id,
    required this.cityBlockId,
    required this.dayNumber,
    required this.date,
    this.notes,
    this.activities = const [],
  });

  final String id;
  final String cityBlockId;
  final int dayNumber;
  final DateTime date;
  final String? notes;
  final List<Activity> activities;

  Day copyWith({
    String? id,
    String? cityBlockId,
    int? dayNumber,
    DateTime? date,
    String? notes,
    List<Activity>? activities,
  }) {
    return Day(
      id: id ?? this.id,
      cityBlockId: cityBlockId ?? this.cityBlockId,
      dayNumber: dayNumber ?? this.dayNumber,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      activities: activities ?? this.activities,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'city_block_id': cityBlockId,
      'day_number': dayNumber,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }
}
