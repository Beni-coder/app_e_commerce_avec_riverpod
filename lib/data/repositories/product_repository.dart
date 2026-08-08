import 'dart:math';

import '../datasources/products_data.dart';
import '../models/product_model.dart';

/// Repository in charge of fetching products.
///
/// In a real app this would talk to an HTTP client; here it returns the local
/// mock [ProductsData] after a simulated network latency so the UI can exercise
/// real loading and error states via [AsyncValue].
class ProductRepository {
  const ProductRepository();

  static const Duration _latency = Duration(milliseconds: 800);

  Future<List<Product>> fetchProducts() async {
    await Future.delayed(_latency);
    final raw = ProductsData.rawProducts;
    return raw.map(Product.fromJson).toList(growable: false);
  }

  Future<Product> fetchById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final json = ProductsData.rawProducts.firstWhere(
      (e) => e['id'] == id,
      orElse: () => throw StateError('Product $id not found'),
    );
    return Product.fromJson(json);
  }

  /// Returns a handful of suggested products for a given one, used on the
  /// detail screen as "you may also like".
  Future<List<Product>> fetchRelated(Product product, {int count = 4}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final all = ProductsData.rawProducts.map(Product.fromJson).toList();
    final pool = all
        .where((p) => p.id != product.id && p.category == product.category)
        .toList();
    // Pad with items from other categories if not enough same-category ones.
    if (pool.length < count) {
      pool.addAll(
        all.where((p) => p.id != product.id && p.category != product.category),
      );
    }
    final random = Random(product.id.hashCode);
    pool.shuffle(random);
    return pool.take(count).toList(growable: false);
  }
}
