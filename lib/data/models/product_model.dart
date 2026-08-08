import 'package:equatable/equatable.dart';

/// A baby clothing product.
///
/// Immutable value object. Equality is based on the full field set so that
/// StateNotifier states can be diffed correctly and the same product in a
/// [CartItem] reflects discount changes.
class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.sizes,
    required this.colors,
    required this.rating,
    required this.reviews,
    required this.material,
    this.isNew = false,
    this.discountPercent = 0,
    this.addedAt = 0,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final List<String> sizes;
  final List<String> colors;
  final double rating;
  final int reviews;
  final String material;
  final bool isNew;
  final int discountPercent;
  final int addedAt;

  /// Effective price after the optional discount.
  double get discountedPrice =>
      discountPercent > 0 ? price * (100 - discountPercent) / 100 : price;

  /// Convenience flag used to display the "promo" badge.
  bool get hasDiscount => discountPercent > 0;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String,
      sizes: (json['sizes'] as List).cast<String>(),
      colors: (json['colors'] as List).cast<String>(),
      rating: (json['rating'] as num).toDouble(),
      reviews: (json['reviews'] as num).toInt(),
      material: json['material'] as String,
      isNew: (json['isNew'] as bool?) ?? false,
      discountPercent: (json['discountPercent'] as num?)?.toInt() ?? 0,
      addedAt: (json['addedAt'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'category': category,
        'sizes': sizes,
        'colors': colors,
        'rating': rating,
        'reviews': reviews,
        'material': material,
        'isNew': isNew,
        'discountPercent': discountPercent,
        'addedAt': addedAt,
      };

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        category,
        sizes,
        colors,
        rating,
        reviews,
        material,
        isNew,
        discountPercent,
        addedAt,
      ];
}
