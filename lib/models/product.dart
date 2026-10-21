import 'package:flutter/material.dart';
import 'vendor.dart';

class DairyProduct {
  final String id;
  final String name;
  final String description;
  double clientPrice;
  double vendorPrice;
  int quantity;
  final IconData icon;
  final Color themeColor;

  DairyProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.clientPrice,
    required this.vendorPrice,
    this.quantity = 0,
    required this.icon,
    required this.themeColor,
  });

  double getPrice(bool isVendorMode, [Vendor? selectedVendor]) {
    if (!isVendorMode) return clientPrice;
    if (selectedVendor != null && selectedVendor.hasCustomPrices) {
      final custom = selectedVendor.getCustomPrice(id);
      if (custom != null) return custom;
    }
    return vendorPrice;
  }

  double getSubtotal(bool isVendorMode, [Vendor? selectedVendor]) {
    final effectivePrice = getPrice(isVendorMode, selectedVendor);

    if (isVendorMode && id == 'requeson') {
      // 2 por $1.15 (o según el precio por unidad/pareja asignado al vendedor)
      final pairPrice = (effectivePrice == 0.575 || effectivePrice == 0.57 || effectivePrice == 0.58)
          ? 1.15
          : (effectivePrice > 0.60 ? effectivePrice : effectivePrice * 2);
      final singlePrice = pairPrice / 2.0;

      int pairs = quantity ~/ 2;
      int remainder = quantity % 2;
      return (pairs * pairPrice) + (remainder * singlePrice);
    }
    return quantity * effectivePrice;
  }

  DairyProduct copyWith({
    String? id,
    String? name,
    String? description,
    double? clientPrice,
    double? vendorPrice,
    int? quantity,
    IconData? icon,
    Color? themeColor,
  }) {
    return DairyProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      clientPrice: clientPrice ?? this.clientPrice,
      vendorPrice: vendorPrice ?? this.vendorPrice,
      quantity: quantity ?? this.quantity,
      icon: icon ?? this.icon,
      themeColor: themeColor ?? this.themeColor,
    );
  }
}
