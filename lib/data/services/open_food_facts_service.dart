import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/food_category.dart';
import '../models/food_unit.dart';
import '../models/storage_location.dart';

/// Representation of a food product returned by the Open Food Facts API.
class OpenFoodProduct {
  final String barcode;
  final String name;
  final String? brand;
  final FoodCategory category;
  final FoodUnit unit;
  final int suggestedShelfLifeDays;
  final StorageLocation suggestedStorage;
  final String? nutriscore;
  final String? ecoscore;
  final String? imageUrl;
  final double? estimatedQuantity;

  const OpenFoodProduct({
    required this.barcode,
    required this.name,
    this.brand,
    required this.category,
    required this.unit,
    required this.suggestedShelfLifeDays,
    required this.suggestedStorage,
    this.nutriscore,
    this.ecoscore,
    this.imageUrl,
    this.estimatedQuantity,
  });

  String get displayName => brand != null && brand!.isNotEmpty ? '$name ($brand)' : name;

  Map<String, dynamic> toMap() => {
        'barcode': barcode,
        'name': name,
        'brand': brand,
        'category': category.name,
        'unit': unit.name,
        'suggestedShelfLifeDays': suggestedShelfLifeDays,
        'suggestedStorage': suggestedStorage.name,
        'nutriscore': nutriscore,
        'ecoscore': ecoscore,
        'imageUrl': imageUrl,
      };
}

/// Service providing live REST API integration with Open Food Facts (world.openfoodfacts.org).
class OpenFoodFactsApiService {
  static const String _baseUrl = 'https://world.openfoodfacts.org';
  static const Duration _timeout = Duration(seconds: 5);

  final http.Client _client;

  OpenFoodFactsApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Checks if the Open Food Facts API is reachable.
  Future<bool> checkHealth() async {
    try {
      final uri = Uri.parse('$_baseUrl/api/v2/preferences');
      final response = await _client.get(uri).timeout(_timeout);
      return response.statusCode >= 200 && response.statusCode < 400;
    } catch (_) {
      return false;
    }
  }

  /// Searches food products in the Open Food Facts live database by keywords.
  Future<List<OpenFoodProduct>> searchProducts(String query, {int limit = 10}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    try {
      final uri = Uri.parse(
        '$_baseUrl/cgi/search.pl?search_terms=${Uri.encodeQueryComponent(trimmed)}'
        '&search_simple=1&action=process&json=1&page_size=$limit',
      );

      final response = await _client.get(
        uri,
        headers: {'User-Agent': 'ValoraApp - Flutter - Version 1.2'},
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final products = decoded['products'] as List<dynamic>?;
        if (products != null && products.isNotEmpty) {
          final results = <OpenFoodProduct>[];
          for (final raw in products) {
            if (raw is Map<String, dynamic>) {
              final product = _parseProduct(raw);
              if (product != null) results.add(product);
            }
          }
          if (results.isNotEmpty) return results;
        }
      }
    } catch (e) {
      debugPrint('OpenFoodFactsApiService search network error: $e');
    }

    // Fallback catalog for offline / airplane mode
    return _localFallbackSearch(trimmed);
  }

  /// Looks up a food product by EAN/UPC barcode in Open Food Facts.
  Future<OpenFoodProduct?> lookupBarcode(String barcode) async {
    final cleanBarcode = barcode.trim().replaceAll(RegExp(r'\D'), '');
    if (cleanBarcode.isEmpty) return null;

    try {
      final uri = Uri.parse('$_baseUrl/api/v2/product/$cleanBarcode.json');
      final response = await _client.get(
        uri,
        headers: {'User-Agent': 'ValoraApp - Flutter - Version 1.2'},
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final status = decoded['status'];
        if (status == 1 || status == '1') {
          final productMap = decoded['product'] as Map<String, dynamic>?;
          if (productMap != null) {
            return _parseProduct(productMap, fallbackBarcode: cleanBarcode);
          }
        }
      }
    } catch (e) {
      debugPrint('OpenFoodFactsApiService barcode network error: $e');
    }

    return null;
  }

