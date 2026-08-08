import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatters.dart';
import '../../data/models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/product_providers.dart';
import '../widgets/async_value_widget.dart';
import '../widgets/product_card.dart';
import '../widgets/product_visual.dart';
import '../widgets/rating_stars.dart';

/// Full product view with size/color selection and add-to-cart action.
class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedSize;
  String? _selectedColor;

  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  void _addToCart(Product product) {
    if (_selectedSize == null || _selectedColor == null) return;
    ref.read(cartProvider.notifier).add(
          product,
          size: _selectedSize!,
          color: _selectedColor!,
        );
    _bounce.forward(from: 0);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${product.name} ajoute au panier'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productByIdProvider(widget.productId));
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: AsyncValueWidget<Product>(
        value: productAsync,
        onRetry: () => ref.invalidate(productByIdProvider(widget.productId)),
        data: (product) {
          // Default selections once the product is available.
          _selectedSize ??= product.sizes.first;
          _selectedColor ??= product.colors.first;
          final isFavorite = ref.watch(isFavoriteProvider(product.id));

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircleAvatar(
                    backgroundColor:
                        Colors.white.withValues(alpha: 0.9),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withValues(alpha: 0.9),
                      child: IconButton(
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFavorite ? scheme.error : null,
                        ),
                        onPressed: () => ref
                            .read(favoritesProvider.notifier)
                            .toggle(product.id),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'product-visual-${product.id}',
                    child: ProductVisual(
                      product: product,
                      iconSize: 90,
                      borderRadius: const Radius.circular(0),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _DetailBody(
                  product: product,
                  selectedSize: _selectedSize!,
                  selectedColor: _selectedColor!,
                  onSelectSize: (s) => setState(() => _selectedSize = s),
                  onSelectColor: (c) => setState(() => _selectedColor = c),
                ),
              ),
              _RelatedSection(product: product, onTap: _pushReplacement),
            ],
          );
        },
      ),
      bottomNavigationBar: productAsync.maybeWhen(
        data: (product) => _AddToCartBar(
          product: product,
          bounce: _bounce,
          onAdd: () => _addToCart(product),
        ),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }

  void _pushReplacement(String id) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(productId: id),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.product,
    required this.selectedSize,
    required this.selectedColor,
    required this.onSelectSize,
    required this.onSelectColor,
  });

  final Product product;
  final String selectedSize;
  final String selectedColor;
  final ValueChanged<String> onSelectSize;
  final ValueChanged<String> onSelectColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: scheme.primary,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.name,
                      style: text.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          RatingStars(rating: product.rating, reviews: product.reviews, size: 16),
          const SizedBox(height: 16),
          _PriceBlock(product: product),
          const SizedBox(height: 20),
          Text(
            product.description,
            style: text.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          _InfoRow(label: 'Matiere', value: product.material),
          const Divider(height: 32),
          _OptionSection(
            label: 'Taille',
            options: product.sizes,
            selected: selectedSize,
            onSelected: onSelectSize,
          ),
          const SizedBox(height: 18),
          _OptionSection(
            label: 'Couleur',
            options: product.colors,
            selected: selectedColor,
            onSelected: onSelectColor,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _PriceBlock extends StatelessWidget {
  const _PriceBlock({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (!product.hasDiscount) {
      return Text(
        Formatters.price(product.price),
        style: TextStyle(
          fontSize: 26,
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
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: scheme.error,
          ),
        ),
        const SizedBox(width: 10),
        Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Text(
            Formatters.price(product.price),
            style: TextStyle(
              fontSize: 16,
              color: scheme.onSurfaceVariant,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: scheme.errorContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '-${product.discountPercent}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: scheme.onErrorContainer,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label : ',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

class _OptionSection extends StatelessWidget {
  const _OptionSection({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Text(
              selected,
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options)
              ChoiceChip(
                label: Text(option),
                selected: option == selected,
                showCheckmark: false,
                onSelected: (_) => onSelected(option),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: option == selected ? scheme.onPrimary : scheme.onSurface,
                ),
                selectedColor: scheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _RelatedSection extends StatelessWidget {
  const _RelatedSection({required this.product, required this.onTap});

  final Product product;
  final void Function(String id) onTap;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Consumer(
        builder: (context, ref, _) {
          final relatedAsync =
              ref.watch(relatedProductsProvider(product));
          return relatedAsync.when(
            data: (items) {
              if (items.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                      child: Text(
                        'Vous aimerez aussi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 270,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          final related = items[index];
                          return SizedBox(
                            width: 160,
                            child: ProductCard(
                              product: related,
                              onTap: () => onTap(related.id),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}

class _AddToCartBar extends StatelessWidget {
  const _AddToCartBar({
    required this.product,
    required this.bounce,
    required this.onAdd,
  });

  final Product product;
  final Animation<double> bounce;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: scheme.outlineVariant),
          ),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Prix',
                  style: TextStyle(
                    fontSize: 11,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  Formatters.price(product.discountedPrice),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ScaleTransition(
                scale: Tween<double>(begin: 1, end: 0.93).animate(
                  CurvedAnimation(parent: bounce, curve: Curves.elasticIn),
                ),
                child: FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_shopping_cart_rounded),
                  label: const Text('Ajouter au panier'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
