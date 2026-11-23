import 'package:flutter/material.dart';
import '../data/local/food_repository.dart';
import '../data/models/food_item.dart';
import '../data/models/food_category.dart';
import '../data/models/expiry_status.dart';
import '../data/models/food_priority.dart';
import '../data/models/storage_location.dart';
import '../data/services/notification_service.dart';
import '../data/services/preferences_service.dart';
import '../core/utils/text_utils.dart';

enum PantrySortOption {
  expirySoonest,
  expiryLatest,
  nameAZ,
  nameZA,
}

class PantryProvider extends ChangeNotifier {
  final FoodRepository repository;
  final NotificationService? notificationService;
  final PreferencesService? preferencesService;

  List<FoodItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _searchQuery = '';
  FoodCategory? _selectedCategory;
  ExpiryStatus? _selectedStatusFilter;
  StorageLocation? _selectedStorageFilter;
  PantrySortOption _sortOption = PantrySortOption.expirySoonest;
  int _warningThresholdDays = 3;
  bool _notificationsEnabled = true;
  DateTime? referenceDate;

  PantryProvider({
    required this.repository,
    this.notificationService,
    this.preferencesService,
    this.referenceDate,
  }) {
    if (preferencesService != null) {
      _warningThresholdDays = preferencesService!.warningThresholdDays;
      _notificationsEnabled = preferencesService!.notificationsEnabled;
    }
  }

  void setReferenceDate(DateTime? date) {
    if (referenceDate != date) {
      referenceDate = date;
      notifyListeners();
    }
  }

  List<FoodItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get searchQuery => _searchQuery;
  FoodCategory? get selectedCategory => _selectedCategory;
  ExpiryStatus? get selectedStatusFilter => _selectedStatusFilter;
  StorageLocation? get selectedStorageFilter => _selectedStorageFilter;
  PantrySortOption get sortOption => _sortOption;
  int get warningThresholdDays => _warningThresholdDays;
  bool get notificationsEnabled => _notificationsEnabled;

  void setNotificationsEnabled(bool enabled) {
    if (_notificationsEnabled != enabled) {
      _notificationsEnabled = enabled;
      preferencesService?.setNotificationsEnabled(enabled);
      if (!enabled) {
        notificationService?.cancelAll();
      } else {
        rescheduleAllExpiryWarnings();
      }
      notifyListeners();
    }
  }

  Future<void> updateWarningThreshold(int days) async {
    if (_warningThresholdDays != days) {
      _warningThresholdDays = days;
      await preferencesService?.setWarningThresholdDays(days);
      notifyListeners();
      if (_notificationsEnabled) {
        await rescheduleAllExpiryWarnings();
      }
    }
  }