  OpenFoodProduct? _parseProduct(Map<String, dynamic> raw, {String? fallbackBarcode}) {
    final rawName = raw['product_name_pt'] ??
        raw['product_name'] ??
        raw['generic_name_pt'] ??
        raw['generic_name'];
    final name = rawName?.toString();

    if (name == null || name.trim().isEmpty) return null;

    final code = raw['code']?.toString() ?? fallbackBarcode ?? '';
    final brand = raw['brands'] is List
        ? (raw['brands'] as List).join(', ')
        : raw['brands']?.toString();
    final catPart1 = raw['categories']?.toString() ?? '';
    final catPart2 = raw['categories_tags'] is List
        ? (raw['categories_tags'] as List).join(' ')
        : raw['categories_tags']?.toString() ?? '';
    final categoriesStr = '$catPart1 $catPart2';

    final category = _mapCategory(name, categoriesStr);
    final unit = _inferUnit(raw['quantity']?.toString());
    final shelfLife = _inferShelfLife(category);
    final storage = _inferStorage(category);

    return OpenFoodProduct(
      barcode: code,
      name: name.trim(),
      brand: brand?.split(',').first.trim(),
      category: category,
      unit: unit,
      suggestedShelfLifeDays: shelfLife,
      suggestedStorage: storage,
      nutriscore: raw['nutriscore_grade']?.toString(),
      ecoscore: raw['ecoscore_grade']?.toString(),
      imageUrl: raw['image_front_small_url']?.toString(),
    );
  }

  static FoodCategory _mapCategory(String name, String tags) {
    final lower = '${name.toLowerCase()} ${tags.toLowerCase()}';

    if (lower.contains('leite') ||
        lower.contains('iogurte') ||
        lower.contains('queijo') ||
        lower.contains('manteiga') ||
        lower.contains('dairy') ||
        lower.contains('fromage') ||
        lower.contains('milk') ||
        lower.contains('yogurt')) {
      return FoodCategory.dairy;
    }

    if (lower.contains('maçã') ||
        lower.contains('banana') ||
        lower.contains('laranja') ||
        lower.contains('uva') ||
        lower.contains('morango') ||
        lower.contains('fruta') ||
        lower.contains('fruit')) {
      return FoodCategory.fruits;
    }

    if (lower.contains('alface') ||
        lower.contains('tomate') ||
        lower.contains('cenoura') ||
        lower.contains('cebola') ||
        lower.contains('batata') ||
        lower.contains('vegetable') ||
        lower.contains('legume') ||
        lower.contains('salada')) {
      return FoodCategory.vegetables;
    }

    if (lower.contains('carne') ||
        lower.contains('frango') ||
        lower.contains('peixe') ||
        lower.contains('bife') ||
        lower.contains('salmão') ||
        lower.contains('meat') ||
        lower.contains('beef') ||
        lower.contains('chicken') ||
        lower.contains('fish')) {
      return FoodCategory.meatFish;
    }

    if (lower.contains('pão') ||
        lower.contains('torrada') ||
        lower.contains('bolo') ||
        lower.contains('croissant') ||
        lower.contains('bread') ||
        lower.contains('bakery')) {
      return FoodCategory.bakery;
    }

    if (lower.contains('suco') ||
        lower.contains('refrigerante') ||
        lower.contains('cerveja') ||
        lower.contains('vinho') ||
        lower.contains('café') ||
        lower.contains('chá') ||
        lower.contains('água') ||
        lower.contains('beverage') ||
        lower.contains('drink') ||
        lower.contains('juice')) {
      return FoodCategory.drinks;
    }

    if (lower.contains('congelado') ||
        lower.contains('sorvete') ||
        lower.contains('pizza congelada') ||
        lower.contains('frozen') ||
        lower.contains('ice cream')) {
      return FoodCategory.frozen;
    }

    if (lower.contains('arroz') ||
        lower.contains('feijão') ||
        lower.contains('macarrão') ||
        lower.contains('azeite') ||
        lower.contains('farinha') ||
        lower.contains('óleo') ||
        lower.contains('açúcar') ||
        lower.contains('pasta') ||
        lower.contains('rice') ||
        lower.contains('beans')) {
      return FoodCategory.pantryStaples;
    }

    return FoodCategory.other;
  }

  static FoodUnit _inferUnit(String? quantityText) {
    if (quantityText == null) return FoodUnit.piece;
    final lower = quantityText.toLowerCase();
    if (lower.contains('kg')) return FoodUnit.kilogram;
    if (lower.contains('g')) return FoodUnit.gram;
    if (lower.contains('ml')) return FoodUnit.milliliter;
    if (lower.contains('l')) return FoodUnit.liter;
    return FoodUnit.piece;
  }

  static int _inferShelfLife(FoodCategory cat) {
    switch (cat) {
      case FoodCategory.meatFish:
        return 3;
      case FoodCategory.bakery:
        return 5;
      case FoodCategory.dairy:
        return 7;
      case FoodCategory.fruits:
      case FoodCategory.vegetables:
        return 7;
      case FoodCategory.drinks:
        return 15;
      case FoodCategory.pantryStaples:
        return 60;
      case FoodCategory.frozen:
        return 90;
      case FoodCategory.other:
        return 14;
    }
  }

