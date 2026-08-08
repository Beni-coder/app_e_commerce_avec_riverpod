import 'package:flutter_test/flutter_test.dart';

import 'package:app_e_commerce_avec_riverpod/providers/filter_provider.dart';

void main() {
  group('ProductFilter defaults', () {
    test('has no category, empty search and newest sort', () {
      const filter = ProductFilter();
      expect(filter.category, isNull);
      expect(filter.searchQuery, isEmpty);
      expect(filter.sort, SortOption.newest);
      expect(filter.hasActiveFilters, isFalse);
    });

    test('selecting a category marks filters as active', () {
      final notifier = ProductFilterNotifier();
      notifier.selectCategory('Robes');
      expect(notifier.state.category, 'Robes');
      expect(notifier.state.hasActiveFilters, isTrue);
    });

    test('search query is trimmed and lowercased', () {
      final notifier = ProductFilterNotifier();
      notifier.updateSearch('  Robe D\'ete  ');
      expect(notifier.state.searchQuery, "robe d'ete");
    });

    test('updateSort changes the active sort option', () {
      final notifier = ProductFilterNotifier();
      notifier.updateSort(SortOption.priceDesc);
      expect(notifier.state.sort, SortOption.priceDesc);
    });

    test('reset restores the defaults', () {
      final notifier = ProductFilterNotifier()
        ..selectCategory('Pyjamas')
        ..updateSearch('xyz');
      notifier.reset();
      expect(notifier.state.category, isNull);
      expect(notifier.state.searchQuery, isEmpty);
      expect(notifier.state.hasActiveFilters, isFalse);
    });

    test('every SortOption exposes a human label', () {
      for (final option in SortOption.values) {
        expect(option.label.isNotEmpty, isTrue);
      }
    });
  });
}
