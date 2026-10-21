import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';
import '../models/sale_record.dart';
import '../models/vendor.dart';

enum SaleMode { cliente, vendedor }

class SalesProvider extends ChangeNotifier {
  SaleMode _mode = SaleMode.cliente;
  double _cashReceived = 0.0;
  bool _isLoading = true;

  late List<DairyProduct> _products;
  List<Vendor> _vendors = [];
  Vendor? _selectedVendor;
  List<SaleRecord> _salesHistory = [];

  SalesProvider() {
    _initProducts();
    _loadInitialData();
  }

  bool get isLoading => _isLoading;
  SaleMode get mode => _mode;
  bool get isVendorMode => _mode == SaleMode.vendedor;
  double get cashReceived => _cashReceived;
  List<DairyProduct> get products => List.unmodifiable(_products);
  List<Vendor> get vendors => List.unmodifiable(_vendors);
  Vendor? get selectedVendor => _selectedVendor;
  List<SaleRecord> get salesHistory => List.unmodifiable(_salesHistory);

  static final List<DairyProduct> _defaultProducts = [
    DairyProduct(
      id: 'queso_pequeno',
      name: 'Queso Pequeño',
      description: 'Bloque pequeño / Marqueta chica',
      clientPrice: 2.75,
      vendorPrice: 2.25,
      icon: Icons.square_outlined,
      themeColor: const Color(0xFFFFB703),
    ),
    DairyProduct(
      id: 'queso_grande',
      name: 'Queso Grande',
      description: 'Bloque grande / Marqueta entera',
      clientPrice: 5.50,
      vendorPrice: 4.75,
      icon: Icons.grid_view_rounded,
      themeColor: const Color(0xFFFB8500),
    ),
    DairyProduct(
      id: 'crema',
      name: 'Crema',
      description: 'Bolsa / Libra de crema fresca',
      clientPrice: 1.50,
      vendorPrice: 1.25,
      icon: Icons.water_drop_rounded,
      themeColor: const Color(0xFF8ECAE6),
    ),
    DairyProduct(
      id: 'requeson',
      name: 'Requesón',
      description: 'Bolsa / Libra (2 x \$1.15 Vendedores)',
      clientPrice: 1.00,
      vendorPrice: 0.575,
      icon: Icons.egg_alt_rounded,
      themeColor: const Color(0xFF023047),
    ),
    DairyProduct(
      id: 'cuajada',
      name: 'Cuajada',
      description: 'Unidad de cuajada fresca',
      clientPrice: 1.25,
      vendorPrice: 1.00,
      icon: Icons.circle_outlined,
      themeColor: const Color(0xFF219EBC),
    ),
  ];

  static final List<Vendor> _defaultVendors = [
    Vendor(id: 'v1', name: 'Juan Pérez'),
    Vendor(id: 'v2', name: 'María Gómez'),
    Vendor(id: 'v3', name: 'Carlos López'),
  ];

  void _initProducts() {
    _products = _defaultProducts.map((p) => p.copyWith()).toList();
  }

  // Cargar datos iniciales desde SharedPreferences
  Future<void> _loadInitialData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Precios guardados
      for (var product in _products) {
        final clientKey = 'price_client_${product.id}';
        final vendorKey = 'price_vendor_${product.id}';

        if (prefs.containsKey(clientKey)) {
          product.clientPrice = prefs.getDouble(clientKey) ?? product.clientPrice;
        }
        if (prefs.containsKey(vendorKey)) {
          product.vendorPrice = prefs.getDouble(vendorKey) ?? product.vendorPrice;
        }
      }

      // 2. Vendedores guardados
      final savedVendorsJson = prefs.getString('saved_vendors');
      if (savedVendorsJson != null && savedVendorsJson.isNotEmpty) {
        _vendors = Vendor.decode(savedVendorsJson);
      } else {
        _vendors = List.from(_defaultVendors);
        await _saveVendorsToPrefs();
      }

