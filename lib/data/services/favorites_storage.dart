import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's favorite product ids locally using SharedPreferences.
class FavoritesStorage {
  FavoritesStorage(this._prefs);

  final SharedPreferences _prefs;

  static const String _key = 'favorite_product_ids';

  /// Reads the persisted favorite ids. Returns an empty set when nothing is
  /// stored yet.
  Set<String> load() {
    final list = _prefs.getStringList(_key);
    return list == null ? <String>{} : list.toSet();
  }

  /// Persists the whole favorite set.
  Future<void> save(Set<String> ids) {
    return _prefs.setStringList(_key, ids.toList());
  }

  Future<void> clear() {
    return _prefs.remove(_key);
  }
}
