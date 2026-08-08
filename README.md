# Petit Nid — App e-commerce de vetements de bebe (Flutter + Riverpod)

Application e-commerce mobile (Flutter) dediee a la vente en ligne de
vetements de bebe. Elle a ete concue pour **valider la maitrise du state
management avec Riverpod** : architecture en couches, separation de la logique
metier et de l'UI, gestion des etats de chargement/erreur via `AsyncValue`, et
persistance locale des favoris.

> Aucune dependance reseau n'est requise : les donnees produits sont moquees
> (fausse API asynchrone avec latence simulee) et les visuels sont generes
> (degrades + icones Material), ce qui permet de tester l'app hors-ligne.

---

## Sommaire

- [Fonctionnalites](#fonctionnalites)
- [Pile technique](#pile-technique)
- [Demarrage rapide](#demarrage-rapide)
- [Architecture](#architecture)
- [State management & providers Riverpod](#state-management--providers-riverpod)
- [Gestion des etats (AsyncValue)](#gestion-des-etats-asyncvalue)
- [Persistence locale (favoris)](#persistence-locale-favoris)
- [Tests](#tests)
- [Structure du projet](#structure-du-projet)
- [Captures conceptuelles des flux](#captures-conceptuelles-des-flux)

---

## Fonctionnalites

- **Catalogue de produits** : liste en grille + ecran de detail (description,
  matiere, tailles/couleurs, note et avis, suggestions).
- **Panier d'achat** : ajout, suppression (swipe), increment/decrement de
  quantite, fusion des lignes identiques, sous-total, frais de port et total.
- **Favoris persistes** : ajout/retrait, conserves entre les lancements via
  `SharedPreferences`.
- **Filtrage et tri** : recherche texte, filtre par categorie, slider de prix
  maximum, tri (nouveautes, prix, nom, note).
- **Profil utilisateur (mock)** : identite editable, points de fidelite,
  statistiques, menu de compte.
- **Bonus** : animations (Hero sur les visuels, badge de panier anime, rebond
  sur le bouton "Ajouter au panier").

---

## Pile technique

| Domaine                | Choix                                                    |
| ---------------------- | -------------------------------------------------------- |
| Framework              | Flutter (Material 3)                                     |
| State management       | `flutter_riverpod` (`StateNotifierProvider`, `FutureProvider`, `Provider`) |
| Persistance locale     | `shared_preferences` (favoris)                           |
| Egalite de valeur      | `equatable` (modeles immuables)                          |
| Donnees                | JSON local + fausse API asynchrone (latence simulee)     |
| Tests                  | `flutter_test` (unitaires + widget smoke test)           |

---

## Demarrage rapide

```bash
# 1. Recuperer les dependances
flutter pub get

# 2. Lancer l'application (choisir un peripherique)
flutter run

# 3. (Optionnel) Verifier la qualite du code
flutter analyze

# 4. (Optionnel) Lancer les tests
flutter test
```

Aucune configuration supplementaire (cle API, serveur) n'est necessaire.

---

## Architecture

Le projet suit une **architecture en couches** qui separe clairement la
logique metier de l'interface utilisateur. La regle de dependance va du haut
(UI) vers le bas (donnees), jamais l'inverse.

```
presentation (UI / widgets / ecrans)
        |  lit et observe
        v
providers (Riverpod : orchestration de l'etat)
        |  utilise
        v
data (repositories, services de persistance, datasources, modeles)
```

- **`data/`** : modeles immuables (`Product`, `CartItem`, `UserModel`),
  datasource JSON moque (`ProductsData`), repository asynchrone
  (`ProductRepository`) et service de persistance (`FavoritesStorage`).
  Aucune reference a Flutter/Riverpod ici (testable pur).
- **`providers/`** : couche Riverpod. Chaque fichier expose les providers d'un
  domaine fonctionnel (catalogue, panier, favoris, filtres, profil) ainsi que
  les `StateNotifier` associes. C'est ici que vit la logique d'etat.
- **`presentation/`** : widgets et ecrans. Les ecrans sont des
  `ConsumerWidget`/`ConsumerStatefulWidget` qui **se contentnt de lire
  (`ref.watch`) et de declencher des actions (`ref.read`)** — aucune logique
  metier dans l'UI.
- **`core/`** : theme, formateurs et helpers transverses.

Cette separation rend le code testable (les `StateNotifier` sont testes en
isolation sans UI) et evolutif (remplacer la fausse API par une vraie ne touche
que `data/`).

---

## State management & providers Riverpod

Riverpod est utilise **exclusivement**. Plus de 12 providers distincts couvrent
tous les besoins, en s'appuyant sur differents types de providers comme
demande.

### Catalogue & donnees (FutureProvider / Provider)

| Provider                       | Type                              | Role |
| ------------------------------ | --------------------------------- | ---- |
| `productRepositoryProvider`    | `Provider<ProductRepository>`     | Source unique d'acces aux produits (injection). |
| `productsProvider`             | `FutureProvider<List<Product>>`   | Charge le catalogue de maniere asynchrone (`AsyncValue`). |
| `productByIdProvider`          | `FutureProvider.family<Product,String>` | Charge un produit pour l'ecran detail. |
| `relatedProductsProvider`      | `FutureProvider.family<List<Product>,Product>` | Suggestions "vous aimerez aussi". |
| `categoriesProvider`           | `Provider<List<String>>`          | Liste des categories (synchrone). |
| `maxCatalogPriceProvider`      | `Provider<double>`                | Borne haute dynamique du slider de prix. |

### Filtre & tri (StateNotifierProvider)

| Provider                  | Type                                       | Role |
| ------------------------- | ------------------------------------------ | ---- |
| `productFilterProvider`   | `StateNotifierProvider<ProductFilterNotifier, ProductFilter>` | Etat de recherche, categorie, prix max et tri. |
| `filteredProductsProvider`| `Provider<AsyncValue<List<Product>>>`      | **Combine** `productsProvider` et le filtre via `AsyncValue.whenData` : conserve les etats loading/error/data et applique le filtre/tri uniquement sur les donnees. |

### Panier (StateNotifierProvider + providers derives)

| Provider                       | Type                              | Role |
| ------------------------------ | --------------------------------- | ---- |
| `cartProvider`                 | `StateNotifierProvider<CartNotifier, List<CartItem>>` | Etat du panier (ajout, quantite, suppression). |
| `cartItemCountProvider`        | `Provider<int>`                   | Nombre total d'unites (badge). |
| `cartSubtotalProvider`         | `Provider<double>`                | Sous-total avant livraison. |
| `shippingProvider`             | `Provider<double>`                | Frais de port (offerts au-dela d'un seuil). |
| `cartTotalProvider`            | `Provider<double>`                | Total a payer. |
| `freeShippingRemainingProvider`| `Provider<double>`                | Restant avant livraison offerte. |

### Favoris persistes (StateNotifierProvider + family + Provider)

| Provider                       | Type                              | Role |
| ------------------------------ | --------------------------------- | ---- |
| `sharedPreferencesProvider`    | `Provider<SharedPreferences>`      | Instance initialisee dans `main()` et **surchargee** dans le `ProviderScope`. |
| `favoritesStorageProvider`     | `Provider<FavoritesStorage>`      | Couche de persistance (lecture/ecriture). |
| `favoritesProvider`            | `StateNotifierProvider<FavoritesNotifier, Set<String>>` | Ensemble des ids favoris, charge puis sauvegarde a chaque changement. |
| `isFavoriteProvider`           | `Provider.family<bool, String>`   | Etat favori d'un produit donne (boutons coeur). |
| `favoritesCountProvider`       | `Provider<int>`                   | Nombre de favoris (badge). |

### Profil (StateNotifierProvider)

| Provider            | Type                                       | Role |
| ------------------- | ------------------------------------------ | ---- |
| `profileProvider`   | `StateNotifierProvider<ProfileNotifier, UserModel>` | Utilisateur mock, editable (nom, email, points). |

---

## Gestion des etats (AsyncValue)

Toutes les donnees asynchrones sont exposees sous forme d'`AsyncValue`, ce qui
rend les etats **loading / error / data** explicites et type-safe. Un widget
reutilisable (`AsyncValueWidget`) centralise le rendu :

```dart
AsyncValueWidget<List<Product>>(
  value: ref.watch(filteredProductsProvider), // AsyncValue
  onRetry: () => ref.invalidate(productsProvider),
  data: (products) => ProductGrid(products: products),
);
```

- **Chargement** : `CircularProgressIndicator`.
- **Erreur** : vue dediee avec bouton **Reessayer** (via `ref.invalidate`).
- **Donnees** : rendu de la grille, avec un etat vide si aucun resultat.

Le bouton "Reessayer" invalide le provider source pour declencher un
re-chargement reel — l'erreur n'est pas masquee.

---

## Persistence locale (favoris)

Les favoris survivent a la fermeture de l'application :

1. Dans `main()`, `SharedPreferences` est initialise puis fourni a Riverpod via
   un **override** du `ProviderScope`.
2. `FavoritesStorage` lit/ecrit un `Set<String>` d'ids de produits.
3. `FavoritesNotifier` charge l'etat au demarrage et le sauvegarde a chaque
   `toggle`/`add`/`remove`.

Ce mecanisme est verifie par un test qui simule un redemarrage (nouvelle
instance du notifier) et confirme la restauration de l'etat.

---

## Tests

```bash
flutter test
```

- **`cart_test.dart`** : logique du panier (ajout, fusion de lignes,
  increment/decrement, suppression, gestion des remises).
- **`favorites_test.dart`** : persistance des favoris (round-trip + restauration
  apres "redemarrage").
- **`filter_test.dart`** : etats et mutations du filtre/tri.
- **`widget_test.dart`** : smoke test de demarrage de l'application complete.

---

## Structure du projet

```
lib/
  main.dart                      # ProviderScope + init SharedPreferences
  app.dart                       # MaterialApp, theme, routes
  core/
    theme.dart                   # Theme Material 3
    categories.dart             # Categories, icones et degrades associes
    formatters.dart             # Helpers de formatage (prix, dates)
  data/
    models/
      product_model.dart        # Produit (fromJson/toJson, Equatable)
      cart_item_model.dart      # Ligne de panier
      user_model.dart           # Utilisateur mock
    datasources/
      products_data.dart        # Payload JSON moque (fausse API)
    repositories/
      product_repository.dart   # Acces asynchrone aux produits
    services/
      favorites_storage.dart    # Persistance SharedPreferences
  providers/
    product_providers.dart      # FutureProvider + provider filtre combine
    filter_provider.dart        # StateNotifier de filtre/tri
    cart_provider.dart          # StateNotifier panier + providers derives
    favorites_provider.dart     # StateNotifier favoris + persistance
    profile_provider.dart       # StateNotifier profil
  presentation/
    screens/
      home_screen.dart          # Shell + bottom navigation
      catalog_screen.dart       # Liste + recherche + filtres
      product_detail_screen.dart# Detail + ajout au panier (anime)
      cart_screen.dart          # Panier + recap + checkout (mock)
      favorites_screen.dart     # Favoris
      profile_screen.dart       # Profil mock editable
    widgets/
      async_value_widget.dart   # Rendu AsyncValue + etats vide/erreur
      product_card.dart         # Carte produit du catalogue
      product_visual.dart       # Visuel degrade (hors-ligne)
      filter_bar.dart           # Barre de filtres/tri
      cart_badge.dart           # Icone panier avec badge anime
      qty_stepper.dart          # Stepper de quantite
      rating_stars.dart         # Etoiles de notation
test/
  cart_test.dart
  favorites_test.dart
  filter_test.dart
  widget_test.dart
```

---

## Captures conceptuelles des flux

**Ajout au panier**

```
ProductDetailScreen
   -- ref.read(cartProvider.notifier).add(product, size, color) -->
CartNotifier (state: List<CartItem>) -- derive -->
cartItemCountProvider / cartSubtotalProvider / cartTotalProvider
   <-- ref.watch(...) <-- CartScreen / badges
```

**Filtrage du catalogue**

```
productsProvider (FutureProvider, AsyncValue)
                         +
productFilterProvider (StateNotifier)
                         |
        filteredProductsProvider (Provider<AsyncValue<...>>)
          via AsyncValue.whenData(applyFilter)
                         |
                 CatalogScreen (ref.watch)
```

**Favoris persistes**

```
main() -> SharedPreferences (override du ProviderScope)
   -> FavoritesStorage -> FavoritesNotifier
   toggle(id) -> etat -> save -> SharedPreferences
```
