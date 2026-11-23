import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

import '../models/food_item.dart';
import '../models/food_activity.dart';
import 'food_repository.dart';

class SqliteFoodRepository implements FoodRepository {
  Database? _db;
  final bool inMemory;
  final String dbName;
  final String? customDbPath;
  final _uuid = const Uuid();

  SqliteFoodRepository({
    this.inMemory = false,
    this.dbName = 'valora_inventory.db',
    this.customDbPath,
    Database? customDatabase,
  }) : _db = customDatabase;

  Database get db {
    if (_db == null) {
      throw StateError('Database has not been initialized. Call init() first.');
    }
    return _db!;
  }

  @override
  Future<void> init() async {
    if (_db != null) return;

    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    Future<void> configureDb(Database db) async {
      await db.execute('PRAGMA foreign_keys = ON;');
    }

    if (inMemory) {
      _db = await databaseFactory.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _onCreate,
          onConfigure: configureDb,
        ),
      );
    } else {
      final String dbPath;
      if (customDbPath != null) {
        dbPath = customDbPath!;
      } else if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        final appDir = await getApplicationSupportDirectory();
        if (!await appDir.exists()) {
          await appDir.create(recursive: true);
        }
        dbPath = join(appDir.path, dbName);
      } else {
        final databasesPath = await getDatabasesPath();
        dbPath = join(databasesPath, dbName);
      }

      _db = await openDatabase(
        dbPath,
        version: 1,
        onCreate: _onCreate,
        onConfigure: configureDb,
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE food_items (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        initial_quantity REAL NOT NULL,
        consumed_quantity REAL NOT NULL DEFAULT 0,
        discarded_quantity REAL NOT NULL DEFAULT 0,
        unit TEXT NOT NULL,
        expiry_date TEXT,
        purchase_price REAL,
        storage_location TEXT,
        purchase_date TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE food_activities (
        id TEXT PRIMARY KEY,
        food_item_id TEXT NOT NULL,
        food_name TEXT NOT NULL,
        category TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit TEXT NOT NULL,
        type TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        estimated_value REAL,
        notes TEXT,
        FOREIGN KEY (food_item_id) REFERENCES food_items (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX IF NOT EXISTS idx_food_items_status ON food_items (status);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_food_activities_timestamp ON food_activities (timestamp DESC);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_food_activities_food_id ON food_activities (food_item_id);');
  }

  @override
  Future<List<FoodItem>> getActiveFoods() async {
    final results = await db.query(
      'food_items',
      where: 'status = ?',
      whereArgs: [FoodLifecycleStatus.active.name],
      orderBy: 'created_at DESC',
    );

    return results
        .map((map) => FoodItem.fromMap(map))
        .where((item) => item.hasRemaining)
        .toList();
  }

  @override
  Future<FoodItem?> getFoodById(String id) async {
    if (id.trim().isEmpty) return null;
    final results = await db.query(
      'food_items',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return FoodItem.fromMap(results.first);
  }

  @override
  Future<void> insertFood(FoodItem item) async {
    final validation = item.validate();
    if (validation.isNotEmpty) {
      throw ArgumentError(validation.join('; '));
    }
    await db.insert(
      'food_items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateFood(FoodItem item) async {
    final validation = item.validate();
    if (validation.isNotEmpty) {
      throw ArgumentError(validation.join('; '));
    }
    await db.update(
      'food_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  @override
  Future<void> deleteFood(String id) async {
    // Soft-delete or archive so historical activity remains intact
    await db.update(
      'food_items',
      {
        'status': FoodLifecycleStatus.archived.name,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> recordConsumption({
    required FoodItem item,
    required double consumedQuantity,
    String? notes,
  }) async {
    final currentItem = (await getFoodById(item.id)) ?? item;
    if (consumedQuantity.isNaN || consumedQuantity.isInfinite || consumedQuantity <= 0) {
      throw ArgumentError('Consumed quantity must be greater than zero.');
    }
    if (consumedQuantity > currentItem.remainingQuantity + 0.0001) {
      throw ArgumentError('Cannot consume more than the remaining quantity.');
    }

    final effectiveConsumed = consumedQuantity > currentItem.remainingQuantity
        ? currentItem.remainingQuantity
        : consumedQuantity;
    var newConsumedTotal = currentItem.consumedQuantity + effectiveConsumed;
    final remainingAfter = currentItem.initialQuantity - (newConsumedTotal + currentItem.discardedQuantity);
    final isDepleted = remainingAfter <= 0.0001;
    if (isDepleted) {
      newConsumedTotal = currentItem.initialQuantity - currentItem.discardedQuantity;
    }

    final updatedItem = currentItem.copyWith(
      consumedQuantity: newConsumedTotal,
      status: isDepleted ? FoodLifecycleStatus.consumed : currentItem.status,
      updatedAt: DateTime.now(),
    );

    final estimatedValue = currentItem.calculateProportionalValue(effectiveConsumed);

    final activity = FoodActivity(
      id: _uuid.v4(),
      foodItemId: currentItem.id,
      foodName: currentItem.name,
      category: currentItem.category,
      quantity: effectiveConsumed,
      unit: currentItem.unit,
      type: ActivityType.consumed,
      timestamp: DateTime.now(),
      estimatedValue: estimatedValue,
      notes: notes,
    );

    await db.transaction((txn) async {
      await txn.update(
        'food_items',
        updatedItem.toMap(),
        where: 'id = ?',
        whereArgs: [currentItem.id],
      );
      await txn.insert('food_activities', activity.toMap());
    });
  }

  @override
  Future<void> recordDisposal({
    required FoodItem item,
    required double discardedQuantity,
    String? notes,
  }) async {
    final currentItem = (await getFoodById(item.id)) ?? item;
    if (discardedQuantity.isNaN || discardedQuantity.isInfinite || discardedQuantity <= 0) {
      throw ArgumentError('Discarded quantity must be greater than zero.');
    }
    if (discardedQuantity > currentItem.remainingQuantity + 0.0001) {
      throw ArgumentError('Cannot discard more than the remaining quantity.');
    }

    final effectiveDiscarded = discardedQuantity > currentItem.remainingQuantity
        ? currentItem.remainingQuantity
        : discardedQuantity;
    var newDiscardedTotal = currentItem.discardedQuantity + effectiveDiscarded;
    final remainingAfter = currentItem.initialQuantity - (currentItem.consumedQuantity + newDiscardedTotal);
    final isDepleted = remainingAfter <= 0.0001;
    if (isDepleted) {
      newDiscardedTotal = currentItem.initialQuantity - currentItem.consumedQuantity;
    }

    final updatedItem = currentItem.copyWith(
      discardedQuantity: newDiscardedTotal,
      status: isDepleted ? FoodLifecycleStatus.discarded : currentItem.status,
      updatedAt: DateTime.now(),
    );

    final estimatedValue = currentItem.calculateProportionalValue(effectiveDiscarded);

    final activity = FoodActivity(
      id: _uuid.v4(),
      foodItemId: currentItem.id,
      foodName: currentItem.name,
      category: currentItem.category,
      quantity: effectiveDiscarded,
      unit: currentItem.unit,
      type: ActivityType.discarded,
      timestamp: DateTime.now(),
      estimatedValue: estimatedValue,
      notes: notes,
    );

    await db.transaction((txn) async {
      await txn.update(
        'food_items',
        updatedItem.toMap(),
        where: 'id = ?',
        whereArgs: [currentItem.id],
      );
      await txn.insert('food_activities', activity.toMap());
    });
  }

  @override
  Future<List<FoodActivity>> getActivityHistory() async {
    final results = await db.query(
      'food_activities',
      orderBy: 'timestamp DESC',
    );
    return results.map((m) => FoodActivity.fromMap(m)).toList();
  }

  @override
  Future<void> clearAllData() async {
    await db.transaction((txn) async {
      await txn.delete('food_activities');
      await txn.delete('food_items');
    });
  }

  @override
  Future<Map<String, dynamic>> exportData() async {
    final items = await db.query('food_items');
    final activities = await db.query('food_activities');

    return {
      'app': 'Valora',
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'food_items': items,
      'food_activities': activities,
    };
  }

  @override
  Future<bool> importData(Map<String, dynamic> data) async {
    if (data['app'] != 'Valora' || !data.containsKey('food_items')) {
      return false;
    }

    final version = data['version'];
    if (version != null && version is int && version > 2) {
      return false;
    }

    try {
      final rawItems = data['food_items'] as List<dynamic>;
      final rawActivities = (data['food_activities'] as List<dynamic>?) ?? [];

      if (rawItems.length > 50000 || rawActivities.length > 100000) {
        return false;
      }

      final validatedItems = <FoodItem>[];
      for (final raw in rawItems) {
        final item = FoodItem.fromMap(Map<String, dynamic>.from(raw as Map));
        final errors = item.validate();
        if (errors.isNotEmpty) {
          return false;
        }
        validatedItems.add(item);
      }

      final validItemIds = validatedItems.map((e) => e.id).toSet();

      final validatedActivities = <FoodActivity>[];
      for (final raw in rawActivities) {
        final act = FoodActivity.fromMap(Map<String, dynamic>.from(raw as Map));
        final errors = act.validate();
        if (errors.isNotEmpty || !validItemIds.contains(act.foodItemId)) {
          return false;
        }
        validatedActivities.add(act);
      }

      await db.transaction((txn) async {
        await txn.delete('food_activities');
        await txn.delete('food_items');

        for (final item in validatedItems) {
          await txn.insert('food_items', item.toMap());
        }
        for (final act in validatedActivities) {
          await txn.insert('food_activities', act.toMap());
        }
      });

      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> getStorageDiagnostics() async {
    final activeRows = await db.rawQuery("SELECT COUNT(*) as count FROM food_items WHERE status = 'active'");
    final activeCount = (activeRows.first['count'] as num?)?.toInt() ?? 0;

    final totalRows = await db.rawQuery("SELECT COUNT(*) as count FROM food_items");
    final totalCount = (totalRows.first['count'] as num?)?.toInt() ?? 0;

    final actRows = await db.rawQuery("SELECT COUNT(*) as count FROM food_activities");
    final activityCount = (actRows.first['count'] as num?)?.toInt() ?? 0;

    return {
      'engine': 'SQLite Relational Database (sqflite)',
      'acid_compliant': true,
      'database_name': dbName,
      'active_items': activeCount,
      'archived_items': totalCount - activeCount,
      'total_items': totalCount,
      'activity_records': activityCount,
      'foreign_keys_enforced': true,
      'indexes': [
        'idx_food_items_status',
        'idx_food_activities_timestamp',
        'idx_food_activities_food_id',
      ],
    };
  }

  @override
  Future<void> optimizeStorage() async {
    try {
      await db.execute('VACUUM;');
      await db.execute('ANALYZE;');
    } catch (_) {}
  }

  @override
  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }
}
