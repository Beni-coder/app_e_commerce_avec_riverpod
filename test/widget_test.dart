import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_e_commerce_avec_riverpod/app.dart';
import 'package:app_e_commerce_avec_riverpod/providers/favorites_provider.dart';

void main() {
  testWidgets('App launches and shows the catalog shell', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const BabyShopApp(),
      ),
    );

    // Resolve the async products provider.
    await tester.pumpAndSettle();

    expect(find.text('Petit Nid'), findsWidgets);
    expect(find.byType(NavigationBar), findsOneWidget);
    // A product card from the mock catalog should be rendered.
    expect(find.byIcon(Icons.favorite_border_rounded), findsWidgets);
  });
}
