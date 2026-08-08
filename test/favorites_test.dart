import 'package:flutter_test/flutter_test.dart';

import 'package:app_e_commerce_avec_riverpod/data/services/favorites_storage.dart';
import 'package:app_e_commerce_avec_riverpod/providers/favorites_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('FavoritesStorage', () {
    test('loads empty by default', () async {
      final prefs = await SharedPreferences.getInstance();
      final storage = FavoritesStorage(prefs);
      expect(storage.load(), isEmpty);
    });

    test('persists a save/load round trip', () async {
      final prefs = await SharedPreferences.getInstance();
      final storage = FavoritesStorage(prefs);
      await storage.save({'a', 'b'});
      final reloaded = FavoritesStorage(prefs);
      expect(reloaded.load(), {'a', 'b'});
    });
  });

  group('FavoritesNotifier', () {
    test('toggle adds and removes ids', () async {
      final prefs = await SharedPreferences.getInstance();
      final notifier = FavoritesNotifier(FavoritesStorage(prefs));
      notifier.toggle('x');
      expect(notifier.state, {'x'});
      notifier.toggle('x');
      expect(notifier.state, isEmpty);
    });

    test('state is restored from a new notifier instance (persistence)',
        () async {
      final prefs = await SharedPreferences.getInstance();
      var notifier = FavoritesNotifier(FavoritesStorage(prefs));
      notifier.add('p1');
      notifier.add('p2');
      expect(notifier.state, {'p1', 'p2'});

      // Simulate an app restart by creating a fresh notifier/storage.
      notifier = FavoritesNotifier(FavoritesStorage(prefs));
      expect(notifier.state, {'p1', 'p2'});
    });
  });
}
