import 'dart:convert';

class Vendor {
  final String id;
  final String name;
  Map<String, double>? customPrices;

  Vendor({
    required this.id,
    required this.name,
    this.customPrices,
  });

  bool get hasCustomPrices => customPrices != null && customPrices!.isNotEmpty;

  double? getCustomPrice(String productId) {
    if (customPrices == null) return null;
    return customPrices![productId];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (customPrices != null)
          'customPrices': customPrices!.map((k, v) => MapEntry(k, v)),
      };

  factory Vendor.fromJson(Map<String, dynamic> json) => Vendor(
        id: json['id'] as String,
        name: json['name'] as String,
        customPrices: json['customPrices'] != null
            ? (json['customPrices'] as Map<String, dynamic>).map(
                (k, v) => MapEntry(k, (v as num).toDouble()),
              )
            : null,
      );

  static String encode(List<Vendor> vendors) => json.encode(
        vendors.map<Map<String, dynamic>>((v) => v.toJson()).toList(),
      );

  static List<Vendor> decode(String vendorsJson) =>
      (json.decode(vendorsJson) as List<dynamic>)
          .map<Vendor>((item) => Vendor.fromJson(item as Map<String, dynamic>))
          .toList();
}
