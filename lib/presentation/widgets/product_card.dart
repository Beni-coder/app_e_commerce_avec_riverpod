import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatters.dart';
import '../../data/models/product_model.dart';
import '../../providers/favorites_provider.dart';
import 'product_visual.dart';
import 'rating_stars.dart';

/// A single product shown in the catalog grid.
class ProductCard extends ConsumerWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isFavorite = ref.watch(isFavoriteProvider(product.id));

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Visual area with badges and favorite button.
            Expanded(
              child: Stack(
                children: [
                  Hero(
                    tag: 'product-visual-${product.id}',
                    child: ProductVisual(
                      product: product,
                      borderRadius: const Radius.circular(0),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _Badge(product: product),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: _FavoriteButton(
                      productId: product.id,
                      isFavorite: isFavorite,
                    ),
                  ),
                ],
              ),
            ),
            // Text area.
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  RatingStars(
                    rating: product.rating,
                    reviews: product.reviews,
                    size: 12,
                  ),
                  const SizedBox(height: 8),
                  _PriceRow(product: product),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    if (product.isNew && product.hasDiscount) {
      return Wrap(
        spacing: 4,
        children: const [
          _Pill(label: 'Nouveau', color: Colors.black87),
        ],
      );
    }
    if (product.isNew) {
      return const _Pill(label: 'Nouveau', color: Colors.black87);
    }
    if (product.hasDiscount) {
      return _Pill(
        label: '-${product.discountPercent}%',
        color: Theme.of(context).colorScheme.error,
      );
    }
    return const SizedBox.shrink();
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _FavoriteButton extends ConsumerWidget {
  const _FavoriteButton({required this.productId, required this.isFavorite});

  final String productId;
  final bool isFavorite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.white.withValues(alpha: 0.85),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => ref.read(favoritesProvider.notifier).toggle(productId),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: 18,
            color: isFavorite ? scheme.error : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (!product.hasDiscount) {
      return Text(
        Formatters.price(product.price),
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
        ),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          Formatters.price(product.discountedPrice),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: scheme.error,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          Formatters.price(product.price),
          style: TextStyle(
            fontSize: 12,
            color: scheme.onSurfaceVariant,
            decoration: TextDecoration.lineThrough,
          ),
        ),
      ],
    );
  }
}
