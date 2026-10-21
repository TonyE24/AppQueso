import 'package:flutter/material.dart';
import '../models/vendor.dart';
import '../providers/sales_provider.dart';

class EditVendorPricesDialog extends StatefulWidget {
  final Vendor vendor;
  final SalesProvider provider;

  const EditVendorPricesDialog({
    super.key,
    required this.vendor,
    required this.provider,
  });

  @override
  State<EditVendorPricesDialog> createState() => _EditVendorPricesDialogState();
}

class _EditVendorPricesDialogState extends State<EditVendorPricesDialog> {
  late Map<String, TextEditingController> _controllers;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controllers = {};

    for (var product in widget.provider.products) {
      final customPrice = widget.vendor.getCustomPrice(product.id);
      _controllers[product.id] = TextEditingController(
        text: customPrice != null ? customPrice.toStringAsFixed(2) : '',
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _saveVendorPrices() async {
    if (_formKey.currentState!.validate()) {
      Map<String, double> customPrices = {};

      for (var product in widget.provider.products) {
        final text = _controllers[product.id]!.text.trim();
        if (text.isNotEmpty) {
          final val = double.tryParse(text.replaceAll(',', '.'));
          if (val != null && val >= 0) {
            customPrices[product.id] = val;
          }
        }
      }

      await widget.provider.updateVendorCustomPrices(
        widget.vendor.id,
        customPrices.isEmpty ? null : customPrices,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    customPrices.isEmpty
                        ? 'Precios del vendedor "${widget.vendor.name}" restablecidos a estándar.'
                        : 'Precios especiales guardados para "${widget.vendor.name}".',
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFE65100),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _clearCustomPrices() async {
    await widget.provider.updateVendorCustomPrices(widget.vendor.id, null);
    if (mounted) {
      for (var controller in _controllers.values) {
        controller.clear();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Se eliminaron los precios especiales de "${widget.vendor.name}".',
          ),
          backgroundColor: Colors.orange.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = widget.provider.products;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 580),
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE0B2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.local_offer_rounded,
                            color: Color(0xFFE65100),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Precios Especiales',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                widget.vendor.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFE65100),
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: Color(0xFFB45309),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Recuerda poner un valor porque sino se ocuparan los que tiene por defecto!',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF78350F),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Product Custom Price List
              Expanded(
                child: ListView.separated(
                  itemCount: products.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final controller = _controllers[product.id]!;

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
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Estándar: \$${product.vendorPrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 105,
                            child: TextFormField(
                              controller: controller,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                prefixText: '\$ ',
                                labelText: 'Precio Esp.',
                                labelStyle: const TextStyle(fontSize: 11),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                isDense: true,
                              ),
                              validator: (value) {
                                if (value != null && value.trim().isNotEmpty) {
                                  final parsed = double.tryParse(
                                    value.replaceAll(',', '.'),
                                  );
                                  if (parsed == null || parsed < 0) {
                                    return 'Inválido';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              // Action Buttons
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.vendor.hasCustomPrices) ...[
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          side: const BorderSide(color: Colors.redAccent),
                        ),
                        onPressed: _clearCustomPrices,
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 16,
                        ),
                        label: const Text(
                          'Quitar Especiales',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 6),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE65100),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _saveVendorPrices,
                      icon: const Icon(Icons.save_rounded, size: 16),
                      label: const Text(
                        'Guardar',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
}
