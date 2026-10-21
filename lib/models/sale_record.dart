import 'dart:convert';

class SaleItemRecord {
  final String productName;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  SaleItemRecord({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  Map<String, dynamic> toJson() => {
    'productName': productName,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'subtotal': subtotal,
  };

  factory SaleItemRecord.fromJson(Map<String, dynamic> json) => SaleItemRecord(
    productName: json['productName'] as String,
    quantity: json['quantity'] as int,
    unitPrice: (json['unitPrice'] as num).toDouble(),
    subtotal: (json['subtotal'] as num).toDouble(),
  );
}

class SaleRecord {
  final String id;
  final DateTime timestamp;
  final String vendorName;
  final String mode; // 'Vendedor' o 'Cliente'
  final List<SaleItemRecord> items;
  final double totalAmount;
  final double cashReceived;
  final double changeAmount;
  bool isPaid;

  SaleRecord({
    required this.id,
    required this.timestamp,
    required this.vendorName,
    required this.mode,
    required this.items,
    required this.totalAmount,
    required this.cashReceived,
    required this.changeAmount,
    this.isPaid = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'vendorName': vendorName,
        'mode': mode,
        'items': items.map((item) => item.toJson()).toList(),
        'totalAmount': totalAmount,
        'cashReceived': cashReceived,
        'changeAmount': changeAmount,
        'isPaid': isPaid,
      };

  factory SaleRecord.fromJson(Map<String, dynamic> json) => SaleRecord(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        vendorName: json['vendorName'] as String,
        mode: json['mode'] as String,
        items: (json['items'] as List<dynamic>)
            .map((item) => SaleItemRecord.fromJson(item as Map<String, dynamic>))
            .toList(),
        totalAmount: (json['totalAmount'] as num).toDouble(),
        cashReceived: (json['cashReceived'] as num).toDouble(),
        changeAmount: (json['changeAmount'] as num).toDouble(),
        isPaid: json['isPaid'] as bool? ?? true,
      );

  static String encode(List<SaleRecord> sales) =>
      json.encode(sales.map<Map<String, dynamic>>((s) => s.toJson()).toList());

  static List<SaleRecord> decode(String salesJson) =>
      (json.decode(salesJson) as List<dynamic>)
          .map<SaleRecord>(
            (item) => SaleRecord.fromJson(item as Map<String, dynamic>),
          )
          .toList();
}
