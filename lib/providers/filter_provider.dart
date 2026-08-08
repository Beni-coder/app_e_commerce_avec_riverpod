import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Available sort criteria for the catalog.
enum SortOption {
  newest('Nouveautes'),
  priceAsc('Prix croissant'),
  priceDesc('Prix decroissant'),
  nameAsc('Nom (A-Z)'),
  ratingDesc('Mieux notes');

  const SortOption(this.label);
  final String label;
}

/// Immutable filter/sort state applied to the product catalog.
class ProductFilter extends Equatable {
  const ProductFilter({
    this.category,
    this.searchQuery = '',
    this.sort = SortOption.newest,
    this.maxPrice = 100,
    this.onlyInStock = true,
  });

  /// `null` means "all categories".
  final String? category;
  final String searchQuery;
  final SortOption sort;
  final double maxPrice;
  final bool onlyInStock;

  /// Sentinel used by the "all categories" filter chip.
  static const String allLabel = 'Tous';

  ProductFilter copyWith({
    Object? category = _sentinel,
    String? searchQuery,
    SortOption? sort,
    double? maxPrice,
    bool? onlyInStock,
  }) {
    return ProductFilter(
      category: identical(category, _sentinel) ? this.category : category as String?,
      searchQuery: searchQuery ?? this.searchQuery,
      sort: sort ?? this.sort,
      maxPrice: maxPrice ?? this.maxPrice,
      onlyInStock: onlyInStock ?? this.onlyInStock,
    );
  }

  bool get hasActiveFilters =>
      category != null || searchQuery.isNotEmpty || maxPrice < 100;

  @override
  List<Object?> get props => [category, searchQuery, sort, maxPrice, onlyInStock];
}

const Object _sentinel = Object();

/// Holds and mutates the catalog [ProductFilter] state.
class ProductFilterNotifier extends StateNotifier<ProductFilter> {
  ProductFilterNotifier() : super(const ProductFilter());

  void selectCategory(String? category) =>
      state = state.copyWith(category: category);

  void updateSearch(String query) =>
      state = state.copyWith(searchQuery: query.toLowerCase().trim());

  void updateSort(SortOption sort) => state = state.copyWith(sort: sort);

  void updateMaxPrice(double value) =>
      state = state.copyWith(maxPrice: value);

  void reset() => state = const ProductFilter();
}

/// Filter/sort state provider for the catalog screen.
final productFilterProvider =
    StateNotifierProvider<ProductFilterNotifier, ProductFilter>(
  (ref) => ProductFilterNotifier(),
);
