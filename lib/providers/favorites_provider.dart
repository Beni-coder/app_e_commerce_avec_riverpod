import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/services/favorites_storage.dart';

/// SharedPreferences instance, overridden in `main()` after initialization.
/// Throwing here ensures a clear failure if the override is ever forgotten.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main()',
  ),
);

/// Exposes the local favorites persistence layer.
final favoritesStorageProvider = Provider<FavoritesStorage>(
  (ref) => FavoritesStorage(ref.watch(sharedPreferencesProvider)),
);

/// State holding the set of favorite product ids, persisted locally.
class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier(this._storage) : super(const <String>{}) {
    // Load the persisted favorites synchronously from SharedPreferences.
    state = _storage.load();
  }

  final FavoritesStorage _storage;

  bool isFavorite(String productId) => state.contains(productId);

  void toggle(String productId) {
    final next = Set<String>.of(state);
    if (!next.add(productId)) {
      next.remove(productId);
    }
    state = next;
    _storage.save(next);
  }

  void add(String productId) {
    if (state.contains(productId)) return;
    final next = Set<String>.of(state)..add(productId);
    state = next;
    _storage.save(next);
  }

  void remove(String productId) {
    if (!state.contains(productId)) return;
    final next = Set<String>.of(state)..remove(productId);
    state = next;
    _storage.save(next);
  }

  void clear() {
    state = const <String>{};
    _storage.clear();
  }
}

/// The persisted favorites state (a set of product ids).
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>(
  (ref) => FavoritesNotifier(ref.watch(favoritesStorageProvider)),
);

/// Convenient per-product boolean provider used to render favorite buttons.
final isFavoriteProvider = Provider.family<bool, String>(
  (ref, productId) => ref.watch(favoritesProvider).contains(productId),
);

/// Number of favorited products, for badges and the favorites tab.
final favoritesCountProvider = Provider<int>(
  (ref) => ref.watch(favoritesProvider).length,
);
