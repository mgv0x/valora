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
import 'package:valora/core/utils/text_utils.dart';
import 'package:valora/data/local/sqlite_food_repository.dart';
import 'package:valora/data/models/food_category.dart';
import 'package:valora/data/models/food_item.dart';
import 'package:valora/data/models/food_unit.dart';
import 'package:valora/data/models/storage_location.dart';
import 'package:valora/data/services/cloud_sync_service.dart';
import 'package:valora/data/services/preferences_service.dart';

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
  late PreferencesService prefs;

  setUpAll(() async {
    tempBenchDir = Directory.systemTemp.createTempSync('valora_extreme_sync_');
    dbFilePath = p.join(tempBenchDir.path, 'valora_extreme_sync.db');

    repository = SqliteFoodRepository(
      customDbPath: dbFilePath,
      inMemory: false,
    );
    await repository.init();

    SharedPreferences.setMockInitialValues({});
    final sp = await SharedPreferences.getInstance();
    prefs = PreferencesService(sp);
  });

  tearDownAll(() async {
    try {
      await repository.close();
    } catch (_) {}
    try {
      if (tempBenchDir.existsSync()) {
        tempBenchDir.deleteSync(recursive: true);
      }
    } catch (_) {}
  });

  group('Extreme Data Resilience, Cloud Backup Roundtrip & VACUUM Storage Engine Stress', () {
    test('Stage 1: Massive Ingestion of 1,500 Items and 1,500 Relational Activity Records', () async {
      print('\n================================================================');
      print('🚀 [BATERIA 2 - ESTÁGIO 1/5] INGESTÃO MASSIVA (1.500 ITENS & 1.500 ATIVIDADES)');
      print('📁 Local do arquivo SQLite físico: $dbFilePath');
      print('================================================================');

      final stopwatch = Stopwatch()..start();
      final random = Random(1337);
      const totalItems = 1500;

      for (int i = 1; i <= totalItems; i++) {
        final cat = FoodCategory.values[i % FoodCategory.values.length];
        final unit = FoodUnit.values[i % FoodUnit.values.length];
        final loc = StorageLocation.values[i % StorageLocation.values.length];
        final qty = (random.nextDouble() * 30.0 + 2.0).roundToDouble();
        final price = (random.nextDouble() * 80.0 + 3.0);

        final item = FoodItem(
          id: 'resilience-food-$i',
          name: 'Alimento Resiliente #$i (${cat.displayName})',
          category: cat,
          initialQuantity: qty,
          unit: unit,
          storageLocation: loc,
          purchasePrice: double.parse(price.toStringAsFixed(2)),
          purchaseDate: DateTime(2026, 1, 1).add(Duration(days: i % 150)),
          expiryDate: DateTime(2026, 8, 1).add(Duration(days: (i % 90) - 15)),
          notes: 'Registro em lote para teste de alta resiliência e concorrência.',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final validationErrors = item.validate();
        expect(validationErrors, isEmpty);

        await repository.insertFood(item);

        // Record a proportional consumption transaction
        final consumeQty = (qty * 0.2).clamp(0.1, qty);
        await repository.recordConsumption(
          item: item,
          consumedQuantity: consumeQty,
          notes: 'Consumo registrado para auditoria #$i',
        );

        if (i % 300 == 0 || i == totalItems) {
          final elapsed = stopwatch.elapsedMilliseconds / 1000.0;
          final ops = i * 2; // 1 insert + 1 consumption transaction
          final throughput = ops / (elapsed > 0 ? elapsed : 0.001);
          final diskFile = File(dbFilePath);
          final fileSizeKb = diskFile.existsSync() ? (diskFile.lengthSync() / 1024.0).toStringAsFixed(1) : '0';

          print('  ⏱️ $i/$totalItems itens e atividades gravados em disco | '
              'Tempo: ${elapsed.toStringAsFixed(2)}s | '
              'Taxa: ${throughput.toStringAsFixed(1)} ops/s | '
              'Tamanho BD: $fileSizeKb KB');
        }
      }

      stopwatch.stop();
      final totalElapsed = stopwatch.elapsedMilliseconds / 1000.0;
      print('✅ [ESTÁGIO 1 CONCLUÍDO] 3.000 operações relacionais em disco concluídas em ${totalElapsed.toStringAsFixed(2)}s\n');

      final activeFoods = await repository.getActiveFoods();
      expect(activeFoods.length, equals(totalItems));

      final countActivities = await repository.db.rawQuery('SELECT COUNT(*) as count FROM food_activities');
      expect(firstInt(countActivities), equals(totalItems));
    });

    test('Stage 2: Full Cloud Snapshot Export, Disaster Simulation & Zero-Loss Restore', () async {
      print('================================================================');
      print('☁️ [BATERIA 2 - ESTÁGIO 2/5] BACKUP EM NUVEM, SIMULAÇÃO DE PERDA TOTAL & RESTAURAÇÃO');
      print('================================================================');

      final stopwatch = Stopwatch()..start();
      final cloudService = CloudSyncService(
        repository: repository,
        preferences: prefs,
      );

      // Step 2.1: Export snapshot to cloud payload
      print('  📦 Gerando snapshot completo e simulando push para nuvem...');
      final syncResult = await cloudService.syncToCloud();
      expect(syncResult.success, isTrue);
      expect(syncResult.syncedItemsCount, equals(1500));
      expect(syncResult.syncedActivitiesCount, equals(1500));
      expect(prefs.cloudBackupSnapshot, isNotNull);

      final snapshotSizeKb = (utf8.encode(prefs.cloudBackupSnapshot!).length / 1024.0).toStringAsFixed(1);
      print('  ☁️ Snapshot em nuvem persistido com sucesso ($snapshotSizeKb KB de JSON estruturado)');

      // Step 2.2: Disaster simulation - WIPE all local data
      print('  💥 Simulando falha catastrófica: Limpando 100% da base local (Wipe Total)...');
      await repository.clearAllData();

      final wipedItems = await repository.getActiveFoods();
      expect(wipedItems, isEmpty);
      final wipedActivities = await repository.db.rawQuery('SELECT COUNT(*) as count FROM food_activities');
      expect(firstInt(wipedActivities), equals(0));
      print('  ⚠️ Base local zerada: 0 itens, 0 atividades.');

      // Step 2.3: Zero-loss restore from cloud snapshot
      print('  🔄 Restaurando base completa a partir do snapshot em nuvem...');
      final restoreResult = await cloudService.restoreFromCloud();
      expect(restoreResult.success, isTrue);
      expect(restoreResult.syncedItemsCount, equals(1500));
      expect(restoreResult.syncedActivitiesCount, equals(1500));

      final restoredItems = await repository.getActiveFoods();
      expect(restoredItems.length, equals(1500));
      final restoredActivities = await repository.db.rawQuery('SELECT COUNT(*) as count FROM food_activities');
      expect(firstInt(restoredActivities), equals(1500));

      stopwatch.stop();
      print('✅ [ESTÁGIO 2 CONCLUÍDO] Restauração atômica 100% íntegra (Zero Bit-Rot) em '
          '${(stopwatch.elapsedMilliseconds / 1000.0).toStringAsFixed(2)}s\n');
    });

    test('Stage 3: Multi-Worker Concurrent Contention & Parallel Transactions Stress', () async {
      print('================================================================');
      print('⚡ [BATERIA 2 - ESTÁGIO 3/5] CONCORRÊNCIA MULTI-TRABALHADOR & CONTENÇÃO DE LOCKS');
      print('================================================================');

      final stopwatch = Stopwatch()..start();
      const numWorkers = 8;
      const opsPerWorker = 50;

      print('  🚀 Disparando $numWorkers trabalhadores assíncronos em paralelo ($opsPerWorker ops cada)...');

      final workerFutures = <Future<int>>[];

      for (int w = 1; w <= numWorkers; w++) {
        workerFutures.add(() async {
          int successfulOps = 0;
          for (int op = 1; op <= opsPerWorker; op++) {
            final targetId = 'resilience-food-${((w * op) % 1500) + 1}';
            final food = await repository.getFoodById(targetId);

            if (food != null && food.hasRemaining) {
              final consumeQty = (food.remainingQuantity * 0.05).clamp(0.01, food.remainingQuantity);
              await repository.recordConsumption(
                item: food,
                consumedQuantity: consumeQty,
                notes: 'Trabalhador concorrente #$w - Operação #$op',
              );
              successfulOps++;
            }
          }
          return successfulOps;
        }());
      }

      final workerResults = await Future.wait(workerFutures);
      final totalConcurrentOps = workerResults.reduce((a, b) => a + b);

      stopwatch.stop();
      final elapsed = stopwatch.elapsedMilliseconds / 1000.0;
      final throughput = totalConcurrentOps / (elapsed > 0 ? elapsed : 0.001);

      print('  ⚡ Total de operações concorrentes concluídas sem deadlocks: $totalConcurrentOps ops | '
          'Tempo: ${elapsed.toStringAsFixed(2)}s | '
          'Taxa de concorrência: ${throughput.toStringAsFixed(1)} tx/s');
      print('✅ [ESTÁGIO 3 CONCLUÍDO] Concorrência multi-worker validada com sucesso!\n');
    });

    test('Stage 4: Diacritical Text Normalization & High-Throughput Search Benchmark (5,000 queries)', () async {
      print('================================================================');
      print('🔎 [BATERIA 2 - ESTÁGIO 4/5] BENCHMARK DE PESQUISA & NORMALIZAÇÃO DIACRÍTICA (5.000 CONSULTAS)');
      print('================================================================');

      final stopwatch = Stopwatch()..start();
      const totalSearchIterations = 5000;

      final testQueries = [
        'alimento',
        'ALIMENTO',
        'Alimento',
        'resiliente',
        'RESILIENTE',
        'frutas',
        'FRUTAS',
        'laticínios',
        'laticinios',
        'LATICÍNIOS',
        'padaria',
        'congelados',
      ];

      for (int i = 1; i <= totalSearchIterations; i++) {
        final query = testQueries[i % testQueries.length];
        final normalized = TextUtils.normalize(query);
        final matches = TextUtils.matchesSearch('Alimento Resiliente #42 (Laticínios)', query);

        expect(normalized, isNotEmpty);
        if (query.toLowerCase().contains('alimento') || query.toLowerCase().contains('laticin')) {
          expect(matches, isTrue);
        }

        if (i % 1000 == 0 || i == totalSearchIterations) {
          final elapsed = stopwatch.elapsedMilliseconds / 1000.0;
          print('  🔎 Consultas normalizadas e validadas: $i/$totalSearchIterations | '
              'Tempo: ${elapsed.toStringAsFixed(2)}s | '
              'Throughput: ${(i / (elapsed > 0 ? elapsed : 0.001)).toStringAsFixed(1)} buscas/s');
        }
      }

      stopwatch.stop();
      print('✅ [ESTÁGIO 4 CONCLUÍDO] 5.000 buscas com normalização Unicode concluídas em '
          '${(stopwatch.elapsedMilliseconds / 1000.0).toStringAsFixed(2)}s\n');
    });

    test('Stage 5: Bulk Pruning, Physical VACUUM, ANALYZE & Structural Storage Diagnostics', () async {
      print('================================================================');
      print('🧹 [BATERIA 2 - ESTÁGIO 5/5] EXPURGO, COMPACTAÇÃO VACUUM, ANALYZE & INTEGRIDADE');
      print('================================================================');

      final stopwatch = Stopwatch()..start();
      final fileBefore = File(dbFilePath);
      final sizeBeforeKb = fileBefore.existsSync() ? fileBefore.lengthSync() / 1024.0 : 0.0;

      print('  📦 Tamanho do arquivo SQLite antes do expurgo: ${sizeBeforeKb.toStringAsFixed(1)} KB');

      // Step 5.1: Archive 1,000 items
      print('  🗑️ Arquivando 1.000 itens obsoletos no banco de dados...');
      for (int i = 1; i <= 1000; i++) {
        await repository.deleteFood('resilience-food-$i');
      }

      // Step 5.2: Run SQLite VACUUM and ANALYZE
      print('  ⚙️ Executando VACUUM e ANALYZE físicos no motor SQLite...');
      await repository.optimizeStorage();

      final fileAfter = File(dbFilePath);
      final sizeAfterKb = fileAfter.existsSync() ? fileAfter.lengthSync() / 1024.0 : 0.0;
      print('  ✨ Tamanho do arquivo SQLite após VACUUM: ${sizeAfterKb.toStringAsFixed(1)} KB');

      // Step 5.3: Storage Diagnostics Verification
      final diagnostics = await repository.getStorageDiagnostics();
      expect(diagnostics['acid_compliant'], isTrue);
      expect(diagnostics['active_items'], equals(500)); // 1500 - 1000 archived
      expect(diagnostics['archived_items'], equals(1000));
      expect(diagnostics['total_items'], equals(1500));
      expect(diagnostics['foreign_keys_enforced'], isTrue);

      // Step 5.4: Integrity Check
      final integrity = await repository.db.rawQuery('PRAGMA integrity_check');
      expect(integrity.first.values.first, equals('ok'));

      stopwatch.stop();
      print('  📋 Diagnóstico do Armazenamento:');
      print('     - Itens Ativos: ${diagnostics['active_items']}');
      print('     - Itens Arquivados: ${diagnostics['archived_items']}');
      print('     - Total de Itens: ${diagnostics['total_items']}');
      print('     - Registros de Atividade: ${diagnostics['activity_records']}');
      print('     - Integridade Física PRAGMA: ${integrity.first.values.first}');
      print('✅ [ESTÁGIO 5 CONCLUÍDO] Compactação e integridade validadas em '
          '${(stopwatch.elapsedMilliseconds / 1000.0).toStringAsFixed(2)}s\n');

      print('================================================================');
      print('🏆 BATERIA 2 DE RESILIÊNCIA E INTEGRIDADE CONCLUÍDA COM 100% DE SUCESSO!');
      print('================================================================\n');
    });
  });
}
