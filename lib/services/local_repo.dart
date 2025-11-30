import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/stock_item.dart';
import '../models/usage.dart';

// Web platform için localStorage erişimi
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;

class LocalRepo {
  LocalRepo._privateConstructor() {
    _loadFromLocalStorage();
  }
  static final LocalRepo instance = LocalRepo._privateConstructor();

  final Map<String, String> admins = {
    'admin@catering.com': 'admin123',
  };

  final List<StockItem> _stockItems = [];
  List<Usage> usages = [];

  // localStorage keys
  static const String _stockItemsKey = 'catering_stock_items';
  static const String _usagesKey = 'catering_usages';

  List<StockItem> getStockItems() => List.unmodifiable(_stockItems);
  List<Usage> getUsages() => List.unmodifiable(usages);

  void addStockItem(StockItem item) {
    _stockItems.add(item);
    saveToLocalStorage();
  }

  void updateStockItem(StockItem item) {
    final idx = _stockItems.indexWhere((e) => e.id == item.id);
    if (idx != -1) _stockItems[idx] = item;
    saveToLocalStorage();
  }

  void removeStockItem(String id) {
    _stockItems.removeWhere((e) => e.id == id);
    saveToLocalStorage();
  }

  void addUsage(Usage usage) {
    final item = _stockItems.firstWhere((e) => e.id == usage.stockItemId, orElse: () => StockItem.empty());
    if (!item.isEmpty) {
      item.quantity = (item.quantity - usage.quantity).clamp(0.0, double.infinity);
    }
    usages.add(usage);
    saveToLocalStorage();
  }

  bool authenticate(String email, String password) {
    return admins[email] == password;
  }

  void saveToLocalStorage() {
    if (!kIsWeb) return;
    try {
      final stockJson = jsonEncode(_stockItems.map((e) => e.toMap()).toList());
      final usageJson = jsonEncode(usages.map((e) => e.toMap()).toList());
      html.window.localStorage[_stockItemsKey] = stockJson;
      html.window.localStorage[_usagesKey] = usageJson;
      print('✓ Saved to localStorage');
    } catch (e) {
      print('✗ Save error: $e');
    }
  }

  void _loadFromLocalStorage() {
    if (!kIsWeb) return;
    try {
      final stockJson = html.window.localStorage[_stockItemsKey];
      final usageJson = html.window.localStorage[_usagesKey];

      if (stockJson != null && stockJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(stockJson);
        _stockItems.addAll(decoded.map((item) => StockItem.fromMap(item as Map<String, dynamic>)));
      }

      if (usageJson != null && usageJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(usageJson);
        usages.addAll(decoded.map((usage) => Usage.fromMap(usage as Map<String, dynamic>)));
      }
      print('✓ Loaded from localStorage');
    } catch (e) {
      print('✗ Load error: $e');
    }
  }
}
}
