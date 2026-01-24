/// Activity model representing a single activity/place in an itinerary
class Activity {
  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String,
      name: json['name'] as String,
      category: ActivityCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ActivityCategory.attraction,
      ),
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      placeId: json['place_id'] as String?,
      address: json['address'] as String?,
      estimatedDurationMinutes: json['estimated_duration_minutes'] as int?,
      estimatedCost: (json['estimated_cost'] as num?)?.toDouble(),
      costCurrency: json['cost_currency'] as String? ?? 'USD',
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: json['review_count'] as int?,
      openingHours: json['opening_hours'] != null
          ? Map<String, String>.from(json['opening_hours'] as Map)
          : null,
      phoneNumber: json['phone_number'] as String?,
      website: json['website'] as String?,
      bookingUrl: json['booking_url'] as String?,
      isBookingRequired: json['is_booking_required'] as bool? ?? false,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : const [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
  const Activity({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.placeId,
    this.address,
    this.estimatedDurationMinutes,
    this.estimatedCost,
    this.costCurrency = 'USD',
    this.rating,
    this.reviewCount,
    this.openingHours,
    this.phoneNumber,
    this.website,
    this.bookingUrl,
    this.isBookingRequired = false,
    this.tags = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final ActivityCategory category;
  final String? description;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  final String? placeId;
  final String? address;
  final int? estimatedDurationMinutes;
  final double? estimatedCost;
  final String costCurrency;
  final double? rating;
  final int? reviewCount;
  final Map<String, String>? openingHours;
  final String? phoneNumber;
  final String? website;
  final String? bookingUrl;
  final bool isBookingRequired;
  final List<String> tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Formatted duration string
  String? get formattedDuration {
    if (estimatedDurationMinutes == null) return null;
    final hours = estimatedDurationMinutes! ~/ 60;
    final minutes = estimatedDurationMinutes! % 60;
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  Activity copyWith({
    String? id,
    String? name,
    ActivityCategory? category,
    String? description,
    String? imageUrl,
    double? latitude,
    double? longitude,
    String? placeId,
    String? address,
    int? estimatedDurationMinutes,
    double? estimatedCost,
    String? costCurrency,
    double? rating,
    int? reviewCount,
    Map<String, String>? openingHours,
    String? phoneNumber,
    String? website,
    String? bookingUrl,
    bool? isBookingRequired,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Activity(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      placeId: placeId ?? this.placeId,
      address: address ?? this.address,
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      costCurrency: costCurrency ?? this.costCurrency,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      openingHours: openingHours ?? this.openingHours,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      website: website ?? this.website,
      bookingUrl: bookingUrl ?? this.bookingUrl,
      isBookingRequired: isBookingRequired ?? this.isBookingRequired,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.name,
      'description': description,
      'image_url': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'place_id': placeId,
      'address': address,
      'estimated_duration_minutes': estimatedDurationMinutes,
      'estimated_cost': estimatedCost,
      'cost_currency': costCurrency,
      'rating': rating,
      'review_count': reviewCount,
      'opening_hours': openingHours,
      'phone_number': phoneNumber,
      'website': website,
      'booking_url': bookingUrl,
      'is_booking_required': isBookingRequired,
      'tags': tags,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

/// Activity category enum
enum ActivityCategory {
  attraction,
  restaurant,
  cafe,
  bar,
  nightlife,
  shopping,
  museum,
  park,
  beach,
  temple,
  landmark,
  entertainment,
  spa,
  sport,
  tour,
  transport,
  accommodation,
  other,
}

/// Extension for category display names and icons
extension ActivityCategoryExtension on ActivityCategory {
  String get displayName {
    switch (this) {
      case ActivityCategory.attraction:
        return 'Attraction';
      case ActivityCategory.restaurant:
        return 'Restaurant';
      case ActivityCategory.cafe:
        return 'Cafe';
      case ActivityCategory.bar:
        return 'Bar';
      case ActivityCategory.nightlife:
        return 'Nightlife';
      case ActivityCategory.shopping:
        return 'Shopping';
      case ActivityCategory.museum:
        return 'Museum';
      case ActivityCategory.park:
        return 'Park';
      case ActivityCategory.beach:
        return 'Beach';
      case ActivityCategory.temple:
        return 'Temple';
      case ActivityCategory.landmark:
        return 'Landmark';
      case ActivityCategory.entertainment:
        return 'Entertainment';
      case ActivityCategory.spa:
        return 'Spa & Wellness';
      case ActivityCategory.sport:
        return 'Sport & Activity';
      case ActivityCategory.tour:
        return 'Tour';
      case ActivityCategory.transport:
        return 'Transport';
      case ActivityCategory.accommodation:
        return 'Accommodation';
      case ActivityCategory.other:
        return 'Other';
    }
  }

  String get iconName {
    switch (this) {
      case ActivityCategory.attraction:
        return 'attractions';
      case ActivityCategory.restaurant:
        return 'restaurant';
      case ActivityCategory.cafe:
        return 'local_cafe';
      case ActivityCategory.bar:
        return 'local_bar';
      case ActivityCategory.nightlife:
        return 'nightlife';
      case ActivityCategory.shopping:
        return 'shopping_bag';
      case ActivityCategory.museum:
        return 'museum';
      case ActivityCategory.park:
        return 'park';
      case ActivityCategory.beach:
        return 'beach_access';
      case ActivityCategory.temple:
        return 'temple_buddhist';
      case ActivityCategory.landmark:
        return 'location_city';
      case ActivityCategory.entertainment:
        return 'movie';
      case ActivityCategory.spa:
        return 'spa';
      case ActivityCategory.sport:
        return 'sports';
      case ActivityCategory.tour:
        return 'tour';
      case ActivityCategory.transport:
        return 'directions_transit';
      case ActivityCategory.accommodation:
        return 'hotel';
      case ActivityCategory.other:
        return 'place';
    }
  }
}

/// Day activity - links an activity to a specific day with time slot
class DayActivity {
  factory DayActivity.fromJson(
    Map<String, dynamic> json, {
    Activity? activity,
  }) {
    return DayActivity(
      id: json['id'] as String,
      dayId: json['day_id'] as String,
      activityId: json['activity_id'] as String,
      orderIndex: json['order_index'] as int,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      notes: json['notes'] as String?,
      isCompleted: json['is_completed'] as bool? ?? false,
      activity: activity,
    );
  }
  const DayActivity({
    required this.id,
    required this.dayId,
    required this.activityId,
    required this.orderIndex,
    this.startTime,
    this.endTime,
    this.notes,
    this.isCompleted = false,
    this.activity,
  });

  final String id;
  final String dayId;
  final String activityId;
  final int orderIndex;
  final String? startTime;
  final String? endTime;
  final String? notes;
  final bool isCompleted;
  final Activity? activity;

  DayActivity copyWith({
    String? id,
    String? dayId,
    String? activityId,
    int? orderIndex,
    String? startTime,
    String? endTime,
    String? notes,
    bool? isCompleted,
    Activity? activity,
  }) {
    return DayActivity(
      id: id ?? this.id,
      dayId: dayId ?? this.dayId,
      activityId: activityId ?? this.activityId,
      orderIndex: orderIndex ?? this.orderIndex,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      activity: activity ?? this.activity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day_id': dayId,
      'activity_id': activityId,
      'order_index': orderIndex,
      'start_time': startTime,
      'end_time': endTime,
      'notes': notes,
      'is_completed': isCompleted,
    };
  }
}
