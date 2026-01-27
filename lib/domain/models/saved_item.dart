/// Saved item type enum
enum SavedItemType { place, itinerary, link }

/// Saved item model for user's saved places, itineraries, and links
class SavedItem {
  const SavedItem({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.url,
    required this.savedAt,
    this.city,
  });

  factory SavedItem.fromJson(Map<String, dynamic> json) {
    return SavedItem(
      id: json['id'] as String,
      type: SavedItemType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SavedItemType.place,
      ),
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      imageUrl: json['image_url'] as String?,
      url: json['url'] as String?,
      savedAt: DateTime.parse(json['saved_at'] as String),
      city: json['city'] as String?,
    );
  }

  final String id;
  final SavedItemType type;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final String? url;
  final DateTime savedAt;
  final String? city;

  SavedItem copyWith({
    String? id,
    SavedItemType? type,
    String? title,
    String? subtitle,
    String? imageUrl,
    String? url,
    DateTime? savedAt,
    String? city,
  }) {
    return SavedItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      url: url ?? this.url,
      savedAt: savedAt ?? this.savedAt,
      city: city ?? this.city,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'subtitle': subtitle,
      'image_url': imageUrl,
      'url': url,
      'saved_at': savedAt.toIso8601String(),
      'city': city,
    };
  }
}

/// Extension for saved item type display names
extension SavedItemTypeExtension on SavedItemType {
  String get displayName {
    switch (this) {
      case SavedItemType.place:
        return 'Place';
      case SavedItemType.itinerary:
        return 'Itinerary';
      case SavedItemType.link:
        return 'Link';
    }
  }
}
