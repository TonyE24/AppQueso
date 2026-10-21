import 'package:flutter/material.dart';
import '../models/product.dart';
import '../providers/sales_provider.dart';

class EditPricesDialog extends StatefulWidget {
  final SalesProvider provider;

  const EditPricesDialog({super.key, required this.provider});

  @override
  State<EditPricesDialog> createState() => _EditPricesDialogState();
}

class _EditPricesDialogState extends State<EditPricesDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Map<String, TextEditingController> _clientControllers;
  late Map<String, TextEditingController> _vendorControllers;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _clientControllers = {};
    _vendorControllers = {};

    for (var product in widget.provider.products) {
      _clientControllers[product.id] = TextEditingController(
        text: product.clientPrice.toStringAsFixed(2),
      );
      _vendorControllers[product.id] = TextEditingController(
        text: product.vendorPrice.toStringAsFixed(2),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var controller in _clientControllers.values) {
      controller.dispose();
    }
    for (var controller in _vendorControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _savePrices() async {
    if (_formKey.currentState!.validate()) {
      Map<String, Map<String, double>> newPrices = {};

      for (var product in widget.provider.products) {
        final clientVal = double.tryParse(_clientControllers[product.id]!.text.replaceAll(',', '.')) ?? product.clientPrice;
        final vendorVal = double.tryParse(_vendorControllers[product.id]!.text.replaceAll(',', '.')) ?? product.vendorPrice;

        newPrices[product.id] = {
          'client': clientVal,
          'vendor': vendorVal,
        };
      }

      await widget.provider.updatePrices(newPrices);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Expanded(child: Text('Precios guardados correctamente.')),
              ],
            ),
            backgroundColor: Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _restoreDefaults() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restablecer Precios'),
        content: const Text('¿Estás seguro de restablecer todos los precios a sus valores predeterminados?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Restablecer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await widget.provider.resetPricesToDefaults();

      for (var product in widget.provider.products) {
        _clientControllers[product.id]?.text = product.clientPrice.toStringAsFixed(2);
        _vendorControllers[product.id]?.text = product.vendorPrice.toStringAsFixed(2);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Precios restablecidos a los valores por defecto.'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 620),
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header title row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.edit_note_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Editar Precios',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // TabBar for Clientes / Vendedores
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey.shade700,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  tabs: const [
                    Tab(text: 'Clientes'),
                    Tab(text: 'Vendedores'),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Scrollable Price List Forms
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPriceList(widget.provider.products, _clientControllers, isVendor: false),
                    _buildPriceList(widget.provider.products, _vendorControllers, isVendor: true),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Action buttons with Wrap to prevent overflow on mobile screens
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        side: const BorderSide(color: Colors.redAccent),
                      ),
                      onPressed: _restoreDefaults,
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Restablecer', style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar', style: TextStyle(fontSize: 13)),
                    ),
                    const SizedBox(width: 6),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _savePrices,
                      icon: const Icon(Icons.save_rounded, size: 16),
                      label: const Text('Guardar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceList(List<DairyProduct> products, Map<String, TextEditingController> controllers, {required bool isVendor}) {
    return ListView.separated(
      itemCount: products.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final product = products[index];
        final controller = controllers[product.id]!;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Image.asset(
                    'assets/images/product_thumb.png',
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      product.description,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 95,
                child: TextFormField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    prefixText: '\$ ',
                    labelText: isVendor ? 'P. Vend.' : 'P. Cli.',
                    labelStyle: const TextStyle(fontSize: 11),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    isDense: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Requerido';
                    }
                    final parsed = double.tryParse(value.replaceAll(',', '.'));
                    if (parsed == null || parsed < 0) {
                      return 'Inválido';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
