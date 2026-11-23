import 'package:flutter_test/flutter_test.dart';
import 'package:valora/data/models/food_activity.dart';
import 'package:valora/data/models/food_category.dart';
import 'package:valora/data/models/food_unit.dart';
import 'package:valora/state/impact_provider.dart';
import 'mocks/in_memory_food_repository.dart';

void main() {
  group('A. ImpactProvider Deterministic Metrics & Temporal Filtering', () {
    late InMemoryFoodRepository repo;
    late ImpactProvider provider;
    final fixedNow = DateTime(2026, 10, 11, 12, 0);

    setUp(() async {
      repo = InMemoryFoodRepository();
      provider = ImpactProvider(repository: repo, referenceDate: fixedNow);
    });

    test('Initial empty state returns zero metrics and null consumption rate', () async {
      await provider.loadActivities();

      expect(provider.activities, isEmpty);
      expect(provider.filteredActivities, isEmpty);
      expect(provider.recordedConsumedCount, equals(0));
      expect(provider.recordedDiscardedCount, equals(0));
      expect(provider.totalRecordedActions, equals(0));
      expect(provider.consumptionRate, isNull);
      expect(provider.estimatedValueConsumed, equals(0.0));
      expect(provider.estimatedValueDiscarded, equals(0.0));
      expect(provider.consumedVolumeByUnit, isEmpty);
      expect(provider.discardedVolumeByUnit, isEmpty);
    });

    test('Filters activities deterministically across last 7 days and last 30 days', () async {
      // Activity 1: Today (2026-10-11)
      final actToday = FoodActivity(
        id: 'act-1',
        foodItemId: 'food-1',
        foodName: 'Fresh Strawberries',
        category: FoodCategory.fruits,
        quantity: 250.0,
        unit: FoodUnit.gram,
        type: ActivityType.consumed,
        timestamp: fixedNow.subtract(const Duration(hours: 2)),
        estimatedValue: 8.50,
      );

      // Activity 2: 5 days ago (2026-10-06)
      final act5DaysAgo = FoodActivity(
        id: 'act-2',
        foodItemId: 'food-2',
        foodName: 'Yogurt',
        category: FoodCategory.dairy,
        quantity: 1.0,
        unit: FoodUnit.piece,
        type: ActivityType.consumed,
        timestamp: fixedNow.subtract(const Duration(days: 5)),
        estimatedValue: 4.00,
      );

      // Activity 3: 15 days ago (2026-09-26)
      final act15DaysAgo = FoodActivity(
        id: 'act-3',
        foodItemId: 'food-3',
        foodName: 'Spinach',
        category: FoodCategory.vegetables,
        quantity: 200.0,
        unit: FoodUnit.gram,
        type: ActivityType.discarded,
        timestamp: fixedNow.subtract(const Duration(days: 15)),
        estimatedValue: 5.00,
      );

      // Activity 4: 45 days ago (2026-08-27)
      final act45DaysAgo = FoodActivity(
        id: 'act-4',
        foodItemId: 'food-4',
        foodName: 'Old Bread',
        category: FoodCategory.bakery,
        quantity: 1.0,
        unit: FoodUnit.piece,
        type: ActivityType.discarded,
        timestamp: fixedNow.subtract(const Duration(days: 45)),
        estimatedValue: 6.00,
      );

      // Populate in repository
      final exportData = {
        'app': 'Valora',
        'version': 1,
        'food_items': [],
        'food_activities': [
          actToday.toMap(),
          act5DaysAgo.toMap(),
          act15DaysAgo.toMap(),
          act45DaysAgo.toMap(),
        ],
      };
      await repo.importData(exportData);
      await provider.loadActivities();

      expect(provider.totalRecordedActions, equals(4));

      // 1. All Time
      provider.setPeriodFilter(ActivityPeriodFilter.allTime);
      expect(provider.filteredActivities.length, equals(4));
      expect(provider.estimatedValueConsumed, equals(12.50));
      expect(provider.estimatedValueDiscarded, equals(11.00));
      expect(provider.consumptionRate, equals(50.0)); // 2 of 4

      // 2. Last 30 Days (excludes act45DaysAgo)
      provider.setPeriodFilter(ActivityPeriodFilter.last30Days);
      expect(provider.filteredActivities.length, equals(3));
      expect(provider.filteredConsumedCount, equals(2));
      expect(provider.filteredDiscardedCount, equals(1));
      expect(provider.estimatedValueConsumed, equals(12.50));
      expect(provider.estimatedValueDiscarded, equals(5.00));
      expect(provider.consumptionRate, closeTo(66.66, 0.1));

      // 3. Last 7 Days (excludes act15DaysAgo and act45DaysAgo)
      provider.setPeriodFilter(ActivityPeriodFilter.last7Days);
      expect(provider.filteredActivities.length, equals(2));
      expect(provider.filteredConsumedCount, equals(2));
      expect(provider.filteredDiscardedCount, equals(0));
      expect(provider.estimatedValueConsumed, equals(12.50));
      expect(provider.estimatedValueDiscarded, equals(0.00));
      expect(provider.consumptionRate, equals(100.0));
    });

    test('Calculates unit-segregated volume breakdowns correctly', () async {
      final actGrams = FoodActivity(
        id: 'act-g1',
        foodItemId: 'f1',
        foodName: 'Flour',
        category: FoodCategory.pantryStaples,
        quantity: 500.0,
        unit: FoodUnit.gram,
        type: ActivityType.consumed,
        timestamp: fixedNow,
      );

      final actGrams2 = FoodActivity(
        id: 'act-g2',
        foodItemId: 'f2',
        foodName: 'Sugar',
        category: FoodCategory.pantryStaples,
        quantity: 250.0,
        unit: FoodUnit.gram,
        type: ActivityType.consumed,
        timestamp: fixedNow,
      );

      final actLiters = FoodActivity(
        id: 'act-l1',
        foodItemId: 'f3',
        foodName: 'Milk',
        category: FoodCategory.dairy,
        quantity: 1.5,
        unit: FoodUnit.liter,
        type: ActivityType.consumed,
        timestamp: fixedNow,
      );

      await repo.importData({
        'app': 'Valora',
        'version': 1,
        'food_items': [],
        'food_activities': [actGrams.toMap(), actGrams2.toMap(), actLiters.toMap()],
      });
      await provider.loadActivities();

      final volumeMap = provider.consumedVolumeByUnit;
      expect(volumeMap[FoodUnit.gram], equals(750.0));
      expect(volumeMap[FoodUnit.liter], equals(1.5));
      expect(volumeMap[FoodUnit.piece], isNull);
    });
  });
}
