import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trippified/data/repositories/saved_repository.dart';
import 'package:trippified/domain/models/scanned_place.dart';

/// Provider for SavedRepository
final savedRepositoryProvider = Provider<SavedRepository>((ref) {
  return SavedRepository();
});

/// Provider for fetching all saved items
final savedItemsProvider =
    FutureProvider.family<List<SavedItem>, SavedItemType?>((ref, type) async {
      final repository = ref.watch(savedRepositoryProvider);
      return repository.getSavedItems(type: type);
    });

/// Provider for checking if an item is saved
final isItemSavedProvider = FutureProvider.family<bool, String>((
  ref,
  itemId,
) async {
  final repository = ref.watch(savedRepositoryProvider);
  return repository.isItemSaved(itemId);
});

/// Notifier for managing saved items
class SavedItemsNotifier extends StateNotifier<AsyncValue<List<SavedItem>>> {
  SavedItemsNotifier(this._repository) : super(const AsyncValue.data([]));

  final SavedRepository _repository;

  /// Load saved items
  Future<void> loadSavedItems({SavedItemType? type}) async {
    state = const AsyncValue.loading();
    try {
      final items = await _repository.getSavedItems(type: type);
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Save an item
  Future<SavedItem?> saveItem({
    required SavedItemType type,
    required String itemId,
    required String title,
    String? description,
    String? imageUrl,
    Map<String, dynamic>? metadata,
    String? sourceUrl,
  }) async {
    try {
      final savedItem = await _repository.saveItem(
        type: type,
        itemId: itemId,
        title: title,
        description: description,
        imageUrl: imageUrl,
        metadata: metadata,
        sourceUrl: sourceUrl,
      );

      // Update state with new item
      state = AsyncValue.data([savedItem, ...state.value ?? []]);
      return savedItem;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Unsave an item
  Future<bool> unsaveItem(String savedItemId) async {
    try {
      await _repository.unsaveItem(savedItemId);

      // Update state
      final items = state.value ?? [];
      items.removeWhere((i) => i.id == savedItemId);
      state = AsyncValue.data([...items]);

      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Save scanned places from social media import
  Future<List<SavedItem>> saveScanResults({
    required List<ScannedPlace> places,
    String? sourceUrl,
  }) async {
    try {
      final imported = await _repository.saveScanResults(
        places: places,
        sourceUrl: sourceUrl,
      );

      // Update state with imported items
      state = AsyncValue.data([...imported, ...state.value ?? []]);
      return imported;
    } catch (e) {
      return [];
    }
  }
}

/// Provider for saved items notifier
final savedItemsNotifierProvider =
    StateNotifierProvider<SavedItemsNotifier, AsyncValue<List<SavedItem>>>((
      ref,
    ) {
      final repository = ref.watch(savedRepositoryProvider);
      return SavedItemsNotifier(repository);
    });
