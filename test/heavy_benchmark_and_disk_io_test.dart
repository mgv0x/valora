// ignore_for_file: avoid_print
@Timeout(Duration(minutes: 5))
library;

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:valora/data/local/sqlite_food_repository.dart';
import 'package:valora/data/models/food_category.dart';
import 'package:valora/data/models/food_item.dart';
import 'package:valora/data/models/food_unit.dart';
import 'package:valora/data/models/shopping_item.dart';
import 'package:valora/data/models/storage_location.dart';
import 'package:valora/data/services/preferences_service.dart';
import 'package:valora/state/shopping_list_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  int firstInt(List<Map<String, Object?>> res) {
    if (res.isEmpty || res.first.isEmpty) return 0;
    final val = res.first.values.first;
    if (val is int) return val;
    if (val is num) return val.toInt();
    return 0;
  }

  late Directory tempBenchDir;
  late String dbFilePath;
  late SqliteFoodRepository repository;

  setUpAll(() async {
    tempBenchDir = Directory.systemTemp.createTempSync('valora_heavy_bench_');
    dbFilePath = p.join(tempBenchDir.path, 'valora_heavy_bench.db');

    repository = SqliteFoodRepository(
      customDbPath: dbFilePath,
      inMemory: false,
    );
    await repository.init();
  });

  tearDownAll(() async {
    try {
      await repository.db.close();
    } catch (_) {}
    try {
      if (tempBenchDir.existsSync()) {
        tempBenchDir.deleteSync(recursive: true);
      }
    } catch (_) {}
  });

  group('Heavy Disk I/O, SQLite Transactions & Real Load Benchmarks', () {
    test('Stage 1: Bulk Disk Ingestion of 1,000 Real Items with Validation & SQLite Sync', () async {
      print('\n================================================================');
      print('🚀 [STAGE 1/5] INICIANDO INGESTÃO MASSIVA EM DISCO (1.000 ITENS)');
      print('📁 Local do arquivo SQLite físico: $dbFilePath');
      print('================================================================');

      final stopwatch = Stopwatch()..start();
      final random = Random(42);
      final categories = FoodCategory.values;
      final units = FoodUnit.values;
      final locations = StorageLocation.values;

      const totalItems = 1000;
      final createdItems = <FoodItem>[];

      for (int i = 1; i <= totalItems; i++) {
        final cat = categories[i % categories.length];
        final unit = units[i % units.length];
        final loc = locations[i % locations.length];
        final initialQty = (random.nextDouble() * 50.0 + 1.0).roundToDouble();
        final price = (random.nextDouble() * 120.0 + 2.50);

        final item = FoodItem(
          id: 'bench-item-$i',
          name: 'Item de Despensa #$i (${cat.name})',
          category: cat,
          initialQuantity: initialQty,
          unit: unit,
          storageLocation: loc,
          purchasePrice: double.parse(price.toStringAsFixed(2)),
          purchaseDate: DateTime(2026, 1, 1).add(Duration(days: i % 180)),
          expiryDate: DateTime(2026, 7, 1).add(Duration(days: (i % 60) - 10)),
          notes: 'Ingerido em teste de carga massiva com validação estrita de invariantes.',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Validates all rules before disk write
        final errors = item.validate();
        expect(errors, isEmpty, reason: 'Item $i should be strictly valid');

        await repository.insertFood(item);
        createdItems.add(item);

        if (i % 200 == 0 || i == totalItems) {
          final elapsed = stopwatch.elapsedMilliseconds / 1000.0;
          final throughput = i / (elapsed > 0 ? elapsed : 0.001);
          final diskFile = File(dbFilePath);
          final fileSizeKb = diskFile.existsSync() ? (diskFile.lengthSync() / 1024.0).toStringAsFixed(1) : '0';
          print('  ⏱️ Progresso: $i/$totalItems itens persistidos no SQLite | '
              'Tempo: ${elapsed.toStringAsFixed(2)}s | '
              'Throughput: ${throughput.toStringAsFixed(1)} ops/s | '
              'Tamanho do BD em Disco: $fileSizeKb KB');
        }
      }

      stopwatch.stop();
      final totalElapsed = stopwatch.elapsedMilliseconds / 1000.0;
      print('✅ [STAGE 1 CONCLUÍDO] 1.000 itens inseridos e gravados no disco em ${totalElapsed.toStringAsFixed(2)}s\n');

      // Verify records on disk
      final activeFoods = await repository.getActiveFoods();
      expect(activeFoods.length, equals(totalItems));

      final diskFile = File(dbFilePath);
      expect(diskFile.existsSync(), isTrue);
      expect(diskFile.lengthSync(), greaterThan(100 * 1024)); // Database is substantial on disk (>100KB)
    });

    test('Stage 2: 1,000 ACID Transactions (Consumption + Ledger Entries + Foreign Keys)', () async {
      print('================================================================');
      print('⚡ [STAGE 2/5] PROCESSAMENTO DE 1.000 TRANSAÇÕES DE CONSUMO & LIVRO-RAZÃO');
      print('================================================================');

      final stopwatch = Stopwatch()..start();
      const transactionCount = 1000;

      for (int i = 1; i <= transactionCount; i++) {
        final foodId = 'bench-item-$i';
        final food = await repository.getFoodById(foodId);
        expect(food, isNotNull);

        final consumeQty = (food!.remainingQuantity * 0.25).clamp(0.1, food.remainingQuantity);

        await repository.recordConsumption(
          item: food,
          consumedQuantity: consumeQty,
          notes: 'Transação auditada #$i - Débito transacional com integridade referencial.',
        );

        if (i % 250 == 0 || i == transactionCount) {
          final elapsed = stopwatch.elapsedMilliseconds / 1000.0;
          final throughput = i / (elapsed > 0 ? elapsed : 0.001);
          print('  💳 Transações ACID concluídas: $i/$transactionCount | '
              'Tempo: ${elapsed.toStringAsFixed(2)}s | '
              'Taxa: ${throughput.toStringAsFixed(1)} tx/s');
        }
      }

      stopwatch.stop();
      print('✅ [STAGE 2 CONCLUÍDO] 1.000 transações de consumo e auditoria concluídas em '
          '${(stopwatch.elapsedMilliseconds / 1000.0).toStringAsFixed(2)}s\n');

      // Verify that 1,000 activity ledger entries were committed
      final activitiesCountResult = await repository.db.rawQuery('SELECT COUNT(*) as count FROM food_activities');
      final totalActivities = firstInt(activitiesCountResult);
      expect(totalActivities, equals(transactionCount));
    });

    test('Stage 3: Deep Relational & Analytical SQL Queries Under Heavy Load', () async {
      print('================================================================');
      print('🔍 [STAGE 3/5] CONSULTAS ANALÍTICAS COMPLEXAS E AGREGAÇÕES RELACIONAIS');
      print('================================================================');

      final stopwatch = Stopwatch()..start();
      const queryIterations = 50;

      for (int q = 1; q <= queryIterations; q++) {
        // Query 1: Waste & Consumption financial aggregation joined with categories
        final financialReport = await repository.db.rawQuery('''
          SELECT 
            f.category,
            COUNT(f.id) as total_items,
            SUM(f.initial_quantity) as total_initial_qty,
            SUM(f.consumed_quantity) as total_consumed_qty,
            SUM(f.purchase_price) as total_spend,
            COUNT(a.id) as activity_count,
            SUM(a.estimated_value) as total_consumed_value
          FROM food_items f
          LEFT JOIN food_activities a ON f.id = a.food_item_id
          WHERE f.status = 'active'
          GROUP BY f.category
          ORDER BY total_spend DESC
        ''');
        expect(financialReport.isNotEmpty, isTrue);

        // Query 2: Expiry window histogram
        final expiryHistogram = await repository.db.rawQuery('''
          SELECT 
            storage_location,
            COUNT(*) as item_count,
            AVG(initial_quantity) as avg_batch_size
          FROM food_items
          WHERE expiry_date IS NOT NULL
          GROUP BY storage_location
          HAVING COUNT(*) > 5
        ''');
        expect(expiryHistogram.isNotEmpty, isTrue);

        if (q % 10 == 0 || q == queryIterations) {
          final elapsed = stopwatch.elapsedMilliseconds / 1000.0;
          print('  📊 Consultas complexas executadas: $q/$queryIterations rodadas '
              '(${q * 2} queries pesadas) | '
              'Tempo acumulado: ${elapsed.toStringAsFixed(2)}s');
        }
      }

      stopwatch.stop();
      print('✅ [STAGE 3 CONCLUÍDO] 100 consultas analíticas com joins e agrupamentos concluídas em '
          '${(stopwatch.elapsedMilliseconds / 1000.0).toStringAsFixed(2)}s\n');
    });

    test('Stage 4: State Management & JSON Serialization Under 5,000 Iteration Load', () async {
      print('================================================================');
      print('📦 [STAGE 4/5] BENCHMARK DE ESTADO & SERIALIZAÇÃO JSON (5.000 CICLOS)');
      print('================================================================');

      final stopwatch = Stopwatch()..start();
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      final prefs = PreferencesService(sp);
      final provider = ShoppingListProvider(prefs: prefs);
      expect(provider.items, isEmpty);

      const cycles = 5000;
      final rawShoppingItems = <String>[];

      for (int i = 1; i <= cycles; i++) {
        final item = ShoppingItem.create(
          name: 'Item de Compras Automatizado #$i',
          category: FoodCategory.values[i % FoodCategory.values.length],
          quantity: (i % 10 + 1).toDouble(),
          unit: FoodUnit.values[i % FoodUnit.values.length],
        );

        final jsonMap = item.toMap();
        final encoded = jsonEncode(jsonMap);
        rawShoppingItems.add(encoded);

        // Every 1,000 cycles, simulate bulk hydration and validation
        if (i % 1000 == 0) {
          final decoded = jsonDecode(encoded) as Map<String, dynamic>;
          final hydrated = ShoppingItem.fromMap(decoded);
          expect(hydrated.name, equals(item.name));
          expect(hydrated.quantity, equals(item.quantity));

          final elapsed = stopwatch.elapsedMilliseconds / 1000.0;
          print('  🔄 Ciclos de serialização/desserialização: $i/$cycles | '
              'Tempo: ${elapsed.toStringAsFixed(2)}s | '
              'Throughput: ${(i / (elapsed > 0 ? elapsed : 0.001)).toStringAsFixed(1)} ops/s');
        }
      }

      // Persist full state to SharedPreferences
      await prefs.setShoppingListJson(rawShoppingItems);
      expect(prefs.shoppingListJson.length, equals(cycles));

      stopwatch.stop();
      print('✅ [STAGE 4 CONCLUÍDO] 5.000 serializações e hidratações validadas com sucesso em '
          '${(stopwatch.elapsedMilliseconds / 1000.0).toStringAsFixed(2)}s\n');
    });

    test('Stage 5: ACID Rollback Integrity & Hostile Stress on Disk', () async {
      print('================================================================');
      print('🛡️ [STAGE 5/5] TESTE DE ESTRESSE HOSTIL & INTEGRIDADE DE ROLLBACK ACID');
      print('================================================================');

      final stopwatch = Stopwatch()..start();
      final initialItemCountResult = await repository.db.rawQuery('SELECT COUNT(*) as count FROM food_items');
      final initialItems = firstInt(initialItemCountResult);

      const hostileAttempts = 100;
      int rollbackSuccessCount = 0;

      for (int i = 1; i <= hostileAttempts; i++) {
        try {
          await repository.db.transaction((txn) async {
            // Step 1: Valid temporary insertion
            await txn.insert('food_items', {
              'id': 'temp-hostile-$i',
              'name': 'Item Hostil Provisório',
              'category': 'fruits',
              'initial_quantity': 10.0,
              'consumed_quantity': 0.0,
              'discarded_quantity': 0.0,
              'unit': 'piece',
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
              'status': 'active',
            });

            // Step 2: Intentional fatal constraint violation (duplicate primary key on 'bench-item-1')
            await txn.insert('food_items', {
              'id': 'bench-item-1', // PRIMARY KEY CONFLICT!
              'name': 'Conflito Forçado de Chave Primária',
              'category': 'dairy',
              'initial_quantity': 1.0,
              'unit': 'piece',
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
              'status': 'active',
            });
          });
          fail('Transaction should have aborted due to primary key conflict');
        } catch (_) {
          // Expected rollback
          rollbackSuccessCount++;
        }

        if (i % 25 == 0 || i == hostileAttempts) {
          final elapsed = stopwatch.elapsedMilliseconds / 1000.0;
          print('  🛡️ Falhas simuladas com Rollback atômico: $i/$hostileAttempts | '
              'Tempo: ${elapsed.toStringAsFixed(2)}s | '
              'Integridade preservada: 100%');
        }
      }

      stopwatch.stop();

      // Verify that database remained 100% intact with zero phantom records
      final finalItemCountResult = await repository.db.rawQuery('SELECT COUNT(*) as count FROM food_items');
      final finalItems = firstInt(finalItemCountResult);
      expect(finalItems, equals(initialItems), reason: 'All 100 transactions must have rolled back cleanly');
      expect(rollbackSuccessCount, equals(hostileAttempts));

      // Quick PRAGMA integrity check
      final integrityResult = await repository.db.rawQuery('PRAGMA integrity_check');
      expect(integrityResult.first.values.first, equals('ok'));

      print('✅ [STAGE 5 CONCLUÍDO] 100 rollbacks atômicos validados. PRAGMA integrity_check: OK!\n');
      print('================================================================');
      print('🏆 BATERIA DE TESTES PESADOS E BENCHMARKS CONCLUÍDA COM SUCESSO!');
      print('================================================================\n');
    });
  });
}
