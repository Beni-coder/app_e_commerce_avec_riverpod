import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/product_model.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/product_providers.dart';
import '../widgets/async_value_widget.dart';
import '../widgets/product_card.dart';

/// Favorites screen: shows products the user has favorited (persisted).
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({
    super.key,
    required this.onOpenCatalog,
    required this.onOpenProduct,
  });

  final VoidCallback onOpenCatalog;
  final void Function(String productId) onOpenProduct;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes favoris'),
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorStateView(
          message: error.toString(),
          onRetry: () => ref.invalidate(productsProvider),
        ),
        data: (products) {
          if (favorites.isEmpty) {
            return EmptyStateView(
              icon: Icons.favorite_outline_rounded,
              title: 'Aucun favori',
              message:
                  'Touchez le coeur sur un article pour le retrouver ici.',
              actionLabel: 'Parcourir le catalogue',
              onAction: onOpenCatalog,
            );
          }
          final favorited = products
              .where((p) => favorites.contains(p.id))
              .toList(growable: false);
          if (favorited.isEmpty) {
            return EmptyStateView(
              icon: Icons.favorite_outline_rounded,
              title: 'Aucun favori',
              message:
                  'Touchez le coeur sur un article pour le retrouver ici.',
              actionLabel: 'Parcourir le catalogue',
              onAction: onOpenCatalog,
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.66,
            ),
            itemCount: favorited.length,
            itemBuilder: (context, index) {
              final Product product = favorited[index];
              return ProductCard(
                product: product,
                onTap: () => onOpenProduct(product.id),
              );
            },
          );
        },
      ),
    );
  }
}
