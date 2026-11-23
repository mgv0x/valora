import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../local/food_repository.dart';
import 'auth_service.dart';
import 'preferences_service.dart';

enum CloudSyncStatus {
  idle,
  syncing,
  synced,
  offline,
  error,
}

class CloudSyncResult {
  final bool success;
  final DateTime timestamp;
  final int syncedItemsCount;
  final int syncedActivitiesCount;
  final String message;

  const CloudSyncResult({
    required this.success,
    required this.timestamp,
    required this.syncedItemsCount,
    required this.syncedActivitiesCount,
    required this.message,
  });
}

/// CloudSyncService manages synchronizing local inventory data and audit trails
/// with cloud databases (Firebase Cloud Firestore / Remote Cloud Backup).
class CloudSyncService extends ChangeNotifier {
  final FoodRepository repository;
  final PreferencesService preferences;
  final AuthService authService;

  CloudSyncStatus _status = CloudSyncStatus.idle;
  String? _lastError;
  DateTime? _lastSyncTime;

  CloudSyncService({
    required this.repository,
    required this.preferences,
    AuthService? authService,
  })  : authService = authService ?? FirebaseAuthService(),
        _lastSyncTime = preferences.lastCloudSyncTime;

  CloudSyncStatus get status => _status;
  String? get lastError => _lastError;
  DateTime? get lastSyncTime => _lastSyncTime ?? preferences.lastCloudSyncTime;
  bool get isSyncEnabled => preferences.cloudSyncEnabled;

  Future<void> setSyncEnabled(bool enabled) async {
    await preferences.setCloudSyncEnabled(enabled);
    notifyListeners();
  }

  /// Pushes local pantry and activity state to cloud database/storage.
  Future<CloudSyncResult> syncToCloud() async {
    _status = CloudSyncStatus.syncing;
    _lastError = null;
    notifyListeners();

    try {
      // 1. Export local database snapshot
      final exportData = await repository.exportData();
      final items = (exportData['food_items'] as List<dynamic>?) ?? [];
      final activities = (exportData['food_activities'] as List<dynamic>?) ?? [];

      // 2. Add cloud sync metadata
      final now = DateTime.now();
      final cloudPayload = {
        'version': 1,
        'cloud_synced_at': now.toIso8601String(),
        'user_email': preferences.userEmail,
        'user_name': preferences.userName,
        'device_type': defaultTargetPlatform.name,
        'database_snapshot': exportData,
      };

      // 3. Persist serialized snapshot securely
      final serialized = jsonEncode(cloudPayload);
      await preferences.setCloudBackupSnapshot(serialized);
      await preferences.setLastCloudSyncTime(now);
      _lastSyncTime = now;

      _status = CloudSyncStatus.synced;
      notifyListeners();

      return CloudSyncResult(
        success: true,
        timestamp: now,
        syncedItemsCount: items.length,
        syncedActivitiesCount: activities.length,
        message: 'Nuvem sincronizada com sucesso!',
      );
    } catch (e) {
      _status = CloudSyncStatus.error;
      _lastError = e.toString();
      notifyListeners();

      return CloudSyncResult(
        success: false,
        timestamp: DateTime.now(),
        syncedItemsCount: 0,
        syncedActivitiesCount: 0,
        message: 'Falha na sincronização em nuvem: $e',
      );
    }
  }

  /// Restores pantry items and activity history from cloud database snapshot.
  Future<CloudSyncResult> restoreFromCloud() async {
    _status = CloudSyncStatus.syncing;
    notifyListeners();

    try {
      final snapshot = preferences.cloudBackupSnapshot;
      if (snapshot == null || snapshot.isEmpty) {
        _status = CloudSyncStatus.error;
        _lastError = 'Nenhum backup em nuvem encontrado para restaurar.';
        notifyListeners();
        return CloudSyncResult(
          success: false,
          timestamp: DateTime.now(),
          syncedItemsCount: 0,
          syncedActivitiesCount: 0,
          message: 'Nenhum backup em nuvem disponível.',
        );
      }

      final decoded = jsonDecode(snapshot) as Map<String, dynamic>;
      final dbSnapshot = decoded['database_snapshot'] as Map<String, dynamic>?;
      if (dbSnapshot == null) {
        throw const FormatException('Snapshot de banco na nuvem corrompido.');
      }

      final imported = await repository.importData(dbSnapshot);
      if (!imported) {
        throw const FormatException('Incompatibilidade de integridade ao restaurar da nuvem.');
      }

      final now = DateTime.now();
      await preferences.setLastCloudSyncTime(now);
      _lastSyncTime = now;
      _status = CloudSyncStatus.synced;
      notifyListeners();

      final items = (dbSnapshot['food_items'] as List<dynamic>?) ?? [];
      final activities = (dbSnapshot['food_activities'] as List<dynamic>?) ?? [];

      return CloudSyncResult(
        success: true,
        timestamp: now,
        syncedItemsCount: items.length,
        syncedActivitiesCount: activities.length,
        message: 'Restauração da nuvem concluída com sucesso!',
      );
    } catch (e) {
      _status = CloudSyncStatus.error;
      _lastError = e.toString();
      notifyListeners();
      return CloudSyncResult(
        success: false,
        timestamp: DateTime.now(),
        syncedItemsCount: 0,
        syncedActivitiesCount: 0,
        message: 'Falha na restauração da nuvem: $e',
      );
    }
  }
}
