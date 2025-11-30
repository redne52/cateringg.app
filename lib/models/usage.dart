import 'package:uuid/uuid.dart';

class Usage {
  String id;
  DateTime date;
  String userEmail;
  String stockItemId;
  double quantity;
  int persons;
  double cost;

  Usage({
    String? id,
    required this.date,
    required this.userEmail,
    required this.stockItemId,
    required this.quantity,
    required this.persons,
    required this.cost,
  }) : id = id ?? Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'userEmail': userEmail,
      'stockItemId': stockItemId,
      'quantity': quantity,
      'persons': persons,
      'cost': cost,
    };
  }

  static Usage fromMap(Map<String, dynamic> map) {
    return Usage(
      id: map['id'] as String?,
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      userEmail: map['userEmail'] ?? '',
      stockItemId: map['stockItemId'] ?? '',
      quantity: (map['quantity'] is num) ? (map['quantity'] as num).toDouble() : double.tryParse(map['quantity'].toString()) ?? 0.0,
      persons: (map['persons'] is int) ? map['persons'] as int : int.tryParse(map['persons'].toString()) ?? 0,
      cost: (map['cost'] is num) ? (map['cost'] as num).toDouble() : double.tryParse(map['cost'].toString()) ?? 0.0,
    );
  }
}
