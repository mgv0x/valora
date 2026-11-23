import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valora/data/models/expiry_status.dart';
import 'package:valora/data/models/food_activity.dart';
import 'package:valora/data/models/food_category.dart';
import 'package:valora/data/models/food_item.dart';
import 'package:valora/data/models/food_unit.dart';
import 'package:valora/data/models/shopping_item.dart';
import 'package:valora/data/models/storage_location.dart';
import 'package:valora/data/services/auth_service.dart';
import 'package:valora/data/services/notification_service.dart';
import 'package:valora/data/services/preferences_service.dart';
import 'package:valora/state/pantry_provider.dart';
import 'package:valora/state/settings_provider.dart';
import 'package:valora/state/shopping_list_provider.dart';
import 'package:valora/state/subscription_provider.dart';
import 'mocks/in_memory_food_repository.dart';

// ---------------------------------------------------------------------------
// Test Doubles (Fakes)
// ---------------------------------------------------------------------------

class _FakeNotificationService implements NotificationService {
  int cancelAllCount = 0;
  final List<String> cancelledFoodIds = [];
  final List<FoodItem> scheduledItems = [];
  bool permissionGranted = true;

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermission() async => permissionGranted;

  @override
  Future<void> scheduleExpiryWarning({
    required FoodItem item,
    required int warningDays,
    required String title,
    required String body,
  }) async {
    scheduledItems.add(item);
  }

  @override
  Future<void> cancelForFood(String foodId) async {
    cancelledFoodIds.add(foodId);
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCount++;
    scheduledItems.clear();
  }
}

class _FakeAuthService implements AuthService {
  AuthUser? _user;

  @override
  AuthUser? get currentUser => _user;

  @override
  Stream<AuthUser?> get authStateChanges => Stream.value(_user);

  @override
  bool get isFirebaseAvailable => false;

  @override
  Future<AuthUser?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _user = AuthUser(uid: 'fake_uid', email: email, displayName: 'Test User');
    return _user;
  }

  @override
  Future<AuthUser?> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    _user = AuthUser(uid: 'fake_uid', email: email, displayName: name);
    return _user;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> signOut() async {
    _user = null;
  }
}

