import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatters.dart';
import '../../providers/filter_provider.dart';
import '../../providers/product_providers.dart';

/// Sticky catalog controls: category chips, sort menu and a collapsible
/// price filter. Reads/writes the [productFilterProvider] state.
class FilterBar extends ConsumerStatefulWidget {
  const FilterBar({super.key});

  @override
  ConsumerState<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends ConsumerState<FilterBar> {
  bool _priceExpanded = false;

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(productFilterProvider);
    final categories = ref.watch(categoriesProvider);
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Category chips.
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _CategoryChip(
                  label: ProductFilter.allLabel,
                  selected: filter.category == null,
                  onTap: () =>
                      ref.read(productFilterProvider.notifier).selectCategory(null),
                );
              }
              final category = categories[index - 1];
              return _CategoryChip(
                label: category,
                selected: filter.category == category,
                onTap: () => ref
                    .read(productFilterProvider.notifier)
                    .selectCategory(category),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Sort + price toggle row.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              PopupMenuButton<SortOption>(
                initialValue: filter.sort,
                onSelected: (value) =>
                    ref.read(productFilterProvider.notifier).updateSort(value),
                itemBuilder: (context) => [
                  for (final option in SortOption.values)
                    PopupMenuItem(
                      value: option,
                      child: Row(
                        children: [
                          if (filter.sort == option)
                            Icon(
                              Icons.check_rounded,
                              size: 18,
                              color: scheme.primary,
                            )
                          else
                            const SizedBox(width: 18),
                          const SizedBox(width: 8),
                          Text(option.label),
                        ],
                      ),
                    ),
                ],
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sort_rounded, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        filter.sort.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down_rounded, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ActionChip(
                onPressed: () =>
                    setState(() => _priceExpanded = !_priceExpanded),
                avatar: Icon(
                  Icons.tune_rounded,
                  size: 16,
                  color: filter.hasActiveFilters
                      ? scheme.onPrimary
                      : scheme.onSurfaceVariant,
                ),
                label: const Text('Filtres'),
                backgroundColor: filter.hasActiveFilters
                    ? scheme.primary
                    : scheme.surfaceContainerHighest,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: filter.hasActiveFilters
                      ? scheme.onPrimary
                      : scheme.onSurface,
                ),
              ),
              const Spacer(),
              if (filter.hasActiveFilters)
                TextButton.icon(
                  onPressed: () =>
                      ref.read(productFilterProvider.notifier).reset(),
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: const Text('Effacer'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
        ),
        // Collapsible price slider.
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: _priceExpanded
              ? _PriceFilter()
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      labelStyle: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 12.5,
        color: selected ? scheme.onPrimary : scheme.onSurface,
      ),
      backgroundColor: scheme.surfaceContainerHighest,
      selectedColor: scheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

class _PriceFilter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(productFilterProvider);
    final maxPrice = ref.watch(maxCatalogPriceProvider);
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Prix maximum',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              Text(
                Formatters.price(filter.maxPrice),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Slider(
            min: 5,
            max: maxPrice,
            divisions: (maxPrice - 5).round().clamp(1, 100),
            value: filter.maxPrice.clamp(5, maxPrice),
            label: Formatters.price(filter.maxPrice),
            onChanged: (value) =>
                ref.read(productFilterProvider.notifier).updateMaxPrice(value),
          ),
        ],
      ),
    );
  }
}
