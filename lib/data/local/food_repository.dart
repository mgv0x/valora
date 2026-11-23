import '../models/food_item.dart';
import '../models/food_activity.dart';

abstract class FoodRepository {
  Future<void> init();
  Future<List<FoodItem>> getActiveFoods();
  Future<FoodItem?> getFoodById(String id);
  Future<void> insertFood(FoodItem item);
  Future<void> updateFood(FoodItem item);
  Future<void> deleteFood(String id);
  
  /// Records a consumption event and updates the food item remaining quantity.
  Future<void> recordConsumption({
    required FoodItem item,
    required double consumedQuantity,
    String? notes,
  });

  /// Records a disposal event and updates the food item remaining quantity.
  Future<void> recordDisposal({
    required FoodItem item,
    required double discardedQuantity,
    String? notes,
  });

  Future<List<FoodActivity>> getActivityHistory();
  Future<void> clearAllData();
  Future<Map<String, dynamic>> exportData();
  Future<bool> importData(Map<String, dynamic> data);
  Future<Map<String, dynamic>> getStorageDiagnostics();
  Future<void> optimizeStorage();
  Future<void> close();
}
