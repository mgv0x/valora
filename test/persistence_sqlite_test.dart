import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:valora/data/local/sqlite_food_repository.dart';
import 'package:valora/data/models/food_activity.dart';
import 'package:valora/data/models/food_category.dart';
import 'package:valora/data/models/food_item.dart';
import 'package:valora/data/models/food_unit.dart';
import 'package:valora/data/models/storage_location.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('SqliteFoodRepository Persistence Tests', () {
    late SqliteFoodRepository repository;
    final now = DateTime(2026, 10, 8, 10, 0);

    setUp(() async {
      repository = SqliteFoodRepository(inMemory: true);
      await repository.init();
      await repository.clearAllData();
    });

    test('Insert food and read back from active foods', () async {
      final item = FoodItem(
        id: 'food-1',
        name: 'Fresh Strawberries',
        category: FoodCategory.fruits,
        initialQuantity: 500,
        unit: FoodUnit.gram,
        expiryDate: now.add(const Duration(days: 3)),
        purchasePrice: 15.00,
        storageLocation: StorageLocation.refrigerator,
        createdAt: now,
        updatedAt: now,
      );

      await repository.insertFood(item);

      final active = await repository.getActiveFoods();
      expect(active.length, equals(1));
      expect(active.first.id, equals('food-1'));
      expect(active.first.name, equals('Fresh Strawberries'));
      expect(active.first.remainingQuantity, equals(500.0));
      expect(active.first.purchasePrice, equals(15.00));
    });

    test('Update existing food item', () async {
      final item = FoodItem(
        id: 'food-2',
        name: 'Butter',
        category: FoodCategory.dairy,
        initialQuantity: 200,
        unit: FoodUnit.gram,
        createdAt: now,
        updatedAt: now,
      );
      await repository.insertFood(item);

      final updated = item.copyWith(
        name: 'Salted Butter',
        initialQuantity: 250,
      );
      await repository.updateFood(updated);

      final fetched = await repository.getFoodById('food-2');
      expect(fetched, isNotNull);
      expect(fetched!.name, equals('Salted Butter'));
      expect(fetched.initialQuantity, equals(250));
    });

    test('Delete food item archives it from active list', () async {
      final item = FoodItem(
        id: 'food-3',
        name: 'Eggs',
        category: FoodCategory.dairy,
        initialQuantity: 12,
        unit: FoodUnit.piece,
        createdAt: now,
        updatedAt: now,
      );
      await repository.insertFood(item);

      var active = await repository.getActiveFoods();
      expect(active.length, equals(1));

      await repository.deleteFood('food-3');

      active = await repository.getActiveFoods();
      expect(active, isEmpty);

      final record = await repository.getFoodById('food-3');
      expect(record, isNotNull);
      expect(record!.status, equals(FoodLifecycleStatus.archived));
    });

    test('Record consumption updates item and writes to activity log', () async {
      final item = FoodItem(
        id: 'food-4',
        name: 'Cheddar Cheese',
        category: FoodCategory.dairy,
        initialQuantity: 400,
        unit: FoodUnit.gram,
        purchasePrice: 20.00,
        createdAt: now,
        updatedAt: now,
      );
      await repository.insertFood(item);

      // Consume 150 grams
      await repository.recordConsumption(
        item: item,
        consumedQuantity: 150,
        notes: 'Breakfast sandwich',
      );

      final active = await repository.getActiveFoods();
      expect(active.length, equals(1));
      expect(active.first.consumedQuantity, equals(150.0));
      expect(active.first.remainingQuantity, equals(250.0));

      final activities = await repository.getActivityHistory();
      expect(activities.length, equals(1));
      expect(activities.first.type, equals(ActivityType.consumed));
      expect(activities.first.quantity, equals(150.0));
      // Proportional value: (150 / 400) * 20 = 7.50
      expect(activities.first.estimatedValue, closeTo(7.50, 0.001));
      expect(activities.first.notes, equals('Breakfast sandwich'));
    });

    test('Full consumption moves item out of active pantry', () async {
      final item = FoodItem(
        id: 'food-5',
        name: 'Orange Juice',
        category: FoodCategory.drinks,
        initialQuantity: 1.0,
        unit: FoodUnit.liter,
        purchasePrice: 8.00,
        createdAt: now,
        updatedAt: now,
      );
      await repository.insertFood(item);

      // Consume full liter
      await repository.recordConsumption(
        item: item,
        consumedQuantity: 1.0,
      );

      final active = await repository.getActiveFoods();
      expect(active, isEmpty);

      final stored = await repository.getFoodById('food-5');
      expect(stored!.status, equals(FoodLifecycleStatus.consumed));
      expect(stored.remainingQuantity, equals(0.0));
    });

    test('Record disposal updates discardedQuantity and activity log', () async {
      final item = FoodItem(
        id: 'food-6',
        name: 'Lettuce',
        category: FoodCategory.vegetables,
        initialQuantity: 1.0,
        unit: FoodUnit.piece,
        purchasePrice: 4.00,
        createdAt: now,
        updatedAt: now,
      );
      await repository.insertFood(item);

      // Discard whole piece due to spoilage
      await repository.recordDisposal(
        item: item,
        discardedQuantity: 1.0,
        notes: 'Wilted leaves',
      );

      final active = await repository.getActiveFoods();
      expect(active, isEmpty);

      final activities = await repository.getActivityHistory();
      expect(activities.length, equals(1));
      expect(activities.first.type, equals(ActivityType.discarded));
      expect(activities.first.estimatedValue, closeTo(4.00, 0.001));
    });

    test('Consuming more than remaining quantity throws ArgumentError', () async {
      final item = FoodItem(
        id: 'food-7',
        name: 'Apple Pie',
        category: FoodCategory.bakery,
        initialQuantity: 2.0,
        unit: FoodUnit.piece,
        createdAt: now,
        updatedAt: now,
      );
      await repository.insertFood(item);

      expect(
        () => repository.recordConsumption(item: item, consumedQuantity: 3.0),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Export and import data roundtrip preserves database state', () async {
      final item = FoodItem(
        id: 'food-export-1',
        name: 'Almond Milk',
        category: FoodCategory.drinks,
        initialQuantity: 1.0,
        unit: FoodUnit.liter,
        purchasePrice: 12.00,
        createdAt: now,
        updatedAt: now,
      );
      await repository.insertFood(item);

      await repository.recordConsumption(
        item: item,
        consumedQuantity: 0.5,
        notes: 'Coffee',
      );

      final exported = await repository.exportData();
      expect(exported['app'], equals('Valora'));
      expect((exported['food_items'] as List).length, equals(1));
      expect((exported['food_activities'] as List).length, equals(1));

      // Clear repository
      await repository.clearAllData();
      expect(await repository.getActiveFoods(), isEmpty);
      expect(await repository.getActivityHistory(), isEmpty);

      // Import back
      final importSuccess = await repository.importData(exported);
      expect(importSuccess, isTrue);

      final restoredActive = await repository.getActiveFoods();
      expect(restoredActive.length, equals(1));
      expect(restoredActive.first.name, equals('Almond Milk'));
      expect(restoredActive.first.consumedQuantity, equals(0.5));

      final restoredActivities = await repository.getActivityHistory();
      expect(restoredActivities.length, equals(1));
      expect(restoredActivities.first.foodName, equals('Almond Milk'));
    });

    test('Clear all data wipes all records', () async {
      await repository.insertFood(
        FoodItem(
          id: 'food-clean-1',
          name: 'Bread',
          category: FoodCategory.bakery,
          initialQuantity: 1,
          unit: FoodUnit.piece,
          createdAt: now,
          updatedAt: now,
        ),
      );

      expect(await repository.getActiveFoods(), isNotEmpty);
      await repository.clearAllData();
      expect(await repository.getActiveFoods(), isEmpty);
    });
  });
}
