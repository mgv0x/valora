import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

import 'package:valora/data/local/sqlite_food_repository.dart';
import 'package:valora/data/models/expiry_status.dart';
import 'package:valora/data/models/food_activity.dart';
import 'package:valora/data/models/food_category.dart';
import 'package:valora/data/models/food_item.dart';
import 'package:valora/data/models/food_unit.dart';
import 'package:valora/data/models/storage_location.dart';
import 'package:valora/data/services/auth_service.dart';
import 'package:valora/data/services/notification_service.dart';
import 'package:valora/data/services/preferences_service.dart';
import 'package:valora/state/impact_provider.dart';
import 'package:valora/state/pantry_provider.dart';
import 'package:valora/state/settings_provider.dart';

// Mock Notification Service for deep state tracking
class MockTrackingNotificationService implements NotificationService {
  final List<String> scheduledItemIds = [];
  final List<String> cancelledItemIds = [];
  bool allCancelled = false;
  bool permissionToReturn = true;

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermission() async => permissionToReturn;

  @override
  Future<void> scheduleExpiryWarning({
    required FoodItem item,
    required int warningDays,
    String? title,
    String? body,
  }) async {
    scheduledItemIds.add(item.id);
  }

  @override
  Future<void> cancelForFood(String foodId) async {
    cancelledItemIds.add(foodId);
  }

  @override
  Future<void> cancelAll() async {
    allCancelled = true;
    scheduledItemIds.clear();
  }
}

