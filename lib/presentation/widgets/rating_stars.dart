import 'package:flutter/material.dart';

/// Read-only star rating row that renders a [rating] (0-5) with a review count.
class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.reviews,
    this.size = 14,
    this.showValue = true,
  });

  final double rating;
  final int? reviews;
  final double size;
  final bool showValue;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: size, color: Colors.amber.shade700),
        const SizedBox(width: 2),
        if (showValue)
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
        if (reviews != null) ...[
          const SizedBox(width: 4),
          Text(
            '($reviews)',
            style: TextStyle(
              fontSize: size,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
