import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/product_model.dart';
import '../../providers/filter_provider.dart';
import '../../providers/product_providers.dart';
import '../widgets/async_value_widget.dart';
import '../widgets/cart_badge.dart';
import '../widgets/filter_bar.dart';
import '../widgets/product_card.dart';

/// Main catalog screen: search, filters, sorting and the product grid.
class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key, required this.onOpenCart});

  final VoidCallback onOpenCart;

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openProduct(String id) {
    Navigator.of(context).pushNamed('/product', arguments: id);
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(filteredProductsProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Petit Nid',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: scheme.primary,
              ),
            ),
            Text(
              'Vetements de bebe',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          CartIconButton(onTap: widget.onOpenCart),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Search field.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) =>
                  ref.read(productFilterProvider.notifier).updateSearch(value),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Rechercher un article...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _searchController,
                  builder: (context, value, _) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        ref
                            .read(productFilterProvider.notifier)
                            .updateSearch('');
                      },
                    );
                  },
                ),
              ),
            ),
          ),
          const FilterBar(),
          const Divider(height: 1),
          // Product grid reacting to loading/error/data.
          Expanded(
            child: AsyncValueWidget<List<Product>>(
              value: productsAsync,
              onRetry: () => ref.invalidate(productsProvider),
              data: (products) {
                if (products.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.search_off_rounded,
                    title: 'Aucun resultat',
                    message:
                        'Essayez de modifier votre recherche ou vos filtres.',
                    actionLabel: 'Reinitialiser les filtres',
                    onAction: () =>
                        ref.read(productFilterProvider.notifier).reset(),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.66,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      onTap: () => _openProduct(product.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
