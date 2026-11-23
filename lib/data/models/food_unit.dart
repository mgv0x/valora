import 'package:valora/l10n/generated/app_localizations.dart';

enum FoodUnit {
  piece,
  gram,
  kilogram,
  milliliter,
  liter,
  package;

  String get shortSymbol {
    switch (this) {
      case FoodUnit.piece:
        return 'un';
      case FoodUnit.gram:
        return 'g';
      case FoodUnit.kilogram:
        return 'kg';
      case FoodUnit.milliliter:
        return 'ml';
      case FoodUnit.liter:
        return 'L';
      case FoodUnit.package:
        return 'pct';
    }
  }

  String localizedShort(AppLocalizations l10n) {
    switch (this) {
      case FoodUnit.piece:
        return l10n.unitPiece;
      case FoodUnit.gram:
        return l10n.unitGram;
      case FoodUnit.kilogram:
        return l10n.unitKilogram;
      case FoodUnit.milliliter:
        return l10n.unitMilliliter;
      case FoodUnit.liter:
        return l10n.unitLiter;
      case FoodUnit.package:
        return l10n.unitPackage;
    }
  }

  /// Format a quantity with sensible decimals (e.g. 1 instead of 1.0, 1.5 instead of 1.50)
  static String formatQuantity(double qty) {
    if (qty.isNaN || qty.isInfinite || qty <= 0.0001) {
      return '0';
    }
    if (qty == qty.roundToDouble()) {
      return qty.toInt().toString();
    }
    return qty.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  static FoodUnit fromString(String value) {
    final lower = value.trim().toLowerCase();
    switch (lower) {
      case 'kg':
      case 'kilo':
      case 'kilos':
      case 'quilo':
      case 'quilos':
      case 'kilogram':
      case 'kilograms':
        return FoodUnit.kilogram;
      case 'g':
      case 'gram':
      case 'grams':
      case 'grama':
      case 'gramas':
        return FoodUnit.gram;
      case 'l':
      case 'liter':
      case 'liters':
      case 'litro':
      case 'litros':
        return FoodUnit.liter;
      case 'ml':
      case 'milliliter':
      case 'milliliters':
      case 'mililitro':
      case 'mililitros':
        return FoodUnit.milliliter;
      case 'pct':
      case 'pack':
      case 'package':
      case 'packages':
      case 'pacote':
      case 'pacotes':
        return FoodUnit.package;
      case 'un':
      case 'unit':
      case 'units':
      case 'unidade':
      case 'unidades':
      case 'piece':
      case 'pieces':
        return FoodUnit.piece;
      default:
        return FoodUnit.values.firstWhere(
          (e) => e.name.toLowerCase() == lower,
          orElse: () => FoodUnit.piece,
        );
    }
  }
}
