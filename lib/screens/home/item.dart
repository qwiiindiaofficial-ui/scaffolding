// lib/models/stock_item.dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StockItem {
  final String id;
  final String image;
  final String title;
  String category;
  final String size;
  final int quantity;
  final double rate;
  final double saleRate;
  final double weight;
  final double value;
  int available;
  int dispatch;

  StockItem({
    required this.id,
    required this.image,
    required this.title,
    required this.category,
    required this.size,
    required this.quantity,
    required this.rate,
    required this.saleRate,
    required this.weight,
    required this.value,
    required this.available,
    required this.dispatch,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image': image,
      'title': title,
      'category': category,
      'size': size,
      'quantity': quantity,
      'rate': rate,
      'saleRate': saleRate,
      'weight': weight,
      'value': value,
      'available': available,
      'dispatch': dispatch,
    };
  }

  factory StockItem.fromMap(Map<String, dynamic> map) {
    return StockItem(
      id: map['id'],
      image: map['image'],
      title: map['title'],
      category: map['category'],
      size: map['size'],
      quantity: map['quantity'],
      rate: map['rate'],
      saleRate: map['saleRate'],
      weight: map['weight'],
      value: map['value'],
      available: map['available'],
      dispatch: map['dispatch'],
    );
  }

  StockItem copyWith({
    String? id,
    String? image,
    String? title,
    String? category,
    String? size,
    int? quantity,
    double? rate,
    double? saleRate,
    double? weight,
    double? value,
    int? available,
    int? dispatch,
  }) {
    return StockItem(
      id: id ?? this.id,
      value: value ?? this.value,
      image: image ?? this.image,
      title: title ?? this.title,
      category: category ?? this.category,
      size: size ?? this.size,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
      saleRate: saleRate ?? this.saleRate,
      weight: weight ?? this.weight,
      available: available ?? this.available,
      dispatch: dispatch ?? this.dispatch,
    );
  }
}

// lib/services/stock_service.dart

class StockService {
  static const String _key = 'stock_items';
  static Future<void> updateItemQuantity(String itemId, int newQuantity) async {
    try {
      final items = await getStockItems();
      final index = items.indexWhere((item) => item.id == itemId);

      if (index != -1) {
        final updatedItem = items[index].copyWith(
          quantity: newQuantity,
          available: newQuantity - (items[index].dispatch),
        );
        items[index] = updatedItem;
        await saveStockItems(items);
      }
    } catch (e) {
      print('Error updating item quantity: $e');
      throw Exception('Failed to update item quantity');
    }
  }

  static Future<void> saveStockItems(List<StockItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = items.map((item) => item.toMap()).toList();
    await prefs.setString(_key, jsonEncode(itemsJson));
  }

  static Future<List<StockItem>> getStockItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = prefs.getString(_key);
    if (itemsJson == null) return [];

    final List<dynamic> decodedItems = jsonDecode(itemsJson);
    return decodedItems.map((item) => StockItem.fromMap(item)).toList();
  }

  static Future<void> addStockItem(StockItem item) async {
    final items = await getStockItems();
    items.add(item);
    await saveStockItems(items);
  }

  static Future<void> updateStockItem(StockItem updatedItem) async {
    final items = await getStockItems();
    final index = items.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      items[index] = updatedItem;
      await saveStockItems(items);
    }
  }

  static Future<void> deleteStockItem(String id) async {
    final items = await getStockItems();
    items.removeWhere((item) => item.id == id);
    await saveStockItems(items);
  }

  static Future<List<StockItem>> getItemsByCategory(String categoryName) async {
    try {
      final allItems = await getStockItems();
      return allItems.where((item) => item.category == categoryName).toList();
    } catch (e) {
      print('Error getting items by category: $e');
      return [];
    }
  }
}