// ---------------------------------------------------------------------------
// Main Unit Test Suite
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // =========================================================================
  // 1. ShoppingItem Model Unit Tests
  // =========================================================================
  group('ShoppingItem Model Unit Tests', () {
    test('create factory instantiates item with valid defaults and non-zero quantity', () {
      final item = ShoppingItem.create(
        name: '  Maçã Gala  ',
        category: FoodCategory.fruits,
        quantity: -5.0, // Should clamp to 1.0
        unit: FoodUnit.piece,
      );

      expect(item.name, equals('Maçã Gala'));
      expect(item.category, equals(FoodCategory.fruits));
      expect(item.quantity, equals(1.0));
      expect(item.unit, equals(FoodUnit.piece));
      expect(item.isChecked, isFalse);
      expect(item.id, isNotEmpty);
      expect(item.createdAt, isNotNull);
    });

    test('copyWith modifies designated fields while keeping others unchanged', () {
      final original = ShoppingItem.create(
        name: 'Leite Integral',
        category: FoodCategory.dairy,
        quantity: 2.0,
        unit: FoodUnit.liter,
      );

      final modified = original.copyWith(
        quantity: 3.5,
        isChecked: true,
      );

      expect(modified.id, equals(original.id));
      expect(modified.name, equals(original.name));
      expect(modified.category, equals(original.category));
      expect(modified.quantity, equals(3.5));
      expect(modified.unit, equals(original.unit));
      expect(modified.isChecked, isTrue);
      expect(modified.createdAt, equals(original.createdAt));
    });

    test('toMap and fromMap achieve complete bidirectional fidelity', () {
      final fixedDate = DateTime.utc(2026, 5, 10, 14, 30);
      final item = ShoppingItem(
        id: 'shop-item-123',
        name: 'Arroz Parboilizado',
        category: FoodCategory.pantryStaples,
        quantity: 5.0,
        unit: FoodUnit.kilogram,
        isChecked: true,
        createdAt: fixedDate,
      );

      final map = item.toMap();
      expect(map['id'], equals('shop-item-123'));
      expect(map['name'], equals('Arroz Parboilizado'));
      expect(map['category'], equals('pantryStaples'));
      expect(map['quantity'], equals(5.0));
      expect(map['unit'], equals('kilogram'));
      expect(map['is_checked'], equals(1));
      expect(map['created_at'], equals(fixedDate.toIso8601String()));

      final reconstructed = ShoppingItem.fromMap(map);
      expect(reconstructed.id, equals(item.id));
      expect(reconstructed.name, equals(item.name));
      expect(reconstructed.category, equals(item.category));
      expect(reconstructed.quantity, equals(item.quantity));
      expect(reconstructed.unit, equals(item.unit));
      expect(reconstructed.isChecked, isTrue);
      expect(reconstructed.createdAt.toIso8601String(), equals(fixedDate.toIso8601String()));
    });

    test('fromMap safely tolerates missing, null, and non-canonical values', () {
      final item = ShoppingItem.fromMap({
        'name': '  Banana Prata  ',
        'category': 'unknown_category',
        'quantity': null,
        'unit': 'un',
        'is_checked': false,
        'created_at': 'invalid_date',
      });

      expect(item.id, isNotEmpty);
      expect(item.name, equals('Banana Prata'));
      expect(item.category, equals(FoodCategory.other)); // fallback
      expect(item.quantity, equals(1.0)); // fallback
      expect(item.unit, equals(FoodUnit.piece));
      expect(item.isChecked, isFalse);
      expect(item.createdAt, isNotNull);
    });
  });

  // =========================================================================
  // 2. ShoppingListProvider State Unit Tests
  // =========================================================================
  group('ShoppingListProvider State Unit Tests', () {
    late PreferencesService prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      prefs = PreferencesService(sp);
    });

    test('initializes with empty list when preferences has no items', () {
      final provider = ShoppingListProvider(prefs: prefs);
      expect(provider.items, isEmpty);
      expect(provider.uncheckedCount, equals(0));
    });

    test('loads pre-existing JSON records on initialization', () async {
      final existingItem = ShoppingItem.create(name: 'Azeite Extra Virgem');
      final jsonStr = jsonEncode(existingItem.toMap());
      await prefs.setShoppingListJson([jsonStr]);

      final provider = ShoppingListProvider(prefs: prefs);
      expect(provider.items.length, equals(1));
      expect(provider.items.first.name, equals('Azeite Extra Virgem'));
      expect(provider.uncheckedCount, equals(1));
    });

    test('ignores corrupted or invalid JSON records during load without crashing', () async {
      await prefs.setShoppingListJson([
        'INVALID_JSON_{{[',
        jsonEncode({'name': 'Café em Grãos', 'category': 'drinks'}),
      ]);

      final provider = ShoppingListProvider(prefs: prefs);
      expect(provider.items.length, equals(1));
      expect(provider.items.first.name, equals('Café em Grãos'));
    });

    test('addItem adds new item to the head of the list and persists', () async {
      final provider = ShoppingListProvider(prefs: prefs);

      await provider.addItem(
        name: 'Iogurte Natural',
        category: FoodCategory.dairy,
        quantity: 4.0,
        unit: FoodUnit.piece,
      );

      expect(provider.items.length, equals(1));
      expect(provider.items.first.name, equals('Iogurte Natural'));
      expect(provider.items.first.quantity, equals(4.0));
      expect(provider.uncheckedCount, equals(1));

      // Check persistence
      expect(prefs.shoppingListJson.length, equals(1));
    });

    test('addItem discards empty or whitespace-only names', () async {
      final provider = ShoppingListProvider(prefs: prefs);

      await provider.addItem(name: '   ');
      await provider.addItem(name: '');

      expect(provider.items, isEmpty);
      expect(provider.uncheckedCount, equals(0));
      expect(prefs.shoppingListJson, isEmpty);
    });

    test('addFromPantryFood inserts new item if food not present in shopping list', () async {
      final provider = ShoppingListProvider(prefs: prefs);
      final food = FoodItem(
        id: 'food-1',
        name: 'Manteiga',
        category: FoodCategory.dairy,
        initialQuantity: 2.0,
        unit: FoodUnit.package,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await provider.addFromPantryFood(food);

      expect(provider.items.length, equals(1));
      expect(provider.items.first.name, equals('Manteiga'));
      expect(provider.items.first.quantity, equals(2.0));
      expect(provider.items.first.unit, equals(FoodUnit.package));
    });

    test('addFromPantryFood increments existing quantity if unchecked item matches name', () async {
      final provider = ShoppingListProvider(prefs: prefs);
      await provider.addItem(
        name: 'Manteiga',
        quantity: 1.0,
        unit: FoodUnit.package,
      );

      final food = FoodItem(
        id: 'food-2',
        name: 'manteiga', // case-insensitive match
        category: FoodCategory.dairy,
        initialQuantity: 3.0,
        unit: FoodUnit.package,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await provider.addFromPantryFood(food);

      // Should not add a duplicate item; should increment quantity to 1.0 + 3.0 = 4.0
      expect(provider.items.length, equals(1));
      expect(provider.items.first.quantity, equals(4.0));
    });

    test('toggleItem inverts isChecked and updates uncheckedCount', () async {
      final provider = ShoppingListProvider(prefs: prefs);
      await provider.addItem(name: 'Pão Francês');

      final itemId = provider.items.first.id;
      expect(provider.items.first.isChecked, isFalse);
      expect(provider.uncheckedCount, equals(1));

      // Toggle to checked
      await provider.toggleItem(itemId);
      expect(provider.items.first.isChecked, isTrue);
      expect(provider.uncheckedCount, equals(0));

      // Toggle back to unchecked
      await provider.toggleItem(itemId);
      expect(provider.items.first.isChecked, isFalse);
      expect(provider.uncheckedCount, equals(1));
    });

    test('removeItem removes target item by id and updates persistence', () async {
      final provider = ShoppingListProvider(prefs: prefs);
      await provider.addItem(name: 'Item A');
      await provider.addItem(name: 'Item B');

      expect(provider.items.length, equals(2));
      final idToRemove = provider.items.first.id;

      await provider.removeItem(idToRemove);

      expect(provider.items.length, equals(1));
      expect(provider.items.any((i) => i.id == idToRemove), isFalse);
      expect(prefs.shoppingListJson.length, equals(1));
    });

    test('clearCompleted removes only checked items and keeps pending unchecked items', () async {
      final provider = ShoppingListProvider(prefs: prefs);
      await provider.addItem(name: 'Unchecked Item 1');
      await provider.addItem(name: 'Checked Item 2');
      await provider.addItem(name: 'Unchecked Item 3');

      final checkedId = provider.items[1].id;
      await provider.toggleItem(checkedId);

      expect(provider.items.length, equals(3));
      expect(provider.uncheckedCount, equals(2));

      await provider.clearCompleted();

      expect(provider.items.length, equals(2));
      expect(provider.items.any((i) => i.id == checkedId), isFalse);
      expect(provider.uncheckedCount, equals(2));
    });
  });

  // =========================================================================
  // 3. FoodItem Domain Model Unit Tests
  // =========================================================================
  group('FoodItem Domain Model Unit Tests', () {
    test('remainingQuantity calculates accurate surplus and clamps to 0.0 on exhaustion', () {
      final item = FoodItem(
        id: '1',
        name: 'Maçãs',
        category: FoodCategory.fruits,
        initialQuantity: 10.0,
        consumedQuantity: 4.0,
        discardedQuantity: 2.0,
        unit: FoodUnit.piece,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(item.remainingQuantity, closeTo(4.0, 0.001));
      expect(item.hasRemaining, isTrue);
      expect(item.isActive, isTrue);

      // Exhausted item
      final exhausted = item.copyWith(consumedQuantity: 10.0);
      expect(exhausted.remainingQuantity, equals(0.0));
      expect(exhausted.hasRemaining, isFalse);
      expect(exhausted.isActive, isFalse);

      // Overconsumed item (defensive clamping)
      final overconsumed = item.copyWith(consumedQuantity: 15.0);
      expect(overconsumed.remainingQuantity, equals(0.0));
    });

    test('calculateProportionalValue computes accurate prorated cost', () {
      final item = FoodItem(
        id: '2',
        name: 'Queijo Parmesão',
        category: FoodCategory.dairy,
        initialQuantity: 500.0,
        unit: FoodUnit.gram,
        purchasePrice: 40.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 250g of 500g at R$ 40 should be R$ 20
      expect(item.calculateProportionalValue(250.0), closeTo(20.0, 0.001));

      // Returns null when purchasePrice is not set or quantities are invalid
      final noPriceItem = item.copyWith(clearPurchasePrice: true);
      expect(noPriceItem.calculateProportionalValue(100.0), isNull);
      expect(item.calculateProportionalValue(0.0), isNull);
      expect(item.calculateProportionalValue(-10.0), isNull);
    });

    test('validate returns empty list for fully compliant FoodItem', () {
      final item = FoodItem(
        id: 'valid-food-1',
        name: 'Arroz Integral 1kg',
        category: FoodCategory.pantryStaples,
        initialQuantity: 1.0,
        consumedQuantity: 0.2,
        discardedQuantity: 0.1,
        unit: FoodUnit.kilogram,
        purchasePrice: 8.50,
        purchaseDate: DateTime(2026, 1, 1),
        expiryDate: DateTime(2026, 12, 31),
        notes: 'Comprado na promoção do supermercado.',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final errors = item.validate();
      expect(errors, isEmpty);
    });

    test('validate catches domain invariant violations across all fields', () {
      final invalidItem = FoodItem(
        id: '   ', // empty id
        name: '', // empty name
        category: FoodCategory.fruits,
        initialQuantity: -5.0, // negative initial quantity
        consumedQuantity: -1.0, // negative consumed
        discardedQuantity: -1.0, // negative discarded
        unit: FoodUnit.piece,
        purchasePrice: -15.0, // negative price
        purchaseDate: DateTime(2026, 6, 10),
        expiryDate: DateTime(2026, 5, 1), // expiry before purchase date!
        notes: 'x' * 501, // exceeds 500 chars
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final errors = invalidItem.validate();
      expect(errors.any((e) => e.contains('Food id cannot be empty')), isTrue);
      expect(errors.any((e) => e.contains('Food name cannot be empty')), isTrue);
      expect(errors.any((e) => e.contains('Initial quantity must be greater than zero')), isTrue);
      expect(errors.any((e) => e.contains('Consumed quantity cannot be negative')), isTrue);
      expect(errors.any((e) => e.contains('Discarded quantity cannot be negative')), isTrue);
      expect(errors.any((e) => e.contains('Purchase price cannot be negative')), isTrue);
      expect(errors.any((e) => e.contains('Expiry date cannot be before purchase date')), isTrue);
      expect(errors.any((e) => e.contains('Notes cannot exceed 500 characters')), isTrue);
    });

    test('validate detects consumed plus discarded exceeding initial quantity', () {
      final item = FoodItem(
        id: 'food-inv',
        name: 'Suco de Uva',
        category: FoodCategory.drinks,
        initialQuantity: 2.0,
        consumedQuantity: 1.5,
        discardedQuantity: 1.0, // Total = 2.5 > 2.0
        unit: FoodUnit.liter,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final errors = item.validate();
      expect(errors.any((e) => e.contains('exceeds initial quantity')), isTrue);
    });
  });

  // =========================================================================
  // 4. FoodActivity Domain Model Unit Tests
  // =========================================================================
  group('FoodActivity Domain Model Unit Tests', () {
    test('validate enforces non-empty fields and positive quantities', () {
      final valid = FoodActivity(
        id: 'act-1',
        foodItemId: 'food-1',
        foodName: 'Iogurte Grego',
        category: FoodCategory.dairy,
        quantity: 1.0,
        unit: FoodUnit.piece,
        type: ActivityType.consumed,
        timestamp: DateTime.now(),
        estimatedValue: 5.50,
      );

      expect(valid.validate(), isEmpty);

      final invalid = FoodActivity(
        id: '',
        foodItemId: '',
        foodName: '',
        category: FoodCategory.dairy,
        quantity: 0.0,
        unit: FoodUnit.piece,
        type: ActivityType.consumed,
        timestamp: DateTime.now(),
        estimatedValue: -2.0,
        notes: 'n' * 501,
      );

      final errors = invalid.validate();
      expect(errors.length, greaterThanOrEqualTo(5));
      expect(errors.any((e) => e.contains('Activity id cannot be empty')), isTrue);
      expect(errors.any((e) => e.contains('Referenced food item id cannot be empty')), isTrue);
      expect(errors.any((e) => e.contains('Food name cannot be empty')), isTrue);
      expect(errors.any((e) => e.contains('quantity must be a valid positive number')), isTrue);
      expect(errors.any((e) => e.contains('Estimated value cannot be negative')), isTrue);
      expect(errors.any((e) => e.contains('notes cannot exceed 500 characters')), isTrue);
    });

    test('ActivityType.fromString handles case-insensitivity and defaults to consumed', () {
      expect(ActivityType.fromString('consumed'), equals(ActivityType.consumed));
      expect(ActivityType.fromString('CONSUMED'), equals(ActivityType.consumed));
      expect(ActivityType.fromString('discarded'), equals(ActivityType.discarded));
      expect(ActivityType.fromString('DISCARDED'), equals(ActivityType.discarded));
      expect(ActivityType.fromString('unknown_type'), equals(ActivityType.consumed));
    });

    test('FoodActivity toMap and fromMap serialization roundtrip', () {
      final activity = FoodActivity(
        id: 'act-10',
        foodItemId: 'food-10',
        foodName: 'Pão de Forma',
        category: FoodCategory.bakery,
        quantity: 3.0,
        unit: FoodUnit.piece,
        type: ActivityType.discarded,
        timestamp: DateTime.utc(2026, 4, 1, 10, 0),
        estimatedValue: 3.50,
        notes: 'Mofou antes do consumo.',
      );

      final map = activity.toMap();
      final roundtrip = FoodActivity.fromMap(map);

      expect(roundtrip.id, equals(activity.id));
      expect(roundtrip.foodItemId, equals(activity.foodItemId));
      expect(roundtrip.foodName, equals(activity.foodName));
      expect(roundtrip.category, equals(activity.category));
      expect(roundtrip.quantity, equals(activity.quantity));
      expect(roundtrip.unit, equals(activity.unit));
      expect(roundtrip.type, equals(activity.type));
      expect(roundtrip.estimatedValue, equals(activity.estimatedValue));
      expect(roundtrip.notes, equals(activity.notes));
    });
  });

  // =========================================================================
  // 5. Enums and Helpers Unit Tests
  // =========================================================================
  group('Enums & Utilities Unit Tests', () {
    test('FoodUnit.formatQuantity formats clean strings without trailing zeros', () {
      expect(FoodUnit.formatQuantity(1.0), equals('1'));
      expect(FoodUnit.formatQuantity(2.5), equals('2.5'));
      expect(FoodUnit.formatQuantity(3.75), equals('3.75'));
      expect(FoodUnit.formatQuantity(0.0), equals('0'));
      expect(FoodUnit.formatQuantity(-5.0), equals('0'));
      expect(FoodUnit.formatQuantity(double.nan), equals('0'));
    });

    test('FoodUnit.fromString supports multi-language synonyms and aliases', () {
      expect(FoodUnit.fromString('kg'), equals(FoodUnit.kilogram));
      expect(FoodUnit.fromString('quilos'), equals(FoodUnit.kilogram));
      expect(FoodUnit.fromString('g'), equals(FoodUnit.gram));
      expect(FoodUnit.fromString('gramas'), equals(FoodUnit.gram));
      expect(FoodUnit.fromString('L'), equals(FoodUnit.liter));
      expect(FoodUnit.fromString('litros'), equals(FoodUnit.liter));
      expect(FoodUnit.fromString('ml'), equals(FoodUnit.milliliter));
      expect(FoodUnit.fromString('pct'), equals(FoodUnit.package));
      expect(FoodUnit.fromString('pacote'), equals(FoodUnit.package));
      expect(FoodUnit.fromString('un'), equals(FoodUnit.piece));
      expect(FoodUnit.fromString('unidades'), equals(FoodUnit.piece));
      expect(FoodUnit.fromString('unknown'), equals(FoodUnit.piece));
    });

    test('FoodCategory.fromString parses identifiers and sanitizes special characters', () {
      expect(FoodCategory.fromString('fruits'), equals(FoodCategory.fruits));
      expect(FoodCategory.fromString('meat_fish'), equals(FoodCategory.meatFish));
      expect(FoodCategory.fromString('meat-fish'), equals(FoodCategory.meatFish));
      expect(FoodCategory.fromString('pantry_staples'), equals(FoodCategory.pantryStaples));
      expect(FoodCategory.fromString('pantry staples'), equals(FoodCategory.pantryStaples));
      expect(FoodCategory.fromString('other'), equals(FoodCategory.other));
      expect(FoodCategory.fromString('non_existent_category'), equals(FoodCategory.other));
    });

    test('StorageLocation.fromString parses locations and falls back safely', () {
      expect(StorageLocation.fromString('refrigerator'), equals(StorageLocation.refrigerator));
      expect(StorageLocation.fromString('FREEZER'), equals(StorageLocation.freezer));
      expect(StorageLocation.fromString('pantry'), equals(StorageLocation.pantry));
      expect(StorageLocation.fromString('unknown_place'), equals(StorageLocation.other));
    });
  });

  // =========================================================================
  // 6. ExpiryStatus Domain Calculations Unit Tests
  // =========================================================================
  group('ExpiryStatus Domain Calculations Unit Tests', () {
    final refDate = DateTime(2026, 7, 10, 12, 0);

    test('calculates accurate status across all calendar day zones', () {
      // Past date (expired)
      final past = DateTime(2026, 7, 9, 23, 59);
      expect(
        ExpiryStatus.calculate(expiryDate: past, referenceDate: refDate),
        equals(ExpiryStatus.expired),
      );

      // Today (expiring today, even late clock hours)
      final today = DateTime(2026, 7, 10, 23, 59);
      expect(
        ExpiryStatus.calculate(expiryDate: today, referenceDate: refDate),
        equals(ExpiryStatus.expiringToday),
      );

      // Tomorrow (expiring soon with default warningThreshold = 3)
      final tomorrow = DateTime(2026, 7, 11, 8, 0);
      expect(
        ExpiryStatus.calculate(expiryDate: tomorrow, referenceDate: refDate),
        equals(ExpiryStatus.expiringSoon),
      );

      // Threshold boundary (exactly 3 days away)
      final in3Days = DateTime(2026, 7, 13, 10, 0);
      expect(
        ExpiryStatus.calculate(expiryDate: in3Days, referenceDate: refDate, warningThresholdDays: 3),
        equals(ExpiryStatus.expiringSoon),
      );

      // Beyond threshold (fresh)
      final in4Days = DateTime(2026, 7, 14, 10, 0);
      expect(
        ExpiryStatus.calculate(expiryDate: in4Days, referenceDate: refDate, warningThresholdDays: 3),
        equals(ExpiryStatus.fresh),
      );

      // Null expiry date
      expect(
        ExpiryStatus.calculate(expiryDate: null, referenceDate: refDate),
        equals(ExpiryStatus.unknown),
      );
    });

    test('daysRemaining calculates exact integer calendar difference', () {
      expect(ExpiryStatus.daysRemaining(expiryDate: DateTime(2026, 7, 15), referenceDate: refDate), equals(5));
      expect(ExpiryStatus.daysRemaining(expiryDate: DateTime(2026, 7, 10), referenceDate: refDate), equals(0));
      expect(ExpiryStatus.daysRemaining(expiryDate: DateTime(2026, 7, 8), referenceDate: refDate), equals(-2));
      expect(ExpiryStatus.daysRemaining(expiryDate: null, referenceDate: refDate), isNull);
    });
  });

  // =========================================================================
  // 7. PreferencesService Unit Tests
  // =========================================================================
  group('PreferencesService Settings & Persistence Unit Tests', () {
    late PreferencesService prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      prefs = PreferencesService(sp);
    });

    test('warningThresholdDays is clamped between 1 and 30 days', () async {
      expect(prefs.warningThresholdDays, equals(3)); // default

      await prefs.setWarningThresholdDays(0);
      expect(prefs.warningThresholdDays, equals(1));

      await prefs.setWarningThresholdDays(45);
      expect(prefs.warningThresholdDays, equals(30));

      await prefs.setWarningThresholdDays(5);
      expect(prefs.warningThresholdDays, equals(5));
    });

    test('redeemedCodes sanitizes whitespace, turns uppercase, and deduplicates', () async {
      await prefs.setRedeemedCodes(['val-abcd', ' VAL-ABCD ', 'VAL-1234', '']);
      final codes = prefs.redeemedCodes;

      expect(codes.length, equals(2));
      expect(codes, containsAll(['VAL-ABCD', 'VAL-1234']));
    });

    test('referralBonusDays and invitedCount prevent negative values', () async {
      await prefs.setReferralBonusDays(-10);
      expect(prefs.referralBonusDays, equals(0));

      await prefs.setInvitedCount(-5);
      expect(prefs.invitedCount, equals(0));
    });

    test('clearAuth removes credentials and profile information completely', () async {
      await prefs.setUserName('Carlos Silva');
      await prefs.setUserEmail('carlos@example.com');
      await prefs.setIsLoggedIn(true);
      await prefs.setUserAvatar('https://avatar.url/img.png');

      expect(prefs.isLoggedIn, isTrue);

      await prefs.clearAuth();

      expect(prefs.userName, isEmpty);
      expect(prefs.userEmail, isEmpty);
      expect(prefs.isLoggedIn, isFalse);
      expect(prefs.userAvatar, isNull);
    });
  });

  // =========================================================================
  // 8. SettingsProvider Unit Tests
  // =========================================================================
  group('SettingsProvider Display and Logic Unit Tests', () {
    late PreferencesService prefs;
    late _FakeNotificationService fakeNotifications;
    late _FakeAuthService fakeAuth;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      prefs = PreferencesService(sp);
      fakeNotifications = _FakeNotificationService();
      fakeAuth = _FakeAuthService();
    });

    test('userFirstName extracts first word or falls back to Amigo', () async {
      final provider = SettingsProvider(
        prefs: prefs,
        notifications: fakeNotifications,
        authService: fakeAuth,
      );

      expect(provider.userFirstName, equals('Amigo'));

      await provider.updateProfile(name: 'Beatriz Almeida Costa', email: 'beatriz@valora.app');
      expect(provider.userFirstName, equals('Beatriz'));
    });

    test('userInitials extracts accurate 2-letter uppercase initials', () async {
      final provider = SettingsProvider(
        prefs: prefs,
        notifications: fakeNotifications,
        authService: fakeAuth,
      );

      expect(provider.userInitials, equals('V')); // fallback

      // Single word name (first 2 characters)
      await provider.updateProfile(name: 'Lucas', email: 'lucas@valora.app');
      expect(provider.userInitials, equals('LU'));

      // Multi-word name (first letters of first and last words)
      await provider.updateProfile(name: 'Ana Carolina Pereira', email: 'ana@valora.app');
      expect(provider.userInitials, equals('AP'));
    });

    test('setLocale and setWarningThresholdDays notify listeners and persist', () async {
      final provider = SettingsProvider(
        prefs: prefs,
        notifications: fakeNotifications,
        authService: fakeAuth,
      );

      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.setLocale('es');
      expect(provider.locale?.languageCode, equals('es'));
      expect(prefs.localeCode, equals('es'));

      await provider.setWarningThresholdDays(5);
      expect(provider.warningThresholdDays, equals(5));
      expect(prefs.warningThresholdDays, equals(5));

      // Out of range days should be ignored
      await provider.setWarningThresholdDays(100);
      expect(provider.warningThresholdDays, equals(5));

      expect(notifyCount, greaterThanOrEqualTo(2));
    });
  });

  // =========================================================================
  // 9. SubscriptionProvider Unit Tests
  // =========================================================================
  group('SubscriptionProvider Logic Unit Tests', () {
    late PreferencesService prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      prefs = PreferencesService(sp);
    });

    test('initializes with 7 base trial days and generated user referral code', () {
      final provider = SubscriptionProvider(prefs: prefs);

      expect(provider.totalTrialDays, equals(7));
      expect(provider.daysRemainingInTrial, inInclusiveRange(6, 7));
      expect(provider.isTrialActive, isTrue);
      expect(provider.userReferralCode, startsWith('VAL-'));
      expect(provider.userReferralCode.length, equals(8));
      expect(provider.isSubscribed, isFalse);
    });

    test('redeemInviteCode validates format, self-code, duplicates, and awards bonus days', () {
      final provider = SubscriptionProvider(prefs: prefs);

      // Empty code
      expect(provider.redeemInviteCode(''), equals(RedemptionResult.empty));

      // Malformed code
      expect(provider.redeemInviteCode('INVALID_CODE'), equals(RedemptionResult.invalidFormat));
      expect(provider.redeemInviteCode('VAL-12'), equals(RedemptionResult.invalidFormat));

      // Self referral code
      expect(provider.redeemInviteCode(provider.userReferralCode), equals(RedemptionResult.selfCode));

      // Valid friend code
      final validFriendCode = 'VAL-ABCD';
      expect(provider.redeemInviteCode(validFriendCode), equals(RedemptionResult.success));
      expect(provider.referralBonusDays, equals(7));
      expect(provider.totalTrialDays, equals(14));

      // Duplicate attempt
      expect(provider.redeemInviteCode(validFriendCode), equals(RedemptionResult.alreadyUsed));
      expect(provider.referralBonusDays, equals(7)); // Remains 7
    });

    test('subscribe and cancelSubscription transition state correctly', () async {
      final provider = SubscriptionProvider(prefs: prefs);
      expect(provider.isSubscribed, isFalse);

      await provider.subscribe(durationDays: 30);
      expect(provider.isSubscribed, isTrue);
      expect(provider.hasActiveAccess, isTrue);
      expect(provider.subscriptionExpiresAt, isNotNull);

      await provider.cancelSubscription();
      expect(provider.isSubscribed, isFalse);
      expect(provider.subscriptionExpiresAt, isNull);
    });
  });

  // =========================================================================
  // 10. PantryProvider State and Filter Unit Tests
  // =========================================================================
  group('PantryProvider State & Filter Unit Tests', () {
    late InMemoryFoodRepository repo;
    late _FakeNotificationService notifications;
    late PreferencesService prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      prefs = PreferencesService(sp);
      repo = InMemoryFoodRepository();
      notifications = _FakeNotificationService();
    });

    test('loads foods and filters accurately by category, location, and search text', () async {
      final fixedNow = DateTime(2026, 6, 1, 12, 0);

      final item1 = FoodItem(
        id: 'f-1',
        name: 'Maçã Fuji',
        category: FoodCategory.fruits,
        storageLocation: StorageLocation.refrigerator,
        initialQuantity: 5.0,
        unit: FoodUnit.piece,
        expiryDate: fixedNow.add(const Duration(days: 2)),
        createdAt: fixedNow,
        updatedAt: fixedNow,
      );

      final item2 = FoodItem(
        id: 'f-2',
        name: 'Arroz Branco',
        category: FoodCategory.pantryStaples,
        storageLocation: StorageLocation.pantry,
        initialQuantity: 1.0,
        unit: FoodUnit.kilogram,
        expiryDate: fixedNow.add(const Duration(days: 90)),
        createdAt: fixedNow,
        updatedAt: fixedNow,
      );

      final item3 = FoodItem(
        id: 'f-3',
        name: 'Sorvete de Baunilha',
        category: FoodCategory.frozen,
        storageLocation: StorageLocation.freezer,
        initialQuantity: 1.0,
        unit: FoodUnit.package,
        expiryDate: fixedNow.subtract(const Duration(days: 1)), // Expired
        createdAt: fixedNow,
        updatedAt: fixedNow,
      );

      await repo.insertFood(item1);
      await repo.insertFood(item2);
      await repo.insertFood(item3);

      final provider = PantryProvider(
        repository: repo,
        notificationService: notifications,
        preferencesService: prefs,
        referenceDate: fixedNow,
      );

      await provider.loadItems();
      expect(provider.items.length, equals(3));
      expect(provider.filteredAndSortedItems.length, equals(3));

      // Filter by search query (accent insensitive)
      provider.setSearchQuery('maca');
      expect(provider.filteredAndSortedItems.length, equals(1));
      expect(provider.filteredAndSortedItems.first.name, equals('Maçã Fuji'));

      // Reset search query
      provider.setSearchQuery('');
      expect(provider.filteredAndSortedItems.length, equals(3));

      // Filter by category
      provider.setSelectedCategory(FoodCategory.pantryStaples);
      expect(provider.filteredAndSortedItems.length, equals(1));
      expect(provider.filteredAndSortedItems.first.name, equals('Arroz Branco'));

      // Reset category filter
      provider.setSelectedCategory(null);

      // Filter by storage location
      provider.setSelectedStorageFilter(StorageLocation.freezer);
      expect(provider.filteredAndSortedItems.length, equals(1));
      expect(provider.filteredAndSortedItems.first.name, equals('Sorvete de Baunilha'));

      provider.resetFilters();
      expect(provider.filteredAndSortedItems.length, equals(3));
    });

    test('priorityItems identifies expired and expiring soon items accurately', () async {
      final refDate = DateTime(2026, 6, 1, 12, 0);

      final expired = FoodItem(
        id: 'p-1',
        name: 'Iogurte',
        category: FoodCategory.dairy,
        initialQuantity: 1.0,
        unit: FoodUnit.piece,
        expiryDate: refDate.subtract(const Duration(days: 1)),
        createdAt: refDate,
        updatedAt: refDate,
      );

      final expiringSoon = FoodItem(
        id: 'p-2',
        name: 'Leite',
        category: FoodCategory.dairy,
        initialQuantity: 1.0,
        unit: FoodUnit.liter,
        expiryDate: refDate.add(const Duration(days: 2)),
        createdAt: refDate,
        updatedAt: refDate,
      );

      final fresh = FoodItem(
        id: 'p-3',
        name: 'Mel',
        category: FoodCategory.pantryStaples,
        initialQuantity: 1.0,
        unit: FoodUnit.piece,
        expiryDate: refDate.add(const Duration(days: 300)),
        createdAt: refDate,
        updatedAt: refDate,
      );

      await repo.insertFood(expired);
      await repo.insertFood(expiringSoon);
      await repo.insertFood(fresh);

      final provider = PantryProvider(
        repository: repo,
        notificationService: notifications,
        preferencesService: prefs,
        referenceDate: refDate,
      );

      await provider.loadItems();

      final priority = provider.priorityItems;
      expect(priority.length, equals(2));
      expect(priority.any((i) => i.id == 'p-1'), isTrue); // expired
      expect(priority.any((i) => i.id == 'p-2'), isTrue); // expiring soon
      expect(priority.any((i) => i.id == 'p-3'), isFalse); // fresh excluded

      expect(provider.expiringSoonCount, equals(1));
      expect(provider.groupExpired.length, equals(1));
      expect(provider.groupExpiringSoon.length, equals(1));
      expect(provider.groupLater.length, equals(1));
    });

    test('sorting options reorder items correctly', () async {
      final refDate = DateTime(2026, 6, 1, 12, 0);

      final itemA = FoodItem(
        id: 'sort-1',
        name: 'Banana',
        category: FoodCategory.fruits,
        initialQuantity: 1.0,
        unit: FoodUnit.piece,
        expiryDate: refDate.add(const Duration(days: 10)),
        createdAt: refDate,
        updatedAt: refDate,
      );

      final itemB = FoodItem(
        id: 'sort-2',
        name: 'Abacate',
        category: FoodCategory.fruits,
        initialQuantity: 1.0,
        unit: FoodUnit.piece,
        expiryDate: refDate.add(const Duration(days: 3)),
        createdAt: refDate,
        updatedAt: refDate,
      );

      await repo.insertFood(itemA);
      await repo.insertFood(itemB);

      final provider = PantryProvider(
        repository: repo,
        preferencesService: prefs,
        referenceDate: refDate,
      );

      await provider.loadItems();

      // Sort by Name A-Z
      provider.setSortOption(PantrySortOption.nameAZ);
      expect(provider.filteredAndSortedItems.first.name, equals('Abacate'));
      expect(provider.filteredAndSortedItems.last.name, equals('Banana'));

      // Sort by Name Z-A
      provider.setSortOption(PantrySortOption.nameZA);
      expect(provider.filteredAndSortedItems.first.name, equals('Banana'));
      expect(provider.filteredAndSortedItems.last.name, equals('Abacate'));

      // Sort by Expiry Soonest
      provider.setSortOption(PantrySortOption.expirySoonest);
      expect(provider.filteredAndSortedItems.first.name, equals('Abacate')); // 3 days
      expect(provider.filteredAndSortedItems.last.name, equals('Banana')); // 10 days

      // Sort by Expiry Latest
      provider.setSortOption(PantrySortOption.expiryLatest);
      expect(provider.filteredAndSortedItems.first.name, equals('Banana'));
      expect(provider.filteredAndSortedItems.last.name, equals('Abacate'));
    });
  });
}