  static StorageLocation _inferStorage(FoodCategory cat) {
    switch (cat) {
      case FoodCategory.frozen:
        return StorageLocation.freezer;
      case FoodCategory.dairy:
      case FoodCategory.meatFish:
      case FoodCategory.vegetables:
      case FoodCategory.fruits:
        return StorageLocation.refrigerator;
      case FoodCategory.bakery:
      case FoodCategory.pantryStaples:
      case FoodCategory.drinks:
      case FoodCategory.other:
        return StorageLocation.pantry;
    }
  }

  List<OpenFoodProduct> _localFallbackSearch(String query) {
    final lower = query.toLowerCase();
    final catalog = <OpenFoodProduct>[
      const OpenFoodProduct(
        barcode: '7891000100101',
        name: 'Leite Integral UHT 1L',
        brand: 'Ninho / Piracanjuba',
        category: FoodCategory.dairy,
        unit: FoodUnit.liter,
        suggestedShelfLifeDays: 7,
        suggestedStorage: StorageLocation.refrigerator,
        nutriscore: 'b',
        ecoscore: 'b',
      ),
      const OpenFoodProduct(
        barcode: '7891000200202',
        name: 'Iogurte Natural Desnatado',
        brand: 'Batavo / Danone',
        category: FoodCategory.dairy,
        unit: FoodUnit.piece,
        suggestedShelfLifeDays: 10,
        suggestedStorage: StorageLocation.refrigerator,
        nutriscore: 'a',
        ecoscore: 'b',
      ),
      const OpenFoodProduct(
        barcode: '7891000300303',
        name: 'Arroz Branco Tipo 1 1kg',
        brand: 'Camil / Tio João',
        category: FoodCategory.pantryStaples,
        unit: FoodUnit.kilogram,
        suggestedShelfLifeDays: 180,
        suggestedStorage: StorageLocation.pantry,
        nutriscore: 'a',
        ecoscore: 'a',
      ),
      const OpenFoodProduct(
        barcode: '7891000400404',
        name: 'Feijão Carioca 1kg',
        brand: 'Kicaldo / Camil',
        category: FoodCategory.pantryStaples,
        unit: FoodUnit.kilogram,
        suggestedShelfLifeDays: 120,
        suggestedStorage: StorageLocation.pantry,
        nutriscore: 'a',
        ecoscore: 'a',
      ),
      const OpenFoodProduct(
        barcode: '7891000500505',
        name: 'Maçã Fuji Fresca',
        brand: 'Hortifruti Selecionado',
        category: FoodCategory.fruits,
        unit: FoodUnit.piece,
        suggestedShelfLifeDays: 10,
        suggestedStorage: StorageLocation.refrigerator,
        nutriscore: 'a',
        ecoscore: 'a',
      ),
      const OpenFoodProduct(
        barcode: '7891000600606',
        name: 'Banana Prata',
        brand: 'Hortifruti',
        category: FoodCategory.fruits,
        unit: FoodUnit.piece,
        suggestedShelfLifeDays: 5,
        suggestedStorage: StorageLocation.pantry,
        nutriscore: 'a',
        ecoscore: 'a',
      ),
      const OpenFoodProduct(
        barcode: '7891000700707',
        name: 'Peito de Frango em Filés',
        brand: 'Sadia / Seara',
        category: FoodCategory.meatFish,
        unit: FoodUnit.kilogram,
        suggestedShelfLifeDays: 3,
        suggestedStorage: StorageLocation.refrigerator,
        nutriscore: 'a',
        ecoscore: 'c',
      ),
      const OpenFoodProduct(
        barcode: '7891000800808',
        name: 'Pão de Forma Tradicional',
        brand: 'Wickbold / Pullman',
        category: FoodCategory.bakery,
        unit: FoodUnit.piece,
        suggestedShelfLifeDays: 6,
        suggestedStorage: StorageLocation.pantry,
        nutriscore: 'b',
        ecoscore: 'b',
      ),
      const OpenFoodProduct(
        barcode: '7891000900909',
        name: 'Suco de Laranja Integral 900ml',
        brand: 'Natural One / Prats',
        category: FoodCategory.drinks,
        unit: FoodUnit.liter,
        suggestedShelfLifeDays: 14,
        suggestedStorage: StorageLocation.refrigerator,
        nutriscore: 'c',
        ecoscore: 'b',
      ),
      const OpenFoodProduct(
        barcode: '7891000000000',
        name: 'Lasanha à Bolonhesa Congelada',
        brand: 'Sadia',
        category: FoodCategory.frozen,
        unit: FoodUnit.piece,
        suggestedShelfLifeDays: 90,
        suggestedStorage: StorageLocation.freezer,
        nutriscore: 'd',
        ecoscore: 'c',
      ),
    ];

    return catalog
        .where((p) =>
            p.name.toLowerCase().contains(lower) ||
            (p.brand != null && p.brand!.toLowerCase().contains(lower)) ||
            p.category.name.toLowerCase().contains(lower))
        .toList();
  }
}
