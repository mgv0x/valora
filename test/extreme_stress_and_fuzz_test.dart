import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:valora/data/local/sqlite_food_repository.dart';
import 'package:valora/data/models/expiry_status.dart';
import 'package:valora/data/models/food_category.dart';
import 'package:valora/data/models/food_item.dart';
import 'package:valora/data/models/food_unit.dart';
import 'package:valora/data/models/storage_location.dart';
import 'package:valora/data/services/notification_service.dart';
import 'package:valora/data/services/preferences_service.dart';
import 'package:valora/state/pantry_provider.dart';
import 'package:valora/state/settings_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('EXTREME TEST: Unicode & Malformed String Fuzzing', () {
    late SqliteFoodRepository repository;

    setUp(() async {
      repository = SqliteFoodRepository(inMemory: true);
      await repository.init();
    });

    tearDown(() async {
      await repository.close();
    });

    test('Fuzzes food item names and notes with complex unicode, emojis, and control chars', () async {
      final fuzzInputs = [
        '🍎🍌🍇 Strawberries & Blueberries 🍓🫐',
        'Complex Ligature: 👨‍👩‍👦‍👦 🏳️‍⚧️ 🏃‍♀️➡️🏠',
        'Zalgo Text: H̷́e̵̅l̷̛l̶͊o̶̕ ̶͝W̸̎o̴̓r̵̈́l̶̋d̵̂',
        'RTL and BiDi: \u202Eمرحبا بالعالم \u202CLeftToRight',
        'Zero-Width and Whitespace: \u200B\u200C\u200D\uFEFF Test \t\r\n',
        'CJK ideographs: 龙井茶 抹茶蛋糕 生鱼片',
        'Devanagari: जैविक दूध और ताजे सेब',
        'Cyrillic: Органическое молоко и свежий сыр',
        'Special Symbols: © ® ™ § ¶ † ‡ • ‰ ‱ ‼ ‽ € \$ ¥ £',
        'Quotation marks: """\'\'\'` ` `',
      ];

      for (int i = 0; i < fuzzInputs.length; i++) {
        final input = fuzzInputs[i];
        final item = FoodItem(
          id: 'fuzz-$i',
          name: input.length > 150 ? input.substring(0, 150) : input,
          category: FoodCategory.values[i % FoodCategory.values.length],
          initialQuantity: (i + 1).toDouble(),
          unit: FoodUnit.values[i % FoodUnit.values.length],
          notes: input.length > 500 ? input.substring(0, 500) : input,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        );

        await repository.insertFood(item);
        final fetched = await repository.getFoodById(item.id);
        expect(fetched, isNotNull);
        expect(fetched!.name, item.name);
        expect(fetched.notes, item.notes);
      }

      final all = await repository.getActiveFoods();
      expect(all.length, fuzzInputs.length);
    });
  });

  group('EXTREME TEST: Massive Inventory High-Load Stress (1,000 Items)', () {
    late SqliteFoodRepository repository;

    setUp(() async {
      repository = SqliteFoodRepository(inMemory: true);
      await repository.init();
    });

    tearDown(() async {
      await repository.close();
    });

    test('Performs high-volume operations with 1,000 items without memory or integrity failure', () async {
      final random = Random(42);
      const itemCount = 1000;
      final now = DateTime(2026, 5, 1);

      // 1. Bulk insertion simulation
      for (int i = 0; i < itemCount; i++) {
        final expiryDaysOffset = random.nextInt(60) - 15; // some expired, some fresh
        final item = FoodItem(
          id: 'load-item-$i',
          name: 'Food Item Batch $i',
          category: FoodCategory.values[random.nextInt(FoodCategory.values.length)],
          initialQuantity: (random.nextInt(10) + 1).toDouble(),
          unit: FoodUnit.values[random.nextInt(FoodUnit.values.length)],
          expiryDate: now.add(Duration(days: expiryDaysOffset)),
          purchasePrice: (random.nextInt(50) + 5).toDouble(),
          storageLocation: StorageLocation.values[random.nextInt(StorageLocation.values.length)],
          createdAt: now.subtract(const Duration(days: 10)),
          updatedAt: now,
        );

        await repository.insertFood(item);
      }

      // 2. Diagnostics verify exactly 1,000 items
      final diag = await repository.getStorageDiagnostics();
      expect(diag['total_items'], itemCount);
      expect(diag['active_items'], itemCount);

      // 3. Fast Retrieval under load
      final stopwatch = Stopwatch()..start();
      final activeFoods = await repository.getActiveFoods();
      stopwatch.stop();

      expect(activeFoods.length, itemCount);
      expect(stopwatch.elapsedMilliseconds, lessThan(3000), reason: 'Querying 1000 items must be fast');

      // 4. Grouping by Expiry Status under load
      final expired = activeFoods.where((f) => f.getExpiryStatus(referenceDate: now) == ExpiryStatus.expired).toList();
      final expiringToday = activeFoods.where((f) => f.getExpiryStatus(referenceDate: now) == ExpiryStatus.expiringToday).toList();
      final expiringSoon = activeFoods.where((f) => f.getExpiryStatus(referenceDate: now) == ExpiryStatus.expiringSoon).toList();
      final fresh = activeFoods.where((f) => f.getExpiryStatus(referenceDate: now) == ExpiryStatus.fresh).toList();

      expect(expired.length + expiringToday.length + expiringSoon.length + fresh.length, itemCount);

      // 5. High-Frequency Partial Consumption and Disposal
      for (int i = 0; i < 50; i++) {
        final itm = await repository.getFoodById('load-item-$i');
        if (itm != null) {
          await repository.recordConsumption(
            item: itm,
            consumedQuantity: 0.5,
            notes: 'Partial consumption stress test #$i',
          );
        }
      }

      final activities = await repository.getActivityHistory();
      expect(activities.length, 50);

      // 6. Database Storage Optimization under load (VACUUM & ANALYZE)
      await repository.optimizeStorage();
      final afterOpt = await repository.getStorageDiagnostics();
      expect(afterOpt['total_items'], itemCount);
    });
  });

  group('EXTREME TEST: Temporal & Calendar Boundary Conditions', () {
    test('Calculates leap day transitions accurately (Feb 28 vs Feb 29 on leap years)', () {
      // Leap year 2028: Feb 29 exists
      final refFeb28 = DateTime(2028, 2, 28, 12, 0);
      final expiryFeb29 = DateTime(2028, 2, 29, 23, 59);

      final daysLeap = ExpiryStatus.daysRemaining(
        expiryDate: expiryFeb29,
        referenceDate: refFeb28,
      );
      expect(daysLeap, 1);

      final statusLeap = ExpiryStatus.calculate(
        expiryDate: expiryFeb29,
        referenceDate: refFeb28,
        warningThresholdDays: 3,
      );
      expect(statusLeap, ExpiryStatus.expiringSoon);

      // Non-leap year 2026: Feb 28 to March 1
      final ref2026 = DateTime(2026, 2, 28, 12, 0);
      final expiryMarch1 = DateTime(2026, 3, 1, 23, 59);

      final daysNonLeap = ExpiryStatus.daysRemaining(
        expiryDate: expiryMarch1,
        referenceDate: ref2026,
      );
      expect(daysNonLeap, 1);
    });

    test('Exact hour boundary: 00:00:00 vs 23:59:59 on the same calendar day evaluates to expiringToday', () {
      final refMorning = DateTime(2026, 10, 24, 0, 0, 1);
      final expiryEndOfDay = DateTime(2026, 10, 24, 23, 59, 59);

      final status = ExpiryStatus.calculate(
        expiryDate: expiryEndOfDay,
        referenceDate: refMorning,
        warningThresholdDays: 3,
      );
      expect(status, ExpiryStatus.expiringToday);

      final days = ExpiryStatus.daysRemaining(
        expiryDate: expiryEndOfDay,
        referenceDate: refMorning,
      );
      expect(days, 0);
    });

    test('Far future century date boundary (2099-12-31)', () {
      final ref = DateTime(2026, 1, 1);
      final farFuture = DateTime(2099, 12, 31);

      final status = ExpiryStatus.calculate(
        expiryDate: farFuture,
        referenceDate: ref,
      );
      expect(status, ExpiryStatus.fresh);
      final days = ExpiryStatus.daysRemaining(expiryDate: farFuture, referenceDate: ref);
      expect(days, greaterThan(25000));
    });
  });

  group('EXTREME TEST: Concurrent Operations & Race Resilience', () {
    late SqliteFoodRepository repository;
    late PreferencesService preferences;
    late LocalNotificationServiceImpl notifications;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      repository = SqliteFoodRepository(inMemory: true);
      await repository.init();
      preferences = await PreferencesService.create();
      notifications = LocalNotificationServiceImpl();
    });

    tearDown(() async {
      await repository.close();
    });

    test('50 concurrent async read/write operations execute without deadlocks', () async {
      // Seed 20 items
      for (int i = 0; i < 20; i++) {
        await repository.insertFood(
          FoodItem(
            id: 'race-$i',
            name: 'Race Item $i',
            category: FoodCategory.bakery,
            initialQuantity: 10.0,
            unit: FoodUnit.piece,
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
          ),
        );
      }

      // Concurrently query, update, and consume across async futures
      final itemsToConsume = await repository.getActiveFoods();
      final futures = <Future>[];
      for (final itm in itemsToConsume) {
        futures.add(repository.getFoodById(itm.id));
        futures.add(repository.recordConsumption(item: itm, consumedQuantity: 0.1));
        futures.add(repository.getActiveFoods());
        futures.add(repository.exportData());
      }

      final results = await Future.wait(futures);
      expect(results.length, 80);

      final active = await repository.getActiveFoods();
      expect(active.length, 20);
    });

    test('Rapid consecutive locale switching across all 11 global languages produces zero errors', () async {
      final settings = SettingsProvider(prefs: preferences, notifications: notifications);
      final allCodes = [
        'pt', 'en', 'es', 'fr', 'de', 'it', 'zh', 'ja', 'ru', 'ar', 'hi', null,
      ];

      // Stress cycle 3 times across all 12 options (36 rapid switches)
      for (int cycle = 0; cycle < 3; cycle++) {
        for (final code in allCodes) {
          await settings.setLocale(code);
          if (code == null) {
            expect(settings.locale, isNull);
          } else {
            expect(settings.locale?.languageCode, code);
          }
        }
      }
    });

    test('PantryProvider survives simultaneous filter changes, search queries, and items loading', () async {
      final pantry = PantryProvider(
        repository: repository,
        notificationService: notifications,
        preferencesService: preferences,
      );

      await pantry.loadItems();

      // Trigger rapid asynchronous UI mutations simultaneously
      pantry.setSearchQuery('Tomato');
      pantry.setSelectedCategory(FoodCategory.vegetables);
      pantry.setSortOption(PantrySortOption.nameAZ);
      pantry.setSortOption(PantrySortOption.expirySoonest);
      pantry.setSelectedCategory(null);
      pantry.setSearchQuery('');

      expect(pantry.items, isEmpty);
      expect(pantry.searchQuery, '');
      expect(pantry.selectedCategory, isNull);
    });
  });
}
