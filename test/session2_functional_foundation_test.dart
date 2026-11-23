import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:valora/core/utils/text_utils.dart';
import 'package:valora/data/local/sqlite_food_repository.dart';
import 'package:valora/data/models/expiry_status.dart';
import 'package:valora/data/models/food_category.dart';
import 'package:valora/data/models/food_item.dart';
import 'package:valora/data/models/food_unit.dart';
import 'package:valora/data/models/storage_location.dart';
import 'package:valora/l10n/generated/app_localizations.dart';
import 'package:valora/presentation/screens/pantry/pantry_screen.dart';
import 'package:valora/presentation/screens/pantry/widgets/food_details_sheet.dart';
import 'package:valora/state/pantry_provider.dart';

import 'mocks/in_memory_food_repository.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('A. TextUtils Accent & Diacritic Normalization', () {
    test('Normalizes Portuguese accented characters to ASCII equivalents', () {
      expect(TextUtils.normalize('Maçã'), equals('maca'));
      expect(TextUtils.normalize('PÃO DE FORMA'), equals('pao de forma'));
      expect(TextUtils.normalize('Café solúvel'), equals('cafe soluvel'));
      expect(TextUtils.normalize('Açaí na tigela'), equals('acai na tigela'));
      expect(TextUtils.normalize('Árvore'), equals('arvore'));
      expect(TextUtils.normalize('Óleo de coco'), equals('oleo de coco'));
    });

    test('Matches search query regardless of case and accents', () {
      expect(TextUtils.matchesSearch('Maçã Fuji', 'maca'), isTrue);
      expect(TextUtils.matchesSearch('Maçã Fuji', 'FUJI'), isTrue);
      expect(TextUtils.matchesSearch('Maçã Fuji', 'maça'), isTrue);
      expect(TextUtils.matchesSearch('Pão Integral', 'pao'), isTrue);
      expect(TextUtils.matchesSearch('Pão Integral', 'PÃO'), isTrue);
      expect(TextUtils.matchesSearch('Frango Congelado', 'frango'), isTrue);
      expect(TextUtils.matchesSearch('Frango Congelado', 'peixe'), isFalse);
      expect(TextUtils.matchesSearch('Qualquer alimento', ''), isTrue);
      expect(TextUtils.matchesSearch('Qualquer alimento', '   '), isTrue);
    });
  });

  group('B. FoodItem Model Validation & Boundary Guards', () {
    final now = DateTime(2026, 10, 8, 12, 0);

    test('Valid item returns no errors', () {
      final item = FoodItem(
        id: 'valid-1',
        name: 'Arroz Integral',
        category: FoodCategory.pantryStaples,
        initialQuantity: 1.0,
        unit: FoodUnit.kilogram,
        expiryDate: now.add(const Duration(days: 90)),
        purchasePrice: 6.50,
        createdAt: now,
        updatedAt: now,
      );
      expect(item.validate(), isEmpty);
    });

    test('Enforces maximum name length of 150 characters', () {
      final longName = 'A' * 151;
      final item = FoodItem(
        id: 'long-name-1',
        name: longName,
        category: FoodCategory.other,
        initialQuantity: 1.0,
        unit: FoodUnit.piece,
        createdAt: now,
        updatedAt: now,
      );
      final errors = item.validate();
      expect(errors, contains('Food name cannot exceed 150 characters.'));
    });

    test('Enforces maximum quantity bounds (1,000,000)', () {
      final item = FoodItem(
        id: 'huge-qty-1',
        name: 'Açúcar Cristal',
        category: FoodCategory.pantryStaples,
        initialQuantity: 1000001.0,
        unit: FoodUnit.gram,
        createdAt: now,
        updatedAt: now,
      );
      final errors = item.validate();
      expect(errors, contains('Initial quantity is too large.'));
    });

    test('Rejects negative and excessive purchase prices', () {
      final negItem = FoodItem(
        id: 'neg-price-1',
        name: 'Azeite de Oliva',
        category: FoodCategory.pantryStaples,
        initialQuantity: 1.0,
        unit: FoodUnit.piece,
        purchasePrice: -5.0,
        createdAt: now,
        updatedAt: now,
      );
      expect(negItem.validate(), contains('Purchase price cannot be negative.'));

      final excessiveItem = negItem.copyWith(purchasePrice: 1000001.0);
      expect(excessiveItem.validate(), contains('Purchase price is too large.'));
    });

    test('Unknown expiry date (null) is valid and yields ExpiryStatus.unknown', () {
      final item = FoodItem(
        id: 'no-expiry-1',
        name: 'Sal refinado',
        category: FoodCategory.pantryStaples,
        initialQuantity: 1.0,
        unit: FoodUnit.kilogram,
        expiryDate: null,
        createdAt: now,
        updatedAt: now,
      );
      expect(item.validate(), isEmpty);
      expect(item.expiryDate, isNull);
      expect(item.getExpiryStatus(), equals(ExpiryStatus.unknown));
      expect(item.getDaysRemaining(), isNull);
    });
  });

  group('C. Persistent Storage Across App Restarts (SQLite File on Disk)', () {
    late Directory tempDir;
    late String dbFilePath;
    final now = DateTime(2026, 10, 8, 14, 0);

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('valora_session2_test_');
      dbFilePath = '${tempDir.path}${Platform.pathSeparator}session2_test.db';
    });

    tearDown(() {
      try {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      } catch (_) {}
    });

    test('Persists food creation across app restart simulation', () async {
      // Phase 1: Open first session, write item, then close DB
      final session1Repo = SqliteFoodRepository(customDbPath: dbFilePath);
      await session1Repo.init();

      final item1 = FoodItem(
        id: 'item-persisted-1',
        name: 'Leite Semi-desnatado',
        category: FoodCategory.dairy,
        initialQuantity: 2.0,
        unit: FoodUnit.liter,
        expiryDate: now.add(const Duration(days: 7)),
        purchasePrice: 9.80,
        storageLocation: StorageLocation.refrigerator,
        notes: 'Lote A2',
        createdAt: now,
        updatedAt: now,
      );
      await session1Repo.insertFood(item1);

      final activePhase1 = await session1Repo.getActiveFoods();
      expect(activePhase1.length, equals(1));
      expect(activePhase1.first.name, equals('Leite Semi-desnatado'));

      // Close repository to simulate app termination
      await session1Repo.close();

      // Phase 2: App reopens (new repository instance pointing to the same file)
      final session2Repo = SqliteFoodRepository(customDbPath: dbFilePath);
      await session2Repo.init();

      final activePhase2 = await session2Repo.getActiveFoods();
      expect(activePhase2.length, equals(1));
      final reloadedItem = activePhase2.first;
      expect(reloadedItem.id, equals('item-persisted-1'));
      expect(reloadedItem.name, equals('Leite Semi-desnatado'));
      expect(reloadedItem.initialQuantity, equals(2.0));
      expect(reloadedItem.remainingQuantity, equals(2.0));
      expect(reloadedItem.unit, equals(FoodUnit.liter));
      expect(reloadedItem.category, equals(FoodCategory.dairy));
      expect(reloadedItem.storageLocation, equals(StorageLocation.refrigerator));
      expect(reloadedItem.purchasePrice, equals(9.80));
      expect(reloadedItem.notes, equals('Lote A2'));
      expect(reloadedItem.expiryDate, isNotNull);

      // Phase 3: Edit item in session 2, restart, verify edit persisted
      final updatedItem = reloadedItem.copyWith(
        name: 'Leite Semi-desnatado 1L',
        consumedQuantity: 1.0,
        notes: 'Uma caixa consumida',
        updatedAt: DateTime.now(),
      );
      await session2Repo.updateFood(updatedItem);
      await session2Repo.close();

      // Phase 4: Reopen third session
      final session3Repo = SqliteFoodRepository(customDbPath: dbFilePath);
      await session3Repo.init();

      final activePhase3 = await session3Repo.getActiveFoods();
      expect(activePhase3.length, equals(1));
      expect(activePhase3.first.name, equals('Leite Semi-desnatado 1L'));
      expect(activePhase3.first.remainingQuantity, equals(1.0));
      expect(activePhase3.first.notes, equals('Uma caixa consumida'));

      // Phase 5: Delete item, restart, verify item no longer in active pantry
      await session3Repo.deleteFood('item-persisted-1');
      await session3Repo.close();

      final session4Repo = SqliteFoodRepository(customDbPath: dbFilePath);
      await session4Repo.init();
      final activePhase4 = await session4Repo.getActiveFoods();
      expect(activePhase4, isEmpty);
      await session4Repo.close();
    });

    test('Persists items with no expiry date across restart', () async {
      final repo1 = SqliteFoodRepository(customDbPath: dbFilePath);
      await repo1.init();

      final unknownExpiryItem = FoodItem(
        id: 'item-no-exp',
        name: 'Pimenta do Reino',
        category: FoodCategory.pantryStaples,
        initialQuantity: 50,
        unit: FoodUnit.gram,
        expiryDate: null,
        storageLocation: StorageLocation.pantry,
        createdAt: now,
        updatedAt: now,
      );
      await repo1.insertFood(unknownExpiryItem);
      await repo1.close();

      final repo2 = SqliteFoodRepository(customDbPath: dbFilePath);
      await repo2.init();

      final active = await repo2.getActiveFoods();
      expect(active.length, equals(1));
      expect(active.first.id, equals('item-no-exp'));
      expect(active.first.expiryDate, isNull);
      expect(active.first.getExpiryStatus(), equals(ExpiryStatus.unknown));
      await repo2.close();
    });
  });

  group('D. PantryProvider Search & Filtering Integration', () {
    late InMemoryFoodRepository mockRepo;
    late PantryProvider provider;
    final now = DateTime(2026, 10, 8, 12, 0);

    setUp(() async {
      mockRepo = InMemoryFoodRepository();
      await mockRepo.init();

      // Seed mock foods
      await mockRepo.insertFood(FoodItem(
        id: 'apple-1',
        name: 'Maçã Fuji',
        category: FoodCategory.fruits,
        initialQuantity: 6,
        unit: FoodUnit.piece,
        expiryDate: now.add(const Duration(days: 2)), // expiring soon
        createdAt: now,
        updatedAt: now,
      ));

      await mockRepo.insertFood(FoodItem(
        id: 'bread-1',
        name: 'Pão Francês',
        category: FoodCategory.bakery,
        initialQuantity: 4,
        unit: FoodUnit.piece,
        expiryDate: now.subtract(const Duration(days: 1)), // expired
        createdAt: now,
        updatedAt: now,
      ));

      await mockRepo.insertFood(FoodItem(
        id: 'salt-1',
        name: 'Sal Marinho',
        category: FoodCategory.pantryStaples,
        initialQuantity: 1,
        unit: FoodUnit.kilogram,
        expiryDate: null, // unknown
        createdAt: now,
        updatedAt: now,
      ));

      await mockRepo.insertFood(FoodItem(
        id: 'yogurt-1',
        name: 'Iogurte Natural',
        category: FoodCategory.dairy,
        initialQuantity: 2,
        unit: FoodUnit.piece,
        expiryDate: now.add(const Duration(days: 15)), // fresh
        createdAt: now,
        updatedAt: now,
      ));

      provider = PantryProvider(
        repository: mockRepo,
        referenceDate: now,
      );
      await provider.loadItems();
    });

    test('Loads initial 4 active items', () {
      expect(provider.totalActiveCount, equals(4));
      expect(provider.filteredAndSortedItems.length, equals(4));
    });

    test('Searches by unaccented query "maca" and finds "Maçã Fuji"', () {
      provider.setSearchQuery('maca');
      final results = provider.filteredAndSortedItems;
      expect(results.length, equals(1));
      expect(results.first.name, equals('Maçã Fuji'));
    });

    test('Searches by unaccented query "pao" and finds "Pão Francês"', () {
      provider.setSearchQuery('pao');
      final results = provider.filteredAndSortedItems;
      expect(results.length, equals(1));
      expect(results.first.name, equals('Pão Francês'));
    });

    test('Filters by FoodCategory', () {
      provider.setSelectedCategory(FoodCategory.bakery);
      final results = provider.filteredAndSortedItems;
      expect(results.length, equals(1));
      expect(results.first.name, equals('Pão Francês'));

      provider.setSelectedCategory(FoodCategory.drinks);
      expect(provider.filteredAndSortedItems, isEmpty);
    });

    test('Filters by ExpiryStatus', () {
      // Bread is expired
      provider.setSelectedStatusFilter(ExpiryStatus.expired);
      final expired = provider.filteredAndSortedItems;
      expect(expired.length, equals(1));
      expect(expired.first.name, equals('Pão Francês'));

      // Salt has unknown expiry
      provider.setSelectedStatusFilter(ExpiryStatus.unknown);
      final unknown = provider.filteredAndSortedItems;
      expect(unknown.length, equals(1));
      expect(unknown.first.name, equals('Sal Marinho'));
    });

    test('Reset filters restores all items', () {
      provider.setSearchQuery('maca');
      provider.setSelectedCategory(FoodCategory.fruits);
      expect(provider.filteredAndSortedItems.length, equals(1));

      provider.resetFilters();
      expect(provider.searchQuery, isEmpty);
      expect(provider.selectedCategory, isNull);
      expect(provider.selectedStatusFilter, isNull);
      expect(provider.filteredAndSortedItems.length, equals(4));
    });
  });

  group('E. Pantry Screen & Food Details Sheet Interaction', () {
    late InMemoryFoodRepository mockRepo;
    late PantryProvider provider;
    final now = DateTime(2026, 10, 8, 12, 0);

    setUp(() async {
      mockRepo = InMemoryFoodRepository();
      await mockRepo.insertFood(FoodItem(
        id: 'cheese-1',
        name: 'Queijo Minas',
        category: FoodCategory.dairy,
        initialQuantity: 500,
        unit: FoodUnit.gram,
        expiryDate: now.add(const Duration(days: 5)),
        purchasePrice: 22.50,
        storageLocation: StorageLocation.refrigerator,
        notes: 'Artesanal da serra',
        createdAt: now,
        updatedAt: now,
      ));

      provider = PantryProvider(repository: mockRepo);
      await provider.loadItems();
    });

    Widget createTestApp() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<PantryProvider>.value(value: provider),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('en', ''),
            Locale('pt', 'BR'),
          ],
          home: PantryScreen(),
        ),
      );
    }

    testWidgets('Tapping food item tile opens FoodDetailsSheet with full data',
        (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Verify item tile is displayed
      expect(find.text('Queijo Minas'), findsOneWidget);
      expect(find.text('500 g'), findsOneWidget);

      // Tap the food card
      await tester.tap(find.text('Queijo Minas'));
      await tester.pumpAndSettle();

      // Verify FoodDetailsSheet modal bottom sheet is open
      expect(find.byType(FoodDetailsSheet), findsOneWidget);

      // Verify detailed notes and metadata are visible in the details sheet
      expect(find.text('Artesanal da serra'), findsOneWidget);

      // Verify action buttons exist in details sheet
      expect(find.byIcon(Icons.restaurant_rounded), findsWidgets);
      expect(find.byIcon(Icons.delete_outline_rounded), findsWidgets);
    });
  });
}
