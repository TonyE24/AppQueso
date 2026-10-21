import 'package:flutter/material.dart';
import '../providers/sales_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/summary_sheet.dart';
import 'edit_prices_dialog.dart';
import 'manage_vendors_dialog.dart';
import 'sales_history_screen.dart';

class HomeScreen extends StatelessWidget {
  final SalesProvider provider;

  const HomeScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        final isVendor = provider.isVendorMode;
        final selectedVendor = provider.selectedVendor;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: isVendor
                ? const Color(0xFFE65100)
                : const Color(0xFF0284C7),
            elevation: 0,
            toolbarHeight: 50,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/app_logo.png',
                      width: 26,
                      height: 26,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Quesitos Kenia',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            actions: [
              // Sales History Button
              IconButton(
                tooltip: 'Historial de Ventas',
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => SalesHistoryScreen(provider: provider),
                    ),
                  );
                },
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.history_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 4),

              // Edit Prices Button
              IconButton(
                tooltip: 'Editar Precios',
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => EditPricesDialog(provider: provider),
                  );
                },
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.edit_note_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // Ultra-compact Mode Selector Header
                    Container(
                      color: isVendor
                          ? const Color(0xFFE65100)
                          : const Color(0xFF0284C7),
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      child: Column(
                        children: [
                          Container(
                            height: 38,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                // CLIENTE Segment
                                Expanded(
                                  child: InkWell(
                                    onTap: () =>
                                        provider.setMode(SaleMode.cliente),
                                    borderRadius: BorderRadius.circular(9),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 180,
                                      ),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: !isVendor
                                            ? Colors.white
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(9),
                                        boxShadow: !isVendor
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.12),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : [],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.person_rounded,
                                            size: 15,
                                            color: !isVendor
                                                ? const Color(0xFF0284C7)
                                                : Colors.white70,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            'CLIENTES',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: !isVendor
                                                  ? const Color(0xFF0284C7)
                                                  : Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),

                                // VENDEDOR Segment
                                Expanded(
                                  child: InkWell(
                                    onTap: () =>
                                        provider.setMode(SaleMode.vendedor),
                                    borderRadius: BorderRadius.circular(9),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 180,
                                      ),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isVendor
                                            ? Colors.white
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(9),
                                        boxShadow: isVendor
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.12),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : [],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.storefront_rounded,
                                            size: 15,
                                            color: isVendor
                                                ? const Color(0xFFE65100)
                                                : Colors.white70,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            'VENDEDORES',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: isVendor
                                                  ? const Color(0xFFE65100)
                                                  : Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Active Vendor selection bar (when in VENDEDOR mode)
                          if (isVendor) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.person_pin_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Vendedor:',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => ManageVendorsDialog(
                                            provider: provider,
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                selectedVendor?.name ??
                                                    'Seleccionar...',
                                                style: const TextStyle(
                                                  color: Color(0xFFE65100),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (selectedVendor
                                                    ?.hasCustomPrices ==
                                                true) ...[
                                              const SizedBox(width: 4),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                      vertical: 1,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFFFF3E0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  border: Border.all(
                                                    color: const Color(
                                                      0xFFFB8500,
                                                    ),
                                                  ),
                                                ),
                                                child: const Text(
                                                  '⭐ Esp.',
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFFE65100),
                                                  ),
                                                ),
                                              ),
                                            ],
                                            const Icon(
                                              Icons.arrow_drop_down_rounded,
                                              color: Color(0xFFE65100),
                                              size: 18,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  IconButton(
                                    tooltip: 'Gestionar Vendedores',
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => ManageVendorsDialog(
                                          provider: provider,
                                        ),
                                      );
                                    },
                                    constraints: const BoxConstraints(
                                      minWidth: 28,
                                      minHeight: 28,
                                    ),
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.person_add_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Products List with maximum vertical space
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                        itemCount: provider.products.length,
                        itemBuilder: (context, index) {
                          final product = provider.products[index];
                          return ProductCard(
                            product: product,
                            provider: provider,
                          );
                        },
                      ),
                    ),

                    // Collapsible / Compact Bottom Total & Change Calculator Sheet
                    SummarySheet(provider: provider),
                  ],
                ),
        );
      },
    );
  }
}
