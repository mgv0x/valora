import 'food_category.dart';
import 'food_unit.dart';

enum ActivityType {
  consumed,
  discarded;

  static ActivityType fromString(String val) {
    return ActivityType.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => ActivityType.consumed,
    );
  }
}

class FoodActivity {
  final String id;
  final String foodItemId;
  final String foodName;
  final FoodCategory category;
  final double quantity;
  final FoodUnit unit;
  final ActivityType type;
  final DateTime timestamp;
  final double? estimatedValue;
  final String? notes;

  FoodActivity({
    required this.id,
    required this.foodItemId,
    required this.foodName,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.type,
    required this.timestamp,
    this.estimatedValue,
    this.notes,
  });

  /// Validates activity invariants and returns list of errors if any.
  List<String> validate() {
    final errors = <String>[];
    if (id.trim().isEmpty) {
      errors.add('Activity id cannot be empty.');
    }
    if (id.length > 100) {
      errors.add('Activity id cannot exceed 100 characters.');
    }
    if (foodItemId.trim().isEmpty) {
      errors.add('Referenced food item id cannot be empty.');
    }
    if (foodItemId.length > 100) {
      errors.add('Referenced food item id cannot exceed 100 characters.');
    }
    if (foodName.trim().isEmpty) {
      errors.add('Food name cannot be empty.');
    }
    if (foodName.trim().length > 150) {
      errors.add('Food name cannot exceed 150 characters.');
    }
    if (quantity <= 0 || quantity.isNaN || quantity.isInfinite) {
      errors.add('Activity quantity must be a valid positive number.');
    }
    if (estimatedValue != null && (estimatedValue! < 0 || estimatedValue!.isNaN || estimatedValue!.isInfinite)) {
      errors.add('Estimated value cannot be negative or invalid.');
    }
    if (notes != null && notes!.length > 500) {
      errors.add('Activity notes cannot exceed 500 characters.');
    }
    return errors;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'food_item_id': foodItemId,
      'food_name': foodName,
      'category': category.name,
      'quantity': quantity,
      'unit': unit.name,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'estimated_value': estimatedValue,
      'notes': notes,
    };
  }

  factory FoodActivity.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return DateTime.now();
    }

    double parseDouble(dynamic val, [double fallback = 0.0]) {
      if (val == null) return fallback;
      if (val is num) {
        final d = val.toDouble();
        return (d.isNaN || d.isInfinite) ? fallback : d;
      }
      if (val is String) {
        final d = double.tryParse(val);
        if (d != null && !d.isNaN && !d.isInfinite) return d;
      }
      return fallback;
    }

    return FoodActivity(
      id: map['id']?.toString() ?? '',
      foodItemId: map['food_item_id']?.toString() ?? '',
      foodName: map['food_name']?.toString() ?? '',
      category: FoodCategory.fromString(map['category']?.toString() ?? ''),
      quantity: parseDouble(map['quantity']),
      unit: FoodUnit.fromString(map['unit']?.toString() ?? ''),
      type: ActivityType.fromString(map['type']?.toString() ?? ''),
      timestamp: parseDate(map['timestamp']),
      estimatedValue: map['estimated_value'] != null ? parseDouble(map['estimated_value']) : null,
      notes: map['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory FoodActivity.fromJson(Map<String, dynamic> json) => FoodActivity.fromMap(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodActivity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          foodItemId == other.foodItemId &&
          foodName == other.foodName &&
          category == other.category &&
          quantity == other.quantity &&
          unit == other.unit &&
          type == other.type &&
          timestamp == other.timestamp;

  @override
  int get hashCode =>
      id.hashCode ^
      foodItemId.hashCode ^
      foodName.hashCode ^
      category.hashCode ^
      quantity.hashCode ^
      unit.hashCode ^
      type.hashCode ^
      timestamp.hashCode;
}
