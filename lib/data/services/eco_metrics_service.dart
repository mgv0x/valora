import '../models/food_activity.dart';
import '../models/food_category.dart';

class EcoImpactSummary {
  final double totalWaterSavedLiters;
  final double totalCo2eSavedKg;
  final double totalFoodSavedKg;
  final int itemsSavedCount;

  const EcoImpactSummary({
    required this.totalWaterSavedLiters,
    required this.totalCo2eSavedKg,
    required this.totalFoodSavedKg,
    required this.itemsSavedCount,
  });

  String get formattedWater {
    if (totalWaterSavedLiters >= 1000) {
      return '${(totalWaterSavedLiters / 1000).toStringAsFixed(1)} m³';
    }
    return '${totalWaterSavedLiters.toInt()} L';
  }

  String get formattedCo2 {
    return '${totalCo2eSavedKg.toStringAsFixed(1)} kg CO₂e';
  }

  String get formattedFoodWeight {
    return '${totalFoodSavedKg.toStringAsFixed(1)} kg';
  }
}

class EcoMetricsService {
  // Liters of virtual water per kg of food
  static const Map<FoodCategory, double> _waterFootprintPerKg = {
    FoodCategory.meatFish: 15400.0,
    FoodCategory.dairy: 3200.0,
    FoodCategory.pantryStaples: 1800.0,
    FoodCategory.bakery: 1608.0,
    FoodCategory.frozen: 2500.0,
    FoodCategory.drinks: 800.0,
    FoodCategory.fruits: 962.0,
    FoodCategory.vegetables: 322.0,
    FoodCategory.other: 1200.0,
  };

  // kg of CO2 equivalent per kg of food
  static const Map<FoodCategory, double> _carbonFootprintPerKg = {
    FoodCategory.meatFish: 27.0,
    FoodCategory.dairy: 8.5,
    FoodCategory.frozen: 4.2,
    FoodCategory.pantryStaples: 2.7,
    FoodCategory.bakery: 1.6,
    FoodCategory.drinks: 1.2,
    FoodCategory.fruits: 1.1,
    FoodCategory.vegetables: 2.0,
    FoodCategory.other: 2.0,
  };

  /// Calculates cumulative ecological savings from all consumed food activities.
  static EcoImpactSummary calculateSavings(List<FoodActivity> activities) {
    double totalWater = 0.0;
    double totalCo2 = 0.0;
    double totalWeight = 0.0;
    int count = 0;

    for (final act in activities) {
      if (act.type != ActivityType.consumed) continue;

      // Estimate weight in kilograms
      final weightKg = _estimateWeightKg(act.quantity, act.unit.name);
      final waterFactor = _waterFootprintPerKg[act.category] ?? 1200.0;
      final carbonFactor = _carbonFootprintPerKg[act.category] ?? 2.0;

      totalWater += weightKg * waterFactor;
      totalCo2 += weightKg * carbonFactor;
      totalWeight += weightKg;
      count++;
    }

    return EcoImpactSummary(
      totalWaterSavedLiters: totalWater,
      totalCo2eSavedKg: totalCo2,
      totalFoodSavedKg: totalWeight,
      itemsSavedCount: count,
    );
  }

  static double _estimateWeightKg(double quantity, String unit) {
    final u = unit.toLowerCase();
    if (u == 'kg' || u == 'kilogram') return quantity;
    if (u == 'g' || u == 'gram') return quantity / 1000.0;
    if (u == 'l' || u == 'liter') return quantity * 1.0; // aprox 1L = 1kg
    if (u == 'ml' || u == 'milliliter') return (quantity / 1000.0);
    // Pieces or packages: conservative estimate 0.35kg per unit
    return quantity * 0.35;
  }
}