  Future<void> rescheduleAllExpiryWarnings() async {
    if (notificationService == null) return;
    if (!_notificationsEnabled) {
      await notificationService!.cancelAll();
      return;
    }
    await notificationService!.cancelAll();
    for (final item in _items) {
      if (item.isActive && item.expiryDate != null) {
        await notificationService!.scheduleExpiryWarning(
          item: item,
          warningDays: _warningThresholdDays,
          title: 'Valora: ${item.name}',
          body: 'Expiring in $_warningThresholdDays days.',
        );
      }
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(FoodCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSelectedStatusFilter(ExpiryStatus? status) {
    _selectedStatusFilter = status;
    notifyListeners();
  }

  void setSelectedStorageFilter(StorageLocation? storage) {
    _selectedStorageFilter = storage;
    notifyListeners();
  }

  void setSortOption(PantrySortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _selectedStatusFilter = null;
    _selectedStorageFilter = null;
    _sortOption = PantrySortOption.expirySoonest;
    notifyListeners();
  }

  /// Extends food shelf-life by +90 days by moving to Freezer (Batch Freezing Feature)
  Future<void> freezeItemToExtendShelfLife(FoodItem item) async {
    final currentExpiry = item.expiryDate ?? DateTime.now();
    final newExpiry = currentExpiry.add(const Duration(days: 90));
    final updated = item.copyWith(
      storageLocation: StorageLocation.freezer,
      expiryDate: newExpiry,
      notes: (item.notes != null && item.notes!.isNotEmpty)
          ? '${item.notes} • Congelado (+90 dias)'
          : 'Congelado (+90 dias)',
      updatedAt: DateTime.now(),
    );
    await updateFood(updated);
  }

  /// Active foods filtered by category, status, storage, and search query, then sorted.
  List<FoodItem> get filteredAndSortedItems {
    final filtered = _items.where((item) {
      if (!item.isActive) return false;

      // Search match (accent-insensitive & case-insensitive)
      if (!TextUtils.matchesSearch(item.name, _searchQuery)) {
        return false;
      }

      // Category match
      if (_selectedCategory != null && item.category != _selectedCategory) {
        return false;
      }

      // Storage location match
      if (_selectedStorageFilter != null && item.storageLocation != _selectedStorageFilter) {
        return false;
      }

      // Status match
      if (_selectedStatusFilter != null) {
        final itemStatus = item.getExpiryStatus(
          referenceDate: referenceDate,
          warningThresholdDays: _warningThresholdDays,
        );
        if (itemStatus != _selectedStatusFilter) {
          return false;
        }
      }

      return true;
    }).toList();

    filtered.sort((a, b) {
      switch (_sortOption) {
        case PantrySortOption.expirySoonest:
          if (a.expiryDate == null && b.expiryDate == null) {
            final cmp = a.name.compareTo(b.name);
            return cmp != 0 ? cmp : a.id.compareTo(b.id);
          }
          if (a.expiryDate == null) return 1;
          if (b.expiryDate == null) return -1;
          final dateCmp = a.expiryDate!.compareTo(b.expiryDate!);
          if (dateCmp != 0) return dateCmp;
          final nameCmp = a.name.compareTo(b.name);
          return nameCmp != 0 ? nameCmp : a.id.compareTo(b.id);

        case PantrySortOption.expiryLatest:
          if (a.expiryDate == null && b.expiryDate == null) {
            final cmp = a.name.compareTo(b.name);
            return cmp != 0 ? cmp : a.id.compareTo(b.id);
          }
          if (a.expiryDate == null) return 1;
          if (b.expiryDate == null) return -1;
          final dateCmp = b.expiryDate!.compareTo(a.expiryDate!);
          if (dateCmp != 0) return dateCmp;
          final nameCmp = a.name.compareTo(b.name);
          return nameCmp != 0 ? nameCmp : a.id.compareTo(b.id);

        case PantrySortOption.nameAZ:
          final normA = TextUtils.normalize(a.name);
          final normB = TextUtils.normalize(b.name);
          final cmp = normA.compareTo(normB);
          if (cmp != 0) return cmp;
          final rawCmp = a.name.compareTo(b.name);
          return rawCmp != 0 ? rawCmp : a.id.compareTo(b.id);

        case PantrySortOption.nameZA:
          final normA = TextUtils.normalize(a.name);
          final normB = TextUtils.normalize(b.name);
          final cmp = normB.compareTo(normA);
          if (cmp != 0) return cmp;
          final rawCmp = b.name.compareTo(a.name);
          return rawCmp != 0 ? rawCmp : b.id.compareTo(a.id);
      }
    });

    return filtered;
  }

  /// Priority items requiring attention: Expired, Expiring Today, or Expiring Soon.
  List<FoodItem> get priorityItems {
    final list = _items.where((item) {
      if (!item.isActive) return false;
      final st = item.getExpiryStatus(
        referenceDate: referenceDate,
        warningThresholdDays: _warningThresholdDays,
      );
      return st == ExpiryStatus.expired ||
          st == ExpiryStatus.expiringToday ||
          st == ExpiryStatus.expiringSoon;
    }).toList();

    list.sort((a, b) {
      if (a.expiryDate == null) return 1;
      if (b.expiryDate == null) return -1;
      return a.expiryDate!.compareTo(b.expiryDate!);
    });

    return list;
  }

  int get totalActiveCount => _items.where((i) => i.isActive).length;

  double get totalEstimatedValue {
    return _items.where((i) => i.isActive).fold(0.0, (sum, item) {
      if (item.purchasePrice == null || item.initialQuantity <= 0) return sum;
      final val = (item.remainingQuantity / item.initialQuantity) * item.purchasePrice!;
      return sum + (val.isFinite ? val : 0.0);
    });
  }

  int get needsAttentionCount => priorityItems.length;

  /// Foods ranked by urgency for the "Consume first" section.
  ///
  /// Uses the intelligent prioritization system: only active items whose
  /// expiry falls within 7 days (or already expired), ordered by urgency
  /// (tier, days remaining, remaining quantity, name).
  List<PrioritizedFood> get consumeFirstItems =>
      FoodPriorityCalculator.consumeFirst(_items, referenceDate: referenceDate);

  /// Aggregated insight derived from [consumeFirstItems].
  PriorityInsight get consumeFirstInsight =>
      FoodPriorityCalculator.buildInsight(consumeFirstItems);

  int get expiringSoonCount {
    return _items.where((item) {
      if (!item.isActive) return false;
      final st = item.getExpiryStatus(
        referenceDate: referenceDate,
        warningThresholdDays: _warningThresholdDays,
      );
      return st == ExpiryStatus.expiringSoon;
    }).length;
  }

  // Groups for Screen 4 (Expiry Center)
  List<FoodItem> get groupExpired {
    final nowRef = referenceDate ?? DateTime.now();
    return _items.where((i) =>
        i.isActive &&
        i.getExpiryStatus(
          referenceDate: referenceDate,
          warningThresholdDays: _warningThresholdDays,
        ) == ExpiryStatus.expired).toList()
      ..sort((a, b) => (a.expiryDate ?? nowRef).compareTo(b.expiryDate ?? nowRef));
  }

  List<FoodItem> get groupExpiringToday {
    return _items.where((i) =>
        i.isActive &&
        i.getExpiryStatus(
          referenceDate: referenceDate,
          warningThresholdDays: _warningThresholdDays,
        ) == ExpiryStatus.expiringToday).toList()
      ..sort((a, b) => TextUtils.normalize(a.name).compareTo(TextUtils.normalize(b.name)));
  }

  List<FoodItem> get groupExpiringSoon {
    final nowRef = referenceDate ?? DateTime.now();
    return _items.where((i) =>
        i.isActive &&
        i.getExpiryStatus(
          referenceDate: referenceDate,
          warningThresholdDays: _warningThresholdDays,
        ) == ExpiryStatus.expiringSoon).toList()
      ..sort((a, b) => (a.expiryDate ?? nowRef).compareTo(b.expiryDate ?? nowRef));
  }

  List<FoodItem> get groupLater {
    final nowRef = referenceDate ?? DateTime.now();
    return _items.where((i) =>
        i.isActive &&
        i.getExpiryStatus(
          referenceDate: referenceDate,
          warningThresholdDays: _warningThresholdDays,
        ) == ExpiryStatus.fresh).toList()
      ..sort((a, b) => (a.expiryDate ?? nowRef).compareTo(b.expiryDate ?? nowRef));
  }

  List<FoodItem> get groupUnknown {
    return _items.where((i) =>
        i.isActive &&
        i.getExpiryStatus(
          referenceDate: referenceDate,
          warningThresholdDays: _warningThresholdDays,
        ) == ExpiryStatus.unknown).toList()
      ..sort((a, b) => TextUtils.normalize(a.name).compareTo(TextUtils.normalize(b.name)));
  }

  Future<void> loadItems() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await repository.getActiveFoods();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addFood(FoodItem item) async {
    try {
      await repository.insertFood(item);
      if (_notificationsEnabled && item.expiryDate != null) {
        await notificationService?.scheduleExpiryWarning(
          item: item,
          warningDays: _warningThresholdDays,
          title: 'Valora: ${item.name}',
          body: 'Expiring in $_warningThresholdDays days.',
        );
      }
      await loadItems();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateFood(FoodItem item) async {
    try {
      await repository.updateFood(item);
      if (_notificationsEnabled && item.expiryDate != null) {
        await notificationService?.scheduleExpiryWarning(
          item: item,
          warningDays: _warningThresholdDays,
          title: 'Valora: ${item.name}',
          body: 'Expiring in $_warningThresholdDays days.',
        );
      } else {
        await notificationService?.cancelForFood(item.id);
      }
      await loadItems();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteFood(String id) async {
    try {
      await notificationService?.cancelForFood(id);
      await repository.deleteFood(id);
      await loadItems();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> recordConsumption({
    required FoodItem item,
    required double consumedQuantity,
    String? notes,
  }) async {
    try {
      await repository.recordConsumption(
        item: item,
        consumedQuantity: consumedQuantity,
        notes: notes,
      );
      final updated = await repository.getFoodById(item.id);
      if (updated == null || !updated.hasRemaining || updated.status != FoodLifecycleStatus.active) {
        await notificationService?.cancelForFood(item.id);
      }
      await loadItems();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> recordDisposal({
    required FoodItem item,
    required double discardedQuantity,
    String? notes,
  }) async {
    try {
      await repository.recordDisposal(
        item: item,
        discardedQuantity: discardedQuantity,
        notes: notes,
      );
      final updated = await repository.getFoodById(item.id);
      if (updated == null || !updated.hasRemaining || updated.status != FoodLifecycleStatus.active) {
        await notificationService?.cancelForFood(item.id);
      }
      await loadItems();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