      if (_vendors.isNotEmpty) {
        _selectedVendor = _vendors.first;
      }

      // 3. Historial de ventas guardado
      final savedSalesJson = prefs.getString('saved_sales_history');
      if (savedSalesJson != null && savedSalesJson.isNotEmpty) {
        _salesHistory = SaleRecord.decode(savedSalesJson);
      }
    } catch (e) {
      debugPrint('Error al cargar datos iniciales: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveVendorsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_vendors', Vendor.encode(_vendors));
  }

  Future<void> _saveSalesHistoryToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_sales_history', SaleRecord.encode(_salesHistory));
  }

  // Selección y adición de Vendedores
  void selectVendor(Vendor vendor) {
    _selectedVendor = vendor;
    notifyListeners();
  }

  Future<void> addVendor(String name) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return;

    final newVendor = Vendor(
      id: 'v_${DateTime.now().millisecondsSinceEpoch}',
      name: cleanName,
    );
    _vendors.add(newVendor);
    _selectedVendor = newVendor;

    await _saveVendorsToPrefs();
    notifyListeners();
  }

  Future<void> deleteVendor(String vendorId) async {
    _vendors.removeWhere((v) => v.id == vendorId);
    if (_selectedVendor?.id == vendorId) {
      _selectedVendor = _vendors.isNotEmpty ? _vendors.first : null;
    }
    await _saveVendorsToPrefs();
    notifyListeners();
  }

  // Guardar la venta actual en el historial
  Future<bool> saveCurrentSale({bool? isPaidStatus}) async {
    if (totalAmount <= 0) return false;

    final vendorParam = isVendorMode ? _selectedVendor : null;

    final selectedItems = _products
        .where((p) => p.quantity > 0)
        .map((p) => SaleItemRecord(
              productName: p.name,
              quantity: p.quantity,
              unitPrice: p.getPrice(isVendorMode, vendorParam),
              subtotal: p.getSubtotal(isVendorMode, vendorParam),
            ))
        .toList();

    if (selectedItems.isEmpty) return false;

    final isPaidValue = isPaidStatus ?? (isPaidInFull || _cashReceived >= totalAmount);

    final record = SaleRecord(
      id: 'sale_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      vendorName: isVendorMode
          ? (_selectedVendor?.name ?? 'Vendedor General')
          : 'Cliente General',
      mode: isVendorMode ? 'Vendedor' : 'Cliente',
      items: selectedItems,
      totalAmount: totalAmount,
      cashReceived: _cashReceived,
      changeAmount: changeAmount,
      isPaid: isPaidValue,
    );

    _salesHistory.insert(0, record); // La venta más reciente va primero
    await _saveSalesHistoryToPrefs();

    resetSale();
    return true;
  }

  Future<void> toggleSalePaymentStatus(String recordId) async {
    final index = _salesHistory.indexWhere((s) => s.id == recordId);
    if (index != -1) {
      _salesHistory[index].isPaid = !_salesHistory[index].isPaid;
      await _saveSalesHistoryToPrefs();
      notifyListeners();
    }
  }

  Future<void> deleteSaleRecord(String recordId) async {
    _salesHistory.removeWhere((s) => s.id == recordId);
    await _saveSalesHistoryToPrefs();
    notifyListeners();
  }

  Future<void> clearSalesHistory() async {
    _salesHistory.clear();
    await _saveSalesHistoryToPrefs();
    notifyListeners();
  }

  List<SaleRecord> getSalesForVendor(String vendorName) {
    return _salesHistory.where((s) => s.vendorName == vendorName).toList();
  }

  double getTotalSalesForVendor(String vendorName) {
    double sum = 0.0;
    for (var sale in getSalesForVendor(vendorName)) {
      sum += sale.totalAmount;
    }
    return sum;
  }

  // Alternar entre modo Cliente y Vendedor
  void setMode(SaleMode newMode) {
    if (_mode != newMode) {
      _mode = newMode;
      notifyListeners();
    }
  }

  void toggleMode() {
    _mode = _mode == SaleMode.cliente ? SaleMode.vendedor : SaleMode.cliente;
    notifyListeners();
  }

  // Cambiar cantidad de un producto
  void setQuantity(String productId, int quantity) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _products[index].quantity = quantity < 0 ? 0 : quantity;
      notifyListeners();
    }
  }

  void incrementQuantity(String productId, [int amount = 1]) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _products[index].quantity += amount;
      notifyListeners();
    }
  }

  void decrementQuantity(String productId, [int amount = 1]) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final current = _products[index].quantity;
      _products[index].quantity = (current - amount) < 0 ? 0 : (current - amount);
      notifyListeners();
    }
  }

  // Actualizar dinero recibido
  void setCashReceived(double amount) {
    _cashReceived = amount < 0 ? 0.0 : amount;
    notifyListeners();
  }

  void addCashReceived(double amount) {
    _cashReceived += amount;
    notifyListeners();
  }

  // Reiniciar la venta actual
  void resetSale() {
    for (var product in _products) {
      product.quantity = 0;
    }
    _cashReceived = 0.0;
    notifyListeners();
  }

  // Guardar nuevos precios configurados
  Future<void> updatePrices(Map<String, Map<String, double>> newPrices) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (var product in _products) {
        if (newPrices.containsKey(product.id)) {
          final prices = newPrices[product.id]!;
          if (prices.containsKey('client')) {
            product.clientPrice = prices['client']!;
            await prefs.setDouble('price_client_${product.id}', product.clientPrice);
          }
          if (prices.containsKey('vendor')) {
            product.vendorPrice = prices['vendor']!;
            await prefs.setDouble('price_vendor_${product.id}', product.vendorPrice);
          }
        }
      }
    } catch (e) {
      debugPrint('Error al guardar precios: $e');
    }
    notifyListeners();
  }

  // Restablecer precios a valores iniciales por defecto
  Future<void> resetPricesToDefaults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (var defaultProduct in _defaultProducts) {
        final index = _products.indexWhere((p) => p.id == defaultProduct.id);
        if (index != -1) {
          _products[index].clientPrice = defaultProduct.clientPrice;
          _products[index].vendorPrice = defaultProduct.vendorPrice;

          await prefs.remove('price_client_${defaultProduct.id}');
          await prefs.remove('price_vendor_${defaultProduct.id}');
        }
      }
    } catch (e) {
      debugPrint('Error al restablecer precios: $e');
    }
    notifyListeners();
  }

  // Actualizar precios personalizados de un vendedor específico
  Future<void> updateVendorCustomPrices(String vendorId, Map<String, double>? customPrices) async {
    final index = _vendors.indexWhere((v) => v.id == vendorId);
    if (index != -1) {
      _vendors[index].customPrices = (customPrices == null || customPrices.isEmpty) ? null : customPrices;
      if (_selectedVendor?.id == vendorId) {
        _selectedVendor = _vendors[index];
      }
      await _saveVendorsToPrefs();
      notifyListeners();
    }
  }

  // Cálculos generales
  double get totalAmount {
    double total = 0.0;
    final vendorParam = isVendorMode ? _selectedVendor : null;
    for (var product in _products) {
      total += product.getSubtotal(isVendorMode, vendorParam);
    }
    return total;
  }

  int get totalItems {
    int count = 0;
    for (var product in _products) {
      count += product.quantity;
    }
    return count;
  }

  double get changeAmount {
    if (_cashReceived >= totalAmount) {
      return _cashReceived - totalAmount;
    }
    return 0.0;
  }

  double get remainingAmount {
    if (totalAmount > _cashReceived) {
      return totalAmount - _cashReceived;
    }
    return 0.0;
  }

  bool get isPaidInFull {
    return _cashReceived >= totalAmount && totalAmount > 0;
  }
}
