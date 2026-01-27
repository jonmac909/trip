/// Place type enum
enum PlaceType { restaurant, attraction, hotel, cafe, bar, shopping }

/// Place model for saved places and search results
class Place {
  const Place({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    this.description,
    this.openingHours,
    required this.isOpen,
    required this.type,
    required this.tips,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      imageUrl: json['image_url'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['review_count'] as int,
      description: json['description'] as String?,
      openingHours: json['opening_hours'] as String?,
      isOpen: json['is_open'] as bool,
      type: PlaceType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PlaceType.attraction,
      ),
      tips: List<String>.from(json['tips'] as List? ?? []),
    );
  }

  final String id;
  final String name;
  final String location;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String? description;
  final String? openingHours;
  final bool isOpen;
  final PlaceType type;
  final List<String> tips;

  Place copyWith({
    String? id,
    String? name,
    String? location,
    String? imageUrl,
    double? rating,
    int? reviewCount,
    String? description,
    String? openingHours,
    bool? isOpen,
    PlaceType? type,
    List<String>? tips,
  }) {
    return Place(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      description: description ?? this.description,
      openingHours: openingHours ?? this.openingHours,
      isOpen: isOpen ?? this.isOpen,
      type: type ?? this.type,
      tips: tips ?? this.tips,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'image_url': imageUrl,
      'rating': rating,
      'review_count': reviewCount,
      'description': description,
      'opening_hours': openingHours,
      'is_open': isOpen,
      'type': type.name,
      'tips': tips,
    };
  }
}

/// Extension for place type display names and icons
extension PlaceTypeExtension on PlaceType {
  String get displayName {
    switch (this) {
      case PlaceType.restaurant:
        return 'Restaurant';
      case PlaceType.attraction:
        return 'Attraction';
      case PlaceType.hotel:
        return 'Hotel';
      case PlaceType.cafe:
        return 'Cafe';
      case PlaceType.bar:
        return 'Bar';
      case PlaceType.shopping:
        return 'Shopping';
    }
  }
}