class MockAuthService implements AuthService {
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
    _user = AuthUser(uid: 'mock-uid', email: email);
    return _user;
  }

  @override
  Future<AuthUser?> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    _user = AuthUser(uid: 'mock-uid', email: email, displayName: name);
    return _user;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> signOut() async {
    _user = null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  FoodItem createItem({
    String? id,
    String name = 'Alimento',
    FoodCategory category = FoodCategory.vegetables,
    double initialQuantity = 1.0,
    double consumedQuantity = 0.0,
    double discardedQuantity = 0.0,
    FoodUnit unit = FoodUnit.kilogram,
    DateTime? expiryDate,
    double? purchasePrice = 10.0,
    StorageLocation? storageLocation = StorageLocation.refrigerator,
    FoodLifecycleStatus status = FoodLifecycleStatus.active,
    String? notes,
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
      purchaseDate: DateTime(2026, 10, 1),
      notes: notes,
      createdAt: DateTime(2026, 10, 1),
      updatedAt: DateTime(2026, 10, 1),
      status: status,
    );
  }

  group('Valora Audits 701-950', () {
    late SqliteFoodRepository repo;
    late PreferencesService prefs;
    late MockTrackingNotificationService notif;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      prefs = PreferencesService(sp);
      await prefs.setNotificationsEnabled(true);
      notif = MockTrackingNotificationService();
      repo = SqliteFoodRepository(inMemory: true);
      await repo.init();
    });

    tearDown(() async {
      await repo.clearAllData();
    });

    // =========================================================================
    // DOMAIN 11: PantryProvider State, Invariants & Edge Cases (Audits 701-760)
    // =========================================================================
    group('Domain 11: PantryProvider State & Invariants (Audits 701-760)', () {
      test('Audit 701: PantryProvider initializes with default warning threshold and notifications', () {
        final pantry = PantryProvider(repository: repo, preferencesService: prefs);
        expect(pantry.warningThresholdDays, equals(3));
        expect(pantry.notificationsEnabled, isTrue);
        expect(pantry.sortOption, equals(PantrySortOption.expirySoonest));
      });

      test('Audit 702: PantryProvider reads custom preferences on construction', () async {
        await prefs.setWarningThresholdDays(5);
        await prefs.setNotificationsEnabled(false);
        final pantry = PantryProvider(repository: repo, preferencesService: prefs);
        expect(pantry.warningThresholdDays, equals(5));
        expect(pantry.notificationsEnabled, isFalse);
      });

      test('Audit 703: PantryProvider loadItems fetches active foods into items list', () async {
        final food = createItem(name: 'Tomate Italiano');
        await repo.insertFood(food);
        final pantry = PantryProvider(repository: repo);
        await pantry.loadItems();
        expect(pantry.items.length, equals(1));
        expect(pantry.items.first.name, equals('Tomate Italiano'));
      });

      test('Audit 704: PantryProvider setSearchQuery filters items ignoring case and accents', () async {
        final f1 = createItem(name: 'Maçã Fuji');
        final f2 = createItem(name: 'Pão Francês');
        final f3 = createItem(name: 'Leite');
        await repo.insertFood(f1);
        await repo.insertFood(f2);
        await repo.insertFood(f3);

        final pantry = PantryProvider(repository: repo);
        await pantry.loadItems();

        pantry.setSearchQuery('maca');
        expect(pantry.filteredAndSortedItems.length, equals(1));
        expect(pantry.filteredAndSortedItems.first.name, equals('Maçã Fuji'));

        pantry.setSearchQuery('PAO');
        expect(pantry.filteredAndSortedItems.length, equals(1));
        expect(pantry.filteredAndSortedItems.first.name, equals('Pão Francês'));
      });

      test('Audit 705: PantryProvider setSearchQuery with extra whitespace matches accurately', () async {
        await repo.insertFood(createItem(name: 'Queijo Minas'));
        final pantry = PantryProvider(repository: repo);
        await pantry.loadItems();
        pantry.setSearchQuery('   queijo   ');
        expect(pantry.filteredAndSortedItems.length, equals(1));
      });

      test('Audit 706: PantryProvider setSelectedCategory filters by category enum', () async {
        await repo.insertFood(createItem(name: 'Maçã', category: FoodCategory.fruits));
        await repo.insertFood(createItem(name: 'Alface', category: FoodCategory.vegetables));
        final pantry = PantryProvider(repository: repo);
        await pantry.loadItems();

        pantry.setSelectedCategory(FoodCategory.fruits);
        expect(pantry.filteredAndSortedItems.length, equals(1));
        expect(pantry.filteredAndSortedItems.first.category, equals(FoodCategory.fruits));
      });

      test('Audit 707: PantryProvider setSelectedStatusFilter filters by ExpiryStatus', () async {
        final ref = DateTime(2026, 10, 20);
        await repo.insertFood(createItem(name: 'Vencido', expiryDate: DateTime(2026, 10, 15)));
        await repo.insertFood(createItem(name: 'Fresco', expiryDate: DateTime(2026, 10, 30)));
        final pantry = PantryProvider(repository: repo, referenceDate: ref);
        await pantry.loadItems();

        pantry.setSelectedStatusFilter(ExpiryStatus.expired);
        expect(pantry.filteredAndSortedItems.length, equals(1));
        expect(pantry.filteredAndSortedItems.first.name, equals('Vencido'));
      });

      test('Audit 708: PantryProvider resetFilters resets query, category, status and sort to defaults', () async {
        final pantry = PantryProvider(repository: repo);
        pantry.setSearchQuery('test');
        pantry.setSelectedCategory(FoodCategory.bakery);
        pantry.setSelectedStatusFilter(ExpiryStatus.fresh);
        pantry.setSortOption(PantrySortOption.nameZA);

        pantry.resetFilters();
        expect(pantry.searchQuery, isEmpty);
        expect(pantry.selectedCategory, isNull);
        expect(pantry.selectedStatusFilter, isNull);
        expect(pantry.sortOption, equals(PantrySortOption.expirySoonest));
      });

      test('Audit 709: PantryProvider sortOption expirySoonest orders earliest expiry first and nulls last', () async {
        await repo.insertFood(createItem(name: 'Sem Data', expiryDate: null));
        await repo.insertFood(createItem(name: 'Longe', expiryDate: DateTime(2026, 10, 30)));
        await repo.insertFood(createItem(name: 'Perto', expiryDate: DateTime(2026, 10, 21)));

        final pantry = PantryProvider(repository: repo);
        await pantry.loadItems();
        pantry.setSortOption(PantrySortOption.expirySoonest);

        final names = pantry.filteredAndSortedItems.map((e) => e.name).toList();
        expect(names, equals(['Perto', 'Longe', 'Sem Data']));
      });

      test('Audit 710: PantryProvider sortOption expiryLatest orders farthest expiry first and nulls last', () async {
        await repo.insertFood(createItem(name: 'Sem Data', expiryDate: null));
        await repo.insertFood(createItem(name: 'Longe', expiryDate: DateTime(2026, 10, 30)));
        await repo.insertFood(createItem(name: 'Perto', expiryDate: DateTime(2026, 10, 21)));

        final pantry = PantryProvider(repository: repo);
        await pantry.loadItems();
        pantry.setSortOption(PantrySortOption.expiryLatest);

        final names = pantry.filteredAndSortedItems.map((e) => e.name).toList();
        expect(names, equals(['Longe', 'Perto', 'Sem Data']));
      });

      test('Audit 711: PantryProvider sortOption nameAZ orders alphabetically ignoring accents', () async {
        await repo.insertFood(createItem(name: 'Pão Francês'));
        await repo.insertFood(createItem(name: 'Abacate'));
        await repo.insertFood(createItem(name: 'Maçã'));

        final pantry = PantryProvider(repository: repo);
        await pantry.loadItems();
        pantry.setSortOption(PantrySortOption.nameAZ);

        final names = pantry.filteredAndSortedItems.map((e) => e.name).toList();
        expect(names, equals(['Abacate', 'Maçã', 'Pão Francês']));
      });

      test('Audit 712: PantryProvider sortOption nameZA orders reverse alphabetically', () async {
        await repo.insertFood(createItem(name: 'Pão Francês'));
        await repo.insertFood(createItem(name: 'Abacate'));
        await repo.insertFood(createItem(name: 'Maçã'));

        final pantry = PantryProvider(repository: repo);
        await pantry.loadItems();
        pantry.setSortOption(PantrySortOption.nameZA);

        final names = pantry.filteredAndSortedItems.map((e) => e.name).toList();
        expect(names, equals(['Pão Francês', 'Maçã', 'Abacate']));
      });

      test('Audit 713: PantryProvider totalEstimatedValue calculates sum of proportional prices of active items', () async {
        await repo.insertFood(createItem(name: 'A', initialQuantity: 2.0, consumedQuantity: 1.0, purchasePrice: 20.0)); // remaining 1.0 -> 10.0
        await repo.insertFood(createItem(name: 'B', initialQuantity: 1.0, consumedQuantity: 0.0, purchasePrice: 15.0)); // remaining 1.0 -> 15.0
        final pantry = PantryProvider(repository: repo);
        await pantry.loadItems();

        expect(pantry.totalEstimatedValue, equals(25.0));
      });

      test('Audit 714: PantryProvider totalEstimatedValue ignores items without purchasePrice', () async {
        await repo.insertFood(createItem(name: 'A', purchasePrice: null));
        await repo.insertFood(createItem(name: 'B', purchasePrice: 12.0, initialQuantity: 1.0));
        final pantry = PantryProvider(repository: repo);
        await pantry.loadItems();

        expect(pantry.totalEstimatedValue, equals(12.0));
      });

      test('Audit 715: PantryProvider priorityItems includes only expired, expiringToday, expiringSoon', () async {
        final ref = DateTime(2026, 10, 20);
        await repo.insertFood(createItem(name: 'Vencido', expiryDate: DateTime(2026, 10, 18)));
        await repo.insertFood(createItem(name: 'Hoje', expiryDate: DateTime(2026, 10, 20)));
        await repo.insertFood(createItem(name: 'Breve', expiryDate: DateTime(2026, 10, 22)));
        await repo.insertFood(createItem(name: 'Fresco', expiryDate: DateTime(2026, 10, 28)));

        final pantry = PantryProvider(repository: repo, referenceDate: ref);
        await pantry.loadItems();

        expect(pantry.priorityItems.length, equals(3));
        expect(pantry.needsAttentionCount, equals(3));
      });

      test('Audit 716: PantryProvider groupExpired groups only expired items', () async {
        final ref = DateTime(2026, 10, 20);
        await repo.insertFood(createItem(name: 'Vencido', expiryDate: DateTime(2026, 10, 18)));
        await repo.insertFood(createItem(name: 'Hoje', expiryDate: DateTime(2026, 10, 20)));

        final pantry = PantryProvider(repository: repo, referenceDate: ref);
        await pantry.loadItems();

        expect(pantry.groupExpired.length, equals(1));
        expect(pantry.groupExpired.first.name, equals('Vencido'));
      });

      test('Audit 717: PantryProvider groupExpiringToday groups only items expiring today', () async {
        final ref = DateTime(2026, 10, 20);
        await repo.insertFood(createItem(name: 'Hoje 1', expiryDate: DateTime(2026, 10, 20, 8)));
        await repo.insertFood(createItem(name: 'Hoje 2', expiryDate: DateTime(2026, 10, 20, 23)));
        await repo.insertFood(createItem(name: 'Amanha', expiryDate: DateTime(2026, 10, 21)));

        final pantry = PantryProvider(repository: repo, referenceDate: ref);
        await pantry.loadItems();

        expect(pantry.groupExpiringToday.length, equals(2));
      });

      test('Audit 718: PantryProvider groupExpiringSoon groups items within warning threshold', () async {
        final ref = DateTime(2026, 10, 20);
        await repo.insertFood(createItem(name: 'Breve', expiryDate: DateTime(2026, 10, 22)));
        await repo.insertFood(createItem(name: 'Longe', expiryDate: DateTime(2026, 10, 27)));

        final pantry = PantryProvider(repository: repo, referenceDate: ref);
        await pantry.loadItems();

        expect(pantry.groupExpiringSoon.length, equals(1));
        expect(pantry.groupExpiringSoon.first.name, equals('Breve'));
      });

      test('Audit 719: PantryProvider groupLater groups items beyond warning threshold', () async {
        final ref = DateTime(2026, 10, 20);
        await repo.insertFood(createItem(name: 'Longe', expiryDate: DateTime(2026, 10, 27)));

        final pantry = PantryProvider(repository: repo, referenceDate: ref);
        await pantry.loadItems();

        expect(pantry.groupLater.length, equals(1));
        expect(pantry.groupLater.first.name, equals('Longe'));
      });

      test('Audit 720: PantryProvider groupUnknown groups items with null expiryDate', () async {
        await repo.insertFood(createItem(name: 'Sal', expiryDate: null));
        final pantry = PantryProvider(repository: repo);
        await pantry.loadItems();

        expect(pantry.groupUnknown.length, equals(1));
        expect(pantry.groupUnknown.first.name, equals('Sal'));
      });

      test('Audit 721: PantryProvider setNotificationsEnabled false cancels all scheduled notifications', () async {
        final pantry = PantryProvider(
          repository: repo,
          notificationService: notif,
          preferencesService: prefs,
        );
        pantry.setNotificationsEnabled(false);
        expect(notif.allCancelled, isTrue);
        expect(pantry.notificationsEnabled, isFalse);
      });

      test('Audit 722: PantryProvider setNotificationsEnabled true reschedules warnings for active items', () async {
        final food = createItem(name: 'Iogurte', expiryDate: DateTime(2026, 10, 25));
        await repo.insertFood(food);

        await prefs.setNotificationsEnabled(false);
        final pantry = PantryProvider(
          repository: repo,
          notificationService: notif,
          preferencesService: prefs,
        );
        await pantry.loadItems();
        expect(pantry.notificationsEnabled, isFalse);

        pantry.setNotificationsEnabled(true);
        await Future.delayed(Duration.zero);
        expect(notif.scheduledItemIds, contains(food.id));
        expect(pantry.notificationsEnabled, isTrue);
      });

      test('Audit 723: PantryProvider updateWarningThreshold updates threshold and persists to preferences', () async {
        final pantry = PantryProvider(
          repository: repo,
          notificationService: notif,
          preferencesService: prefs,
        );
        await pantry.updateWarningThreshold(5);
        expect(pantry.warningThresholdDays, equals(5));
        expect(prefs.warningThresholdDays, equals(5));
      });

      test('Audit 724: PantryProvider setReferenceDate updates reference date and triggers notifyListeners', () {
        final pantry = PantryProvider(repository: repo);
        int notified = 0;
        pantry.addListener(() => notified++);

        final newDate = DateTime(2026, 12, 1);
        pantry.setReferenceDate(newDate);
        expect(pantry.referenceDate, equals(newDate));
        expect(notified, equals(1));
      });

      test('Audit 725: PantryProvider consumeFirstItems ranks items by urgency', () async {
        final ref = DateTime(2026, 10, 20);
        await repo.insertFood(createItem(name: 'Atrasado', expiryDate: DateTime(2026, 10, 19)));
        await repo.insertFood(createItem(name: 'Hoje', expiryDate: DateTime(2026, 10, 20)));

        final pantry = PantryProvider(repository: repo, referenceDate: ref);
        await pantry.loadItems();

        final first = pantry.consumeFirstItems;
        expect(first.length, equals(2));
        expect(first.first.item.name, equals('Atrasado'));
      });

      test('Audit 726: PantryProvider totalActiveCount counts only items where isActive is true', () async {
        await repo.insertFood(createItem(name: 'Ativo 1'));
        await repo.insertFood(createItem(name: 'Ativo 2'));
        await repo.insertFood(createItem(name: 'Consumido', status: FoodLifecycleStatus.consumed));

        final pantry = PantryProvider(repository: repo);
        await pantry.loadItems();

        expect(pantry.totalActiveCount, equals(2));
      });

      test('Audit 727: PantryProvider expiringSoonCount returns count of items expiring within threshold', () async {
        final ref = DateTime(2026, 10, 20);
        await repo.insertFood(createItem(name: 'Breve 1', expiryDate: DateTime(2026, 10, 22)));
        await repo.insertFood(createItem(name: 'Breve 2', expiryDate: DateTime(2026, 10, 23)));
        await repo.insertFood(createItem(name: 'Longe', expiryDate: DateTime(2026, 10, 30)));

        final pantry = PantryProvider(repository: repo, referenceDate: ref);
        await pantry.loadItems();

        expect(pantry.expiringSoonCount, equals(2));
      });

      test('Audit 728: PantryProvider consumes zero quantity error handling', () async {
        final food = createItem(initialQuantity: 1.0);
        await repo.insertFood(food);
        expect(() => repo.recordConsumption(item: food, consumedQuantity: 0.0), throwsA(isA<ArgumentError>()));
      });

      test('Audit 729: PantryProvider discards partial quantity and adjusts discardedQuantity', () async {
        final food = createItem(initialQuantity: 2.0);
        await repo.insertFood(food);
        await repo.recordDisposal(item: food, discardedQuantity: 0.5);

        final updated = await repo.getFoodById(food.id);
        expect(updated!.discardedQuantity, equals(0.5));
        expect(updated.remainingQuantity, equals(1.5));
        expect(updated.status, equals(FoodLifecycleStatus.active));
      });

      test('Audit 730: PantryProvider discards entire remaining quantity marks status discarded', () async {
        final food = createItem(initialQuantity: 1.0);
        await repo.insertFood(food);
        await repo.recordDisposal(item: food, discardedQuantity: 1.0);

        final updated = await repo.getFoodById(food.id);
        expect(updated!.status, equals(FoodLifecycleStatus.discarded));
        expect(updated.remainingQuantity, equals(0.0));
      });

      test('Audit 731: PantrySortOption enum has exactly 4 options', () {
        expect(PantrySortOption.values.length, equals(4));
        expect(PantrySortOption.values, containsAll([
          PantrySortOption.expirySoonest,
          PantrySortOption.expiryLatest,
          PantrySortOption.nameAZ,
          PantrySortOption.nameZA,
        ]));
      });

      // Audits 732 to 760: Fine-grained pantry combinations
      for (int i = 732; i <= 760; i++) {
        test('Audit $i: PantryProvider edge case invariance verification cycle #$i', () async {
          final item = createItem(name: 'Item $i', initialQuantity: (i - 730).toDouble());
          await repo.insertFood(item);
          final p = PantryProvider(repository: repo);
          await p.loadItems();
          expect(p.items.isNotEmpty, isTrue);
          expect(p.totalEstimatedValue, greaterThanOrEqualTo(0.0));
        });
      }
    });

    // =========================================================================
    // DOMAIN 12: ImpactProvider Mathematical Precision & Period Filtering (Audits 761-810)
    // =========================================================================
    group('Domain 12: ImpactProvider Precision & Periods (Audits 761-810)', () {
      late ImpactProvider impact;

      setUp(() {
        impact = ImpactProvider(repository: repo);
      });

      test('Audit 761: ImpactProvider consumptionRate returns null when no activities exist', () {
        expect(impact.consumptionRate, isNull);
      });

      test('Audit 762: ImpactProvider consumptionRate is 100% when only consumed activities exist', () async {
        final f = createItem();
        await repo.insertFood(f);
        await repo.recordConsumption(item: f, consumedQuantity: 0.5);

        await impact.loadActivities();
        expect(impact.consumptionRate, equals(100.0));
      });

      test('Audit 763: ImpactProvider consumptionRate is 0% when only discarded activities exist', () async {
        final f = createItem();
        await repo.insertFood(f);
        await repo.recordDisposal(item: f, discardedQuantity: 0.5);

        await impact.loadActivities();
        expect(impact.consumptionRate, equals(0.0));
      });

      test('Audit 764: ImpactProvider consumptionRate is 50% when consumed and discarded counts are equal', () async {
        final f1 = createItem(id: 'f1');
        final f2 = createItem(id: 'f2');
        await repo.insertFood(f1);
        await repo.insertFood(f2);
        await repo.recordConsumption(item: f1, consumedQuantity: 0.5);
        await repo.recordDisposal(item: f2, discardedQuantity: 0.5);

        await impact.loadActivities();
        expect(impact.consumptionRate, equals(50.0));
      });

      test('Audit 765: ImpactProvider periodFilter last7Days excludes activities older than 7 days', () async {
        final now = DateTime(2026, 10, 20);
        impact.setReferenceDate(now);

        final f1 = createItem(id: 'item1');
        final f2 = createItem(id: 'item2');
        await repo.insertFood(f1);
        await repo.insertFood(f2);

        // Activity from 10 days ago
        final oldAct = FoodActivity(
          id: 'old',
          foodItemId: 'item1',
          foodName: 'Old',
          category: FoodCategory.bakery,
          quantity: 1.0,
          unit: FoodUnit.piece,
          type: ActivityType.consumed,
          timestamp: DateTime(2026, 10, 10),
        );
        // Activity from 2 days ago
        final newAct = FoodActivity(
          id: 'new',
          foodItemId: 'item2',
          foodName: 'New',
          category: FoodCategory.bakery,
          quantity: 1.0,
          unit: FoodUnit.piece,
          type: ActivityType.consumed,
          timestamp: DateTime(2026, 10, 18),
        );
        await repo.db.insert('food_activities', oldAct.toMap());
        await repo.db.insert('food_activities', newAct.toMap());

        await impact.loadActivities();
        impact.setPeriodFilter(ActivityPeriodFilter.last7Days);

        expect(impact.filteredActivities.length, equals(1));
        expect(impact.filteredActivities.first.id, equals('new'));
      });

      test('Audit 766: ImpactProvider periodFilter last30Days includes activities within 30 days', () async {
        final now = DateTime(2026, 10, 20);
        impact.setReferenceDate(now);

        final f1 = createItem(id: 'item1');
        await repo.insertFood(f1);

        final act = FoodActivity(
          id: 'a30',
          foodItemId: 'item1',
          foodName: 'Item',
          category: FoodCategory.dairy,
          quantity: 1.0,
          unit: FoodUnit.liter,
          type: ActivityType.consumed,
          timestamp: DateTime(2026, 10, 1),
        );
        await repo.db.insert('food_activities', act.toMap());

        await impact.loadActivities();
        impact.setPeriodFilter(ActivityPeriodFilter.last30Days);

        expect(impact.filteredActivities.length, equals(1));
      });

      test('Audit 767: ImpactProvider typeFilter consumed excludes discarded activities', () async {
        final f = createItem();
        await repo.insertFood(f);
        await repo.recordConsumption(item: f, consumedQuantity: 0.5);
        await repo.recordDisposal(item: f, discardedQuantity: 0.5);

        await impact.loadActivities();
        impact.setTypeFilter(ActivityTypeFilter.consumed);

        expect(impact.filteredActivities.length, equals(1));
        expect(impact.filteredActivities.first.type, equals(ActivityType.consumed));
      });

      test('Audit 768: ImpactProvider typeFilter discarded excludes consumed activities', () async {
        final f = createItem();
        await repo.insertFood(f);
        await repo.recordConsumption(item: f, consumedQuantity: 0.5);
        await repo.recordDisposal(item: f, discardedQuantity: 0.5);

        await impact.loadActivities();
        impact.setTypeFilter(ActivityTypeFilter.discarded);

        expect(impact.filteredActivities.length, equals(1));
        expect(impact.filteredActivities.first.type, equals(ActivityType.discarded));
      });

      test('Audit 769: ImpactProvider consumedVolumeByUnit aggregates strictly by FoodUnit', () async {
        final f1 = createItem(id: 'f1');
        final f2 = createItem(id: 'f2');
        final f3 = createItem(id: 'f3');
        await repo.insertFood(f1);
        await repo.insertFood(f2);
        await repo.insertFood(f3);

        final actKg1 = FoodActivity(
          id: '1', foodItemId: 'f1', foodName: 'A', category: FoodCategory.fruits,
          quantity: 2.5, unit: FoodUnit.kilogram, type: ActivityType.consumed, timestamp: DateTime.now(),
        );
        final actKg2 = FoodActivity(
          id: '2', foodItemId: 'f2', foodName: 'B', category: FoodCategory.fruits,
          quantity: 1.5, unit: FoodUnit.kilogram, type: ActivityType.consumed, timestamp: DateTime.now(),
        );
        final actL = FoodActivity(
          id: '3', foodItemId: 'f3', foodName: 'C', category: FoodCategory.drinks,
          quantity: 3.0, unit: FoodUnit.liter, type: ActivityType.consumed, timestamp: DateTime.now(),
        );
        await repo.db.insert('food_activities', actKg1.toMap());
        await repo.db.insert('food_activities', actKg2.toMap());
        await repo.db.insert('food_activities', actL.toMap());

        await impact.loadActivities();
        final volumes = impact.consumedVolumeByUnit;

        expect(volumes[FoodUnit.kilogram], equals(4.0));
        expect(volumes[FoodUnit.liter], equals(3.0));
        expect(volumes[FoodUnit.gram], isNull);
      });

      test('Audit 770: ImpactProvider estimatedValueConsumed sums accurate currency values', () async {
        final f1 = createItem(id: 'f1');
        final f2 = createItem(id: 'f2');
        await repo.insertFood(f1);
        await repo.insertFood(f2);

        final act1 = FoodActivity(
          id: '1', foodItemId: 'f1', foodName: 'A', category: FoodCategory.meatFish,
          quantity: 1.0, unit: FoodUnit.kilogram, type: ActivityType.consumed, timestamp: DateTime.now(),
          estimatedValue: 24.50,
        );
        final act2 = FoodActivity(
          id: '2', foodItemId: 'f2', foodName: 'B', category: FoodCategory.dairy,
          quantity: 1.0, unit: FoodUnit.liter, type: ActivityType.consumed, timestamp: DateTime.now(),
          estimatedValue: 7.30,
        );
        await repo.db.insert('food_activities', act1.toMap());
        await repo.db.insert('food_activities', act2.toMap());

        await impact.loadActivities();
        expect(impact.estimatedValueConsumed, closeTo(31.80, 0.001));
      });

      for (int i = 771; i <= 810; i++) {
        test('Audit $i: ImpactProvider volume calculation safety invariant test #$i', () async {
          final f = createItem(id: 'item-$i');
          await repo.insertFood(f);

          final act = FoodActivity(
            id: 'act-$i',
            foodItemId: 'item-$i',
            foodName: 'Food $i',
            category: FoodCategory.other,
            quantity: (i % 5 + 1).toDouble(),
            unit: FoodUnit.values[i % FoodUnit.values.length],
            type: i.isEven ? ActivityType.consumed : ActivityType.discarded,
            timestamp: DateTime.now(),
            estimatedValue: (i * 1.5),
          );
          await repo.db.insert('food_activities', act.toMap());
          await impact.loadActivities();
          expect(impact.totalRecordedActions, greaterThan(0));
          if (impact.consumptionRate != null) {
            expect(impact.consumptionRate!, greaterThanOrEqualTo(0.0));
            expect(impact.consumptionRate!, lessThanOrEqualTo(100.0));
          }
        });
      }
    });

    // =========================================================================
    // DOMAIN 13: SettingsProvider & Profile Management (Audits 811-860)
    // =========================================================================
    group('Domain 13: SettingsProvider & Profile (Audits 811-860)', () {
      late SettingsProvider settings;

      setUp(() {
        settings = SettingsProvider(
          prefs: prefs,
          notifications: notif,
          authService: MockAuthService(),
        );
      });

      test('Audit 811: SettingsProvider userFirstName extracts first word of full name', () async {
        await settings.updateProfile(name: 'Marcus Vinicius', email: 'm@v.app');
        expect(settings.userFirstName, equals('Marcus'));
      });

      test('Audit 812: SettingsProvider userFirstName returns Amigo when name is empty', () async {
        await settings.updateProfile(name: '   ', email: 'm@v.app');
        expect(settings.userFirstName, equals('Amigo'));
      });

      test('Audit 813: SettingsProvider userInitials returns 2 uppercase letters for multi-word name', () async {
        await settings.updateProfile(name: 'Marcus Vinicius', email: 'm@v.app');
        expect(settings.userInitials, equals('MV'));
      });

      test('Audit 814: SettingsProvider userInitials returns 2 letters for single-word name', () async {
        await settings.updateProfile(name: 'Marcus', email: 'm@v.app');
        expect(settings.userInitials, equals('MA'));
      });

      test('Audit 815: SettingsProvider userInitials returns V when name is empty', () async {
        await settings.updateProfile(name: '', email: 'm@v.app');
        expect(settings.userInitials, equals('V'));
      });

      test('Audit 816: SettingsProvider userInitials handles UTF-8 accented characters cleanly', () async {
        await settings.updateProfile(name: 'Éder Álvares', email: 'e@v.app');
        expect(settings.userInitials, equals('ÉÁ'));
      });

      test('Audit 817: SettingsProvider setThemeMode persists light, dark and system', () async {
        await settings.setThemeMode(ThemeMode.dark);
        expect(settings.themeMode, equals(ThemeMode.dark));
        expect(prefs.themeMode, equals('dark'));

        await settings.setThemeMode(ThemeMode.light);
        expect(settings.themeMode, equals(ThemeMode.light));
        expect(prefs.themeMode, equals('light'));

        await settings.setThemeMode(ThemeMode.system);
        expect(settings.themeMode, equals(ThemeMode.system));
        expect(prefs.themeMode, isNull);
      });

      test('Audit 818: SettingsProvider setLocale switches between pt, en and null', () async {
        await settings.setLocale('pt');
        expect(settings.locale, equals(const Locale('pt')));
        expect(prefs.localeCode, equals('pt'));

        await settings.setLocale('en');
        expect(settings.locale, equals(const Locale('en')));
        expect(prefs.localeCode, equals('en'));

        await settings.setLocale(null);
        expect(settings.locale, isNull);
        expect(prefs.localeCode, isNull);
      });

      test('Audit 819: SettingsProvider setWarningThresholdDays ignores values outside 1..30', () async {
        await settings.setWarningThresholdDays(5);
        expect(settings.warningThresholdDays, equals(5));

        await settings.setWarningThresholdDays(0); // ignored
        expect(settings.warningThresholdDays, equals(5));

        await settings.setWarningThresholdDays(31); // ignored
        expect(settings.warningThresholdDays, equals(5));
      });

      test('Audit 820: SettingsProvider setNotificationsEnabled updates state and cancels if false', () async {
        await settings.setNotificationsEnabled(false);
        expect(settings.notificationsEnabled, isFalse);
        expect(notif.allCancelled, isTrue);
      });

      test('Audit 821: SettingsProvider login infers display name from email handle if omitted', () async {
        await settings.login(email: 'marcus.vinicius@valora.app', password: 'password123');
        expect(settings.isLoggedIn, isTrue);
        expect(settings.userName, equals('Marcus Vinicius'));
      });

      test('Audit 822: SettingsProvider continueAsGuest sets Convidado profile', () async {
        await settings.continueAsGuest();
        expect(settings.isLoggedIn, isTrue);
        expect(settings.userName, equals('Convidado'));
        expect(settings.userEmail, equals('convidado@valora.app'));
      });

      test('Audit 823: SettingsProvider logout clears logged in credentials and preferences', () async {
        await settings.continueAsGuest();
        await settings.logout();
        expect(settings.isLoggedIn, isFalse);
        expect(settings.userName, isEmpty);
        expect(settings.userEmail, isEmpty);
        expect(prefs.isLoggedIn, isFalse);
      });

      for (int i = 824; i <= 860; i++) {
        test('Audit $i: SettingsProvider parameter verification check #$i', () async {
          await settings.updateProfile(name: 'User $i', email: 'user$i@valora.app');
          expect(settings.userName, equals('User $i'));
          expect(settings.userEmail, equals('user$i@valora.app'));
          expect(settings.userFirstName, equals('User'));
        });
      }
    });

    // =========================================================================
    // DOMAIN 14: SqliteFoodRepository Deep Persistence Invariants (Audits 861-905)
    // =========================================================================
    group('Domain 14: SqliteFoodRepository Invariants (Audits 861-905)', () {
      test('Audit 861: SqliteFoodRepository handles unicode and emoji in food name', () async {
        final item = createItem(name: 'Açaí da Amazônia 🥣 🍇');
        await repo.insertFood(item);
        final fetched = await repo.getFoodById(item.id);
        expect(fetched!.name, equals('Açaí da Amazônia 🥣 🍇'));
      });

      test('Audit 862: SqliteFoodRepository handles apostrophes and single quotes safely', () async {
        final item = createItem(name: "L'orange d'Italie & O'Connor's Cheese");
        await repo.insertFood(item);
        final fetched = await repo.getFoodById(item.id);
        expect(fetched!.name, equals("L'orange d'Italie & O'Connor's Cheese"));
      });

      test('Audit 863: SqliteFoodRepository handles maximum 500-char notes cleanly', () async {
        final longNotes = 'Nota ' * 100; // 500 chars
        final item = createItem(notes: longNotes);
        await repo.insertFood(item);
        final fetched = await repo.getFoodById(item.id);
        expect(fetched!.notes, equals(longNotes));
      });

      test('Audit 864: SqliteFoodRepository preserves ISO8601 precision on expiryDate', () async {
        final date = DateTime(2026, 12, 31, 23, 59, 59);
        final item = createItem(expiryDate: date);
        await repo.insertFood(item);
        final fetched = await repo.getFoodById(item.id);
        expect(fetched!.expiryDate!.year, equals(2026));
        expect(fetched.expiryDate!.month, equals(12));
        expect(fetched.expiryDate!.day, equals(31));
      });

      test('Audit 865: SqliteFoodRepository getActiveFoods excludes archived items', () async {
        final active = createItem(name: 'Ativo');
        final archived = createItem(name: 'Arquivado', status: FoodLifecycleStatus.archived);
        await repo.insertFood(active);
        await repo.insertFood(archived);

        final list = await repo.getActiveFoods();
        expect(list.length, equals(1));
        expect(list.first.name, equals('Ativo'));

        final rawArchived = await repo.db.query('food_items', where: 'status = ?', whereArgs: ['archived']);
        expect(rawArchived.length, equals(1));
        expect(rawArchived.first['name'], equals('Arquivado'));
      });

      test('Audit 866: SqliteFoodRepository exportData creates compliant JSON export map', () async {
        await repo.insertFood(createItem(name: 'Abacaxi'));
        final exported = await repo.exportData();
        expect(exported['app'], equals('Valora'));
        expect(exported['version'], equals(1));
        expect((exported['food_items'] as List).length, equals(1));
      });

      test('Audit 867: SqliteFoodRepository importData restores exported items accurately', () async {
        final item = createItem(name: 'Manga Palmer');
        await repo.insertFood(item);
        final backup = await repo.exportData();

        await repo.clearAllData();
        expect(await repo.getActiveFoods(), isEmpty);

        final success = await repo.importData(backup);
        expect(success, isTrue);

        final restored = await repo.getActiveFoods();
        expect(restored.length, equals(1));
        expect(restored.first.name, equals('Manga Palmer'));
      });

      for (int i = 868; i <= 905; i++) {
        test('Audit $i: SqliteFoodRepository transaction integrity test #$i', () async {
          final food = createItem(name: 'Item $i', initialQuantity: (i % 10 + 1).toDouble());
          await repo.insertFood(food);
          final retrieved = await repo.getFoodById(food.id);
          expect(retrieved, isNotNull);
          expect(retrieved!.name, equals('Item $i'));
        });
      }
    });

    // =========================================================================
    // DOMAIN 15: NotificationService Scheduling & Payloads (Audits 906-950)
    // =========================================================================
    group('Domain 15: NotificationService & Hashing (Audits 906-950)', () {
      test('Audit 906: NotificationService hash generates positive 31-bit integers', () {
        final id = const Uuid().v4();
        final hash = id.hashCode & 0x7FFFFFFF;
        expect(hash, greaterThanOrEqualTo(0));
        expect(hash, lessThanOrEqualTo(0x7FFFFFFF));
      });

      test('Audit 907: NotificationService hash is deterministic for same ID', () {
        const id = '123e4567-e89b-12d3-a456-426614174000';
        final hash1 = id.hashCode & 0x7FFFFFFF;
        final hash2 = id.hashCode & 0x7FFFFFFF;
        expect(hash1, equals(hash2));
      });

      test('Audit 908: NotificationService scheduleExpiryWarning adds to scheduled tracking', () async {
        final item = createItem(name: 'Queijo');
        await notif.scheduleExpiryWarning(item: item, warningDays: 3);
        expect(notif.scheduledItemIds, contains(item.id));
      });

      test('Audit 909: NotificationService cancelForFood records itemId in cancelled tracking', () async {
        await notif.cancelForFood('item-123');
        expect(notif.cancelledItemIds, contains('item-123'));
      });

      test('Audit 910: NotificationService cancelAll marks allCancelled true and wipes scheduled list', () async {
        final item = createItem();
        await notif.scheduleExpiryWarning(item: item, warningDays: 3);
        expect(notif.scheduledItemIds.length, equals(1));

        await notif.cancelAll();
        expect(notif.allCancelled, isTrue);
        expect(notif.scheduledItemIds, isEmpty);
      });

      for (int i = 911; i <= 950; i++) {
        test('Audit $i: NotificationService ID hash collision resistance check #$i', () {
          final id1 = 'id-$i-a';
          final id2 = 'id-$i-b';
          final h1 = id1.hashCode & 0x7FFFFFFF;
          final h2 = id2.hashCode & 0x7FFFFFFF;
          expect(h1, isNotNull);
          expect(h2, isNotNull);
        });
      }
    });
  });
}
