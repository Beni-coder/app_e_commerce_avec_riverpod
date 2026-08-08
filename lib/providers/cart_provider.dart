import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/cart_item_model.dart';
import '../data/models/product_model.dart';

/// State holding the shopping cart: an ordered list of [CartItem]s.
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super(const []);

  /// Adds a product to the cart, merging into an existing line when the
  /// product + size + color combination already exists.
  void add(Product product, {required String size, required String color, int quantity = 1}) {
    final lineId = '${product.id}|$size|$color';
    final existingIndex = state.indexWhere((item) => item.lineId == lineId);

    List<CartItem> next;
    if (existingIndex >= 0) {
      next = List<CartItem>.of(state);
      final current = next[existingIndex];
      next[existingIndex] = current.copyWith(quantity: current.quantity + quantity);
    } else {
      next = [
        ...state,
        CartItem(product: product, size: size, color: color, quantity: quantity),
      ];
    }
    state = next;
  }

  void increment(String lineId) {
    state = [
      for (final item in state)
        if (item.lineId == lineId)
          item.copyWith(quantity: item.quantity + 1)
        else
          item,
    ];
  }

  void decrement(String lineId) {
    state = [
      for (final item in state)
        if (item.lineId == lineId)
          item.copyWith(quantity: item.quantity - 1)
        else
          item,
    ].where((item) => item.quantity > 0).toList();
  }

  void setQuantity(String lineId, int quantity) {
    if (quantity <= 0) {
      removeLine(lineId);
      return;
    }
    state = [
      for (final item in state)
        if (item.lineId == lineId) item.copyWith(quantity: quantity) else item,
    ];
  }

  void removeLine(String lineId) {
    state = state.where((item) => item.lineId != lineId).toList();
  }

  void clear() => state = const [];
}

/// The shopping cart state.
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) => CartNotifier(),
);

/// Total number of individual units in the cart.
final cartItemCountProvider = Provider<int>(
  (ref) => ref.watch(cartProvider).fold(0, (sum, item) => sum + item.quantity),
);

/// Sum of the discounted line totals (before shipping).
final cartSubtotalProvider = Provider<double>(
  (ref) => ref
      .watch(cartProvider)
      .fold(0.0, (sum, item) => sum + item.lineTotal),
);

/// Threshold above which shipping becomes free.
const double freeShippingThreshold = 60.0;
const double shippingFee = 4.90;

/// Flat shipping cost, free once the subtotal reaches the threshold.
final shippingProvider = Provider<double>((ref) {
  final subtotal = ref.watch(cartSubtotalProvider);
  if (subtotal <= 0) return 0;
  return subtotal >= freeShippingThreshold ? 0 : shippingFee;
});

/// Grand total to pay.
final cartTotalProvider = Provider<double>(
  (ref) => ref.watch(cartSubtotalProvider) + ref.watch(shippingProvider),
);

/// Remaining amount before free shipping is unlocked (0 when already unlocked).
final freeShippingRemainingProvider = Provider<double>((ref) {
  final subtotal = ref.watch(cartSubtotalProvider);
  if (subtotal >= freeShippingThreshold || subtotal <= 0) return 0;
  return freeShippingThreshold - subtotal;
});
