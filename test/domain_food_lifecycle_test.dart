import 'package:flutter_test/flutter_test.dart';
import 'package:valora/data/models/food_category.dart';
import 'package:valora/data/models/food_item.dart';
import 'package:valora/data/models/food_unit.dart';
import 'package:valora/data/models/storage_location.dart';

void main() {
  group('FoodItem Domain Validation & Lifecycle', () {
    final now = DateTime(2026, 10, 8, 12, 0);

    test('Valid item returns no validation errors', () {
      final item = FoodItem(
        id: '123',
        name: 'Whole Milk',
        category: FoodCategory.dairy,
        initialQuantity: 2.0,
        unit: FoodUnit.liter,
        expiryDate: now.add(const Duration(days: 5)),
        purchasePrice: 4.50,
        storageLocation: StorageLocation.refrigerator,
        createdAt: now,
        updatedAt: now,
      );

      expect(item.validate(), isEmpty);
      expect(item.remainingQuantity, equals(2.0));
      expect(item.hasRemaining, isTrue);
      expect(item.isActive, isTrue);
    });

    test('Invalid blank name returns validation error', () {
      final item = FoodItem(
        id: '124',
        name: '   ',
        category: FoodCategory.bakery,
        initialQuantity: 1.0,
        unit: FoodUnit.piece,
        createdAt: now,
        updatedAt: now,
      );

      final errors = item.validate();
      expect(errors, contains('Food name cannot be empty.'));
    });

    test('Zero or negative quantity returns validation error', () {
      final item = FoodItem(
        id: '125',
        name: 'Apples',
        category: FoodCategory.fruits,
        initialQuantity: 0.0,
        unit: FoodUnit.kilogram,
        createdAt: now,
        updatedAt: now,
      );

      final errors = item.validate();
      expect(errors, contains('Initial quantity must be greater than zero.'));
    });

    test('Negative purchase price returns validation error', () {
      final item = FoodItem(
        id: '126',
        name: 'Bread',
        category: FoodCategory.bakery,
        initialQuantity: 1.0,
        unit: FoodUnit.piece,
        purchasePrice: -3.50,
        createdAt: now,
        updatedAt: now,
      );

      final errors = item.validate();
      expect(errors, contains('Purchase price cannot be negative.'));
    });

    test('Partial consumption reduces remaining quantity correctly', () {
      final item = FoodItem(
        id: '127',
        name: 'Rice',
        category: FoodCategory.pantryStaples,
        initialQuantity: 5.0,
        consumedQuantity: 1.5,
        unit: FoodUnit.kilogram,
        createdAt: now,
        updatedAt: now,
      );

      expect(item.remainingQuantity, closeTo(3.5, 0.001));
      expect(item.hasRemaining, isTrue);
      expect(item.isActive, isTrue);
    });

    test('Full consumption depletes item remaining quantity', () {
      final item = FoodItem(
        id: '128',
        name: 'Yogurt',
        category: FoodCategory.dairy,
        initialQuantity: 2.0,
        consumedQuantity: 2.0,
        unit: FoodUnit.piece,
        createdAt: now,
        updatedAt: now,
        status: FoodLifecycleStatus.consumed,
      );

      expect(item.remainingQuantity, equals(0.0));
      expect(item.hasRemaining, isFalse);
      expect(item.isActive, isFalse);
    });

    test('Combined consumption and disposal updates remaining quantity', () {
      final item = FoodItem(
        id: '129',
        name: 'Tomatoes',
        category: FoodCategory.vegetables,
        initialQuantity: 10.0,
        consumedQuantity: 6.0,
        discardedQuantity: 2.5,
        unit: FoodUnit.piece,
        createdAt: now,
        updatedAt: now,
      );

      expect(item.remainingQuantity, closeTo(1.5, 0.001));
      expect(item.validate(), isEmpty);
    });

    test('Consumed + discarded quantity exceeding initial returns error', () {
      final item = FoodItem(
        id: '130',
        name: 'Bananas',
        category: FoodCategory.fruits,
        initialQuantity: 5.0,
        consumedQuantity: 4.0,
        discardedQuantity: 2.0,
        unit: FoodUnit.piece,
        createdAt: now,
        updatedAt: now,
      );

      final errors = item.validate();
      expect(errors, contains('Total consumed and discarded quantity exceeds initial quantity.'));
    });

    test('Proportional value calculation is exact', () {
      final item = FoodItem(
        id: '131',
        name: 'Steak',
        category: FoodCategory.meatFish,
        initialQuantity: 4.0,
        unit: FoodUnit.piece,
        purchasePrice: 40.00,
        createdAt: now,
        updatedAt: now,
      );

      // Consuming 1 of 4 pieces is 25% of 40 = 10.0
      expect(item.calculateProportionalValue(1.0), closeTo(10.0, 0.001));
      // Consuming 2.5 pieces is 25.0
      expect(item.calculateProportionalValue(2.5), closeTo(25.0, 0.001));
      // Consuming without purchase price is null
      final itemNoPrice = item.copyWith(clearPurchasePrice: true);
      expect(itemNoPrice.calculateProportionalValue(1.0), isNull);
    });

    test('Serialization toMap and fromMap roundtrip preserves all data', () {
      final original = FoodItem(
        id: 'uuid-test-123',
        name: 'Greek Yogurt',
        category: FoodCategory.dairy,
        initialQuantity: 4.0,
        consumedQuantity: 1.0,
        discardedQuantity: 0.5,
        unit: FoodUnit.package,
        expiryDate: DateTime(2026, 10, 20),
        purchasePrice: 12.99,
        storageLocation: StorageLocation.refrigerator,
        purchaseDate: DateTime(2026, 10, 5),
        notes: 'Low fat, high protein',
        createdAt: now,
        updatedAt: now,
        status: FoodLifecycleStatus.active,
      );

      final map = original.toMap();
      final restored = FoodItem.fromMap(map);

      expect(restored.id, equals(original.id));
      expect(restored.name, equals(original.name));
      expect(restored.category, equals(original.category));
      expect(restored.initialQuantity, equals(original.initialQuantity));
      expect(restored.consumedQuantity, equals(original.consumedQuantity));
      expect(restored.discardedQuantity, equals(original.discardedQuantity));
      expect(restored.unit, equals(original.unit));
      expect(restored.expiryDate, equals(original.expiryDate));
      expect(restored.purchasePrice, equals(original.purchasePrice));
      expect(restored.storageLocation, equals(original.storageLocation));
      expect(restored.purchaseDate, equals(original.purchaseDate));
      expect(restored.notes, equals(original.notes));
      expect(restored.status, equals(original.status));
    });
  });
}
