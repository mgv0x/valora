import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

import 'package:valora/data/local/sqlite_food_repository.dart';
import 'package:valora/data/models/food_category.dart';
import 'package:valora/data/models/food_item.dart';
import 'package:valora/data/models/food_unit.dart';
import 'package:valora/data/models/storage_location.dart';
import 'package:valora/data/services/cloud_sync_service.dart';
import 'package:valora/data/services/open_food_facts_service.dart';
import 'package:valora/data/services/preferences_service.dart';
import 'mocks/in_memory_food_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  const uuid = Uuid();

  group('Data Management System: 1. Local Storage (SQLite & SharedPreferences)', () {
    late SqliteFoodRepository repo;
    late PreferencesService prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await PreferencesService.create();
      repo = SqliteFoodRepository(
        inMemory: true,
        dbName: 'test_dm_${uuid.v4()}.db',
      );
      await repo.init();
    });

    tearDown(() async {
      await repo.close();
    });

    test('SQLite repository provides storage diagnostics and table stats', () async {
      final initialStats = await repo.getStorageDiagnostics();
      expect(initialStats['acid_compliant'], isTrue);
      expect(initialStats['active_items'], equals(0));
      expect(initialStats['total_items'], equals(0));
      expect(initialStats['activity_records'], equals(0));

      // Insert item
      final now = DateTime.now();
      await repo.insertFood(FoodItem(
        id: 'food-1',
        name: 'Arroz Integral',
        category: FoodCategory.pantryStaples,
        initialQuantity: 2.0,
        unit: FoodUnit.kilogram,
        createdAt: now,
        updatedAt: now,
      ));

      final updatedStats = await repo.getStorageDiagnostics();
      expect(updatedStats['active_items'], equals(1));
      expect(updatedStats['total_items'], equals(1));
      expect(updatedStats['indexes'], contains('idx_food_items_status'));
    });

    test('SQLite repository optimizes storage via VACUUM & ANALYZE without error', () async {
      await expectLater(repo.optimizeStorage(), completes);
    });

    test('Local Storage Export and Import JSON preserves full inventory and activities', () async {
      final now = DateTime.now();
      final item = FoodItem(
        id: 'food-export-1',
        name: 'Leite Desnatado',
        category: FoodCategory.dairy,
        initialQuantity: 3.0,
        unit: FoodUnit.liter,
        purchasePrice: 6.50,
        createdAt: now,
        updatedAt: now,
      );
      await repo.insertFood(item);
      await repo.recordConsumption(item: item, consumedQuantity: 1.0);

      // Export JSON
      final exported = await repo.exportData();
      expect(exported['app'], equals('Valora'));
      expect(exported['food_items'], isNotEmpty);
      expect(exported['food_activities'], isNotEmpty);

      // Clear & Import
      await repo.clearAllData();
      final emptyStats = await repo.getStorageDiagnostics();
      expect(emptyStats['active_items'], equals(0));

      final importSuccess = await repo.importData(exported);
      expect(importSuccess, isTrue);

      final restoredItem = await repo.getFoodById('food-export-1');
      expect(restoredItem, isNotNull);
      expect(restoredItem!.consumedQuantity, equals(1.0));
      expect(restoredItem.remainingQuantity, equals(2.0));
    });

    test('SharedPreferences manages user preferences and local settings safely', () async {
      await prefs.setWarningThresholdDays(7);
      expect(prefs.warningThresholdDays, equals(7));

      await prefs.setNotificationsEnabled(true);
      expect(prefs.notificationsEnabled, isTrue);

      await prefs.setThemeMode('dark');
      expect(prefs.themeMode, equals('dark'));
    });
  });

  group('Data Management System: 2. Cloud Database & Remote Sync', () {
    late InMemoryFoodRepository repo;
    late PreferencesService prefs;
    late CloudSyncService cloudService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await PreferencesService.create();
      repo = InMemoryFoodRepository();
      cloudService = CloudSyncService(repository: repo, preferences: prefs);
    });

    test('CloudSyncService pushes local state to cloud backup snapshot', () async {
      final now = DateTime.now();
      await repo.insertFood(FoodItem(
        id: 'cloud-item-1',
        name: 'Queijo Parmesão',
        category: FoodCategory.dairy,
        initialQuantity: 1.0,
        unit: FoodUnit.piece,
        createdAt: now,
        updatedAt: now,
      ));

      expect(cloudService.lastSyncTime, isNull);

      final result = await cloudService.syncToCloud();
      expect(result.success, isTrue);
      expect(result.syncedItemsCount, equals(1));
      expect(cloudService.status, equals(CloudSyncStatus.synced));
      expect(cloudService.lastSyncTime, isNotNull);

      final snapshot = prefs.cloudBackupSnapshot;
      expect(snapshot, isNotNull);
      final decoded = jsonDecode(snapshot!) as Map<String, dynamic>;
      expect(decoded['database_snapshot'], isNotNull);
    });

    test('CloudSyncService restores pantry state from cloud snapshot', () async {
      final now = DateTime.now();
      await repo.insertFood(FoodItem(
        id: 'cloud-item-2',
        name: 'Azeite de Oliva',
        category: FoodCategory.pantryStaples,
        initialQuantity: 1.0,
        unit: FoodUnit.liter,
        createdAt: now,
        updatedAt: now,
      ));

      // Sync to cloud
      await cloudService.syncToCloud();

      // Wipe local repo
      await repo.clearAllData();
      final itemsAfterClear = await repo.getActiveFoods();
      expect(itemsAfterClear, isEmpty);

      // Restore from cloud
      final restoreResult = await cloudService.restoreFromCloud();
      expect(restoreResult.success, isTrue);
      expect(restoreResult.syncedItemsCount, equals(1));

      final restoredItems = await repo.getActiveFoods();
      expect(restoredItems.length, equals(1));
      expect(restoredItems.first.name, equals('Azeite de Oliva'));
    });

    test('CloudSyncService handles missing cloud snapshot gracefully', () async {
      await prefs.setCloudBackupSnapshot(null);
      final result = await cloudService.restoreFromCloud();
      expect(result.success, isFalse);
      expect(cloudService.status, equals(CloudSyncStatus.error));
    });
  });

  group('Data Management System: 3. External Food APIs (Open Food Facts REST API)', () {
    test('OpenFoodFactsApiService parses product search response from REST API', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('search.pl')) {
          final responseJson = {
            'products': [
              {
                'code': '7891000123456',
                'product_name': 'Iogurte Natural Batavo',
                'brands': 'Batavo',
                'categories': 'Dairies, Fermented foods, Yogurts',
                'quantity': '170g',
                'nutriscore_grade': 'a',
                'ecoscore_grade': 'b',
              },
              {
                'code': '7891000987654',
                'product_name': 'Arroz Integral Camil',
                'brands': 'Camil',
                'categories': 'Plant-based foods, Cereals, Rice',
                'quantity': '1kg',
                'nutriscore_grade': 'a',
                'ecoscore_grade': 'a',
              }
            ]
          };
          return http.Response(jsonEncode(responseJson), 200);
        }
        return http.Response('Not Found', 404);
      });

      final apiService = OpenFoodFactsApiService(client: mockClient);
      final results = await apiService.searchProducts('iogurte');

      expect(results.length, equals(2));
      expect(results.first.name, equals('Iogurte Natural Batavo'));
      expect(results.first.category, equals(FoodCategory.dairy));
      expect(results.first.suggestedStorage, equals(StorageLocation.refrigerator));
      expect(results.first.suggestedShelfLifeDays, equals(7));

      expect(results[1].name, equals('Arroz Integral Camil'));
      expect(results[1].category, equals(FoodCategory.pantryStaples));
      expect(results[1].suggestedStorage, equals(StorageLocation.pantry));
    });

    test('OpenFoodFactsApiService looks up product by barcode', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('7891000123456.json')) {
          final responseJson = {
            'status': 1,
            'product': {
              'code': '7891000123456',
              'product_name': 'Leite UHT Integral Ninho',
              'brands': 'Nestlé',
              'categories': 'Dairies, Milks, UHT Milk',
              'quantity': '1L',
              'nutriscore_grade': 'b',
            }
          };
          return http.Response(jsonEncode(responseJson), 200);
        }
        return http.Response('{"status": 0}', 200);
      });

      final apiService = OpenFoodFactsApiService(client: mockClient);
      final product = await apiService.lookupBarcode('7891000123456');

      expect(product, isNotNull);
      expect(product!.name, equals('Leite UHT Integral Ninho'));
      expect(product.category, equals(FoodCategory.dairy));
      expect(product.unit, equals(FoodUnit.liter));
      expect(product.suggestedStorage, equals(StorageLocation.refrigerator));
    });

    test('OpenFoodFactsApiService falls back to local offline catalog when network is unavailable', () async {
      final mockClient = MockClient((request) async {
        throw http.ClientException('Sem conexão de internet');
      });

      final apiService = OpenFoodFactsApiService(client: mockClient);
      final results = await apiService.searchProducts('leite');

      expect(results, isNotEmpty);
      expect(results.any((p) => p.name.toLowerCase().contains('leite')), isTrue);
    });

    test('OpenFoodFactsApiService checkHealth returns true on 200 and false on error', () async {
      final healthyClient = MockClient((_) async => http.Response('{}', 200));
      final errorClient = MockClient((_) async => throw Exception('Timeout'));

      expect(await OpenFoodFactsApiService(client: healthyClient).checkHealth(), isTrue);
      expect(await OpenFoodFactsApiService(client: errorClient).checkHealth(), isFalse);
    });
  });
}
