import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:trippified/core/config/env_config.dart';
import 'package:trippified/core/errors/exceptions.dart';
import 'package:trippified/core/services/supabase_service.dart';
import 'package:trippified/domain/models/scanned_place.dart';

/// Repository for saved items (places, itineraries, social imports)
class SavedRepository {
  SavedRepository({SupabaseClient? client})
    : _client = EnvConfig.isConfigured
          ? (client ?? SupabaseService.instance.client)
          : null;

  final SupabaseClient? _client;

  /// In-memory store for demo mode (no Supabase)
  static final List<SavedItem> _memoryStore = [];

  /// Get all saved items for the current user
  Future<List<SavedItem>> getSavedItems({
    SavedItemType? type,
    int limit = 50,
    int offset = 0,
  }) async {
    if (_client == null) {
      if (type == null) return List.unmodifiable(_memoryStore);
      return _memoryStore.where((i) => i.itemType == type).toList();
    }

    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const UnauthorizedException('User not authenticated');
      }

      var query = _client.from('saved_items').select().eq('user_id', userId);

      if (type != null) {
        query = query.eq('item_type', type.name);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => SavedItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw DatabaseException('Failed to fetch saved items: ${e.message}');
    }
  }

  /// Save an item
  Future<SavedItem> saveItem({
    required SavedItemType type,
    required String itemId,
    required String title,
    String? description,
    String? imageUrl,
    Map<String, dynamic>? metadata,
    String? sourceUrl,
  }) async {
    if (_client == null) {
      final item = SavedItem(
        id: const Uuid().v4(),
        userId: 'demo',
        itemType: type,
        itemId: itemId,
        title: title,
        description: description,
        imageUrl: imageUrl,
        metadata: metadata,
        sourceUrl: sourceUrl,
        createdAt: DateTime.now(),
      );
      _memoryStore.insert(0, item);
      return item;
    }

    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const UnauthorizedException('User not authenticated');
      }

      final response = await _client
          .from('saved_items')
          .insert({
            'user_id': userId,
            'item_type': type.name,
            'item_id': itemId,
            'title': title,
            'description': description,
            'image_url': imageUrl,
            'metadata': metadata,
            'source_url': sourceUrl,
          })
          .select()
          .single();

      return SavedItem.fromJson(response);
    } on PostgrestException catch (e) {
      throw DatabaseException('Failed to save item: ${e.message}');
    }
  }

  /// Remove a saved item
  Future<void> unsaveItem(String savedItemId) async {
    if (_client == null) {
      _memoryStore.removeWhere((i) => i.id == savedItemId);
      return;
    }

    try {
      await _client.from('saved_items').delete().eq('id', savedItemId);
    } on PostgrestException catch (e) {
      throw DatabaseException('Failed to remove saved item: ${e.message}');
    }
  }

  /// Check if an item is saved
  Future<bool> isItemSaved(String itemId) async {
    if (_client == null) {
      return _memoryStore.any((i) => i.itemId == itemId);
    }

    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return false;

      final response = await _client
          .from('saved_items')
          .select('id')
          .eq('user_id', userId)
          .eq('item_id', itemId)
          .limit(1);

      return (response as List).isNotEmpty;
    } on PostgrestException {
      return false;
    }
  }

  /// Save scanned places from social media import
  Future<List<SavedItem>> saveScanResults({
    required List<ScannedPlace> places,
    String? sourceUrl,
  }) async {
    final savedItems = <SavedItem>[];
    for (final place in places) {
      final item = await saveItem(
        type: SavedItemType.socialImport,
        itemId: place.id,
        title: place.name,
        description: '${place.category} - ${place.location}',
        metadata: {
          'category': place.category,
          'location': place.location,
          'confidence': place.confidence,
          'source_url': sourceUrl,
        },
        sourceUrl: sourceUrl,
      );
      savedItems.add(item);
    }
    return savedItems;
  }
}

/// Saved item model
class SavedItem {
  factory SavedItem.fromJson(Map<String, dynamic> json) {
    return SavedItem(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      itemType: SavedItemType.values.firstWhere(
        (e) => e.name == json['item_type'],
        orElse: () => SavedItemType.place,
      ),
      itemId: json['item_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      sourceUrl: json['source_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
  const SavedItem({
    required this.id,
    required this.userId,
    required this.itemType,
    required this.itemId,
    required this.title,
    this.description,
    this.imageUrl,
    this.metadata,
    this.sourceUrl,
    this.createdAt,
  });

  final String id;
  final String userId;
  final SavedItemType itemType;
  final String itemId;
  final String title;
  final String? description;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;
  final String? sourceUrl;
  final DateTime? createdAt;

  SavedItem copyWith({
    String? id,
    String? userId,
    SavedItemType? itemType,
    String? itemId,
    String? title,
    String? description,
    String? imageUrl,
    Map<String, dynamic>? metadata,
    String? sourceUrl,
    DateTime? createdAt,
  }) {
    return SavedItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      itemType: itemType ?? this.itemType,
      itemId: itemId ?? this.itemId,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      metadata: metadata ?? this.metadata,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'item_type': itemType.name,
      'item_id': itemId,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'metadata': metadata,
      'source_url': sourceUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

/// Saved item type enum
enum SavedItemType { place, itinerary, activity, socialImport }
