import 'package:uuid/uuid.dart';

class StockItem {
  String id;
  String name;
  String unit; // e.g., kg, lt, adet
  double unitPrice;
  double quantity;
  String supplier;
  String? code;

  StockItem({
    String? id,
    required this.name,
    required this.unit,
    required this.unitPrice,
    required this.quantity,
    required this.supplier,
    this.code,
  }) : id = id ?? Uuid().v4();

  StockItem.empty()
      : id = 'empty',
        name = '',
        unit = '',
        unitPrice = 0.0,
        quantity = 0.0,
        supplier = '',
        code = null;

  bool get isEmpty => id == 'empty';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'unit': unit,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'supplier': supplier,
      'code': code,
    };
  }

  static StockItem fromMap(Map<String, dynamic> map) {
    return StockItem(
      id: map['id'] as String?,
      name: map['name'] ?? '',
      unit: map['unit'] ?? '',
      unitPrice: (map['unitPrice'] is num) ? (map['unitPrice'] as num).toDouble() : double.tryParse(map['unitPrice'].toString()) ?? 0.0,
      quantity: (map['quantity'] is num) ? (map['quantity'] as num).toDouble() : double.tryParse(map['quantity'].toString()) ?? 0.0,
      supplier: map['supplier'] ?? '',
      code: map['code'],
    );
  }
}
