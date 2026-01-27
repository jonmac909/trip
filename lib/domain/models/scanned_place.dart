/// Model for a place extracted by AI from social media content
class ScannedPlace {
  const ScannedPlace({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.confidence,
    this.description,
  });

  factory ScannedPlace.fromJson(Map<String, dynamic> json) {
    return ScannedPlace(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Place',
      category: json['category'] as String? ?? 'Attraction',
      location: json['location'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
      description: json['description'] as String?,
    );
  }

  final String id;
  final String name;
  final String category;
  final String location;
  final double confidence;
  final String? description;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'location': location,
      'confidence': confidence,
      'description': description,
    };
  }
}
