import 'package:flutter/material.dart';

import '../../core/categories.dart';
import '../../data/models/product_model.dart';

/// Offline-safe product visual: a soft gradient tile with a large category
/// icon. Reused by the catalog card, detail header and cart/favorites rows.
class ProductVisual extends StatelessWidget {
  const ProductVisual({
    super.key,
    required this.product,
    this.iconSize = 56,
    this.borderRadius = const Radius.circular(20),
  });

  final Product product;
  final double iconSize;
  final Radius borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = gradientForCategory(product.category);
    final icon = iconForCategory(product.category);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.all(borderRadius),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              icon,
              size: iconSize,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          // Subtle decorative circle.
          Positioned(
            right: -16,
            top: -16,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
