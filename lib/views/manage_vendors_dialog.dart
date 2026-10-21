import 'package:flutter/material.dart';
import '../models/vendor.dart';
import '../providers/sales_provider.dart';
import 'edit_vendor_prices_dialog.dart';

class ManageVendorsDialog extends StatefulWidget {
  final SalesProvider provider;

  const ManageVendorsDialog({super.key, required this.provider});

  @override
  State<ManageVendorsDialog> createState() => _ManageVendorsDialogState();
}

class _ManageVendorsDialogState extends State<ManageVendorsDialog> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addVendor() async {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      await widget.provider.addVendor(name);
      _nameController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vendedor "$name" agregado.'),
            backgroundColor: const Color(0xFF2E7D32),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _openEditVendorPrices(Vendor vendor) {
    showDialog(
      context: context,
      builder: (ctx) => EditVendorPricesDialog(
        vendor: vendor,
        provider: widget.provider,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 540),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Title Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.badge_outlined, color: Color(0xFFE65100), size: 22),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Gestionar Vendedores',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Form to add vendor
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Nombre del vendedor',
                      labelText: 'Nuevo Vendedor',
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                    onSubmitted: (_) => _addVendor(),
                  ),
                ),
                const SizedBox(width: 6),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE65100),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _addVendor,
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Agregar', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Text(
              'Vendedores Registrados:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 6),

            // List of registered vendors
            Expanded(
              child: provider.vendors.isEmpty
                  ? const Center(child: Text('No hay vendedores agregados.'))
                  : ListView.separated(
                      itemCount: provider.vendors.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final vendor = provider.vendors[index];
                        final isSelected = provider.selectedVendor?.id == vendor.id;
                        final hasCustom = vendor.hasCustomPrices;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: isSelected ? const Color(0xFFFFE0B2) : Colors.grey.shade200,
                            child: Icon(
                              Icons.person_rounded,
                              size: 18,
                              color: isSelected ? const Color(0xFFE65100) : Colors.grey.shade700,
                            ),
                          ),
                          title: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  vendor.name,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? const Color(0xFFE65100) : Colors.black87,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (hasCustom) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFE0B2),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFFFB703)),
                                  ),
                                  child: const Text(
                                    'Especiales',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFE65100),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          subtitle: isSelected
                              ? const Text('Seleccionado', style: TextStyle(fontSize: 11, color: Color(0xFFE65100)))
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Button to edit custom prices for this vendor
                              IconButton(
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                padding: EdgeInsets.zero,
                                tooltip: 'Precios Especiales',
                                icon: Icon(
                                  Icons.sell_outlined,
                                  color: hasCustom ? const Color(0xFFE65100) : Colors.grey.shade600,
                                  size: 19,
                                ),
                                onPressed: () => _openEditVendorPrices(vendor),
                              ),
                              const SizedBox(width: 4),
                              if (!isSelected)
                                TextButton(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: () {
                                    provider.selectVendor(vendor);
                                  },
                                  child: const Text('Elegir', style: TextStyle(fontSize: 12)),
                                ),
                              IconButton(
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                                onPressed: () => provider.deleteVendor(vendor.id),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
