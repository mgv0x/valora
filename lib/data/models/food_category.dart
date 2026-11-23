import 'package:flutter/material.dart';
import 'package:valora/l10n/generated/app_localizations.dart';

enum FoodCategory {
  fruits,
  vegetables,
  dairy,
  meatFish,
  bakery,
  pantryStaples,
  frozen,
  drinks,
  other;

  String get displayName {
    switch (this) {
      case FoodCategory.fruits:
        return 'Frutas';
      case FoodCategory.vegetables:
        return 'Verduras';
      case FoodCategory.dairy:
        return 'Laticínios';
      case FoodCategory.meatFish:
        return 'Carnes & Peixes';
      case FoodCategory.bakery:
        return 'Padaria';
      case FoodCategory.pantryStaples:
        return 'Despensa';
      case FoodCategory.frozen:
        return 'Congelados';
      case FoodCategory.drinks:
        return 'Bebidas';
      case FoodCategory.other:
        return 'Outros';
    }
  }

  String localizedName(AppLocalizations l10n) {
    switch (this) {
      case FoodCategory.fruits:
        return l10n.catFruits;
      case FoodCategory.vegetables:
        return l10n.catVegetables;
      case FoodCategory.dairy:
        return l10n.catDairy;
      case FoodCategory.meatFish:
        return l10n.catMeatFish;
      case FoodCategory.bakery:
        return l10n.catBakery;
      case FoodCategory.pantryStaples:
        return l10n.catPantryStaples;
      case FoodCategory.frozen:
        return l10n.catFrozen;
      case FoodCategory.drinks:
        return l10n.catDrinks;
      case FoodCategory.other:
        return l10n.catOther;
    }
  }

  IconData get icon {
    switch (this) {
      case FoodCategory.fruits:
        return Icons.apple_rounded;
      case FoodCategory.vegetables:
        return Icons.eco_rounded;
      case FoodCategory.dairy:
        return Icons.egg_outlined;
      case FoodCategory.meatFish:
        return Icons.set_meal_rounded;
      case FoodCategory.bakery:
        return Icons.bakery_dining_rounded;
      case FoodCategory.pantryStaples:
        return Icons.inventory_2_outlined;
      case FoodCategory.frozen:
        return Icons.ac_unit_rounded;
      case FoodCategory.drinks:
        return Icons.local_cafe_outlined;
      case FoodCategory.other:
        return Icons.category_outlined;
    }
  }

  static FoodCategory fromString(String value) {
    final clean = value.replaceAll(RegExp(r'[-_\s]'), '').toLowerCase();
    return FoodCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == clean || e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => FoodCategory.other,
    );
  }
}
