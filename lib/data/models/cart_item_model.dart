import 'package:equatable/equatable.dart';

import 'product_model.dart';

/// A line in the shopping cart: a [product] combined with a chosen
/// [size] and [color] and a [quantity].
///
/// The same product in different sizes/colors forms distinct lines, hence
/// [lineId] is composed of those three parts.
class CartItem extends Equatable {
  const CartItem({
    required this.product,
    required this.size,
    required this.color,
    required this.quantity,
  });

  final Product product;
  final String size;
  final String color;
  final int quantity;

  String get lineId => '${product.id}|$size|$color';

  double get lineTotal => product.discountedPrice * quantity;

  CartItem copyWith({
    Product? product,
    String? size,
    String? color,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      size: size ?? this.size,
      color: color ?? this.color,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [product.id, size, color, quantity];
}
