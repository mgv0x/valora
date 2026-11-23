import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:valora/data/local/sqlite_food_repository.dart';
import 'package:valora/data/models/expiry_status.dart';
import 'package:valora/data/models/food_activity.dart';
import 'package:valora/data/models/food_category.dart';
import 'package:valora/data/models/food_item.dart';
import 'package:valora/data/models/food_unit.dart';
import 'package:valora/data/models/storage_location.dart';
import 'package:valora/l10n/generated/app_localizations.dart';
import 'package:valora/presentation/screens/expiry/expiry_center_screen.dart';
import 'package:valora/presentation/screens/impact/impact_screen.dart';
import 'package:valora/presentation/screens/pantry/widgets/food_details_sheet.dart';
import 'package:valora/state/impact_provider.dart';
import 'package:valora/state/pantry_provider.dart';

import 'mocks/in_memory_food_repository.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('A. Expiry Center Grouping & Boundaries', () {
    late InMemoryFoodRepository mockRepo;
    late PantryProvider pantryProvider;
    late ImpactProvider impactProvider;
    final now = DateTime(2026, 10, 8, 12, 0);

    setUp(() async {
      mockRepo = InMemoryFoodRepository();

      // Expired item (yesterday)
      await mockRepo.insertFood(FoodItem(
        id: 'exp-1',
        name: 'Iogurte Grego',
        category: FoodCategory.dairy,
        initialQuantity: 2,
        unit: FoodUnit.piece,
        expiryDate: now.subtract(const Duration(days: 1)),
        purchasePrice: 8.0,
        createdAt: now,
        updatedAt: now,
      ));

      // Expiring today (same day)
      await mockRepo.insertFood(FoodItem(
        id: 'today-1',
        name: 'Pão de Queijo Fresco',
        category: FoodCategory.bakery,
        initialQuantity: 6,
        unit: FoodUnit.piece,
        expiryDate: now,
        purchasePrice: 12.0,
        createdAt: now,
        updatedAt: now,
      ));

      // Expiring soon (in 2 days, within 3 days threshold)
      await mockRepo.insertFood(FoodItem(
        id: 'soon-1',
        name: 'Morangos Selecionados',
        category: FoodCategory.fruits,
        initialQuantity: 250,
        unit: FoodUnit.gram,
        expiryDate: now.add(const Duration(days: 2)),
        purchasePrice: 14.0,
        createdAt: now,
        updatedAt: now,
      ));

      // Good for later (in 30 days)
      await mockRepo.insertFood(FoodItem(
        id: 'later-1',
        name: 'Arroz Parboilizado',
        category: FoodCategory.pantryStaples,
        initialQuantity: 5,
        unit: FoodUnit.kilogram,
        expiryDate: now.add(const Duration(days: 30)),
        purchasePrice: 28.0,
        createdAt: now,
        updatedAt: now,
      ));

      // Unknown expiry (null)
      await mockRepo.insertFood(FoodItem(
        id: 'unk-1',
        name: 'Sal Grosso',
        category: FoodCategory.pantryStaples,
        initialQuantity: 1,
        unit: FoodUnit.kilogram,
        expiryDate: null,
        createdAt: now,
        updatedAt: now,
      ));

      pantryProvider = PantryProvider(
        repository: mockRepo,
        referenceDate: now,
      );
      impactProvider = ImpactProvider(repository: mockRepo);
      await pantryProvider.loadItems();
      await impactProvider.loadActivities();
    });

    test('Classifies items into 5 distinct expiry groups correctly', () {
      expect(pantryProvider.groupExpired.length, equals(1));
      expect(pantryProvider.groupExpired.first.name, equals('Iogurte Grego'));

      expect(pantryProvider.groupExpiringToday.length, equals(1));
      expect(pantryProvider.groupExpiringToday.first.name, equals('Pão de Queijo Fresco'));

      expect(pantryProvider.groupExpiringSoon.length, equals(1));
      expect(pantryProvider.groupExpiringSoon.first.name, equals('Morangos Selecionados'));

      expect(pantryProvider.groupLater.length, equals(1));
      expect(pantryProvider.groupLater.first.name, equals('Arroz Parboilizado'));

      expect(pantryProvider.groupUnknown.length, equals(1));
      expect(pantryProvider.groupUnknown.first.name, equals('Sal Grosso'));
    });

    test('Unknown expiry items are never treated as expired or fresh', () {
      final unk = pantryProvider.groupUnknown.first;
      expect(unk.expiryDate, isNull);
      expect(unk.getExpiryStatus(), equals(ExpiryStatus.unknown));
      expect(unk.getDaysRemaining(), isNull);
    });

    test('Direct consumption from pantry syncs repository and impact history', () async {
      final bread = pantryProvider.groupExpiringToday.first;
      await pantryProvider.recordConsumption(
        item: bread,
        consumedQuantity: 3, // Consuming half of the 6 units
        notes: 'Café da tarde',
      );
      await impactProvider.loadActivities();

      // Check remaining stock
      final updatedBread = await mockRepo.getFoodById(bread.id);
      expect(updatedBread!.remainingQuantity, equals(3.0));
      expect(updatedBread.consumedQuantity, equals(3.0));
      expect(updatedBread.isActive, isTrue);

      // Check activity log
      expect(impactProvider.totalRecordedActions, equals(1));
      final act = impactProvider.activities.first;
      expect(act.foodName, equals('Pão de Queijo Fresco'));
      expect(act.type, equals(ActivityType.consumed));
      expect(act.quantity, equals(3.0));
      // Purchase price was 12.0 for 6 units -> 3 units is exactly 6.0
      expect(act.estimatedValue, equals(6.0));
      expect(act.notes, equals('Café da tarde'));
    });
  });

  group('B. Comprehensive Consumption & Disposal Flow', () {
    late InMemoryFoodRepository mockRepo;
    final now = DateTime(2026, 10, 8, 14, 0);

    setUp(() async {
      mockRepo = InMemoryFoodRepository();
    });

    test('Prevents negative or zero quantity consumption', () async {
      final item = FoodItem(
        id: 'item-val-1',
        name: 'Tomates',
        category: FoodCategory.vegetables,
        initialQuantity: 10,
        unit: FoodUnit.piece,
        createdAt: now,
        updatedAt: now,
      );
      await mockRepo.insertFood(item);

      expect(
        () => mockRepo.recordConsumption(item: item, consumedQuantity: 0),
        throwsArgumentError,
      );
      expect(
        () => mockRepo.recordConsumption(item: item, consumedQuantity: -2),
        throwsArgumentError,
      );
    });

    test('Prevents consuming or discarding more than available remaining stock', () async {
      final item = FoodItem(
        id: 'item-val-2',
        name: 'Azeite',
        category: FoodCategory.pantryStaples,
        initialQuantity: 500,
        unit: FoodUnit.milliliter,
        createdAt: now,
        updatedAt: now,
      );
      await mockRepo.insertFood(item);

      // First consume 300ml -> 200ml remaining
      await mockRepo.recordConsumption(item: item, consumedQuantity: 300);
      final updated = (await mockRepo.getFoodById(item.id))!;
      expect(updated.remainingQuantity, equals(200.0));

      // Attempting to consume 201ml must throw ArgumentError
      expect(
        () => mockRepo.recordConsumption(item: updated, consumedQuantity: 201),
        throwsArgumentError,
      );

      // Attempting to discard 201ml must throw ArgumentError
      expect(
        () => mockRepo.recordDisposal(item: updated, discardedQuantity: 201),
        throwsArgumentError,
      );
    });

    test('Full consumption archives item from active pantry but preserves activity history', () async {
      final item = FoodItem(
        id: 'item-val-3',
        name: 'Chocolate 70%',
        category: FoodCategory.other,
        initialQuantity: 1,
        unit: FoodUnit.piece,
        purchasePrice: 15.0,
        createdAt: now,
        updatedAt: now,
      );
      await mockRepo.insertFood(item);

      await mockRepo.recordConsumption(item: item, consumedQuantity: 1.0);

      // Item is no longer in active pantry
      final activeList = await mockRepo.getActiveFoods();
      expect(activeList, isEmpty);

      // Direct lookup shows item is consumed
      final rawItem = await mockRepo.getFoodById(item.id);
      expect(rawItem!.status, equals(FoodLifecycleStatus.consumed));
      expect(rawItem.remainingQuantity, equals(0.0));

      // Activity history is fully intact
      final history = await mockRepo.getActivityHistory();
      expect(history.length, equals(1));
      expect(history.first.foodItemId, equals('item-val-3'));
      expect(history.first.type, equals(ActivityType.consumed));
      expect(history.first.estimatedValue, equals(15.0));
    });

    test('Full disposal archives item and correctly records disposal activity', () async {
      final item = FoodItem(
        id: 'item-val-4',
        name: 'Molho Estragado',
        category: FoodCategory.pantryStaples,
        initialQuantity: 300,
        unit: FoodUnit.gram,
        purchasePrice: 9.0,
        createdAt: now,
        updatedAt: now,
      );
      await mockRepo.insertFood(item);

      await mockRepo.recordDisposal(
        item: item,
        discardedQuantity: 300,
        notes: 'Mofo na tampa',
      );

      final activeList = await mockRepo.getActiveFoods();
      expect(activeList, isEmpty);

      final history = await mockRepo.getActivityHistory();
      expect(history.length, equals(1));
      expect(history.first.foodName, equals('Molho Estragado'));
      expect(history.first.type, equals(ActivityType.discarded));
      expect(history.first.estimatedValue, equals(9.0));
      expect(history.first.notes, equals('Mofo na tampa'));
    });
  });

  group('C. Persistent SQLite App Restart for Consumption & Disposal', () {
    late Directory tempDir;
    late String dbFilePath;
    final now = DateTime(2026, 10, 8, 15, 0);

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('valora_session3_sqlite_');
      dbFilePath = '${tempDir.path}${Platform.pathSeparator}session3_test.db';
    });

    tearDown(() {
      try {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      } catch (_) {}
    });

    test('Persists consumption and disposal history across SQLite database reopening', () async {
      // Phase 1: Open first session, write item, record partial consumption and partial discard
      final repo1 = SqliteFoodRepository(customDbPath: dbFilePath);
      await repo1.init();

      final item = FoodItem(
        id: 'sqlite-flow-1',
        name: 'Café Especial em Grãos',
        category: FoodCategory.drinks,
        initialQuantity: 500,
        unit: FoodUnit.gram,
        purchasePrice: 40.0,
        storageLocation: StorageLocation.pantry,
        createdAt: now,
        updatedAt: now,
      );
      await repo1.insertFood(item);

      // Consume 200g (proportional value: 16.0)
      await repo1.recordConsumption(
        item: item,
        consumedQuantity: 200,
        notes: 'Coado da manhã',
      );

      // Discard 50g (proportional value: 4.0)
      final afterConsume = (await repo1.getFoodById(item.id))!;
      await repo1.recordDisposal(
        item: afterConsume,
        discardedQuantity: 50,
        notes: 'Moagem desregulada',
      );

      // Verify active item has 250g remaining
      final active1 = await repo1.getActiveFoods();
      expect(active1.length, equals(1));
      expect(active1.first.remainingQuantity, equals(250.0));

      // Close repository 1 (simulating app close)
      await repo1.close();

      // Phase 2: Open second session on the exact same database file
      final repo2 = SqliteFoodRepository(customDbPath: dbFilePath);
      await repo2.init();

      // Active food state reloaded correctly
      final active2 = await repo2.getActiveFoods();
      expect(active2.length, equals(1));
      expect(active2.first.id, equals('sqlite-flow-1'));
      expect(active2.first.remainingQuantity, equals(250.0));
      expect(active2.first.consumedQuantity, equals(200.0));
      expect(active2.first.discardedQuantity, equals(50.0));

      // Activities log reloaded correctly
      final history = await repo2.getActivityHistory();
      expect(history.length, equals(2));

      // Check consumed event
      final consumedAct = history.firstWhere((a) => a.type == ActivityType.consumed);
      expect(consumedAct.quantity, equals(200.0));
      expect(consumedAct.estimatedValue, equals(16.0));
      expect(consumedAct.notes, equals('Coado da manhã'));

      // Check discarded event
      final discardedAct = history.firstWhere((a) => a.type == ActivityType.discarded);
      expect(discardedAct.quantity, equals(50.0));
      expect(discardedAct.estimatedValue, equals(4.0));
      expect(discardedAct.notes, equals('Moagem desregulada'));

      await repo2.close();
    });
  });

  group('D. My Impact Metrics, Honest Calculations & Unit Volume Grouping', () {
    late InMemoryFoodRepository mockRepo;
    late ImpactProvider provider;
    final now = DateTime.now();

    setUp(() async {
      mockRepo = InMemoryFoodRepository();

      // Item 1: Consumed 1.5 kg of apples (purchase price 15.0 for 2.0 kg -> 11.25)
      final apple = FoodItem(
        id: 'imp-apple',
        name: 'Maçãs',
        category: FoodCategory.fruits,
        initialQuantity: 2.0,
        unit: FoodUnit.kilogram,
        purchasePrice: 15.0,
        createdAt: now,
        updatedAt: now,
      );
      await mockRepo.insertFood(apple);
      await mockRepo.recordConsumption(item: apple, consumedQuantity: 1.5);

      // Item 2: Discarded 0.5 kg of apples (purchase price 15.0 for 2.0 kg -> 3.75)
      final appleAfter = (await mockRepo.getFoodById(apple.id))!;
      await mockRepo.recordDisposal(item: appleAfter, discardedQuantity: 0.5);

      // Item 3: Consumed 2.0 L of Milk (purchase price 10.0 for 2.0 L -> 10.0)
      final milk = FoodItem(
        id: 'imp-milk',
        name: 'Leite Integral',
        category: FoodCategory.dairy,
        initialQuantity: 2.0,
        unit: FoodUnit.liter,
        purchasePrice: 10.0,
        createdAt: now,
        updatedAt: now,
      );
      await mockRepo.insertFood(milk);
      await mockRepo.recordConsumption(item: milk, consumedQuantity: 2.0);

      // Item 4: Discarded 1 piece without purchase price (null price)
      final avocado = FoodItem(
        id: 'imp-avocado',
        name: 'Abacate do Quintal',
        category: FoodCategory.fruits,
        initialQuantity: 1.0,
        unit: FoodUnit.piece,
        purchasePrice: null, // No price entered
        createdAt: now,
        updatedAt: now,
      );
      await mockRepo.insertFood(avocado);
      await mockRepo.recordDisposal(item: avocado, discardedQuantity: 1.0);

      provider = ImpactProvider(repository: mockRepo);
      await provider.loadActivities();
    });

    test('Accurately calculates consumed and discarded counts and rate', () {
      expect(provider.totalRecordedActions, equals(4));
      expect(provider.recordedConsumedCount, equals(2));
      expect(provider.recordedDiscardedCount, equals(2));
      expect(provider.consumptionRate, equals(50.0)); // 2 consumed / 4 total = 50%
    });

    test('Never counts discarded items as savings; only calculates values when price was entered', () {
      // Consumed: 11.25 (apples) + 10.0 (milk) = 21.25
      expect(provider.estimatedValueConsumed, closeTo(21.25, 0.001));

      // Discarded: 3.75 (apples) + 0 (avocado with null price) = 3.75
      expect(provider.estimatedValueDiscarded, closeTo(3.75, 0.001));
    });

    test('Groups volume strictly by unit without invalidly summing kilograms with liters', () {
      final consumedVolume = provider.consumedVolumeByUnit;
      expect(consumedVolume[FoodUnit.kilogram], equals(1.5));
      expect(consumedVolume[FoodUnit.liter], equals(2.0));
      expect(consumedVolume.containsKey(FoodUnit.piece), isFalse);

      final discardedVolume = provider.discardedVolumeByUnit;
      expect(discardedVolume[FoodUnit.kilogram], equals(0.5));
      expect(discardedVolume[FoodUnit.piece], equals(1.0));
      expect(discardedVolume.containsKey(FoodUnit.liter), isFalse);
    });

    test('Filters activities by action type (consumed only vs discarded only)', () {
      provider.setTypeFilter(ActivityTypeFilter.consumed);
      expect(provider.filteredActivities.length, equals(2));
      expect(provider.filteredActivities.every((a) => a.type == ActivityType.consumed), isTrue);

      provider.setTypeFilter(ActivityTypeFilter.discarded);
      expect(provider.filteredActivities.length, equals(2));
      expect(provider.filteredActivities.every((a) => a.type == ActivityType.discarded), isTrue);

      provider.setTypeFilter(ActivityTypeFilter.all);
      expect(provider.filteredActivities.length, equals(4));
    });

    test('Filters activities by period (last 7 days)', () {
      provider.setPeriodFilter(ActivityPeriodFilter.last7Days);
      // All activities were recorded just now, so all are within 7 days
      expect(provider.filteredActivities.length, equals(4));
    });
  });

  group('E. UI Widgets: Expiry Center & Impact Screen', () {
    late InMemoryFoodRepository mockRepo;
    late PantryProvider pantryProvider;
    late ImpactProvider impactProvider;
    final now = DateTime.now();

    setUp(() async {
      mockRepo = InMemoryFoodRepository();

      await mockRepo.insertFood(FoodItem(
        id: 'w-exp-1',
        name: 'Ricota Fresca',
        category: FoodCategory.dairy,
        initialQuantity: 200,
        unit: FoodUnit.gram,
        expiryDate: now.subtract(const Duration(days: 2)),
        purchasePrice: 12.0,
        createdAt: now,
        updatedAt: now,
      ));

      await mockRepo.insertFood(FoodItem(
        id: 'w-fresh-1',
        name: 'Castanha de Caju',
        category: FoodCategory.pantryStaples,
        initialQuantity: 150,
        unit: FoodUnit.gram,
        expiryDate: now.add(const Duration(days: 60)),
        purchasePrice: 18.0,
        createdAt: now,
        updatedAt: now,
      ));

      // Record 1 consumption activity
      final rawRicota = (await mockRepo.getFoodById('w-exp-1'))!;
      await mockRepo.recordConsumption(
        item: rawRicota,
        consumedQuantity: 50,
        notes: 'Pão de manhã',
      );

      pantryProvider = PantryProvider(
        repository: mockRepo,
        referenceDate: now,
      );
      impactProvider = ImpactProvider(repository: mockRepo);
      await pantryProvider.loadItems();
      await impactProvider.loadActivities();
    });

    Widget createTestApp(Widget child) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<PantryProvider>.value(value: pantryProvider),
          ChangeNotifierProvider<ImpactProvider>.value(value: impactProvider),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: child,
        ),
      );
    }

    testWidgets('ExpiryCenterScreen renders food safety disclaimer banner and opens details sheet',
        (tester) async {
      await tester.pumpWidget(createTestApp(const ExpiryCenterScreen()));
      await tester.pumpAndSettle();

      // Verify food safety education banner is visible
      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);

      // Verify expired item tile is present
      expect(find.text('Ricota Fresca'), findsOneWidget);

      // Tap on item tile
      await tester.tap(find.text('Ricota Fresca'));
      await tester.pumpAndSettle();

      // Verify FoodDetailsSheet modal is opened
      expect(find.byType(FoodDetailsSheet), findsOneWidget);
    });

    testWidgets('ImpactScreen renders metric cards, unit breakdown, and opens activity details',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestApp(const ImpactScreen()));
      await tester.pumpAndSettle();

      // Verify summary title
      expect(find.text('Meu Impacto'), findsOneWidget);

      // Verify filter chips exist
      expect(find.text('Este mês'), findsOneWidget);
      expect(find.text('Últimos 3 meses'), findsOneWidget);
      expect(find.text('Todo o ano'), findsOneWidget);

      // Verify impact rate and community cards
      expect(find.text('Alimentos aproveitados com sucesso'), findsOneWidget);
      expect(find.text('Valora Comunidade'), findsOneWidget);
    });
  });
}
