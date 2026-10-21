import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sale_record.dart';
import '../providers/sales_provider.dart';

class SalesHistoryScreen extends StatefulWidget {
  final SalesProvider provider;

  const SalesHistoryScreen({super.key, required this.provider});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  String _selectedVendorFilter = 'TODOS';
  String _selectedStatusFilter = 'TODOS'; // 'TODOS', 'PAGADO', 'PENDIENTE'

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final allSales = provider.salesHistory;

    // Lista de vendedores para filtro
    final vendorNames = <String>{'TODOS'};
    for (var v in provider.vendors) {
      vendorNames.add(v.name);
    }
    for (var s in allSales) {
      vendorNames.add(s.vendorName);
    }

    // Filtrar por vendedor y estado de pago
    final filteredSales = allSales.where((s) {
      final matchesVendor = _selectedVendorFilter == 'TODOS' || s.vendorName == _selectedVendorFilter;
      final matchesStatus = _selectedStatusFilter == 'TODOS' ||
          (_selectedStatusFilter == 'PAGADO' && s.isPaid) ||
          (_selectedStatusFilter == 'PENDIENTE' && !s.isPaid);
      return matchesVendor && matchesStatus;
    }).toList();

    // Estadísticas financieras
    double totalRevenue = 0.0;
    double totalPaid = 0.0;
    double totalPending = 0.0;

    for (var s in filteredSales) {
      totalRevenue += s.totalAmount;
      if (s.isPaid) {
        totalPaid += s.totalAmount;
      } else {
        totalPending += s.totalAmount;
      }
    }

    final dateFormat = DateFormat('dd/MM/yyyy hh:mm a');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: const Text(
          'Historial de Ventas',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          if (allSales.isNotEmpty)
            IconButton(
              tooltip: 'Borrar Historial',
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
              onPressed: () => _confirmClearHistory(context, provider),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Header Bar
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vendor Dropdown Filter Row
                Row(
                  children: [
                    const Icon(Icons.filter_alt_rounded, color: Color(0xFF0284C7), size: 18),
                    const SizedBox(width: 6),
                    const Text(
                      'Vendedor:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: vendorNames.contains(_selectedVendorFilter) ? _selectedVendorFilter : 'TODOS',
                            isExpanded: true,
                            isDense: true,
                            icon: const Icon(Icons.arrow_drop_down_rounded),
                            style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 12),
                            items: vendorNames.map((name) {
                              return DropdownMenuItem<String>(
                                value: name,
                                child: Text(name == 'TODOS' ? '🌐 Todos los Vendedores' : '👤 $name'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedVendorFilter = val;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Status Chips Filter (Scrollable to prevent overflow on small screens)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const Text(
                        'Estado:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusFilterChip('TODOS', 'Todos'),
                      const SizedBox(width: 6),
                      _buildStatusFilterChip('PAGADO', '🟢 Pagados'),
                      const SizedBox(width: 6),
                      _buildStatusFilterChip('PENDIENTE', '🟠 Pendientes'),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Financial Summary Cards
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(child: _buildSummaryStatColumn('REGISTRADO', '\$${totalRevenue.toStringAsFixed(2)}', Colors.white)),
                      Container(width: 1, height: 28, color: Colors.white24),
                      Expanded(child: _buildSummaryStatColumn('PAGADO', '\$${totalPaid.toStringAsFixed(2)}', const Color(0xFF4ADE80))),
                      Container(width: 1, height: 28, color: Colors.white24),
                      Expanded(child: _buildSummaryStatColumn('PENDIENTE', '\$${totalPending.toStringAsFixed(2)}', const Color(0xFFFBBF24))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Sales List
          Expanded(
            child: filteredSales.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_rounded, size: 54, color: Colors.grey.shade400),
                        const SizedBox(height: 10),
                        Text(
                          'No hay ventas encontradas.',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Prueba cambiando el filtro de vendedor o estado de pago.',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: filteredSales.length,
                    itemBuilder: (context, index) {
                      final sale = filteredSales[index];
                      return _buildSaleRecordCard(context, sale, provider, dateFormat);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilterChip(String value, String label) {
    final isSelected = _selectedStatusFilter == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedStatusFilter = value;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0284C7) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryStatColumn(String title, String amount, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 9, color: Colors.white54, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            amount,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color),
          ),
        ),
      ],
    );
  }

  Widget _buildSaleRecordCard(
    BuildContext context,
    SaleRecord sale,
    SalesProvider provider,
    DateFormat dateFormat,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: sale.mode == 'Vendedor' ? const Color(0xFFFFE0B2) : const Color(0xFFE0F2FE),
          child: Icon(
            sale.mode == 'Vendedor' ? Icons.storefront_rounded : Icons.person_rounded,
            color: sale.mode == 'Vendedor' ? const Color(0xFFE65100) : const Color(0xFF0284C7),
            size: 16,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                sale.vendorName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '\$${sale.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F172A)),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                '${dateFormat.format(sale.timestamp)} • ${sale.items.length} prod.',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            // Payment Status Interactive Badge
            InkWell(
              onTap: () async {
                await provider.toggleSalePaymentStatus(sale.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        !sale.isPaid ? 'Estado cambiado a: PAGADO' : 'Estado cambiado a: PENDIENTE DE PAGO',
                      ),
                      duration: const Duration(seconds: 1),
                      backgroundColor: !sale.isPaid ? const Color(0xFF16A34A) : Colors.orange.shade800,
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: sale.isPaid
                      ? const Color(0xFF15803D).withValues(alpha: 0.15)
                      : const Color(0xFFB45309).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: sale.isPaid ? const Color(0xFF22C55E) : const Color(0xFFF59E0B),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      sale.isPaid ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                      size: 11,
                      color: sale.isPaid ? const Color(0xFF15803D) : const Color(0xFFB45309),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      sale.isPaid ? 'PAGADO' : 'PENDIENTE',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: sale.isPaid ? const Color(0xFF15803D) : const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 1),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Detalle de productos:',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    // Toggle Status Button inside Expansion
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: sale.isPaid ? const Color(0xFFB45309) : const Color(0xFF15803D),
                        side: BorderSide(color: sale.isPaid ? const Color(0xFFF59E0B) : const Color(0xFF22C55E)),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => provider.toggleSalePaymentStatus(sale.id),
                      icon: Icon(
                        sale.isPaid ? Icons.pending_actions_rounded : Icons.check_circle_rounded,
                        size: 13,
                      ),
                      label: Text(
                        sale.isPaid ? 'Marcar Pendiente' : 'Marcar Pagado',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ...sale.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.quantity}x ${item.productName}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '(\$${item.unitPrice.toStringAsFixed(2)} c/u)  \$${item.subtotal.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Paga: \$${sale.cashReceived.toStringAsFixed(2)} | Vuelto: \$${sale.changeAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      padding: EdgeInsets.zero,
                      onPressed: () => provider.deleteSaleRecord(sale.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearHistory(BuildContext context, SalesProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Borrar Historial'),
        content: const Text('¿Deseas eliminar permanentemente todo el historial de ventas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () {
              provider.clearSalesHistory();
              Navigator.of(ctx).pop();
            },
            child: const Text('Borrar Todo'),
          ),
        ],
      ),
    );
  }
}
