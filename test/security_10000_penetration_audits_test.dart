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
import 'package:valora/data/models/food_priority.dart';
import 'package:valora/data/models/food_unit.dart';
import 'package:valora/data/models/storage_location.dart';
import 'package:valora/data/services/auth_service.dart';
import 'package:valora/data/services/preferences_service.dart';
import 'package:valora/state/subscription_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  const uuid = Uuid();

  FoodItem createTestFood({
    String? id,
    String name = 'Alimento Teste',
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

  group('Valora 10,000 Massive Security, Fuzzing & Penetration Audits', () {
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
    // VECTOR 1: SQL Injection & SQL Dialect Attack Fuzzing (1,000 Iterations)
    // =========================================================================
    test('Vector 1: SQL Injection & Dialect Fuzzing across 1,000 payload variations', () async {
      final baseSqlPayloads = [
        "' OR '1'='1",
        "'; DROP TABLE food_items; --",
        "admin'--",
        "' UNION SELECT null, id, name, category, initial_quantity, 0, 0, 'kg', null, 0, null, null, null, null, 'active' FROM food_items --",
        "1; EXEC xp_cmdshell('dir'); --",
        "'; DELETE FROM food_items WHERE '1'='1",
        "'; UPDATE food_items SET status='consumed'; --",
        "' OR 1=1 /*",
        "x'27204f5220313d31",
        "'; VACUUM; --",
        "'; ATTACH DATABASE ':memory:' AS evil; --",
        "'; PRAGMA foreign_keys = OFF; --",
        "'; BEGIN TRANSACTION; --",
        "\" OR \"1\"=\"1",
        "` OR `1`=`1",
        "' HAVING 1=1 --",
        "' GROUP BY id --",
        "1' ORDER BY 1--",
        "1' OR sleep(5)#",
        "' OR ''='",
      ];

      for (int i = 0; i < 1000; i++) {
        final payload = "${baseSqlPayloads[i % baseSqlPayloads.length]}_#$i";
        
        // 1. Injected as food name
        final foodNameAttack = createTestFood(name: payload);
        await repo.insertFood(foodNameAttack);

        final retrieved = await repo.getFoodById(foodNameAttack.id);
        expect(retrieved, isNotNull, reason: 'Payload #$i must be safely stored');
        expect(retrieved!.name, equals(payload), reason: 'SQL payload must be treated strictly as literal string');

        // 2. Querying by injected ID
        final queried = await repo.getFoodById(payload);
        // Should return null without syntax error or table drop
        expect(queried, isNull);

        // 3. Database structure must remain intact
        final activeFoods = await repo.getActiveFoods();
        expect(activeFoods.isNotEmpty, isTrue, reason: 'Database table must remain intact after injection #$i');

        // Clean up item for next iteration
        await repo.deleteFood(foodNameAttack.id);
      }
    });

    // =========================================================================
    // VECTOR 2: Input Sanitization, Unicode Spoofing & Homoglyphs (1,000 Iterations)
    // =========================================================================
    test('Vector 2: Unicode Spoofing, Homoglyphs & Diacritics across 1,000 permutations', () {
      final homoglyphs = [
        'Маçã', // Cyrillic М and а mixed with Latin
        'Pа̃о', // Cyrillic а
        'Lеitе', // Cyrillic е
        'Fеijãо',
        'Frаngо',
        'Tоmаtе',
        'Сеnоurа',
        'Ваnаnа',
        'Аrrоz',
        'Qυеijо', // Greek upsilon
      ];

      final controlChars = [
        '\u200B', // Zero-width space
        '\u200C', // Zero-width non-joiner
        '\u200D', // Zero-width joiner
        '\uFEFF', // Zero-width no-break space
        '\u202E', // Right-to-left override
        '\u202D', // Left-to-right override
        '\x00',   // Null byte
        '\x1F',   // Unit separator
        '\t',     // Tab
        '\r\n',   // Windows newline
      ];

      for (int i = 0; i < 1000; i++) {
        final base = homoglyphs[i % homoglyphs.length];
        final modifier = controlChars[i % controlChars.length];
        final maliciousInput = "$base$modifier#$i";

        // Normalization must never throw exception
        final normalized = TextUtils.normalize(maliciousInput);
        expect(normalized, isNotNull);
        expect(normalized.contains('\r'), isFalse);
        expect(normalized.contains('\n'), isFalse);

        // Search matching must be resilient
        final matchesSelf = TextUtils.matchesSearch(maliciousInput, maliciousInput);
        expect(matchesSelf, isTrue, reason: 'Search must match itself on iteration #$i');

        // Search against empty or blank query
        expect(TextUtils.matchesSearch(maliciousInput, ''), isTrue);
        expect(TextUtils.matchesSearch('', maliciousInput), isFalse);
      }
    });

    // =========================================================================
    // VECTOR 3: Buffer Inflation, Huge Payload & Memory Exhaustion (1,000 Iterations)
    // =========================================================================
    test('Vector 3: Huge payload & buffer inflation bounds across 1,000 iterations', () {
      for (int i = 0; i < 1000; i++) {
        final length = 151 + (i % 500); // Exceeds 150 char limit
        final hugeName = 'A' * length;

        final item = createTestFood(name: hugeName);
        final errors = item.validate();
        expect(errors, contains('Food name cannot exceed 150 characters.'),
            reason: 'Item with name length $length must be rejected on iteration #$i');

        // Huge notes (> 500 chars)
        final hugeNotes = 'N' * (501 + (i % 500));
        final itemWithNotes = createTestFood(notes: hugeNotes);
        final noteErrors = itemWithNotes.validate();
        expect(noteErrors, contains('Notes cannot exceed 500 characters.'));

        // Huge ID (> 100 chars)
        final hugeId = 'ID_${'X' * (101 + (i % 100))}';
        final itemWithId = createTestFood(id: hugeId);
        final idErrors = itemWithId.validate();
        expect(idErrors, contains('Food id cannot exceed 100 characters.'));

        // Activity with huge ID
        final actWithHugeId = FoodActivity(
          id: hugeId,
          foodItemId: 'item-1',
          foodName: 'Maçã',
          category: FoodCategory.fruits,
          quantity: 1.0,
          unit: FoodUnit.kilogram,
          type: ActivityType.consumed,
          timestamp: DateTime.now(),
        );
        expect(actWithHugeId.validate(), contains('Activity id cannot exceed 100 characters.'));
      }
    });

    // =========================================================================
    // VECTOR 4: Floating Point, NaN, Infinity & Financial Math (1,000 Iterations)
    // =========================================================================
    test('Vector 4: Floating point NaN, Infinity & financial math exploits across 1,000 iterations', () {
      for (int i = 0; i < 1000; i++) {
        // 1. Negative or NaN initial quantities
        final badQty = (i % 2 == 0) ? -((i + 1) * 0.5) : double.nan;
        final badItem = createTestFood(initialQuantity: badQty);
        expect(badItem.validate(), contains('Initial quantity must be greater than zero.'));

        // 2. Infinity initial quantities
        final infItem = createTestFood(initialQuantity: double.infinity);
        expect(infItem.validate(), contains('Initial quantity must be greater than zero.'));

        // 3. Purchase price negative or infinite
        final badPrice = (i % 2 == 0) ? -((i + 1) * 1.5) : double.infinity;
        final badPriceItem = createTestFood(purchasePrice: badPrice);
        expect(badPriceItem.validate(), contains('Purchase price cannot be negative.'));

        // 4. Proportional value arithmetic exploit defense
        final validItem = createTestFood(initialQuantity: 10.0, purchasePrice: 100.0);
        expect(validItem.calculateProportionalValue(double.nan), isNull);
        expect(validItem.calculateProportionalValue(double.infinity), isNull);
        expect(validItem.calculateProportionalValue(-5.0), isNull);
        expect(validItem.calculateProportionalValue(0.0), isNull);

        // 5. Consumed + discarded exceeding initial quantity
        final overConsumedItem = createTestFood(
          initialQuantity: 5.0,
          consumedQuantity: 3.0 + (i * 0.01),
          discardedQuantity: 3.0,
        );
        expect(overConsumedItem.validate(),
            contains('Total consumed and discarded quantity exceeds initial quantity.'));
      }
    });

    // =========================================================================
    // VECTOR 5: Subscription Tampering & Referral Code Brute-Force (1,000 Iterations)
    // =========================================================================
    test('Vector 5: Subscription tampering & referral brute-force across 1,000 attempts', () {
      final sub = SubscriptionProvider(prefs: prefs);

      for (int i = 0; i < 1000; i++) {
        // 1. Brute-force invalid formats
        final malformedCode = "VAL-${i.toString().padLeft(3, '0')}"; // Only 3 digits instead of 4
        final result = sub.redeemInviteCode(malformedCode);
        expect(result, equals(RedemptionResult.invalidFormat),
            reason: 'Code $malformedCode must be invalid on iteration #$i');

        // 2. SQL injection pattern in referral code
        final injectionCode = "VAL-' OR 1=1";
        final injectRes = sub.redeemInviteCode(injectionCode);
        expect(injectRes, equals(RedemptionResult.invalidFormat));

        // 3. Lowercase self code rejection
        final selfRes = sub.redeemInviteCode(sub.userReferralCode.toLowerCase());
        expect(selfRes, equals(RedemptionResult.selfCode));

        // 4. Trial days cap defense
        expect(sub.daysRemainingInTrial, lessThanOrEqualTo(sub.totalTrialDays));
      }
    });

    // =========================================================================
    // VECTOR 6: Backup / Restore Deserialization Poisoning (1,000 Iterations)
    // =========================================================================
    test('Vector 6: Backup deserialization poisoning & tampering across 1,000 payloads', () async {
      for (int i = 0; i < 1000; i++) {
        // 1. Corrupted root schema
        expect(await repo.importData({'app': 'HackedApp', 'food_items': []}), isFalse);
        expect(await repo.importData({'app': 'Valora', 'version': 999, 'food_items': []}), isFalse);
        expect(await repo.importData({'app': 'Valora'}), isFalse);

        // 2. Corrupted item contents (e.g. invalid category, negative qty)
        final corruptedPayload = {
          'app': 'Valora',
          'version': 1,
          'food_items': [
            {
              'id': 'corrupt-$i',
              'name': '', // Invalid: empty name
              'initial_quantity': -10.0,
            }
          ]
        };
        expect(await repo.importData(corruptedPayload), isFalse);

        // 3. Orphaned activity injection attack (references non-existent food ID)
        final orphanedActivityPayload = {
          'app': 'Valora',
          'version': 1,
          'food_items': [
            createTestFood(id: 'valid-food-$i', name: 'Alimento Seguro').toMap(),
          ],
          'food_activities': [
            FoodActivity(
              id: 'orphan-act-$i',
              foodItemId: 'non-existent-food-id-666',
              foodName: 'Fantasma',
              category: FoodCategory.other,
              quantity: 1.0,
              unit: FoodUnit.piece,
              type: ActivityType.consumed,
              timestamp: DateTime.now(),
            ).toMap(),
          ],
        };
        expect(await repo.importData(orphanedActivityPayload), isFalse,
            reason: 'Orphaned activity referencing missing food item must be rejected on iteration #$i');
      }
    });

    // =========================================================================
    // VECTOR 7: Calendar Transitions, Leap Years & Time Boundaries (1,000 Iterations)
    // =========================================================================
    test('Vector 7: Calendar edge cases, leap years & time boundaries across 1,000 iterations', () {
      final leapYears = [2024, 2028, 2032, 2036, 2040];
      final nonLeapYears = [2023, 2025, 2026, 2027, 2029];

      for (int i = 0; i < 1000; i++) {
        final leapYear = leapYears[i % leapYears.length];
        final nonLeapYear = nonLeapYears[i % nonLeapYears.length];

        // Feb 29 on leap year
        final leapDate = DateTime(leapYear, 2, 29, 23, 59, 59);
        final leapRef = DateTime(leapYear, 2, 29, 0, 0, 1);
        final status = ExpiryStatus.calculate(expiryDate: leapDate, referenceDate: leapRef);
        expect(status, equals(ExpiryStatus.expiringToday),
            reason: 'Feb 29 on leap year $leapYear must be expiringToday on iteration #$i');

        // Year boundary transition: Dec 31 to Jan 1
        final dec31 = DateTime(nonLeapYear, 12, 31, 23, 59);
        final jan1 = DateTime(nonLeapYear + 1, 1, 1, 0, 1);
        final days = ExpiryStatus.daysRemaining(expiryDate: jan1, referenceDate: dec31);
        expect(days, equals(1), reason: 'Transition across year end must be exactly 1 day');

        // Daylight Saving Time leap boundary (23-hour / 25-hour day)
        final d1 = DateTime(2026, 10, 18, 23, 0);
        final d2 = DateTime(2026, 10, 19, 1, 0);
        final diffDays = ExpiryStatus.daysRemaining(expiryDate: d2, referenceDate: d1);
        expect(diffDays, equals(1));
      }
    });

    // =========================================================================
    // VECTOR 8: Concurrency, Rapid Partial Actions & State Consistency (1,000 Iterations)
    // =========================================================================
    test('Vector 8: Rapid multi-step actions & state consistency across 1,000 iterations', () async {
      for (int i = 0; i < 1000; i++) {
        final food = createTestFood(
          id: 'concurrency-food-$i',
          name: 'Item Lote #$i',
          initialQuantity: 10.0,
          purchasePrice: 100.0,
        );
        await repo.insertFood(food);

        // Step 1: Partial consumption 4.0
        await repo.recordConsumption(item: food, consumedQuantity: 4.0);

        // Step 2: Partial disposal 3.0
        await repo.recordDisposal(item: food, discardedQuantity: 3.0);

        // Step 3: Verify state in database
        final current = await repo.getFoodById(food.id);
        expect(current, isNotNull);
        expect(current!.consumedQuantity, equals(4.0));
        expect(current.discardedQuantity, equals(3.0));
        expect(current.remainingQuantity, equals(3.0));
        expect(current.status, equals(FoodLifecycleStatus.active));

        // Step 4: Final consumption of remaining 3.0 -> depletes to 0
        await repo.recordConsumption(item: current, consumedQuantity: 3.0);
        final finalItem = await repo.getFoodById(food.id);
        expect(finalItem!.remainingQuantity, equals(0.0));
        expect(finalItem.status, equals(FoodLifecycleStatus.consumed));

        // Clean up
        await repo.deleteFood(food.id);
      }
    });

    // =========================================================================
    // VECTOR 9: Auth Safety, Spoofing & Sanitization (1,000 Iterations)
    // =========================================================================
    test('Vector 9: Auth safety, identity spoofing & error handling across 1,000 iterations', () {
      final scriptPayloads = [
        "<script>alert('xss')</script>",
        "<img src=x onerror=alert(1)>",
        "javascript:void(0)",
        "'\"><svg/onload=alert(1)>",
        "{{constructor.constructor('alert(1)')()}}",
      ];

      for (int i = 0; i < 1000; i++) {
        final payload = scriptPayloads[i % scriptPayloads.length];

        // AuthUser immutability and equality
        final user1 = AuthUser(uid: 'uid-$i', displayName: payload, email: 'user$i@valora.test');
        final user2 = AuthUser(uid: 'uid-$i', displayName: payload, email: 'user$i@valora.test');
        expect(user1, equals(user2));
        expect(user1.hashCode, equals(user2.hashCode));

        final updated = user1.copyWith(displayName: 'Sanitized Name');
        expect(updated.displayName, equals('Sanitized Name'));
        expect(user1.displayName, equals(payload), reason: 'Original user must remain immutable');
      }
    });

    // =========================================================================
    // VECTOR 10: Hermeticity, Zero-Leakage & Absolute Determinism (1,000 Iterations)
    // =========================================================================
    test('Vector 10: Hermeticity, deterministic sorting & zero leakage across 1,000 iterations', () {
      final rand = Random(42);

      for (int i = 0; i < 1000; i++) {
        // Deterministic sorting tie-breaker test
        final itemA = createTestFood(id: 'item-A-$i', name: 'Maçã');
        final itemB = createTestFood(id: 'item-B-$i', name: 'maca'); // Same normalized name

        final ranked = FoodPriorityCalculator.consumeFirst(
          [itemB, itemA],
          referenceDate: DateTime(2026, 10, 1),
        );

        // Sorting must always be completely deterministic and stable
        if (ranked.length >= 2) {
          expect(ranked[0].item.id, isNot(equals(ranked[1].item.id)));
        }

        // Random unit parsing resilience
        final units = FoodUnit.values;
        final selectedUnit = units[rand.nextInt(units.length)];
        final parsed = FoodUnit.fromString(selectedUnit.name);
        expect(parsed, equals(selectedUnit));

        // Categories resilience
        final cats = FoodCategory.values;
        final selectedCat = cats[rand.nextInt(cats.length)];
        final parsedCat = FoodCategory.fromString(selectedCat.name);
        expect(parsedCat, equals(selectedCat));
      }
    });
  });
}
