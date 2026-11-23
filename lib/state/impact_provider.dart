import 'package:flutter/material.dart';
import '../data/local/food_repository.dart';
import '../data/models/food_activity.dart';
import '../data/models/food_unit.dart';

enum ActivityPeriodFilter {
  allTime,
  last7Days,
  last30Days,
  last90Days,
}

enum ActivityTypeFilter {
  all,
  consumed,
  discarded,
}

class ImpactProvider extends ChangeNotifier {
  final FoodRepository repository;

  List<FoodActivity> _activities = [];
  bool _isLoading = false;
  String? _errorMessage;

  ActivityPeriodFilter _periodFilter = ActivityPeriodFilter.allTime;
  ActivityTypeFilter _typeFilter = ActivityTypeFilter.all;
  DateTime? referenceDate;

  ImpactProvider({required this.repository, this.referenceDate});

  List<FoodActivity> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ActivityPeriodFilter get periodFilter => _periodFilter;
  ActivityTypeFilter get typeFilter => _typeFilter;

  void setReferenceDate(DateTime? date) {
    if (referenceDate != date) {
      referenceDate = date;
      notifyListeners();
    }
  }

  void setPeriodFilter(ActivityPeriodFilter filter) {
    if (_periodFilter != filter) {
      _periodFilter = filter;
      notifyListeners();
    }
  }

  void setTypeFilter(ActivityTypeFilter filter) {
    if (_typeFilter != filter) {
      _typeFilter = filter;
      notifyListeners();
    }
  }

  /// Activities matching the selected period and action type filters.
  List<FoodActivity> get filteredActivities {
    final now = referenceDate ?? DateTime.now();
    return _activities.where((act) {
      // Type filter
      if (_typeFilter == ActivityTypeFilter.consumed && act.type != ActivityType.consumed) {
        return false;
      }
      if (_typeFilter == ActivityTypeFilter.discarded && act.type != ActivityType.discarded) {
        return false;
      }

      // Period filter
      final startOfToday = DateTime(now.year, now.month, now.day);
      if (_periodFilter == ActivityPeriodFilter.last7Days) {
        final cutoff = startOfToday.subtract(const Duration(days: 6));
        if (act.timestamp.isBefore(cutoff)) return false;
      } else if (_periodFilter == ActivityPeriodFilter.last30Days) {
        final cutoff = startOfToday.subtract(const Duration(days: 29));
        if (act.timestamp.isBefore(cutoff)) return false;
      } else if (_periodFilter == ActivityPeriodFilter.last90Days) {
        final cutoff = startOfToday.subtract(const Duration(days: 89));
        if (act.timestamp.isBefore(cutoff)) return false;
      }

      return true;
    }).toList();
  }

  int get recordedConsumedCount =>
      _activities.where((a) => a.type == ActivityType.consumed).length;

  int get recordedDiscardedCount =>
      _activities.where((a) => a.type == ActivityType.discarded).length;

  int get totalRecordedActions => _activities.length;

  int get filteredConsumedCount =>
      filteredActivities.where((a) => a.type == ActivityType.consumed).length;

  int get filteredDiscardedCount =>
      filteredActivities.where((a) => a.type == ActivityType.discarded).length;

  /// Sum of proportional purchase prices of all filtered items consumed.
  /// Only includes items that had an entered purchase price.
  double get estimatedValueConsumed {
    return filteredActivities
        .where((a) => a.type == ActivityType.consumed && a.estimatedValue != null && a.estimatedValue!.isFinite)
        .fold(0.0, (sum, a) => sum + a.estimatedValue!);
  }

  /// Sum of proportional purchase prices of all filtered items discarded.
  /// Only includes items that had an entered purchase price.
  double get estimatedValueDiscarded {
    return filteredActivities
        .where((a) => a.type == ActivityType.discarded && a.estimatedValue != null && a.estimatedValue!.isFinite)
        .fold(0.0, (sum, a) => sum + a.estimatedValue!);
  }

  /// Rate of consumption actions relative to total recorded actions (consumed + discarded).
  /// Returns null if there are 0 recorded events matching current filter.
  double? get consumptionRate {
    final total = filteredConsumedCount + filteredDiscardedCount;
    if (total == 0) return null;
    final rate = (filteredConsumedCount / total) * 100.0;
    return rate.isFinite ? rate : null;
  }

  /// Breakdown of recorded consumed quantity strictly grouped by unit.
  /// Never adds incompatible units (e.g. kg + L) together.
  Map<FoodUnit, double> get consumedVolumeByUnit {
    final result = <FoodUnit, double>{};
    for (final act in filteredActivities.where((a) => a.type == ActivityType.consumed)) {
      if (act.quantity.isFinite && act.quantity > 0) {
        result[act.unit] = (result[act.unit] ?? 0.0) + act.quantity;
      }
    }
    return result;
  }

  /// Breakdown of recorded discarded quantity strictly grouped by unit.
  /// Never adds incompatible units (e.g. kg + L) together.
  Map<FoodUnit, double> get discardedVolumeByUnit {
    final result = <FoodUnit, double>{};
    for (final act in filteredActivities.where((a) => a.type == ActivityType.discarded)) {
      if (act.quantity.isFinite && act.quantity > 0) {
        result[act.unit] = (result[act.unit] ?? 0.0) + act.quantity;
      }
    }
    return result;
  }

  Future<void> loadActivities() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _activities = await repository.getActivityHistory();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
