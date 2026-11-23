import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../data/models/food_category.dart';
import '../data/models/food_item.dart';
import '../data/models/food_unit.dart';
import '../data/models/shopping_item.dart';
import '../data/services/preferences_service.dart';

class ShoppingListProvider extends ChangeNotifier {
  final PreferencesService prefs;
  final List<ShoppingItem> _items = [];

  ShoppingListProvider({required this.prefs}) {
    _loadItems();
  }

  List<ShoppingItem> get items => List.unmodifiable(_items);

  int get uncheckedCount => _items.where((i) => !i.isChecked).length;

  void _loadItems() {
    _items.clear();
    final jsonList = prefs.shoppingListJson;
    for (final raw in jsonList) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          _items.add(ShoppingItem.fromMap(decoded));
        } else if (decoded is Map) {
          _items.add(ShoppingItem.fromMap(Map<String, dynamic>.from(decoded)));
        }
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    final jsonList = _items.map((i) => jsonEncode(i.toMap())).toList();
    await prefs.setShoppingListJson(jsonList);
    notifyListeners();
  }

  Future<void> addItem({
    required String name,
    FoodCategory category = FoodCategory.pantryStaples,
    double quantity = 1.0,
    FoodUnit unit = FoodUnit.piece,
  }) async {
    if (name.trim().isEmpty) return;
    final item = ShoppingItem.create(
      name: name,
      category: category,
      quantity: quantity,
      unit: unit,
    );
    _items.insert(0, item);
    await _persist();
  }

  Future<void> addFromPantryFood(FoodItem food) async {
    // Avoid exact duplicate unchecked items
    final existingIndex = _items.indexWhere(
      (i) => !i.isChecked && i.name.toLowerCase() == food.name.toLowerCase(),
    );
    if (existingIndex >= 0) {
      final current = _items[existingIndex];
      _items[existingIndex] = current.copyWith(
        quantity: current.quantity + (food.initialQuantity > 0 ? food.initialQuantity : 1.0),
      );
    } else {
      _items.insert(
        0,
        ShoppingItem.create(
          name: food.name,
          category: food.category,
          quantity: food.initialQuantity > 0 ? food.initialQuantity : 1.0,
          unit: food.unit,
        ),
      );
    }
    await _persist();
  }

  Future<void> toggleItem(String id) async {
    final index = _items.indexWhere((i) => i.id == id);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(isChecked: !_items[index].isChecked);
      await _persist();
    }
  }

  Future<void> removeItem(String id) async {
    _items.removeWhere((i) => i.id == id);
    await _persist();
  }

  Future<void> clearCompleted() async {
    _items.removeWhere((i) => i.isChecked);
    await _persist();
  }
}
