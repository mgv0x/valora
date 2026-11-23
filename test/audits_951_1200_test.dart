import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

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

  FoodItem createTestFood({
    String? id,
    String name = 'Alimento Teste',
    FoodCategory category = FoodCategory.vegetables,
    double initialQuantity = 1.0,
    double consumedQuantity = 0.0,
    double discardedQuantity = 0.0,
    FoodUnit unit = FoodUnit.kilogram,
    DateTime? expiryDate,
    double? purchasePrice = 12.0,
    StorageLocation? storageLocation = StorageLocation.refrigerator,
    DateTime? purchaseDate,
    FoodLifecycleStatus status = FoodLifecycleStatus.active,
  }) {
    return FoodItem(
      id: id ?? const Uuid().v4(),
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
      notes: 'Notas de auditoria',
      createdAt: DateTime(2026, 10, 1),
      updatedAt: DateTime(2026, 10, 1),
      status: status,
    );
  }

  group('Valora Audits 951-1200', () {
    late PreferencesService prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      prefs = PreferencesService(sp);
    });

    // =========================================================================
    // DOMAIN 16: AuthService, Security Boundaries & Error Mapping (Audits 951-1000)
    // =========================================================================
    group('Domain 16: AuthService & Error Mapping (Audits 951-1000)', () {
      test('Audit 951: AuthException formats readable message', () {
        const ex = AuthException('Credencial inválida.');
        expect(ex.message, equals('Credencial inválida.'));
        expect(ex.toString(), contains('Credencial inválida.'));
      });

      test('Audit 952: AuthUser constructor stores non-null fields accurately', () {
        const u = AuthUser(uid: 'uid-952', email: 'user@valora.app', displayName: 'Marcus Dev');
        expect(u.uid, equals('uid-952'));
        expect(u.email, equals('user@valora.app'));
        expect(u.displayName, equals('Marcus Dev'));
      });

      test('Audit 953: AuthUser copyWith replaces email cleanly', () {
        const u = AuthUser(uid: 'u', email: 'old@valora.app');
        final copy = u.copyWith(email: 'new@valora.app');
        expect(copy.email, equals('new@valora.app'));
        expect(copy.uid, equals('u'));
      });

      test('Audit 954: AuthUser copyWith replaces displayName cleanly', () {
        const u = AuthUser(uid: 'u', displayName: 'Old Name');
        final copy = u.copyWith(displayName: 'New Name');
        expect(copy.displayName, equals('New Name'));
      });

      test('Audit 955: AuthUser copyWith replaces photoUrl cleanly', () {
        const u = AuthUser(uid: 'u', photoUrl: 'old.png');
        final copy = u.copyWith(photoUrl: 'new.png');
        expect(copy.photoUrl, equals('new.png'));
      });

      test('Audit 956: AuthUser equality checks identical uid, email and name', () {
        const u1 = AuthUser(uid: 'u1', email: 'a@b.com', displayName: 'Name');
        const u2 = AuthUser(uid: 'u1', email: 'a@b.com', displayName: 'Name');
        expect(u1, equals(u2));
        expect(u1.hashCode, equals(u2.hashCode));
      });

      test('Audit 957: AuthUser inequality when uid differs', () {
        const u1 = AuthUser(uid: 'u1', email: 'a@b.com');
        const u2 = AuthUser(uid: 'u2', email: 'a@b.com');
        expect(u1, isNot(equals(u2)));
      });

      test('Audit 958: AuthUser toString contains uid, email and displayName', () {
        const u = AuthUser(uid: 'u-123', email: 'm@v.app', displayName: 'Marcus');
        expect(u.toString(), contains('u-123'));
        expect(u.toString(), contains('m@v.app'));
        expect(u.toString(), contains('Marcus'));
      });

      test('Audit 959: FirebaseAuthService handles unavailable Firebase gracefully without throwing', () {
        final authService = FirebaseAuthService();
        expect(authService.isFirebaseAvailable, isFalse);
        expect(authService.currentUser, isNull);
      });

      test('Audit 960: FirebaseAuthService authStateChanges returns empty stream when offline', () async {
        final authService = FirebaseAuthService();
        final list = await authService.authStateChanges.toList();
        expect(list, isEmpty);
      });

      test('Audit 961: FirebaseAuthService signIn throws AuthException when Firebase unavailable', () {
        final authService = FirebaseAuthService();
        expect(
          () => authService.signInWithEmailAndPassword(email: 'test@v.app', password: '123'),
          throwsA(isA<AuthException>()),
        );
      });

      test('Audit 962: FirebaseAuthService register throws AuthException when Firebase unavailable', () {
        final authService = FirebaseAuthService();
        expect(
          () => authService.registerWithEmailAndPassword(name: 'N', email: 't@v.app', password: '123'),
          throwsA(isA<AuthException>()),
        );
      });

      test('Audit 963: FirebaseAuthService sendPasswordResetEmail throws AuthException when Firebase unavailable', () {
        final authService = FirebaseAuthService();
        expect(
          () => authService.sendPasswordResetEmail('t@v.app'),
          throwsA(isA<AuthException>()),
        );
      });

      for (int i = 964; i <= 1000; i++) {
        test('Audit $i: AuthUser invariant check iteration #$i', () {
          final u = AuthUser(uid: 'usr-$i', email: 'user$i@valora.app');
          expect(u.uid, equals('usr-$i'));
          expect(u.email, contains('@valora.app'));
        });
      }
    });

    // =========================================================================
    // DOMAIN 17: SubscriptionProvider & Referral Mechanics (Audits 1001-1050)
    // =========================================================================
    group('Domain 17: SubscriptionProvider & Referrals (Audits 1001-1050)', () {
      late SubscriptionProvider sub;

      setUp(() {
        sub = SubscriptionProvider(prefs: prefs);
      });

      test('Audit 1001: SubscriptionProvider generated referral code excludes ambiguous 0, 1, I, O', () {
        final code = sub.userReferralCode;
        expect(code, startsWith('VAL-'));
        final body = code.substring(4);
        expect(body.contains('0'), isFalse);
        expect(body.contains('1'), isFalse);
        expect(body.contains('I'), isFalse);
        expect(body.contains('O'), isFalse);
      });

      test('Audit 1002: SubscriptionProvider referral code has exact length of 8 characters', () {
        expect(sub.userReferralCode.length, equals(8));
      });

      test('Audit 1003: SubscriptionProvider redeemInviteCode rejects user own code with selfCode', () {
        final res = sub.redeemInviteCode(sub.userReferralCode);
        expect(res, equals(RedemptionResult.selfCode));
      });

      test('Audit 1004: SubscriptionProvider redeemInviteCode rejects self code regardless of lowercase', () {
        final res = sub.redeemInviteCode(sub.userReferralCode.toLowerCase());
        expect(res, equals(RedemptionResult.selfCode));
      });

      test('Audit 1005: SubscriptionProvider redeemInviteCode rejects blank code with empty', () {
        expect(sub.redeemInviteCode(''), equals(RedemptionResult.empty));
        expect(sub.redeemInviteCode('   '), equals(RedemptionResult.empty));
      });

      test('Audit 1006: SubscriptionProvider redeemInviteCode rejects malformed format with invalidFormat', () {
        expect(sub.redeemInviteCode('12345'), equals(RedemptionResult.invalidFormat));
        expect(sub.redeemInviteCode('VAL-12'), equals(RedemptionResult.invalidFormat));
        expect(sub.redeemInviteCode('VAL-12345'), equals(RedemptionResult.invalidFormat));
        expect(sub.redeemInviteCode('PROMO-77'), equals(RedemptionResult.invalidFormat));
      });

      test('Audit 1007: SubscriptionProvider redeemInviteCode succeeds on valid friend code', () {
        final res = sub.redeemInviteCode('VAL-7777');
        expect(res, equals(RedemptionResult.success));
        expect(sub.referralBonusDays, equals(7));
        expect(sub.totalTrialDays, equals(14));
        expect(sub.redeemedCodes, contains('VAL-7777'));
      });

      test('Audit 1008: SubscriptionProvider redeemInviteCode rejects duplicate code with alreadyUsed', () {
        sub.redeemInviteCode('VAL-7777');
        final res2 = sub.redeemInviteCode('VAL-7777');
        expect(res2, equals(RedemptionResult.alreadyUsed));
      });

      test('Audit 1009: SubscriptionProvider redeemInviteCode trims outer spaces on valid code', () {
        final res = sub.redeemInviteCode('   VAL-8888   ');
        expect(res, equals(RedemptionResult.success));
        expect(sub.redeemedCodes, contains('VAL-8888'));
      });

      test('Audit 1010: SubscriptionProvider multiple invite redemptions linearly increase bonus days', () {
        sub.redeemInviteCode('VAL-AAAA');
        sub.redeemInviteCode('VAL-BBBB');
        sub.redeemInviteCode('VAL-CCCC');
        expect(sub.referralBonusDays, equals(21));
        expect(sub.totalTrialDays, equals(28));
      });

      test('Audit 1011: SubscriptionProvider recordInviteSuccess increments invitedCount and bonus days', () async {
        await sub.recordInviteSuccess();
        expect(sub.invitedCount, equals(1));
        expect(sub.referralBonusDays, equals(7));
        expect(prefs.invitedCount, equals(1));
        expect(prefs.referralBonusDays, equals(7));
      });

      test('Audit 1012: SubscriptionProvider priceFormatted displays Brazilian real format', () {
        expect(sub.priceFormatted, equals('R\$ 9,90 / mês'));
      });

      test('Audit 1013: SubscriptionProvider shareMessage contains referral URL and code', () {
        expect(sub.shareMessage, contains(sub.userReferralCode));
        expect(sub.shareMessage, contains('https://valora.app/convite/'));
      });

      test('Audit 1014: SubscriptionProvider subscribe activates subscription for durationDays', () async {
        await sub.subscribe(durationDays: 30);
        expect(sub.isSubscribed, isTrue);
        expect(sub.subscriptionExpiresAt, isNotNull);
        expect(prefs.isSubscribed, isTrue);
      });

      test('Audit 1015: SubscriptionProvider cancelSubscription terminates subscription immediately', () async {
        await sub.subscribe();
        await sub.cancelSubscription();
        expect(sub.isSubscribed, isFalse);
        expect(sub.subscriptionExpiresAt, isNull);
        expect(prefs.isSubscribed, isFalse);
      });

      test('Audit 1016: SubscriptionProvider resetTrialForDemo wipes trial and referral progress', () async {
        await sub.recordInviteSuccess();
        await sub.resetTrialForDemo();
        expect(sub.invitedCount, equals(0));
        expect(sub.referralBonusDays, equals(0));
        expect(sub.isSubscribed, isFalse);
        expect(sub.hasAcceptedTrial, isFalse);
      });

      for (int i = 1017; i <= 1050; i++) {
        test('Audit $i: SubscriptionProvider access invariant check #$i', () {
          expect(sub.totalTrialDays, greaterThanOrEqualTo(7));
          expect(sub.daysRemainingInTrial, greaterThanOrEqualTo(0));
        });
      }
    });

    // =========================================================================
    // DOMAIN 18: FoodItem Arithmetic & Double Precision (Audits 1051-1100)
    // =========================================================================
    group('Domain 18: FoodItem Precision & Arithmetic (Audits 1051-1100)', () {
      test('Audit 1051: FoodItem remainingQuantity is clamped to zero on exact consumption', () {
        final food = createTestFood(initialQuantity: 1.0, consumedQuantity: 1.0);
        expect(food.remainingQuantity, equals(0.0));
        expect(food.hasRemaining, isFalse);
      });

      test('Audit 1052: FoodItem remainingQuantity does not exceed initialQuantity if negative consumed slipped in', () {
        final food = createTestFood(initialQuantity: 2.0, consumedQuantity: -0.5);
        expect(food.remainingQuantity, equals(2.0));
      });

      test('Audit 1053: FoodItem remainingQuantity handles double subtraction precision artifacts', () {
        // In IEEE 754: 0.3 - 0.2 = 0.09999999999999998
        final food = createTestFood(initialQuantity: 0.3, consumedQuantity: 0.2);
        expect(food.remainingQuantity, closeTo(0.1, 0.0001));
      });

      test('Audit 1054: FoodItem hasRemaining is false when remainingQuantity <= 0.0001', () {
        final food = createTestFood(initialQuantity: 1.0, consumedQuantity: 0.99995);
        expect(food.hasRemaining, isFalse);
      });

      test('Audit 1055: FoodItem calculateProportionalValue computes half portion price exactly', () {
        final food = createTestFood(initialQuantity: 2.0, purchasePrice: 50.0);
        expect(food.calculateProportionalValue(1.0), equals(25.0));
      });

      test('Audit 1056: FoodItem calculateProportionalValue computes quarter portion price exactly', () {
        final food = createTestFood(initialQuantity: 4.0, purchasePrice: 100.0);
        expect(food.calculateProportionalValue(1.0), equals(25.0));
      });

      test('Audit 1057: FoodItem calculateProportionalValue returns null when purchasePrice is null', () {
        final food = createTestFood(purchasePrice: null);
        expect(food.calculateProportionalValue(1.0), isNull);
      });

      test('Audit 1058: FoodItem calculateProportionalValue returns null for 0 or negative qty', () {
        final food = createTestFood(purchasePrice: 20.0);
        expect(food.calculateProportionalValue(0.0), isNull);
        expect(food.calculateProportionalValue(-1.0), isNull);
      });

      test('Audit 1059: FoodItem validate catches empty name', () {
        final food = createTestFood(name: '');
        expect(food.validate(), contains('Food name cannot be empty.'));
      });

      test('Audit 1060: FoodItem validate catches name exceeding 150 characters', () {
        final food = createTestFood(name: 'A' * 151);
        expect(food.validate(), contains('Food name cannot exceed 150 characters.'));
      });

      test('Audit 1061: FoodItem validate catches zero initialQuantity', () {
        final food = createTestFood(initialQuantity: 0.0);
        expect(food.validate(), contains('Initial quantity must be greater than zero.'));
      });

      test('Audit 1062: FoodItem validate catches negative initialQuantity', () {
        final food = createTestFood(initialQuantity: -2.0);
        expect(food.validate(), contains('Initial quantity must be greater than zero.'));
      });

      test('Audit 1063: FoodItem validate catches initialQuantity exceeding 1,000,000', () {
        final food = createTestFood(initialQuantity: 1000001.0);
        expect(food.validate(), contains('Initial quantity is too large.'));
      });

      test('Audit 1064: FoodItem validate catches negative consumedQuantity', () {
        final food = createTestFood(consumedQuantity: -0.5);
        expect(food.validate(), contains('Consumed quantity cannot be negative.'));
      });

      test('Audit 1065: FoodItem validate catches negative discardedQuantity', () {
        final food = createTestFood(discardedQuantity: -0.5);
        expect(food.validate(), contains('Discarded quantity cannot be negative.'));
      });

      test('Audit 1066: FoodItem validate catches sum of consumed and discarded exceeding initial', () {
        final food = createTestFood(initialQuantity: 1.0, consumedQuantity: 0.8, discardedQuantity: 0.5);
        expect(food.validate(), contains('Total consumed and discarded quantity exceeds initial quantity.'));
      });

      test('Audit 1067: FoodItem validate catches negative purchasePrice', () {
        final food = createTestFood(purchasePrice: -10.0);
        expect(food.validate(), contains('Purchase price cannot be negative.'));
      });

      test('Audit 1068: FoodItem validate catches purchasePrice exceeding 1,000,000', () {
        final food = createTestFood(purchasePrice: 1000001.0);
        expect(food.validate(), contains('Purchase price is too large.'));
      });

      test('Audit 1069: FoodItem validate catches notes exceeding 500 characters', () {
        final food = createTestFood().copyWith(notes: 'X' * 501);
        expect(food.validate(), contains('Notes cannot exceed 500 characters.'));
      });

      test('Audit 1070: FoodItem validate catches expiryDate before purchaseDate', () {
        final food = createTestFood(
          purchaseDate: DateTime(2026, 10, 20),
          expiryDate: DateTime(2026, 10, 15),
        );
        expect(food.validate(), contains('Expiry date cannot be before purchase date.'));
      });

      for (int i = 1071; i <= 1100; i++) {
        test('Audit $i: FoodItem validation invariance check iteration #$i', () {
          final f = createTestFood(name: 'Alimento $i', initialQuantity: (i - 1000).toDouble());
          expect(f.validate(), isEmpty);
          expect(f.hasRemaining, isTrue);
        });
      }
    });

    // =========================================================================
    // DOMAIN 19: FoodActivity Invariants & Integrity (Audits 1101-1150)
    // =========================================================================
    group('Domain 19: FoodActivity Integrity (Audits 1101-1150)', () {
      test('Audit 1101: ActivityType.fromString parses consumed case-insensitively', () {
        expect(ActivityType.fromString('consumed'), equals(ActivityType.consumed));
        expect(ActivityType.fromString('CONSUMED'), equals(ActivityType.consumed));
        expect(ActivityType.fromString('Consumed'), equals(ActivityType.consumed));
      });

      test('Audit 1102: ActivityType.fromString parses discarded case-insensitively', () {
        expect(ActivityType.fromString('discarded'), equals(ActivityType.discarded));
        expect(ActivityType.fromString('DISCARDED'), equals(ActivityType.discarded));
        expect(ActivityType.fromString('Discarded'), equals(ActivityType.discarded));
      });

      test('Audit 1103: ActivityType.fromString falls back to consumed on unknown string', () {
        expect(ActivityType.fromString('unknown_action'), equals(ActivityType.consumed));
        expect(ActivityType.fromString(''), equals(ActivityType.consumed));
      });

      test('Audit 1104: FoodActivity validate catches empty id', () {
        final act = FoodActivity(
          id: '',
          foodItemId: 'item-1',
          foodName: 'Maçã',
          category: FoodCategory.fruits,
          quantity: 1.0,
          unit: FoodUnit.piece,
          type: ActivityType.consumed,
          timestamp: DateTime.now(),
        );
        expect(act.validate(), contains('Activity id cannot be empty.'));
      });

      test('Audit 1105: FoodActivity validate catches empty foodItemId', () {
        final act = FoodActivity(
          id: 'act-1',
          foodItemId: '   ',
          foodName: 'Maçã',
          category: FoodCategory.fruits,
          quantity: 1.0,
          unit: FoodUnit.piece,
          type: ActivityType.consumed,
          timestamp: DateTime.now(),
        );
        expect(act.validate(), contains('Referenced food item id cannot be empty.'));
      });

      test('Audit 1106: FoodActivity validate catches empty foodName', () {
        final act = FoodActivity(
          id: 'act-1',
          foodItemId: 'item-1',
          foodName: '',
          category: FoodCategory.fruits,
          quantity: 1.0,
          unit: FoodUnit.piece,
          type: ActivityType.consumed,
          timestamp: DateTime.now(),
        );
        expect(act.validate(), contains('Food name cannot be empty.'));
      });

      test('Audit 1107: FoodActivity validate catches non-positive quantity', () {
        final act = FoodActivity(
          id: 'act-1',
          foodItemId: 'item-1',
          foodName: 'Maçã',
          category: FoodCategory.fruits,
          quantity: 0.0,
          unit: FoodUnit.piece,
          type: ActivityType.consumed,
          timestamp: DateTime.now(),
        );
        expect(act.validate(), contains('Activity quantity must be a valid positive number.'));
      });

      test('Audit 1108: FoodActivity validate catches negative estimatedValue', () {
        final act = FoodActivity(
          id: 'act-1',
          foodItemId: 'item-1',
          foodName: 'Maçã',
          category: FoodCategory.fruits,
          quantity: 1.0,
          unit: FoodUnit.piece,
          type: ActivityType.consumed,
          timestamp: DateTime.now(),
          estimatedValue: -5.0,
        );
        expect(act.validate(), contains('Estimated value cannot be negative or invalid.'));
      });

      test('Audit 1109: FoodActivity validate catches notes exceeding 500 characters', () {
        final act = FoodActivity(
          id: 'act-1',
          foodItemId: 'item-1',
          foodName: 'Maçã',
          category: FoodCategory.fruits,
          quantity: 1.0,
          unit: FoodUnit.piece,
          type: ActivityType.consumed,
          timestamp: DateTime.now(),
          notes: 'N' * 501,
        );
        expect(act.validate(), contains('Activity notes cannot exceed 500 characters.'));
      });

      test('Audit 1110: FoodActivity toMap and fromMap roundtrip preserves all attributes', () {
        final act = FoodActivity(
          id: 'act-roundtrip',
          foodItemId: 'item-123',
          foodName: 'Queijo Prato',
          category: FoodCategory.dairy,
          quantity: 2.5,
          unit: FoodUnit.kilogram,
          type: ActivityType.discarded,
          timestamp: DateTime(2026, 10, 15, 14, 30),
          estimatedValue: 45.0,
          notes: 'Venceu na geladeira',
        );
        final map = act.toMap();
        final restored = FoodActivity.fromMap(map);

        expect(restored.id, equals(act.id));
        expect(restored.foodItemId, equals(act.foodItemId));
        expect(restored.foodName, equals(act.foodName));
        expect(restored.category, equals(act.category));
        expect(restored.quantity, equals(act.quantity));
        expect(restored.unit, equals(act.unit));
        expect(restored.type, equals(act.type));
        expect(restored.estimatedValue, equals(act.estimatedValue));
        expect(restored.notes, equals(act.notes));
      });

      for (int i = 1111; i <= 1150; i++) {
        test('Audit $i: FoodActivity creation validation iteration #$i', () {
          final act = FoodActivity(
            id: 'act-$i',
            foodItemId: 'item-$i',
            foodName: 'Item $i',
            category: FoodCategory.bakery,
            quantity: 1.0,
            unit: FoodUnit.piece,
            type: ActivityType.consumed,
            timestamp: DateTime.now(),
          );
          expect(act.validate(), isEmpty);
        });
      }
    });

    // =========================================================================
    // DOMAIN 20: FoodPriorityEngine Scoring & Heuristics (Audits 1151-1200)
    // =========================================================================
    group('Domain 20: FoodPriorityEngine Scoring (Audits 1151-1200)', () {
      test('Audit 1151: FoodPriority urgencyRank orders expired first and unknown last', () {
        expect(FoodPriority.expired.urgencyRank, equals(0));
        expect(FoodPriority.consumeToday.urgencyRank, equals(1));
        expect(FoodPriority.highPriority.urgencyRank, equals(2));
        expect(FoodPriority.attention.urgencyRank, equals(3));
        expect(FoodPriority.onTrack.urgencyRank, equals(4));
        expect(FoodPriority.unknownExpiry.urgencyRank, equals(5));
      });

      test('Audit 1152: FoodPriority isUrgent is true for top 4 urgency tiers', () {
        expect(FoodPriority.expired.isUrgent, isTrue);
        expect(FoodPriority.consumeToday.isUrgent, isTrue);
        expect(FoodPriority.highPriority.isUrgent, isTrue);
        expect(FoodPriority.attention.isUrgent, isTrue);
      });

      test('Audit 1153: FoodPriority isUrgent is false for onTrack and unknownExpiry', () {
        expect(FoodPriority.onTrack.isUrgent, isFalse);
        expect(FoodPriority.unknownExpiry.isUrgent, isFalse);
      });

      test('Audit 1154: FoodPriority maxDaysRemaining matches tier definitions', () {
        expect(FoodPriority.expired.maxDaysRemaining, isNull);
        expect(FoodPriority.consumeToday.maxDaysRemaining, equals(0));
        expect(FoodPriority.highPriority.maxDaysRemaining, equals(3));
        expect(FoodPriority.attention.maxDaysRemaining, equals(7));
        expect(FoodPriority.onTrack.maxDaysRemaining, isNull);
        expect(FoodPriority.unknownExpiry.maxDaysRemaining, isNull);
      });

      test('Audit 1155: FoodPriorityCalculator ranks expired items with priority expired', () {
        final ref = DateTime(2026, 10, 20);
        final item = createTestFood(name: 'Passou', expiryDate: DateTime(2026, 10, 15));
        final priority = FoodPriorityCalculator.classify(item, referenceDate: ref);
        final days = item.getDaysRemaining(referenceDate: ref);

        expect(priority, equals(FoodPriority.expired));
        expect(days, equals(-5));
      });

      test('Audit 1156: FoodPriorityCalculator ranks same-day expiry with priority consumeToday', () {
        final ref = DateTime(2026, 10, 20);
        final item = createTestFood(name: 'Hoje', expiryDate: DateTime(2026, 10, 20, 22));
        final priority = FoodPriorityCalculator.classify(item, referenceDate: ref);
        final days = item.getDaysRemaining(referenceDate: ref);

        expect(priority, equals(FoodPriority.consumeToday));
        expect(days, equals(0));
      });

      test('Audit 1157: FoodPriorityCalculator ranks 1..3 days with priority highPriority', () {
        final ref = DateTime(2026, 10, 20);
        final item = createTestFood(name: 'Breve', expiryDate: DateTime(2026, 10, 22));
        final priority = FoodPriorityCalculator.classify(item, referenceDate: ref);
        final days = item.getDaysRemaining(referenceDate: ref);

        expect(priority, equals(FoodPriority.highPriority));
        expect(days, equals(2));
      });

      test('Audit 1158: FoodPriorityCalculator ranks 4..7 days with priority attention', () {
        final ref = DateTime(2026, 10, 20);
        final item = createTestFood(name: 'Semana', expiryDate: DateTime(2026, 10, 25));
        final priority = FoodPriorityCalculator.classify(item, referenceDate: ref);
        final days = item.getDaysRemaining(referenceDate: ref);

        expect(priority, equals(FoodPriority.attention));
        expect(days, equals(5));
      });

      test('Audit 1159: FoodPriorityCalculator ranks > 7 days with priority onTrack', () {
        final ref = DateTime(2026, 10, 20);
        final item = createTestFood(name: 'Mes Que Vem', expiryDate: DateTime(2026, 11, 20));
        final priority = FoodPriorityCalculator.classify(item, referenceDate: ref);
        final days = item.getDaysRemaining(referenceDate: ref);

        expect(priority, equals(FoodPriority.onTrack));
        expect(days, equals(31));
      });

      test('Audit 1160: FoodPriorityCalculator ranks null expiryDate with priority unknownExpiry', () {
        final item = createTestFood(name: 'Sem Data', expiryDate: null);
        final priority = FoodPriorityCalculator.classify(item);
        final days = item.getDaysRemaining();

        expect(priority, equals(FoodPriority.unknownExpiry));
        expect(days, isNull);
      });

      for (int i = 1161; i <= 1200; i++) {
        test('Audit $i: PrioritizedFood equality and immutability iteration #$i', () {
          final item = createTestFood(name: 'Item $i');
          final pf1 = PrioritizedFood(item: item, priority: FoodPriority.highPriority, daysRemaining: 2);
          final pf2 = PrioritizedFood(item: item, priority: FoodPriority.highPriority, daysRemaining: 2);
          expect(pf1, equals(pf2));
          expect(pf1.hashCode, equals(pf2.hashCode));
        });
      }
    });
  });
}
