import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/product_detail_screen.dart';

/// Root [MaterialApp] wiring the theme and navigation routes.
class BabyShopApp extends StatelessWidget {
  const BabyShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Petit Nid',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const HomeScreen(),
      onGenerateRoute: (settings) {
        if (settings.name == '/product') {
          final productId = settings.arguments! as String;
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => ProductDetailScreen(productId: productId),
          );
        }
        return null;
      },
    );
  }
}
