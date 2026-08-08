import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatters.dart';
import '../../data/models/cart_item_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/profile_provider.dart';
import '../widgets/async_value_widget.dart';
import '../widgets/product_visual.dart';
import '../widgets/qty_stepper.dart';

/// Shopping cart screen: line items, quantity controls, totals and a mock
/// checkout action.
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key, required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mon panier')),
      body: items.isEmpty
          ? EmptyStateView(
              icon: Icons.shopping_bag_outlined,
              title: 'Votre panier est vide',
              message: 'Decouvrez notre collection de vetements de bebe.',
              actionLabel: 'Voir le catalogue',
              onAction: onBrowse,
            )
          : _CartList(items: items),
      bottomNavigationBar: items.isEmpty
          ? null
          : _CartSummary(onCheckout: () => _checkout(context, ref)),
    );
  }

  void _checkout(BuildContext context, WidgetRef ref) {
    ref.read(cartProvider.notifier).clear();
    ref.read(profileProvider.notifier).addLoyaltyPoints(15);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Commande confirmee. Merci !'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
  }
}

class _CartList extends ConsumerWidget {
  const _CartList({required this.items});

  final List<CartItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return Dismissible(
          key: ValueKey(item.lineId),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
          ),
          onDismissed: (_) {
            ref.read(cartProvider.notifier).removeLine(item.lineId);
          },
          child: _CartLine(item: item),
        );
      },
    );
  }
}

class _CartLine extends ConsumerWidget {
  const _CartLine({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 72,
                height: 72,
                child: ProductVisual(
                  product: item.product,
                  iconSize: 30,
                  borderRadius: const Radius.circular(14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    children: [
                      _Chip('Taille ${item.size}'),
                      _Chip(item.color),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      QtyStepper(
                        quantity: item.quantity,
                        onDecrement: () => ref
                            .read(cartProvider.notifier)
                            .decrement(item.lineId),
                        onIncrement: () => ref
                            .read(cartProvider.notifier)
                            .increment(item.lineId),
                      ),
                      const Spacer(),
                      Text(
                        Formatters.price(item.lineTotal),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: scheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
      ),
    );
  }
}

class _CartSummary extends ConsumerWidget {
  const _CartSummary({required this.onCheckout});

  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtotal = ref.watch(cartSubtotalProvider);
    final shipping = ref.watch(shippingProvider);
    final total = ref.watch(cartTotalProvider);
    final remaining = ref.watch(freeShippingRemainingProvider);
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: scheme.outlineVariant)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (remaining > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _FreeShippingNotice(remaining: remaining),
              ),
            _SummaryLine(label: 'Sous-total', value: Formatters.price(subtotal)),
            const SizedBox(height: 6),
            _SummaryLine(
              label: 'Livraison',
              value: shipping == 0 ? 'Offerte' : Formatters.price(shipping),
              valueColor: shipping == 0 ? scheme.primary : null,
            ),
            const Divider(height: 24),
            _SummaryLine(
              label: 'Total',
              value: Formatters.price(total),
              emphasize: true,
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onCheckout,
              icon: const Icon(Icons.lock_outline_rounded),
              label: const Text('Passer la commande'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FreeShippingNotice extends StatelessWidget {
  const _FreeShippingNotice({required this.remaining});

  final double remaining;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.local_shipping_rounded, size: 18, color: scheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Plus que ${Formatters.price(remaining)} pour la livraison offerte !',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: scheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.value,
    this.emphasize = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool emphasize;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: emphasize ? 16 : 14,
            fontWeight: emphasize ? FontWeight.w800 : FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: emphasize ? 18 : 14,
            fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
