import '../../core/categories.dart';

/// Local mock "API" payload for the baby clothing catalog.
///
/// Stored as raw JSON maps so the [ProductRepository] can exercise a realistic
/// `fromJson` decoding path (as if the data came from a remote service).
class ProductsData {
  const ProductsData._();

  static const List<Map<String, dynamic>> rawProducts = [
    {
      'id': 'p001',
      'name': 'Body coton bio Naissance',
      'description':
          'Body ultra-doux en coton biologique, pressions en nickel-free. '
          'Coupe confortable ideale pour la peau sensible des nouveau-nes.',
      'price': 12.90,
      'category': AppCategories.bodies,
      'sizes': ['0-1M', '1-3M', '3-6M', '6-12M'],
      'colors': ['Blanc', 'Ecru', 'Rose pale'],
      'rating': 4.8,
      'reviews': 132,
      'material': '100% coton bio',
      'isNew': true,
      'discountPercent': 0,
      'addedAt': 1008,
    },
    {
      'id': 'p002',
      'name': 'Pyjama velours etoile',
      'description':
          'Pyjama deux pieces en velours cousu doux, fermeture eclaire '
          'dans le dos pour un habillage facile. Motif etoiles brodees.',
      'price': 29.90,
      'category': AppCategories.pyjamas,
      'sizes': ['3-6M', '6-12M', '12-18M', '18-24M'],
      'colors': ['Bleu nuit', 'Gris', 'Vert sauge'],
      'rating': 4.9,
      'reviews': 87,
      'material': 'Velours coseute',
      'isNew': false,
      'discountPercent': 15,
      'addedAt': 1002,
    },
    {
      'id': 'p003',
      'name': 'Robe volantee d''ete',
      'description':
          'Robe leghere a bretelles, jupon volante et ceinture integree. '
          'Parfaite pour les beaux jours et les ceremonies.',
      'price': 24.90,
      'category': AppCategories.robes,
      'sizes': ['6-12M', '12-18M', '18-24M', '2-3A'],
      'colors': ['Corail', 'Jaune moutarde', 'Bleu ciel'],
      'rating': 4.7,
      'reviews': 64,
      'material': 'Viscose',
      'isNew': false,
      'discountPercent': 0,
      'addedAt': 1004,
    },
    {
      'id': 'p004',
      'name': 'Ensemble cardigan + legging',
      'description':
          'Duo coordonne: cardigan boutonne en maille fine et legging '
          'extensible. Confort et style pour tous les jours.',
      'price': 34.90,
      'category': AppCategories.ensembles,
      'sizes': ['6-12M', '12-18M', '18-24M', '2-3A'],
      'colors': ['Camel', 'Rose poudre', 'Marine'],
      'rating': 4.6,
      'reviews': 41,
      'material': 'Coton et elasthanne',
      'isNew': true,
      'discountPercent': 0,
      'addedAt': 1010,
    },
    {
      'id': 'p005',
      'name': 'Legging cotele confort',
      'description':
          'Legging taille basse a taille elastique douce, coteles pour un '
          'maintien parfait sans serrer le ventre.',
      'price': 14.90,
      'category': AppCategories.pantalons,
      'sizes': ['3-6M', '6-12M', '12-18M', '18-24M'],
      'colors': ['Gris', 'Noir', 'Vert'],
      'rating': 4.5,
      'reviews': 53,
      'material': 'Cotele et elasthanne',
      'isNew': false,
      'discountPercent': 10,
      'addedAt': 1003,
    },
    {
      'id': 'p006',
      'name': 'Veste pilou doublure',
      'description':
          'Petite veste doudoune pilou, doublure douce et capuche assortie. '
          'Idem pour les fraiches matinees d''automne.',
      'price': 39.90,
      'category': AppCategories.vestes,
      'sizes': ['6-12M', '12-18M', '18-24M', '2-3A'],
      'colors': ['Camel', 'Rose', 'Marine'],
      'rating': 4.9,
      'reviews': 29,
      'material': 'Polyester recycle',
      'isNew': false,
      'discountPercent': 0,
      'addedAt': 1005,
    },
    {
      'id': 'p007',
      'name': 'Chapeau melon froncon',
      'description':
          'Chapeau de soleil a larges bords pour proteger le visage et la '
          'nuque. Noeud decorative et mentonniere reglable.',
      'price': 16.90,
      'category': AppCategories.accessoires,
      'sizes': ['6-12M', '12-24M', '2-4A'],
      'colors': ['Beige', 'Rose', 'Bleu'],
      'rating': 4.7,
      'reviews': 38,
      'material': 'Paille souple',
      'isNew': false,
      'discountPercent': 20,
      'addedAt': 1001,
    },
    {
      'id': 'p008',
      'name': 'Body manches longues thermo',
      'description':
          'Body thermique a manches longues pour garder au chaud tout en '
          'restant respirant. Pressions renforcees.',
      'price': 15.90,
      'category': AppCategories.bodies,
      'sizes': ['0-1M', '1-3M', '3-6M', '6-12M'],
      'colors': ['Blanc', 'Gris', 'Rose pale'],
      'rating': 4.6,
      'reviews': 76,
      'material': 'Laine merinos',
      'isNew': false,
      'discountPercent': 0,
      'addedAt': 1006,
    },
    {
      'id': 'p009',
      'name': 'Pyjama grenouillere integrale',
      'description':
          'Grenouillere une piece avec pieds antiderapants et double '
          'fermeture eclaire pour les changes de nuit.',
      'price': 32.90,
      'category': AppCategories.pyjamas,
      'sizes': ['0-1M', '1-3M', '3-6M', '6-12M'],
      'colors': ['Rose', 'Bleu', 'Vert'],
      'rating': 4.8,
      'reviews': 95,
      'material': 'Jersey de coton',
      'isNew': true,
      'discountPercent': 0,
      'addedAt': 1011,
    },
    {
      'id': 'p010',
      'name': 'Robe trappee lurex',
      'description':
          'Robe trappee avec fils lurex discrets et collant assorti. Tenue '
          'de fete elegante et confortable.',
      'price': 36.90,
      'category': AppCategories.robes,
      'sizes': ['6-12M', '12-18M', '18-24M', '2-3A'],
      'colors': ['Bordeaux', 'Bleu nuit', 'Or'],
      'rating': 4.5,
      'reviews': 22,
      'material': 'Polyester et lurex',
      'isNew': false,
      'discountPercent': 25,
      'addedAt': 1000,
    },
    {
      'id': 'p011',
      'name': 'Ensemble salopette + t-shirt',
      'description':
          'Salopette en denim souple avec t-shirt raye coordonne. Bretelles '
          'reglables et boutons pression a l''entrejambe.',
      'price': 38.90,
      'category': AppCategories.ensembles,
      'sizes': ['12-18M', '18-24M', '2-3A', '3-4A'],
      'colors': ['Bleu denim', 'Beige', 'Rose'],
      'rating': 4.7,
      'reviews': 48,
      'material': 'Denim et coton',
      'isNew': false,
      'discountPercent': 0,
      'addedAt': 1007,
    },
    {
      'id': 'p012',
      'name': 'Pantalon doubl polaire',
      'description':
          'Pantalon coupe doubl polaire pour un maximum de chaleur. Taille '
          'elastique et poches laterales.',
      'price': 21.90,
      'category': AppCategories.pantalons,
      'sizes': ['6-12M', '12-18M', '18-24M', '2-3A'],
      'colors': ['Gris', 'Bordeaux', 'Marine'],
      'rating': 4.4,
      'reviews': 31,
      'material': 'Polaire recyclee',
      'isNew': false,
      'discountPercent': 5,
      'addedAt': 1002,
    },
    {
      'id': 'p013',
      'name': 'Veste jean capuche',
      'description':
          'Veste en denim doubl coton avec capuche detachable. Style intemporel '
          'pour les promenades au parc.',
      'price': 42.90,
      'category': AppCategories.vestes,
      'sizes': ['12-18M', '18-24M', '2-3A', '3-4A'],
      'colors': ['Bleu clair', 'Bleu moyen', 'Noir'],
      'rating': 4.8,
      'reviews': 19,
      'material': 'Denim',
      'isNew': true,
      'discountPercent': 0,
      'addedAt': 1012,
    },
    {
      'id': 'p014',
      'name': 'Lot de 3 paires de chaussettes',
      'description':
          'Lot de chaussettes anti-glisse avec semelle silicone. Maille fine '
          'et bords douce pour ne pas marquer.',
      'price': 9.90,
      'category': AppCategories.accessoires,
      'sizes': ['0-6M', '6-12M', '12-24M'],
      'colors': ['Assortiment', 'Rose', 'Bleu'],
      'rating': 4.6,
      'reviews': 110,
      'material': 'Coton et elasthanne',
      'isNew': false,
      'discountPercent': 0,
      'addedAt': 1003,
    },
  ];
}
