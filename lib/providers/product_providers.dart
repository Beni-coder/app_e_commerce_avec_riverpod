import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/categories.dart';
import '../data/models/product_model.dart';
import '../data/repositories/product_repository.dart';
import 'filter_provider.dart';

/// Exposes the product repository to the rest of the app.
final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => const ProductRepository(),
);

/// Asynchronously loads the full product catalog. Exposed as a
/// [FutureProvider] so the UI can react to loading/error/data via [AsyncValue].
final productsProvider = FutureProvider<List<Product>>(
  (ref) => ref.watch(productRepositoryProvider).fetchProducts(),
);

/// Loads a single product by id (used on the detail screen).
final productByIdProvider =
    FutureProvider.family<Product, String>((ref, id) {
  return ref.watch(productRepositoryProvider).fetchById(id);
});

/// Loads "related" suggestions for a given product.
final relatedProductsProvider =
    FutureProvider.family<List<Product>, Product>((ref, product) {
  return ref.watch(productRepositoryProvider).fetchRelated(product);
});

/// Static list of catalog categories, available synchronously.
final categoriesProvider = Provider<List<String>>(
  (ref) => AppCategories.all,
);

/// Applies the current [ProductFilter] to the catalog, while preserving the
/// async lifecycle of the underlying [productsProvider].
///
/// Uses [AsyncValue.whenData] so loading and error states bubble up unchanged.
final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productsAsync = ref.watch(productsProvider);
  final filter = ref.watch(productFilterProvider);
  return productsAsync.whenData((products) => _applyFilter(products, filter));
});

List<Product> _applyFilter(List<Product> products, ProductFilter filter) {
  Iterable<Product> result = products;

  if (filter.category != null) {
    result = result.where((p) => p.category == filter.category);
  }

  if (filter.searchQuery.isNotEmpty) {
    final query = filter.searchQuery;
    result = result.where(
      (p) =>
          p.name.toLowerCase().contains(query) ||
          p.description.toLowerCase().contains(query) ||
          p.category.toLowerCase().contains(query),
    );
  }

  result = result.where((p) => p.discountedPrice <= filter.maxPrice);

  switch (filter.sort) {
    case SortOption.newest:
      result = result.toList()
        ..sort((a, b) {
          final byNew = (b.isNew ? 1 : 0).compareTo(a.isNew ? 1 : 0);
          if (byNew != 0) return byNew;
          return b.addedAt.compareTo(a.addedAt);
        });
      break;
    case SortOption.priceAsc:
      result = result.toList()
        ..sort((a, b) => a.discountedPrice.compareTo(b.discountedPrice));
      break;
    case SortOption.priceDesc:
      result = result.toList()
        ..sort((a, b) => b.discountedPrice.compareTo(a.discountedPrice));
      break;
    case SortOption.nameAsc:
      result = result.toList()..sort((a, b) => a.name.compareTo(b.name));
      break;
    case SortOption.ratingDesc:
      result = result.toList()..sort((a, b) => b.rating.compareTo(a.rating));
      break;
  }

  return result.toList(growable: false);
}

/// Largest discounted price in the catalog, used to set the filter slider range.
final maxCatalogPriceProvider = Provider<double>((ref) {
  final products = ref.watch(productsProvider).valueOrNull ?? const <Product>[];
  if (products.isEmpty) return 100;
  return products
      .map((p) => p.discountedPrice)
      .reduce((a, b) => a > b ? a : b);
});
