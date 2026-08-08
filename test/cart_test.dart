import 'package:flutter_test/flutter_test.dart';

import 'package:app_e_commerce_avec_riverpod/data/models/product_model.dart';
import 'package:app_e_commerce_avec_riverpod/providers/cart_provider.dart';

Product _product(String id) => Product(
      id: id,
      name: 'Article $id',
      description: 'desc',
      price: 10,
      category: 'Cat',
      sizes: const ['S', 'M'],
      colors: const ['Red', 'Blue'],
      rating: 4.5,
      reviews: 10,
      material: 'coton',
    );

void main() {
  group('CartNotifier', () {
    test('adds a new line', () {
      final cart = CartNotifier();
      cart.add(_product('1'), size: 'S', color: 'Red');
      expect(cart.state.length, 1);
      expect(cart.state.first.quantity, 1);
    });

    test('merges identical product/size/color into one line', () {
      final cart = CartNotifier();
      cart.add(_product('1'), size: 'S', color: 'Red');
      cart.add(_product('1'), size: 'S', color: 'Red');
      expect(cart.state.length, 1);
      expect(cart.state.first.quantity, 2);
    });

    test('treats different size/color as separate lines', () {
      final cart = CartNotifier();
      cart.add(_product('1'), size: 'S', color: 'Red');
      cart.add(_product('1'), size: 'M', color: 'Red');
      cart.add(_product('1'), size: 'S', color: 'Blue');
      expect(cart.state.length, 3);
    });

    test('increment and decrement adjust quantity', () {
      final cart = CartNotifier();
      cart.add(_product('1'), size: 'S', color: 'Red');
      final lineId = cart.state.first.lineId;
      cart.increment(lineId);
      expect(cart.state.first.quantity, 2);
      cart.decrement(lineId);
      expect(cart.state.first.quantity, 1);
    });

    test('decrement removes the line when quantity reaches zero', () {
      final cart = CartNotifier();
      cart.add(_product('1'), size: 'S', color: 'Red');
      final lineId = cart.state.first.lineId;
      cart.decrement(lineId);
      expect(cart.state, isEmpty);
    });

    test('removeLine removes only the targeted line', () {
      final cart = CartNotifier();
      cart.add(_product('1'), size: 'S', color: 'Red');
      cart.add(_product('2'), size: 'S', color: 'Red');
      final firstId = cart.state.first.lineId;
      cart.removeLine(firstId);
      expect(cart.state.length, 1);
      expect(cart.state.first.product.id, '2');
    });

    test('clear empties the cart', () {
      final cart = CartNotifier();
      cart.add(_product('1'), size: 'S', color: 'Red');
      cart.clear();
      expect(cart.state, isEmpty);
    });

    test('lineTotal accounts for discounts', () {
      final cart = CartNotifier();
      final product = Product(
        id: '1',
        name: 'Solded',
        description: 'd',
        price: 100,
        category: 'Cat',
        sizes: const ['S'],
        colors: const ['Red'],
        rating: 4,
        reviews: 1,
        material: 'coton',
        discountPercent: 20,
      );
      cart.add(product, size: 'S', color: 'Red', quantity: 2);
      // 100 - 20% = 80 per unit, times 2 = 160.
      expect(cart.state.first.lineTotal, 160);
    });
  });
}
