/// Destination model for explore destinations
class Destination {
  const Destination({
    required this.id,
    required this.name,
    required this.country,
    required this.imageUrl,
    required this.description,
    required this.cities,
    required this.itineraryCount,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json['id'] as String,
      name: json['name'] as String,
      country: json['country'] as String,
      imageUrl: json['image_url'] as String,
      description: json['description'] as String,
      cities: List<String>.from(json['cities'] as List),
      itineraryCount: json['itinerary_count'] as int,
    );
  }

  final String id;
  final String name;
  final String country;
  final String imageUrl;
  final String description;
  final List<String> cities;
  final int itineraryCount;

  Destination copyWith({
    String? id,
    String? name,
    String? country,
    String? imageUrl,
    String? description,
    List<String>? cities,
    int? itineraryCount,
  }) {
    return Destination(
      id: id ?? this.id,
      name: name ?? this.name,
      country: country ?? this.country,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      cities: cities ?? this.cities,
      itineraryCount: itineraryCount ?? this.itineraryCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'image_url': imageUrl,
      'description': description,
      'cities': cities,
      'itinerary_count': itineraryCount,
    };
  }
}
