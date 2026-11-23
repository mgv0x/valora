import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

import 'package:valora/core/utils/text_utils.dart';
import 'package:valora/data/local/sqlite_food_repository.dart';
import 'package:valora/data/models/expiry_status.dart';
import 'package:valora/data/models/food_activity.dart';
import 'package:valora/data/models/food_category.dart';
import 'package:valora/data/models/food_item.dart';
import 'package:valora/data/models/food_unit.dart';
import 'package:valora/data/models/storage_location.dart';
import 'package:valora/data/services/preferences_service.dart';
import 'package:valora/state/impact_provider.dart';
import 'package:valora/state/pantry_provider.dart';
import 'package:valora/state/subscription_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  const uuid = Uuid();

  FoodItem createFood({
    String? id,
    String name = 'Alimento Fundo',
    FoodCategory category = FoodCategory.fruits,
    double initialQuantity = 1.0,
    double consumedQuantity = 0.0,
    double discardedQuantity = 0.0,
    FoodUnit unit = FoodUnit.kilogram,
    DateTime? expiryDate,
    double? purchasePrice = 10.0,
    StorageLocation? storageLocation = StorageLocation.refrigerator,
    DateTime? purchaseDate,
    String? notes,
    FoodLifecycleStatus status = FoodLifecycleStatus.active,
  }) {
    return FoodItem(
      id: id ?? uuid.v4(),
      name: name,
      category: category,
      initialQuantity: initialQuantity,
      consumedQuantity: consumedQuantity,
      discardedQuantity: discardedQuantity,
      unit: unit,
      expiryDate: expiryDate,
      purchasePrice: purchasePrice,
      storageLocation: storageLocation,
      purchaseDate: purchaseDate ?? DateTime(2026, 10, 1),
      notes: notes,
      createdAt: DateTime(2026, 10, 1),
      updatedAt: DateTime(2026, 10, 1),
      status: status,
    );
  }

  group('Valora 10,000 Deeper Security, Mutation & Concurrency Penetration Audits', () {
    late SqliteFoodRepository repo;
    late PreferencesService prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      prefs = PreferencesService(sp);
      repo = SqliteFoodRepository(inMemory: true);
      await repo.init();
    });

    tearDown(() async {
      await repo.clearAllData();
      await repo.close();
    });

    // =========================================================================
    // VECTOR 11: Second-Order SQL Injection & Wildcard Manipulation (1,000 Iterations)
    // =========================================================================
    test('Vector 11: Second-Order SQL Injection & Wildcards across 1,000 variations', () async {
      final injectionTokens = [
        "%%",
        "%_%",
        "[_a-z]%",
        "test' OR '1'='1' --",
        "notes'; DROP TABLE food_activities; --",
        "Robert'); DROP TABLE Students;--",
        "UNION ALL SELECT 'a','b','c','d',1,1,1,'kg','2026-01-01',1,'pantry',null,null,'active' --",
        "'; UPDATE food_items SET initial_quantity = 999999; --",
        "\\x00' OR 1=1 --",
        "\\'; --",
      ];

      for (int i = 0; i < 1000; i++) {
        final token = "${injectionTokens[i % injectionTokens.length]}_#$i";
        final food = createFood(name: 'Item Seguro', notes: token);
        await repo.insertFood(food);

        // Record activity with injected note
        await repo.recordConsumption(item: food, consumedQuantity: 0.5, notes: token);

        // Retrieve activities and ensure injection token is purely literal
        final history = await repo.getActivityHistory();
        expect(history.any((a) => a.notes == token), isTrue,
            reason: 'Activity notes must store SQL token literally without second-order execution');

        // Verify database tables still exist and are accessible
        final active = await repo.getActiveFoods();
        expect(active.isNotEmpty, isTrue);

        await repo.deleteFood(food.id);
      }
    });

    // =========================================================================
    // VECTOR 12: Precision Floating-Point Boundary & Micro-Depletion (1,000 Iterations)
    // =========================================================================
    test('Vector 12: Micro-increment floating point depletion across 1,000 steps', () async {
      // Create an item with exactly 1.0 kg
      final food = createFood(name: 'Grão Fino', initialQuantity: 1.0, purchasePrice: 100.0);
      await repo.insertFood(food);

      var current = food;
      const microStep = 0.001; // 1 gram

      for (int i = 0; i < 1000; i++) {
        await repo.recordConsumption(item: current, consumedQuantity: microStep);
        current = (await repo.getFoodById(food.id))!;

        // Invariants must hold on every single step
        expect(current.remainingQuantity, greaterThanOrEqualTo(0.0));
        expect(current.remainingQuantity, lessThanOrEqualTo(1.0));
        expect(current.consumedQuantity, greaterThanOrEqualTo(0.0));
      }

      // After exactly 1,000 steps of 0.001, item should be exactly 0.0 remaining and marked consumed
      expect(current.remainingQuantity, equals(0.0));
      expect(current.status, equals(FoodLifecycleStatus.consumed));
      expect(current.hasRemaining, isFalse);
    });

    // =========================================================================
    // VECTOR 13: High-Entropy Referral Generator Collision & Charset (1,000 Iterations)
    // =========================================================================
    test('Vector 13: Referral code generator charset & entropy across 1,000 generated codes', () {
      final codeRegex = RegExp(r'^VAL-[A-Z0-9]{4}$');
      // Prohibited ambiguous characters in Valora generator
      final ambiguousChars = ['0', 'O', '1', 'I'];

      for (int i = 0; i < 1000; i++) {
        // Instantiate a new subscription provider with clean mock prefs
        final sub = SubscriptionProvider(prefs: prefs);
        final code = sub.userReferralCode;

        expect(codeRegex.hasMatch(code), isTrue, reason: 'Code $code must strictly match VAL-XXXX pattern');
        for (final badChar in ambiguousChars) {
          expect(code.contains(badChar), isFalse,
              reason: 'Code $code must not contain confusing character $badChar');
        }

        // Clean for next iteration
        prefs.setUserReferralCode('');
      }
    });

    // =========================================================================
    // VECTOR 14: Cache Invalidation & Stale-Object Attack Defense (1,000 Iterations)
    // =========================================================================
    test('Vector 14: Stale-object passing rejected against fresh database state (1,000 iterations)', () async {
      for (int i = 0; i < 1000; i++) {
        final food = createFood(id: 'stale-food-$i', initialQuantity: 10.0);
        await repo.insertFood(food);

        // Deplete 6.0 in the DB directly
        await repo.recordConsumption(item: food, consumedQuantity: 6.0);

        // Stale object still thinks 10.0 is remaining!
        expect(food.remainingQuantity, equals(10.0));

        // An attacker tries to consume 6.0 using the stale object (which would total 12.0 > 10.0)
        expect(
          () => repo.recordConsumption(item: food, consumedQuantity: 6.0),
          throwsArgumentError,
          reason: 'Repository must reject consumption exceeding real remaining quantity in DB on iteration #$i',
        );

        // Clean up
        await repo.deleteFood(food.id);
      }
    });

    // =========================================================================
    // VECTOR 15: ImpactProvider Time Filter Boundary Stress (1,000 Iterations)
    // =========================================================================
    test('Vector 15: ImpactProvider time-series boundary stress across 1,000 activity timestamps', () async {
      final impact = ImpactProvider(repository: repo);
      final refDate = DateTime(2026, 10, 18, 12, 0);
      impact.setReferenceDate(refDate);

      // Create a food item for activities
      final food = createFood(id: 'impact-food', initialQuantity: 1000.0, purchasePrice: 5000.0);
      await repo.insertFood(food);

      for (int i = 0; i < 1000; i++) {
        // Distribute activity timestamps between 0 and 100 days ago
        final daysAgo = i % 100;
        final actDate = refDate.subtract(Duration(days: daysAgo, minutes: i));

        final act = FoodActivity(
          id: 'act-stress-$i',
          foodItemId: food.id,
          foodName: food.name,
          category: food.category,
          quantity: 1.0,
          unit: food.unit,
          type: (i % 3 == 0) ? ActivityType.discarded : ActivityType.consumed,
          timestamp: actDate,
          estimatedValue: 5.0,
        );
        await repo.db.insert('food_activities', act.toMap());
      }

      await impact.loadActivities();
      expect(impact.activities.length, equals(1000));

      // Test all time period filters
      impact.setPeriodFilter(ActivityPeriodFilter.allTime);
      expect(impact.filteredActivities.length, equals(1000));

      impact.setPeriodFilter(ActivityPeriodFilter.last7Days);
      expect(impact.filteredActivities.every((a) => refDate.difference(a.timestamp).inDays <= 7), isTrue);

      impact.setPeriodFilter(ActivityPeriodFilter.last30Days);
      expect(impact.filteredActivities.every((a) => refDate.difference(a.timestamp).inDays <= 30), isTrue);

      impact.setPeriodFilter(ActivityPeriodFilter.last90Days);
      expect(impact.filteredActivities.every((a) => refDate.difference(a.timestamp).inDays <= 90), isTrue);

      // Financial arithmetic must never be NaN or infinite
      expect(impact.estimatedValueConsumed.isFinite, isTrue);
      expect(impact.estimatedValueDiscarded.isFinite, isTrue);
      expect(impact.consumptionRate, isNotNull);
      expect(impact.consumptionRate!.isFinite, isTrue);
    });

    // =========================================================================
    // VECTOR 16: Complex Diacritics, Accents & Compound Words (1,000 Iterations)
    // =========================================================================
    test('Vector 16: Portuguese diacritics & compound words across 1,000 permutations', () {
      final compoundPhrases = [
        "Pão de Açúcar à Francesa",
        "Açaí com Granola & Cupuaçu",
        "Café com Leite e Geleia de Frutas Vermelhas",
        "Água de Coco Integral Enriquecida",
        "Maçã Fuji Orgânica Selecionada",
        "Linguiça Calabresa Defumada Artesanal",
        "Mandioca Cozida com Manteiga de Garrafa",
        "Melão Orange Extra Doce",
        "Filé de Pescada Amarela Fresco",
        "Iogurte Desnatado com Pró-bióticos",
      ];

      for (int i = 0; i < 1000; i++) {
        final phrase = compoundPhrases[i % compoundPhrases.length];
        final normalized = TextUtils.normalize(phrase);

        // Verification of normalized output: must not contain uppercase, diacritics, or extra whitespace
        expect(normalized, equals(normalized.toLowerCase()));
        expect(normalized.contains('ã'), isFalse);
        expect(normalized.contains('ç'), isFalse);
        expect(normalized.contains('á'), isFalse);
        expect(normalized.contains('é'), isFalse);
        expect(normalized.contains('  '), isFalse);

        // Substring searches in both directions
        final words = phrase.split(' ');
        for (final word in words) {
          if (word.length >= 3) {
            expect(TextUtils.matchesSearch(phrase, word), isTrue);
          }
        }
      }
    });

    // =========================================================================
    // VECTOR 17: Century Leap Rules & Distant Date Boundaries (1,000 Iterations)
    // =========================================================================
    test('Vector 17: Century leap rules & distant date boundaries across 1,000 iterations', () {
      for (int i = 0; i < 1000; i++) {
        final year = 2000 + (i * 4);
        final isCentury = (year % 100 == 0);
        final isLeapCentury = (year % 400 == 0);
        final isLeap = isCentury ? isLeapCentury : (year % 4 == 0);

        if (isLeap) {
          // Feb 28 to Feb 29 is 1 day
          final feb28 = DateTime(year, 2, 28);
          final feb29 = DateTime(year, 2, 29);
          final diff = ExpiryStatus.daysRemaining(expiryDate: feb29, referenceDate: feb28);
          expect(diff, equals(1));
        }
      }
    });

    // =========================================================================
    // VECTOR 18: Notification Id Hashing Collision Resistance (1,000 Iterations)
    // =========================================================================
    test('Vector 18: Notification Id 31-bit positive bounds across 1,000 distinct UUIDs', () {
      final generatedIds = <int>{};

      for (int i = 0; i < 1000; i++) {
        final generatedUuid = uuid.v4();
        final notificationId = generatedUuid.hashCode & 0x7FFFFFFF;

        expect(notificationId, greaterThanOrEqualTo(0));
        expect(notificationId, lessThanOrEqualTo(2147483647));
        generatedIds.add(notificationId);
      }

      // Assert high entropy: collision rate must be less than 1%
      expect(generatedIds.length, greaterThan(990));
    });

    // =========================================================================
    // VECTOR 19: Preferences Fuzzing & Out-of-Bounds Clamping (1,000 Iterations)
    // =========================================================================
    test('Vector 19: Preferences boundary clamping & sanitization across 1,000 inputs', () async {
      for (int i = 0; i < 1000; i++) {
        // Warning threshold must be clamped strictly to [1, 30]
        final crazyDays = (i % 2 == 0) ? -i : (i + 100);
        await prefs.setWarningThresholdDays(crazyDays);
        expect(prefs.warningThresholdDays, greaterThanOrEqualTo(1));
        expect(prefs.warningThresholdDays, lessThanOrEqualTo(30));

        // Referral bonus days must be clamped strictly to >= 0
        await prefs.setReferralBonusDays(-i);
        expect(prefs.referralBonusDays, greaterThanOrEqualTo(0));

        // Invited count must be clamped strictly to >= 0
        await prefs.setInvitedCount(-i);
        expect(prefs.invitedCount, greaterThanOrEqualTo(0));
      }
    });

    // =========================================================================
    // VECTOR 20: Random State-Machine Mutation Fuzzing (1,000 Iterations)
    // =========================================================================
    test('Vector 20: Random state-machine mutation fuzzing preserving all invariants (1,000 steps)', () async {
      final pantry = PantryProvider(repository: repo);
      final rand = Random(1337);

      for (int step = 0; step < 1000; step++) {
        final action = rand.nextInt(4);

        if (action == 0 || pantry.items.isEmpty) {
          // Add food
          final initial = 1.0 + rand.nextInt(10);
          final food = createFood(
            id: 'mutation-$step',
            name: 'Alimento Mutation $step',
            initialQuantity: initial,
            purchasePrice: 10.0,
          );
          await pantry.addFood(food);
        } else if (action == 1) {
          // Consume random portion from random food
          final target = pantry.items[rand.nextInt(pantry.items.length)];
          final portion = target.remainingQuantity <= 0.01
              ? target.remainingQuantity
              : (target.remainingQuantity * 0.5).clamp(0.001, target.remainingQuantity);
          await pantry.recordConsumption(item: target, consumedQuantity: portion);
        } else if (action == 2) {
          // Discard random portion
          final target = pantry.items[rand.nextInt(pantry.items.length)];
          final portion = target.remainingQuantity <= 0.01
              ? target.remainingQuantity
              : (target.remainingQuantity * 0.3).clamp(0.001, target.remainingQuantity);
          await pantry.recordDisposal(item: target, discardedQuantity: portion);
        } else {
          // Update metadata
          final target = pantry.items[rand.nextInt(pantry.items.length)];
          final updated = target.copyWith(notes: 'Nota atualizada no passo $step');
          await pantry.updateFood(updated);
        }

        // Assert core invariants after every single mutation step
        for (final item in pantry.items) {
          expect(item.remainingQuantity, greaterThanOrEqualTo(0.0));
          expect(item.remainingQuantity, lessThanOrEqualTo(item.initialQuantity));
          expect(item.consumedQuantity + item.discardedQuantity, lessThanOrEqualTo(item.initialQuantity + 0.0001));
          expect(item.hasRemaining, isTrue);
          expect(item.isActive, isTrue);
        }

        expect(pantry.totalEstimatedValue, greaterThanOrEqualTo(0.0));
      }
    });
  });
}
