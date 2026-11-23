import 'package:flutter_test/flutter_test.dart';
import 'package:valora/core/utils/currency_formatter.dart';
import 'package:valora/data/models/food_activity.dart';
import 'package:valora/data/models/food_category.dart';
import 'package:valora/data/models/food_item.dart';
import 'package:valora/data/models/food_unit.dart';
import 'package:valora/data/models/storage_location.dart';
import 'mocks/in_memory_food_repository.dart';

void main() {
  group('A. CurrencyFormatter Defensive Resilience', () {
    test('Gracefully formats null as empty string', () {
      expect(CurrencyFormatter.format(null), equals(''));
    });

    test('Formats valid positive, zero, and negative values with default USD', () {
      expect(CurrencyFormatter.format(0.0), contains('0.00'));
      expect(CurrencyFormatter.format(29.99), contains('29.99'));
      expect(CurrencyFormatter.format(-10.50), contains('10.50'));
    });

    test('Formats with custom locale pt_BR', () {
      final formatted = CurrencyFormatter.format(15.50, localeCode: 'pt_BR');
      expect(formatted, contains('15,50'));
      expect(formatted, contains('R\$'));
    });

    test('Handles malformed or unrecognized locale codes without throwing', () {
      final result1 = CurrencyFormatter.format(42.0, localeCode: 'xyz_INVALID_LOCALE_123');
      expect(result1, contains('42.00'));

      final result2 = CurrencyFormatter.format(100.0, localeCode: '@@@malformed###');
      expect(result2, contains('100.00'));
    });
  });

  group('B. Data Import/Export Security & Corruption Prevention', () {
    late InMemoryFoodRepository repo;

    setUp(() {
      repo = InMemoryFoodRepository();
    });

    test('Rejects import when app identifier is missing or mismatched', () async {
      final invalidAppPayload = {
        'app': 'MaliciousApp',
        'version': 1,
        'food_items': [],
      };
      final success = await repo.importData(invalidAppPayload);
      expect(success, isFalse);
    });

    test('Rejects import when food_items payload is missing', () async {
      final missingPayload = {
        'app': 'Valora',
        'version': 1,
      };
      final success = await repo.importData(missingPayload);
      expect(success, isFalse);
    });

    test('Rejects import containing items with invalid business invariants', () async {
      final now = DateTime.now();
      final invalidItemMap = FoodItem(
        id: 'bad-1',
        name: '', // Empty name violates item.validate()
        category: FoodCategory.bakery,
        initialQuantity: -5.0, // Negative initial quantity violates invariants
        unit: FoodUnit.gram,
        createdAt: now,
        updatedAt: now,
      ).toMap();

      final payload = {
        'app': 'Valora',
        'version': 1,
        'food_items': [invalidItemMap],
      };

      final success = await repo.importData(payload);
      expect(success, isFalse);

      final activeFoods = await repo.getActiveFoods();
      expect(activeFoods, isEmpty);
    });

    test('Rejects import containing activities with invalid business invariants', () async {
      final now = DateTime.now();
      final validItemMap = FoodItem(
        id: 'item-1',
        name: 'Rice',
        category: FoodCategory.pantryStaples,
        initialQuantity: 1.0,
        unit: FoodUnit.kilogram,
        createdAt: now,
        updatedAt: now,
      ).toMap();

      final invalidActivityMap = {
        'id': '', // Empty ID violates activity.validate()
        'food_item_id': 'item-1',
        'food_name': 'Rice',
        'category': 'pantryStaples',
        'quantity': -2.0, // Negative quantity
        'unit': 'kilogram',
        'type': 'consumed',
        'timestamp': now.toIso8601String(),
      };

      final payload = {
        'app': 'Valora',
        'version': 1,
        'food_items': [validItemMap],
        'food_activities': [invalidActivityMap],
      };

      final success = await repo.importData(payload);
      expect(success, isFalse);

      final activities = await repo.getActivityHistory();
      expect(activities, isEmpty);
    });

    test('Gracefully parses malformed ISO datetime strings without crashing', () {
      final malformedFoodMap = {
        'id': 'defensive-1',
        'name': 'Oats',
        'category': 'pantryStaples',
        'initial_quantity': 2.0,
        'unit': 'kilogram',
        'created_at': 'NOT_A_DATE',
        'updated_at': '2026-99-99T99:99:99',
        'expiry_date': 'INVALID_EXPIRY',
        'purchase_date': 'CORRUPTED',
      };

      final item = FoodItem.fromMap(malformedFoodMap);
      expect(item.id, equals('defensive-1'));
      expect(item.name, equals('Oats'));
      expect(item.expiryDate, isNull);
      expect(item.purchaseDate, isNull);
      expect(item.createdAt, isA<DateTime>());
      expect(item.updatedAt, isA<DateTime>());

      final malformedActivityMap = {
        'id': 'act-defensive-1',
        'food_item_id': 'defensive-1',
        'food_name': 'Oats',
        'category': 'pantryStaples',
        'quantity': 1.0,
        'unit': 'kilogram',
        'type': 'consumed',
        'timestamp': 'MALFORMED_TIMESTAMP_STR',
      };

      final activity = FoodActivity.fromMap(malformedActivityMap);
      expect(activity.id, equals('act-defensive-1'));
      expect(activity.timestamp, isA<DateTime>());
    });

    test('Atomically replaces dataset upon valid import', () async {
      final now = DateTime.now();
      final initialItem = FoodItem(
        id: 'old-item',
        name: 'Old Apple',
        category: FoodCategory.fruits,
        initialQuantity: 3.0,
        unit: FoodUnit.piece,
        createdAt: now,
        updatedAt: now,
      );
      await repo.insertFood(initialItem);
      expect(await repo.getActiveFoods(), hasLength(1));

      final newItem = FoodItem(
        id: 'imported-item',
        name: 'Imported Bread',
        category: FoodCategory.bakery,
        initialQuantity: 1.0,
        unit: FoodUnit.piece,
        storageLocation: StorageLocation.pantry,
        createdAt: now,
        updatedAt: now,
      );

      final exportPayload = {
        'app': 'Valora',
        'version': 1,
        'food_items': [newItem.toMap()],
        'food_activities': [],
      };

      final success = await repo.importData(exportPayload);
      expect(success, isTrue);

      final current = await repo.getActiveFoods();
      expect(current, hasLength(1));
      expect(current.first.id, equals('imported-item'));
      expect(current.first.name, equals('Imported Bread'));
    });
  });

  group('C. Math & Decimal Precision in Proportional Values', () {
    test('Calculates proportional values with floating-point stability', () {
      final now = DateTime.now();
      final item = FoodItem(
        id: 'prop-item',
        name: 'Olive Oil',
        category: FoodCategory.pantryStaples,
        initialQuantity: 1.0, // 1 liter
        unit: FoodUnit.liter,
        purchasePrice: 30.00,
        createdAt: now,
        updatedAt: now,
      );

      // Consume 0.33 liters
      final consumedVal = item.calculateProportionalValue(0.33);
      expect(consumedVal, isNotNull);
      expect(consumedVal!, closeTo(9.90, 0.01));

      // Discard remaining 0.67 liters
      final discardedVal = item.calculateProportionalValue(0.67);
      expect(discardedVal, isNotNull);
      expect(discardedVal!, closeTo(20.10, 0.01));

      // Sum equals original purchase price
      expect(consumedVal + discardedVal, closeTo(30.00, 0.01));
    });

    test('Returns null proportional value when purchase price is not set', () {
      final now = DateTime.now();
      final item = FoodItem(
        id: 'no-price-item',
        name: 'Garden Rosemary',
        category: FoodCategory.pantryStaples,
        initialQuantity: 50.0,
        unit: FoodUnit.gram,
        purchasePrice: null,
        createdAt: now,
        updatedAt: now,
      );

      expect(item.calculateProportionalValue(25.0), isNull);
    });
  });
}
