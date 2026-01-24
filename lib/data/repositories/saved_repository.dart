import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:trippified/core/errors/exceptions.dart';
import 'package:trippified/core/services/supabase_service.dart';

/// Repository for saved items (places, itineraries, social imports)
class SavedRepository {
  SavedRepository({SupabaseClient? client})
    : _client = client ?? SupabaseService.instance.client;

  final SupabaseClient _client;

  /// Get all saved items for the current user
  Future<List<SavedItem>> getSavedItems({
    SavedItemType? type,
    int limit = 50,
    int offset = 0,
  }) async {
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
          .map((json) => SavedItem.fromJson(json))
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
    try {
      await _client.from('saved_items').delete().eq('id', savedItemId);
    } on PostgrestException catch (e) {
      throw DatabaseException('Failed to remove saved item: ${e.message}');
    }
  }

  /// Check if an item is saved
  Future<bool> isItemSaved(String itemId) async {
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

  /// Import from social media URL (calls edge function)
  Future<List<SavedItem>> importFromSocialMedia(String url) async {
    try {
      // This would call a Supabase Edge Function that uses AI to extract places
      // For now, return empty list
      return [];
    } catch (e) {
      throw ExternalServiceException('Failed to import from social media: $e');
    }
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
