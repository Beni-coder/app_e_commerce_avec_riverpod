import 'package:flutter/material.dart';

/// Centralized catalog categories for the baby clothing shop.
class AppCategories {
  const AppCategories._();

  static const String bodies = 'Bodies & Brassieres';
  static const String pyjamas = 'Pyjamas';
  static const String robes = 'Robes';
  static const String ensembles = 'Ensembles';
  static const String pantalons = 'Pantalons & Leggings';
  static const String vestes = 'Vestes & Manteaux';
  static const String accessoires = 'Chapeaux & Accessoires';

  static const List<String> all = [
    bodies,
    pyjamas,
    robes,
    ensembles,
    pantalons,
    vestes,
    accessoires,
  ];
}

/// Maps a category label to a representative Material icon used as the
/// product placeholder visual (keeps the app fully offline-capable).
IconData iconForCategory(String category) {
  switch (category) {
    case AppCategories.bodies:
      return Icons.layers_rounded;
    case AppCategories.pyjamas:
      return Icons.bedtime_rounded;
    case AppCategories.robes:
      return Icons.local_mall_rounded;
    case AppCategories.ensembles:
      return Icons.dry_cleaning_rounded;
    case AppCategories.pantalons:
      return Icons.view_stream_rounded;
    case AppCategories.vestes:
      return Icons.checkroom_rounded;
    case AppCategories.accessoires:
      return Icons.face_retouching_natural_rounded;
    default:
      return Icons.child_friendly_rounded;
  }
}

/// A soft, distinct gradient pair per category used for product visuals.
List<Color> gradientForCategory(String category) {
  switch (category) {
    case AppCategories.bodies:
      return const [Color(0xFFFFD6E0), Color(0xFFFFAEC9)];
    case AppCategories.pyjamas:
      return const [Color(0xFFD6E4FF), Color(0xFFA9C4FF)];
    case AppCategories.robes:
      return const [Color(0xFFFFE0D6), Color(0xFFFFB199)];
    case AppCategories.ensembles:
      return const [Color(0xFFE6D6FF), Color(0xFFC3A9FF)];
    case AppCategories.pantalons:
      return const [Color(0xFFD6F5E6), Color(0xFFA9E6C4)];
    case AppCategories.vestes:
      return const [Color(0xFFFFF0C2), Color(0xFFFFE08A)];
    case AppCategories.accessoires:
      return const [Color(0xFFD6F0FF), Color(0xFFA9E0FF)];
    default:
      return const [Color(0xFFF3E8FF), Color(0xFFE4D0FF)];
  }
}
