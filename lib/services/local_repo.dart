import 'package:flutter/foundation.dart';
import '../models/stock_item.dart';
import '../models/usage.dart';

class LocalRepo {
  LocalRepo._privateConstructor();
  static final LocalRepo instance = LocalRepo._privateConstructor();

  final Map<String, String> admins = {
    'admin@catering.com': 'admin123',
  };

  final List<StockItem> _stockItems = [];
  final List<Usage> _usages = [];

  List<StockItem> getStockItems() => List.unmodifiable(_stockItems);
  List<Usage> getUsages() => List.unmodifiable(_usages);

  void addStockItem(StockItem item) {
    _stockItems.add(item);
  }

  void updateStockItem(StockItem item) {
    final idx = _stockItems.indexWhere((e) => e.id == item.id);
    if (idx != -1) _stockItems[idx] = item;
  }

  void removeStockItem(String id) {
    _stockItems.removeWhere((e) => e.id == id);
  }

  void addUsage(Usage usage) {
    // decrement stock quantity if item exists
    final item = _stockItems.firstWhere((e) => e.id == usage.stockItemId, orElse: () => StockItem.empty());
    if (!item.isEmpty) {
      item.quantity = (item.quantity - usage.quantity).clamp(0.0, double.infinity);
    }
    _usages.add(usage);
  }

  bool authenticate(String email, String password) {
    return admins[email] == password;
  }
}
