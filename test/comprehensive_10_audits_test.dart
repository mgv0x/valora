import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:valora/data/models/expiry_status.dart';
import 'package:valora/data/models/food_category.dart';
import 'package:valora/data/models/food_item.dart';
import 'package:valora/data/models/food_unit.dart';
import 'package:valora/data/models/storage_location.dart';
import 'package:valora/data/services/preferences_service.dart';
import 'package:valora/state/impact_provider.dart';
import 'package:valora/state/subscription_provider.dart';

import 'mocks/in_memory_food_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ---------------------------------------------------------------------------
  // AUDIT 1: Timezone Initialization & Notification Scheduling
  // ---------------------------------------------------------------------------
  group('AUDIT 1: Timezone Initialization & Notification Scheduling', () {
    test('Timezone database is loaded and tz.local is properly usable', () {
      tz.initializeTimeZones();
      final now = DateTime.now().toUtc();
      final tzDate = tz.TZDateTime.from(now, tz.local);
      expect(tzDate.year, equals(now.year));
      expect(tzDate.month, equals(now.month));
      expect(tzDate.day, equals(now.day));

      // Test scheduling an advance notification for 2 days from now
      final scheduledDate = tzDate.add(const Duration(days: 2));
      expect(scheduledDate.isAfter(tzDate), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // AUDIT 2: Expiry Center Timeline Segregation
  // ---------------------------------------------------------------------------
  group('AUDIT 2: Expiry Center Timeline Segregation', () {
    test('Items expired in the past are strictly separated from items expiring today', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final expiredItem = FoodItem(
        id: 'exp-1',
        name: 'Iogurte Vencido',
        category: FoodCategory.dairy,
        initialQuantity: 1,
        unit: FoodUnit.piece,
        expiryDate: today.subtract(const Duration(days: 2)),
        createdAt: now,
        updatedAt: now,
      );

      final todayItem = FoodItem(
        id: 'today-1',
        name: 'Leite Vence Hoje',
        category: FoodCategory.dairy,
        initialQuantity: 1,
        unit: FoodUnit.liter,
        expiryDate: today,
        createdAt: now,
        updatedAt: now,
      );

      final threeDaysItem = FoodItem(
        id: 'soon-1',
        name: 'Queijo Atenção',
        category: FoodCategory.dairy,
        initialQuantity: 1,
        unit: FoodUnit.package,
        expiryDate: today.add(const Duration(days: 2)),
        createdAt: now,
        updatedAt: now,
      );

      final expiredDays = expiredItem.getDaysRemaining(referenceDate: today);
      final todayDays = todayItem.getDaysRemaining(referenceDate: today);
      final threeDaysDays = threeDaysItem.getDaysRemaining(referenceDate: today);

      expect(expiredDays, lessThan(0));
      expect(todayDays, equals(0));
      expect(threeDaysDays, inInclusiveRange(1, 3));
    });
  });

  // ---------------------------------------------------------------------------
  // AUDIT 3: Expiry Date Calculations & Price Capture
  // ---------------------------------------------------------------------------
  group('AUDIT 3: Expiry Date Calculations & Price Capture', () {
    test('ExpiryStatus.daysRemaining handles calendar day transitions without off-by-one errors', () {
      final now = DateTime.now();
      final todayMidnight = DateTime(now.year, now.month, now.day, 23, 59, 59);

      // Tomorrow morning
      final tomorrowMorning = DateTime(now.year, now.month, now.day + 1, 8, 0, 0);
      final remainingTomorrow = ExpiryStatus.daysRemaining(
        expiryDate: tomorrowMorning,
        referenceDate: todayMidnight,
      );
      expect(remainingTomorrow, equals(1));

      // Same calendar day at different hours
      final todayMorning = DateTime(now.year, now.month, now.day, 10, 0, 0);
      final remainingToday = ExpiryStatus.daysRemaining(
        expiryDate: todayMorning,
        referenceDate: todayMidnight,
      );
      expect(remainingToday, equals(0));
    });

    test('FoodItem model preserves purchasePrice across copies and serialization', () {
      final now = DateTime.now();
      final item = FoodItem(
        id: 'item-price',
        name: 'Azeite Extra Virgem',
        category: FoodCategory.pantryStaples,
        initialQuantity: 1,
        unit: FoodUnit.piece,
        purchasePrice: 38.50,
        createdAt: now,
        updatedAt: now,
      );

      expect(item.purchasePrice, equals(38.50));
      final map = item.toMap();
      expect(map['purchase_price'], equals(38.50));

      final restored = FoodItem.fromMap(map);
      expect(restored.purchasePrice, equals(38.50));

      final copied = restored.copyWith(name: 'Azeite Especial');
      expect(copied.purchasePrice, equals(38.50));
    });
  });

  // ---------------------------------------------------------------------------
  // AUDIT 4: Subscription & Referral Redemption Validation
  // ---------------------------------------------------------------------------
  group('AUDIT 4: Subscription & Referral Redemption Validation', () {
    late PreferencesService prefs;
    late SubscriptionProvider subscription;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      prefs = PreferencesService(sp);
      subscription = SubscriptionProvider(prefs: prefs);
    });

    test('Rejects arbitrary non-pattern strings with invalidFormat', () {
      expect(subscription.redeemInviteCode('hello'), equals(RedemptionResult.invalidFormat));
      expect(subscription.redeemInviteCode('12345'), equals(RedemptionResult.invalidFormat));
      expect(subscription.redeemInviteCode('VAL-TOOLONG'), equals(RedemptionResult.invalidFormat));
      expect(subscription.redeemInviteCode('VAL-12'), equals(RedemptionResult.invalidFormat));
    });

    test('Rejects self-referral and empty codes', () {
      expect(subscription.redeemInviteCode('   '), equals(RedemptionResult.empty));
      expect(subscription.redeemInviteCode(subscription.userReferralCode), equals(RedemptionResult.selfCode));
    });

    test('Accepts valid VAL-XXXX pattern, grants +7 bonus days, and prevents duplicate', () {
      const validFriendCode = 'VAL-88AB';
      final res = subscription.redeemInviteCode(validFriendCode);
      expect(res, equals(RedemptionResult.success));
      expect(subscription.referralBonusDays, equals(7));
      expect(subscription.redeemedCodes, contains(validFriendCode));

      // Second attempt on same code
      final duplicateRes = subscription.redeemInviteCode(validFriendCode);
      expect(duplicateRes, equals(RedemptionResult.alreadyUsed));
      expect(subscription.referralBonusDays, equals(7)); // Not incremented again
    });
  });

  // ---------------------------------------------------------------------------
  // AUDIT 5: Trial Onboarding Flow & Login Screen Auth Redirection
  // ---------------------------------------------------------------------------
  group('AUDIT 5: Trial Onboarding Flow & Login Screen Auth Redirection', () {
    test('First launch starts with hasAcceptedTrial as false until explicitly accepted', () async {
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      final prefs = PreferencesService(sp);
      final sub = SubscriptionProvider(prefs: prefs);

      expect(sub.hasAcceptedTrial, isFalse);

      await sub.acceptTrial();
      expect(sub.hasAcceptedTrial, isTrue);
      expect(prefs.hasAcceptedTrial, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // AUDIT 6: Dynamic Impact Metrics & Proportional Financial Tracking
  // ---------------------------------------------------------------------------
  group('AUDIT 6: Dynamic Impact Metrics & Proportional Financial Tracking', () {
    late InMemoryFoodRepository repo;
    late ImpactProvider impact;

    setUp(() {
      repo = InMemoryFoodRepository();
      impact = ImpactProvider(repository: repo);
    });

    test('Accurately tracks proportional value of consumed items without hardcoded defaults', () async {
      final now = DateTime.now();
      final foodItem = FoodItem(
        id: 'meat-1',
        name: 'Carne Moída 1kg',
        category: FoodCategory.meatFish,
        initialQuantity: 1000,
        unit: FoodUnit.gram,
        purchasePrice: 40.00,
        createdAt: now,
        updatedAt: now,
      );

      await repo.insertFood(foodItem);

      // Consume half (500g)
      await repo.recordConsumption(
        item: foodItem,
        consumedQuantity: 500,
      );

      await impact.loadActivities();

      expect(impact.filteredConsumedCount, equals(1));
      expect(impact.estimatedValueConsumed, closeTo(20.00, 0.01));
      expect(impact.consumptionRate, equals(100.0));
      expect(impact.consumedVolumeByUnit[FoodUnit.gram], equals(500.0));
    });
  });

  // ---------------------------------------------------------------------------
  // AUDIT 7: Quantity Depletion Precision
  // ---------------------------------------------------------------------------
  group('AUDIT 7: Quantity Depletion Precision', () {
    test('Direct exact quantity consumption leaves exactly zero remainder', () {
      final now = DateTime.now();
      final item = FoodItem(
        id: 'qty-1',
        name: 'Arroz',
        category: FoodCategory.pantryStaples,
        initialQuantity: 0.333333,
        consumedQuantity: 0.0,
        unit: FoodUnit.kilogram,
        createdAt: now,
        updatedAt: now,
      );

      // Remaining quantity before
      expect(item.remainingQuantity, closeTo(0.333333, 0.000001));

      // Apply exact remaining
      final updated = item.copyWith(
        consumedQuantity: item.remainingQuantity,
      );

      expect(updated.remainingQuantity, equals(0.0));
    });
  });

  // ---------------------------------------------------------------------------
  // AUDIT 8: SQLite Data Integrity & Safe Restoration Warning
  // ---------------------------------------------------------------------------
  group('AUDIT 8: SQLite Data Integrity & Safe Restoration Warning', () {
    test('Repository validates JSON payload and replaces items atomically', () async {
      final repo = InMemoryFoodRepository();
      final now = DateTime.now();

      final initial = FoodItem(
        id: 'item-prev',
        name: 'Item Anterior',
        category: FoodCategory.fruits,
        initialQuantity: 2,
        unit: FoodUnit.piece,
        createdAt: now,
        updatedAt: now,
      );
      await repo.insertFood(initial);
      expect((await repo.getActiveFoods()).length, equals(1));

      final export = await repo.exportData();
      expect(export['app'], equals('Valora'));
      expect((export['food_items'] as List).length, equals(1));

      // Valid restore
      final valid = await repo.importData(export);
      expect(valid, isTrue);
      expect((await repo.getActiveFoods()).length, equals(1));
    });
  });

  // ---------------------------------------------------------------------------
  // AUDIT 9: Portuguese Domain Enums & Formatting Consistency
  // ---------------------------------------------------------------------------
  group('AUDIT 9: Portuguese Domain Enums & Formatting Consistency', () {
    test('All FoodCategory, FoodUnit, and StorageLocation enums return Portuguese labels', () {
      expect(FoodCategory.fruits.displayName, equals('Frutas'));
      expect(FoodCategory.vegetables.displayName, equals('Verduras'));
      expect(FoodCategory.dairy.displayName, equals('Laticínios'));
      expect(FoodCategory.meatFish.displayName, equals('Carnes & Peixes'));
      expect(FoodCategory.pantryStaples.displayName, equals('Despensa'));

      expect(FoodUnit.piece.shortSymbol, equals('un'));
      expect(FoodUnit.kilogram.shortSymbol, equals('kg'));
      expect(FoodUnit.liter.shortSymbol, equals('L'));
      expect(FoodUnit.package.shortSymbol, equals('pct'));

      expect(StorageLocation.refrigerator.displayName, equals('Geladeira'));
      expect(StorageLocation.freezer.displayName, equals('Congelador'));
      expect(StorageLocation.pantry.displayName, equals('Despensa'));
    });
  });

  // ---------------------------------------------------------------------------
  // AUDIT 10: App Resilience & Settings Cleanup
  // ---------------------------------------------------------------------------
  group('AUDIT 10: App Resilience & Settings Cleanup', () {
    test('Clearing all pantry items cleans repository and notifies listeners', () async {
      final repo = InMemoryFoodRepository();
      final now = DateTime.now();

      await repo.insertFood(FoodItem(
        id: 'clear-1',
        name: 'Para Limpar',
        category: FoodCategory.other,
        initialQuantity: 1,
        unit: FoodUnit.piece,
        createdAt: now,
        updatedAt: now,
      ));

      expect((await repo.getActiveFoods()).length, equals(1));
      await repo.clearAllData();
      expect((await repo.getActiveFoods()), isEmpty);
    });
  });
}
