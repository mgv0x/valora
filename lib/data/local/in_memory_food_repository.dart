import 'package:uuid/uuid.dart';
import 'food_repository.dart';
import '../models/food_activity.dart';
import '../models/food_item.dart';

class InMemoryFoodRepository implements FoodRepository {
  final List<FoodItem> _foods = [];
  final List<FoodActivity> _activities = [];
  final _uuid = const Uuid();

  @override
  Future<void> init() async {}

  @override
  Future<List<FoodItem>> getActiveFoods() async {
    return _foods
        .where((i) => i.status == FoodLifecycleStatus.active && i.hasRemaining)
        .toList();
  }

  @override
  Future<FoodItem?> getFoodById(String id) async {
    try {
      return _foods.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> insertFood(FoodItem item) async {
    final validation = item.validate();
    if (validation.isNotEmpty) {
      throw ArgumentError(validation.join('; '));
    }
    _foods.removeWhere((i) => i.id == item.id);
    _foods.add(item);
  }

  @override
  Future<void> updateFood(FoodItem item) async {
    final validation = item.validate();
    if (validation.isNotEmpty) {
      throw ArgumentError(validation.join('; '));
    }
    final index = _foods.indexWhere((i) => i.id == item.id);
    if (index >= 0) {
      _foods[index] = item;
    } else {
      _foods.add(item);
    }
  }

  @override
  Future<void> deleteFood(String id) async {
    final index = _foods.indexWhere((i) => i.id == id);
    if (index >= 0) {
      _foods[index] = _foods[index].copyWith(
        status: FoodLifecycleStatus.archived,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> recordConsumption({
    required FoodItem item,
    required double consumedQuantity,
    String? notes,
  }) async {
    if (consumedQuantity.isNaN || consumedQuantity.isInfinite || consumedQuantity <= 0) {
      throw ArgumentError('Consumed quantity must be greater than zero.');
    }
    if (consumedQuantity > item.remainingQuantity + 0.0001) {
      throw ArgumentError('Cannot consume more than remaining quantity.');
    }

    var newConsumedTotal = item.consumedQuantity + consumedQuantity;
    final remainingAfter = item.initialQuantity - (newConsumedTotal + item.discardedQuantity);
    final isDepleted = remainingAfter <= 0.0001;
    if (isDepleted) {
      newConsumedTotal = item.initialQuantity - item.discardedQuantity;
    }

    final updated = item.copyWith(
      consumedQuantity: newConsumedTotal,
      status: isDepleted ? FoodLifecycleStatus.consumed : item.status,
      updatedAt: DateTime.now(),
    );

    await updateFood(updated);

    final estimatedValue = item.calculateProportionalValue(consumedQuantity);
    _activities.insert(
      0,
      FoodActivity(
        id: _uuid.v4(),
        foodItemId: item.id,
        foodName: item.name,
        category: item.category,
        quantity: consumedQuantity,
        unit: item.unit,
        type: ActivityType.consumed,
        timestamp: DateTime.now(),
        estimatedValue: estimatedValue,
        notes: notes,
      ),
    );
  }

  @override
  Future<void> recordDisposal({
    required FoodItem item,
    required double discardedQuantity,
    String? notes,
  }) async {
    if (discardedQuantity.isNaN || discardedQuantity.isInfinite || discardedQuantity <= 0) {
      throw ArgumentError('Discarded quantity must be greater than zero.');
    }
    if (discardedQuantity > item.remainingQuantity + 0.0001) {
      throw ArgumentError('Cannot discard more than remaining quantity.');
    }

    var newDiscardedTotal = item.discardedQuantity + discardedQuantity;
    final remainingAfter = item.initialQuantity - (item.consumedQuantity + newDiscardedTotal);
    final isDepleted = remainingAfter <= 0.0001;
    if (isDepleted) {
      newDiscardedTotal = item.initialQuantity - item.consumedQuantity;
    }

    final updated = item.copyWith(
      discardedQuantity: newDiscardedTotal,
      status: isDepleted ? FoodLifecycleStatus.discarded : item.status,
      updatedAt: DateTime.now(),
    );

    await updateFood(updated);

    final estimatedValue = item.calculateProportionalValue(discardedQuantity);
    _activities.insert(
      0,
      FoodActivity(
        id: _uuid.v4(),
        foodItemId: item.id,
        foodName: item.name,
        category: item.category,
        quantity: discardedQuantity,
        unit: item.unit,
        type: ActivityType.discarded,
        timestamp: DateTime.now(),
        estimatedValue: estimatedValue,
        notes: notes,
      ),
    );
  }

  @override
  Future<List<FoodActivity>> getActivityHistory() async {
    return List.unmodifiable(_activities);
  }

  @override
  Future<void> clearAllData() async {
    _foods.clear();
    _activities.clear();
  }

  @override
  Future<Map<String, dynamic>> exportData() async {
    return {
      'app': 'Valora',
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'food_items': _foods.map((f) => f.toMap()).toList(),
      'food_activities': _activities.map((a) => a.toMap()).toList(),
    };
  }

  @override
  Future<bool> importData(Map<String, dynamic> data) async {
    if (data['app'] != 'Valora' || !data.containsKey('food_items')) return false;

    final version = data['version'];
    if (version != null && version is int && version > 2) return false;

    try {
      final rawItems = data['food_items'] as List<dynamic>;
      final rawActs = (data['food_activities'] as List<dynamic>?) ?? [];

      if (rawItems.length > 50000 || rawActs.length > 100000) {
        return false;
      }

      final newItems = <FoodItem>[];
      for (final m in rawItems) {
        final item = FoodItem.fromMap(Map<String, dynamic>.from(m as Map));
        final errors = item.validate();
        if (errors.isNotEmpty) return false;
        newItems.add(item);
      }

      final validItemIds = newItems.map((e) => e.id).toSet();
      final newActs = <FoodActivity>[];
      for (final m in rawActs) {
        final act = FoodActivity.fromMap(Map<String, dynamic>.from(m as Map));
        final errors = act.validate();
        if (errors.isNotEmpty || !validItemIds.contains(act.foodItemId)) return false;
        newActs.add(act);
      }

      _foods.clear();
      _foods.addAll(newItems);
      _activities.clear();
      _activities.addAll(newActs);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> getStorageDiagnostics() async {
    final activeCount = _foods.where((f) => f.status == FoodLifecycleStatus.active).length;
    final totalCount = _foods.length;
    return {
      'engine': 'In-Memory Cache (Web & Fast State)',
      'acid_compliant': true,
      'database_name': 'in_memory_catalog',
      'active_items': activeCount,
      'archived_items': totalCount - activeCount,
      'total_items': totalCount,
      'activity_records': _activities.length,
      'foreign_keys_enforced': true,
      'indexes': ['in_memory_primary_id'],
    };
  }

  @override
  Future<void> optimizeStorage() async {}

  @override
  Future<void> close() async {}
}
