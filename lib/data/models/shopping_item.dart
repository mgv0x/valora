import 'package:uuid/uuid.dart';
import 'food_category.dart';
import 'food_unit.dart';

class ShoppingItem {
  final String id;
  final String name;
  final FoodCategory category;
  final double quantity;
  final FoodUnit unit;
  final bool isChecked;
  final DateTime createdAt;

  const ShoppingItem({
    required this.id,
    required this.name,
    this.category = FoodCategory.pantryStaples,
    this.quantity = 1.0,
    this.unit = FoodUnit.piece,
    this.isChecked = false,
    required this.createdAt,
  });

  factory ShoppingItem.create({
    required String name,
    FoodCategory category = FoodCategory.pantryStaples,
    double quantity = 1.0,
    FoodUnit unit = FoodUnit.piece,
  }) {
    return ShoppingItem(
      id: const Uuid().v4(),
      name: name.trim(),
      category: category,
      quantity: quantity <= 0 ? 1.0 : quantity,
      unit: unit,
      isChecked: false,
      createdAt: DateTime.now(),
    );
  }

  ShoppingItem copyWith({
    String? id,
    String? name,
    FoodCategory? category,
    double? quantity,
    FoodUnit? unit,
    bool? isChecked,
    DateTime? createdAt,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isChecked: isChecked ?? this.isChecked,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category.name,
      'quantity': quantity,
      'unit': unit.name,
      'is_checked': isChecked ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'] as String? ?? const Uuid().v4(),
      name: (map['name'] as String? ?? '').trim(),
      category: FoodCategory.fromString(map['category'] as String? ?? 'other'),
      quantity: (map['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: FoodUnit.fromString(map['unit'] as String? ?? 'un'),
      isChecked: map['is_checked'] == 1 || map['is_checked'] == true,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
