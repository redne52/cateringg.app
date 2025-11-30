import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:html' as html;
import '../models/stock_item.dart';
import '../models/usage.dart';

class LocalRepo {
  LocalRepo._privateConstructor() {
    _loadFromLocalStorage();
  }
  static final LocalRepo instance = LocalRepo._privateConstructor();

  final Map<String, String> admins = {
    'admin@catering.com': 'admin123',
  };

  final List<StockItem> _stockItems = [];
  final List<Usage> _usages = [];

  // localStorage keys
  static const String _stockItemsKey = 'catering_stock_items';
  static const String _usagesKey = 'catering_usages';

  List<StockItem> getStockItems() => List.unmodifiable(_stockItems);
  List<Usage> getUsages() => List.unmodifiable(_usages);

  void addStockItem(StockItem item) {
    _stockItems.add(item);
    _saveToLocalStorage();
  }

  void updateStockItem(StockItem item) {
    final idx = _stockItems.indexWhere((e) => e.id == item.id);
    if (idx != -1) _stockItems[idx] = item;
    _saveToLocalStorage();
  }

  void removeStockItem(String id) {
    _stockItems.removeWhere((e) => e.id == id);
    _saveToLocalStorage();
  }

  void addUsage(Usage usage) {
    // decrement stock quantity if item exists
    final item = _stockItems.firstWhere((e) => e.id == usage.stockItemId, orElse: () => StockItem.empty());
    if (!item.isEmpty) {
      item.quantity = (item.quantity - usage.quantity).clamp(0.0, double.infinity);
    }
    _usages.add(usage);
    _saveToLocalStorage();
  }

  bool authenticate(String email, String password) {
    return admins[email] == password;
  }

  // localStorage kaydetme ve yükleme
  void _saveToLocalStorage() {
    if (kIsWeb) {
      try {
        final stockJson = jsonEncode(_stockItems.map((e) => e.toMap()).toList());
        final usageJson = jsonEncode(_usages.map((e) => e.toMap()).toList());
        
        html.window.localStorage[_stockItemsKey] = stockJson;
        html.window.localStorage[_usagesKey] = usageJson;
        
        print('✓ localStorage saved: ${_stockItems.length} stocks, ${_usages.length} usages');
      } catch (e, st) {
        print('✗ localStorage save error: $e');
        print('  StackTrace: $st');
      }
    }
  }

  void _loadFromLocalStorage() {
    if (kIsWeb) {
      try {
        final stockJson = html.window.localStorage[_stockItemsKey];
        final usageJson = html.window.localStorage[_usagesKey];

        print('Loading from localStorage...');
        print('  Stock data exists: ${stockJson != null && stockJson.isNotEmpty}');
        print('  Usage data exists: ${usageJson != null && usageJson.isNotEmpty}');

        if (stockJson != null && stockJson.isNotEmpty) {
          final List<dynamic> decoded = jsonDecode(stockJson);
          _stockItems.addAll(decoded.map((item) => StockItem.fromMap(item as Map<String, dynamic>)));
          print('  ✓ Loaded ${_stockItems.length} stock items');
        }

        if (usageJson != null && usageJson.isNotEmpty) {
          final List<dynamic> decoded = jsonDecode(usageJson);
          _usages.addAll(decoded.map((usage) => Usage.fromMap(usage as Map<String, dynamic>)));
          print('  ✓ Loaded ${_usages.length} usages');
        }
      } catch (e, st) {
        print('✗ localStorage load error: $e');
        print('  StackTrace: $st');
      }
    }
  }
}
