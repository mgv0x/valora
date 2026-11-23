import 'package:flutter_test/flutter_test.dart';
import 'package:valora/data/models/food_category.dart';
import 'package:valora/data/models/food_item.dart';
import 'package:valora/data/models/food_priority.dart';
import 'package:valora/data/models/food_unit.dart';

void main() {
  group('FoodPriority Domain Logic & Prioritization Calculator', () {
    final refDate = DateTime(2026, 10, 10, 12, 0); // Reference date: Oct 10, 2026

    test('Classifies expired foods correctly (negative days remaining)', () {
      final item = FoodItem(
        id: '1',
        name: 'Expired Milk',
        category: FoodCategory.dairy,
        initialQuantity: 1.0,
        unit: FoodUnit.liter,
        expiryDate: DateTime(2026, 10, 9), // Expired yesterday
        createdAt: refDate,
        updatedAt: refDate,
      );

      final priority = FoodPriorityCalculator.classify(item, referenceDate: refDate);
      expect(priority, equals(FoodPriority.expired));
      expect(priority.isUrgent, isTrue);
      expect(priority.urgencyRank, equals(0));
    });

    test('Classifies foods expiring today correctly (0 days remaining)', () {
      final item = FoodItem(
        id: '2',
        name: 'Bread Expiring Today',
        category: FoodCategory.bakery,
        initialQuantity: 1.0,
        unit: FoodUnit.piece,
        expiryDate: DateTime(2026, 10, 10, 23, 59), // Today
        createdAt: refDate,
        updatedAt: refDate,
      );

      final priority = FoodPriorityCalculator.classify(item, referenceDate: refDate);
      expect(priority, equals(FoodPriority.consumeToday));
      expect(priority.isUrgent, isTrue);
      expect(priority.urgencyRank, equals(1));
    });

    test('Classifies high priority foods (1 to 3 days remaining)', () {
      final item1 = FoodItem(
        id: '3a',
        name: 'Strawberries (1 day)',
        category: FoodCategory.fruits,
        initialQuantity: 1.0,
        unit: FoodUnit.package,
        expiryDate: DateTime(2026, 10, 11),
        createdAt: refDate,
        updatedAt: refDate,
      );

      final item3 = FoodItem(
        id: '3b',
        name: 'Cheese (3 days)',
        category: FoodCategory.dairy,
        initialQuantity: 1.0,
        unit: FoodUnit.gram,
        expiryDate: DateTime(2026, 10, 13),
        createdAt: refDate,
        updatedAt: refDate,
      );

      expect(
        FoodPriorityCalculator.classify(item1, referenceDate: refDate),
        equals(FoodPriority.highPriority),
      );
      expect(
        FoodPriorityCalculator.classify(item3, referenceDate: refDate),
        equals(FoodPriority.highPriority),
      );
    });

    test('Classifies attention foods (4 to 7 days remaining)', () {
      final item4 = FoodItem(
        id: '4a',
        name: 'Yogurt (4 days)',
        category: FoodCategory.dairy,
        initialQuantity: 1.0,
        unit: FoodUnit.piece,
        expiryDate: DateTime(2026, 10, 14),
        createdAt: refDate,
        updatedAt: refDate,
      );

      final item7 = FoodItem(
        id: '4b',
        name: 'Butter (7 days)',
        category: FoodCategory.dairy,
        initialQuantity: 1.0,
        unit: FoodUnit.package,
        expiryDate: DateTime(2026, 10, 17),
        createdAt: refDate,
        updatedAt: refDate,
      );

      expect(
        FoodPriorityCalculator.classify(item4, referenceDate: refDate),
        equals(FoodPriority.attention),
      );
      expect(
        FoodPriorityCalculator.classify(item7, referenceDate: refDate),
        equals(FoodPriority.attention),
      );
    });

    test('Classifies on-track foods (more than 7 days remaining)', () {
      final item = FoodItem(
        id: '5',
        name: 'Canned Beans',
        category: FoodCategory.pantryStaples,
        initialQuantity: 2.0,
        unit: FoodUnit.piece,
        expiryDate: DateTime(2026, 10, 25), // 15 days
        createdAt: refDate,
        updatedAt: refDate,
      );

      final priority = FoodPriorityCalculator.classify(item, referenceDate: refDate);
      expect(priority, equals(FoodPriority.onTrack));
      expect(priority.isUrgent, isFalse);
    });

    test('Classifies foods without expiry date as unknownExpiry, never expired or urgent', () {
      final item = FoodItem(
        id: '6',
        name: 'Table Salt',
        category: FoodCategory.pantryStaples,
        initialQuantity: 1.0,
        unit: FoodUnit.kilogram,
        expiryDate: null,
        createdAt: refDate,
        updatedAt: refDate,
      );

      final priority = FoodPriorityCalculator.classify(item, referenceDate: refDate);
      expect(priority, equals(FoodPriority.unknownExpiry));
      expect(priority.isUrgent, isFalse);
    });

    test('Excludes consumed, discarded, or fully depleted items from consumeFirst', () {
      final activeUrgent = FoodItem(
        id: 'act-1',
        name: 'Ripe Bananas',
        category: FoodCategory.fruits,
        initialQuantity: 5.0,
        unit: FoodUnit.piece,
        expiryDate: DateTime(2026, 10, 11), // 1 day
        createdAt: refDate,
        updatedAt: refDate,
      );

      final consumedItem = FoodItem(
        id: 'con-1',
        name: 'Eaten Yogurt',
        category: FoodCategory.dairy,
        initialQuantity: 1.0,
        consumedQuantity: 1.0,
        unit: FoodUnit.piece,
        expiryDate: DateTime(2026, 10, 9), // expired but consumed
        status: FoodLifecycleStatus.consumed,
        createdAt: refDate,
        updatedAt: refDate,
      );

      final discardedItem = FoodItem(
        id: 'dis-1',
        name: 'Thrown Bread',
        category: FoodCategory.bakery,
        initialQuantity: 1.0,
        discardedQuantity: 1.0,
        unit: FoodUnit.piece,
        expiryDate: DateTime(2026, 10, 9),
        status: FoodLifecycleStatus.discarded,
        createdAt: refDate,
        updatedAt: refDate,
      );

      final result = FoodPriorityCalculator.consumeFirst(
        [activeUrgent, consumedItem, discardedItem],
        referenceDate: refDate,
      );

      expect(result.length, equals(1));
      expect(result.first.item.name, equals('Ripe Bananas'));
    });

    test('Ranks items by urgency tier, then remaining days, then quantity, then name', () {
      final expired = FoodItem(
        id: 'r1',
        name: 'Old Ham',
        category: FoodCategory.meatFish,
        initialQuantity: 1.0,
        unit: FoodUnit.package,
        expiryDate: DateTime(2026, 10, 8), // -2 days
        createdAt: refDate,
        updatedAt: refDate,
      );

      final today = FoodItem(
        id: 'r2',
        name: 'Fresh Bread',
        category: FoodCategory.bakery,
        initialQuantity: 1.0,
        unit: FoodUnit.piece,
        expiryDate: DateTime(2026, 10, 10), // 0 days
        createdAt: refDate,
        updatedAt: refDate,
      );

      final highTomorrowSmall = FoodItem(
        id: 'r3',
        name: 'Avocado Small',
        category: FoodCategory.fruits,
        initialQuantity: 1.0,
        unit: FoodUnit.piece,
        expiryDate: DateTime(2026, 10, 11), // 1 day
        createdAt: refDate,
        updatedAt: refDate,
      );

      final highTomorrowLarge = FoodItem(
        id: 'r4',
        name: 'Avocado Large',
        category: FoodCategory.fruits,
        initialQuantity: 5.0,
        unit: FoodUnit.piece,
        expiryDate: DateTime(2026, 10, 11), // 1 day
        createdAt: refDate,
        updatedAt: refDate,
      );

      final result = FoodPriorityCalculator.consumeFirst(
        [highTomorrowSmall, expired, today, highTomorrowLarge],
        referenceDate: refDate,
      );

      expect(result.map((pf) => pf.item.name).toList(), [
        'Old Ham', // Tier 0 (expired)
        'Fresh Bread', // Tier 1 (today)
        'Avocado Large', // Tier 2 (1 day, larger qty 5.0)
        'Avocado Small', // Tier 2 (1 day, smaller qty 1.0)
      ]);
    });

    test('Builds appropriate PriorityInsight for different pantry states', () {
      final emptyInsight = FoodPriorityCalculator.buildInsight([]);
      expect(emptyInsight.kind, equals(PriorityInsightKind.noneUrgent));

      final pfExpired = PrioritizedFood(
        item: FoodItem(
          id: '1',
          name: 'Item 1',
          category: FoodCategory.other,
          initialQuantity: 1,
          unit: FoodUnit.piece,
          expiryDate: DateTime(2026, 10, 8),
          createdAt: refDate,
          updatedAt: refDate,
        ),
        priority: FoodPriority.expired,
        daysRemaining: -2,
      );

      final expiredInsight = FoodPriorityCalculator.buildInsight([pfExpired]);
      expect(expiredInsight.kind, equals(PriorityInsightKind.expired));
      expect(expiredInsight.expiredCount, equals(1));
    });
  });
}
