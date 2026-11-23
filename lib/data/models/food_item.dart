import 'food_category.dart';
import 'food_unit.dart';
import 'storage_location.dart';
import 'expiry_status.dart';

enum FoodLifecycleStatus {
  active,
  consumed,
  discarded,
  archived;

  static FoodLifecycleStatus fromString(String val) {
    return FoodLifecycleStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => FoodLifecycleStatus.active,
    );
  }
}

class FoodItem {
  final String id;
  final String name;
  final FoodCategory category;
  final double initialQuantity;
  final double consumedQuantity;
  final double discardedQuantity;
  final FoodUnit unit;
  final DateTime? expiryDate;
  final double? purchasePrice;
  final StorageLocation? storageLocation;
  final DateTime? purchaseDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final FoodLifecycleStatus status;

  FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.initialQuantity,
    this.consumedQuantity = 0.0,
    this.discardedQuantity = 0.0,
    required this.unit,
    this.expiryDate,
    this.purchasePrice,
    this.storageLocation,
    this.purchaseDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.status = FoodLifecycleStatus.active,
  });

  /// Quantity still remaining in the pantry.
  double get remainingQuantity {
    if (initialQuantity.isNaN || consumedQuantity.isNaN || discardedQuantity.isNaN) return 0.0;
    final rem = initialQuantity - (consumedQuantity + discardedQuantity);
    if (rem.isNaN || rem.isInfinite || rem <= 0.0001) return 0.0;
    if (rem > initialQuantity) return initialQuantity;
    return rem;
  }

  /// Whether any portion is still available in active pantry.
  bool get hasRemaining => remainingQuantity > 0.0001;

  /// Whether the item is currently active in the pantry.
  bool get isActive => status == FoodLifecycleStatus.active && hasRemaining;

  /// Calculates expiry status relative to now or reference date.
  ExpiryStatus getExpiryStatus({DateTime? referenceDate, int warningThresholdDays = 3}) {
    return ExpiryStatus.calculate(
      expiryDate: expiryDate,
      referenceDate: referenceDate,
      warningThresholdDays: warningThresholdDays,
    );
  }

  /// Days remaining until expiry (or negative if expired).
  int? getDaysRemaining({DateTime? referenceDate}) {
    return ExpiryStatus.daysRemaining(
      expiryDate: expiryDate,
      referenceDate: referenceDate,
    );
  }

  /// Proportion of unit price for a given quantity (if purchasePrice is provided).
  double? calculateProportionalValue(double qty) {
    if (purchasePrice == null || initialQuantity <= 0) return null;
    if (qty.isNaN || qty.isInfinite || qty <= 0) return null;
    final ratio = qty / initialQuantity;
    final value = purchasePrice! * ratio;
    if (value.isNaN || value.isInfinite) return null;
    return value;
  }

  /// Validates model fields and returns a list of human-readable issues if any.
  List<String> validate() {
    final errors = <String>[];
    if (id.trim().isEmpty) {
      errors.add('Food id cannot be empty.');
    }
    if (id.length > 100) {
      errors.add('Food id cannot exceed 100 characters.');
    }
    if (name.trim().isEmpty) {
      errors.add('Food name cannot be empty.');
    }
    if (name.trim().length > 150) {
      errors.add('Food name cannot exceed 150 characters.');
    }
    if (initialQuantity.isNaN || initialQuantity.isInfinite || initialQuantity <= 0) {
      errors.add('Initial quantity must be greater than zero.');
    }
    if (initialQuantity > 1000000) {
      errors.add('Initial quantity is too large.');
    }
    if (consumedQuantity.isNaN || consumedQuantity.isInfinite || consumedQuantity < 0) {
      errors.add('Consumed quantity cannot be negative.');
    }
    if (discardedQuantity.isNaN || discardedQuantity.isInfinite || discardedQuantity < 0) {
      errors.add('Discarded quantity cannot be negative.');
    }
    if (consumedQuantity + discardedQuantity > initialQuantity + 0.0001) {
      errors.add('Total consumed and discarded quantity exceeds initial quantity.');
    }
    if (purchasePrice != null && (purchasePrice!.isNaN || purchasePrice!.isInfinite || purchasePrice! < 0)) {
      errors.add('Purchase price cannot be negative.');
    }
    if (purchasePrice != null && purchasePrice! > 1000000) {
      errors.add('Purchase price is too large.');
    }
    if (purchaseDate != null && expiryDate != null) {
      final pDate = DateTime(purchaseDate!.year, purchaseDate!.month, purchaseDate!.day);
      final eDate = DateTime(expiryDate!.year, expiryDate!.month, expiryDate!.day);
      if (eDate.isBefore(pDate)) {
        errors.add('Expiry date cannot be before purchase date.');
      }
    }
    if (notes != null && notes!.length > 500) {
      errors.add('Notes cannot exceed 500 characters.');
    }
    return errors;
  }

  FoodItem copyWith({
    String? id,
    String? name,
    FoodCategory? category,
    double? initialQuantity,
    double? consumedQuantity,
    double? discardedQuantity,
    FoodUnit? unit,
    DateTime? expiryDate,
    bool clearExpiryDate = false,
    double? purchasePrice,
    bool clearPurchasePrice = false,
    StorageLocation? storageLocation,
    bool clearStorageLocation = false,
    DateTime? purchaseDate,
    bool clearPurchaseDate = false,
    String? notes,
    bool clearNotes = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    FoodLifecycleStatus? status,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      initialQuantity: initialQuantity ?? this.initialQuantity,
      consumedQuantity: consumedQuantity ?? this.consumedQuantity,
      discardedQuantity: discardedQuantity ?? this.discardedQuantity,
      unit: unit ?? this.unit,
      expiryDate: clearExpiryDate ? null : (expiryDate ?? this.expiryDate),
      purchasePrice: clearPurchasePrice ? null : (purchasePrice ?? this.purchasePrice),
      storageLocation: clearStorageLocation ? null : (storageLocation ?? this.storageLocation),
      purchaseDate: clearPurchaseDate ? null : (purchaseDate ?? this.purchaseDate),
      notes: clearNotes ? null : (notes ?? this.notes),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category.name,
      'initial_quantity': initialQuantity,
      'consumed_quantity': consumedQuantity,
      'discarded_quantity': discardedQuantity,
      'unit': unit.name,
      'expiry_date': expiryDate?.toIso8601String(),
      'purchase_price': purchasePrice,
      'storage_location': storageLocation?.name,
      'purchase_date': purchaseDate?.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'status': status.name,
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is String) return DateTime.tryParse(val);
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return null;
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

    return FoodItem(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      category: FoodCategory.fromString(map['category']?.toString() ?? ''),
      initialQuantity: parseDouble(map['initial_quantity']),
      consumedQuantity: parseDouble(map['consumed_quantity']),
      discardedQuantity: parseDouble(map['discarded_quantity']),
      unit: FoodUnit.fromString(map['unit']?.toString() ?? ''),
      expiryDate: parseDate(map['expiry_date']),
      purchasePrice: map['purchase_price'] != null ? parseDouble(map['purchase_price'], 0.0) : null,
      storageLocation: map['storage_location'] != null
          ? StorageLocation.fromString(map['storage_location'].toString())
          : null,
      purchaseDate: parseDate(map['purchase_date']),
      notes: map['notes']?.toString(),
      createdAt: parseDate(map['created_at']) ?? DateTime.now(),
      updatedAt: parseDate(map['updated_at']) ?? DateTime.now(),
      status: FoodLifecycleStatus.fromString(map['status']?.toString() ?? 'active'),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem.fromMap(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          category == other.category &&
          initialQuantity == other.initialQuantity &&
          consumedQuantity == other.consumedQuantity &&
          discardedQuantity == other.discardedQuantity &&
          unit == other.unit &&
          expiryDate == other.expiryDate &&
          status == other.status;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      category.hashCode ^
      initialQuantity.hashCode ^
      consumedQuantity.hashCode ^
      discardedQuantity.hashCode ^
      unit.hashCode ^
      expiryDate.hashCode ^
      status.hashCode;
}
