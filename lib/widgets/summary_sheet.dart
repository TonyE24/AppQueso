import 'package:flutter/material.dart';
import '../providers/sales_provider.dart';

class SummarySheet extends StatefulWidget {
  final SalesProvider provider;

  const SummarySheet({super.key, required this.provider});

  @override
  State<SummarySheet> createState() => _SummarySheetState();
}

class _SummarySheetState extends State<SummarySheet> {
  late TextEditingController _cashController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _cashController = TextEditingController();
    _syncCashText();
  }

  @override
  void didUpdateWidget(covariant SummarySheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.provider.cashReceived == 0.0 &&
        _cashController.text.isNotEmpty &&
        double.tryParse(_cashController.text) != 0.0) {
      _cashController.clear();
    }
  }

  void _syncCashText() {
    if (widget.provider.cashReceived > 0) {
      _cashController.text = widget.provider.cashReceived.toStringAsFixed(2);
    } else {
      _cashController.clear();
    }
  }

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final total = provider.totalAmount;
    final cash = provider.cashReceived;
    final change = provider.changeAmount;
    final remaining = provider.remainingAmount;
    final isPaid = provider.isPaidInFull;

    return GestureDetector(
      onTap: !_isExpanded
          ? () {
              setState(() {
                _isExpanded = true;
              });
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.fastOutSlowIn,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A), // Slate Dark Palette
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle Bar and Toggle Indicator
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              if (!_isExpanded) ...[
                // --- COLLAPSED VIEW (Ultra compact bar) ---
                Row(
                  children: [
                    // Total & Item Count
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${provider.totalItems} items',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            children: [
                              const Text(
                                'TOTAL: ',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Quick Vuelto Badge (if cash entered) or Expand prompt
                    Expanded(
                      flex: 5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (cash > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isPaid
                                    ? const Color(
                                        0xFF15803D,
                                      ).withValues(alpha: 0.4)
                                    : const Color(
                                        0xFFB45309,
                                      ).withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isPaid
                                      ? const Color(0xFF22C55E)
                                      : const Color(0xFFF59E0B),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    isPaid ? 'Vuelto' : 'Falta',
                                    style: TextStyle(
                                      color: isPaid
                                          ? const Color(0xFF4ADE80)
                                          : const Color(0xFFFBBF24),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    isPaid
                                        ? '\$${change.toStringAsFixed(2)}'
                                        : '\$${remaining.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: isPaid
                                          ? const Color(0xFF4ADE80)
                                          : const Color(0xFFFBBF24),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(width: 8),

                          // Expand Button
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _isExpanded = true;
                              });
                            },
                            tooltip: 'Abrir Calculadora de Vuelto',
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.12,
                              ),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(6),
                            ),
                            icon: const Icon(
                              Icons.keyboard_arrow_up_rounded,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // --- EXPANDED VIEW (Full detailed payment calculator) ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calculate_outlined,
                          color: Colors.white70,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${provider.totalItems} productos selec.',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isExpanded = false;
                        });
                      },
                      tooltip: 'Minimizar',
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        foregroundColor: Colors.white70,
                        padding: const EdgeInsets.all(4),
                      ),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 22,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Total Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL A PAGAR:',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 10),

                // Cash Input
                Row(
                  children: [
                    const Expanded(
                      flex: 4,
                      child: Text(
                        'Paga con:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: TextField(
                        controller: _cashController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.end,
                        decoration: InputDecoration(
                          prefixIcon: const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              '\$',
                              style: TextStyle(
                                color: Color(0xFF4ADE80),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 0,
                            minHeight: 0,
                          ),
                          hintText: '0.00',
                          hintStyle: const TextStyle(color: Colors.white30),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.08),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        onChanged: (value) {
                          final val =
                              double.tryParse(value.replaceAll(',', '.')) ??
                              0.0;
                          provider.setCashReceived(val);
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Quick Cash Buttons ($5, $10, $20, $50, Exacto)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Exacto Chip
                      InkWell(
                        onTap: () {
                          provider.setCashReceived(total);
                          _cashController.text = total.toStringAsFixed(2);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF0284C7,
                            ).withValues(alpha: 0.25),
                            border: Border.all(color: const Color(0xFF0284C7)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Exacto',
                            style: TextStyle(
                              color: Color(0xFF38BDF8),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),

                      ...[5.0, 10.0, 20.0, 50.0].map((bill) {
                        return InkWell(
                          onTap: () {
                            provider.setCashReceived(bill);
                            _cashController.text = bill.toStringAsFixed(2);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              border: Border.all(color: Colors.white12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '\$${bill.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Vuelto Box
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isPaid
                        ? const Color(0xFF15803D).withValues(alpha: 0.25)
                        : (cash > 0
                              ? const Color(0xFFB45309).withValues(alpha: 0.25)
                              : Colors.white.withValues(alpha: 0.05)),
                    border: Border.all(
                      color: isPaid
                          ? const Color(0xFF22C55E)
                          : (cash > 0
                                ? const Color(0xFFF59E0B)
                                : Colors.white12),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isPaid
                                ? Icons.check_circle_rounded
                                : (cash > 0
                                      ? Icons.error_outline_rounded
                                      : Icons.payments_outlined),
                            color: isPaid
                                ? const Color(0xFF4ADE80)
                                : (cash > 0
                                      ? const Color(0xFFFBBF24)
                                      : Colors.white54),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isPaid
                                ? 'VUELTO:'
                                : (cash > 0 ? 'Faltante:' : 'Vuelto:'),
                            style: TextStyle(
                              color: isPaid
                                  ? const Color(0xFF4ADE80)
                                  : (cash > 0
                                        ? const Color(0xFFFBBF24)
                                        : Colors.white70),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        isPaid
                            ? '\$${change.toStringAsFixed(2)}'
                            : (cash > 0
                                  ? '\$${remaining.toStringAsFixed(2)}'
                                  : '\$0.00'),
                        style: TextStyle(
                          color: isPaid
                              ? const Color(0xFF4ADE80)
                              : (cash > 0
                                    ? const Color(0xFFFBBF24)
                                    : Colors.white),
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Action buttons row (Save Sale & Reset)
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent.shade100,
                          side: BorderSide(
                            color: Colors.redAccent.withValues(alpha: 0.4),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          provider.resetSale();
                          _cashController.clear();
                        },
                        icon: const Icon(
                          Icons.cleaning_services_rounded,
                          size: 16,
                        ),
                        label: const Text(
                          'Limpiar',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 6,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: total > 0
                              ? const Color(0xFF16A34A)
                              : Colors.grey.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: total > 0
                            ? () async {
                                final messenger = ScaffoldMessenger.of(context);
                                final success = await provider
                                    .saveCurrentSale();
                                if (success && mounted) {
                                  _cashController.clear();
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle_rounded,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Venta registrada en el historial correctamente.',
                                          ),
                                        ],
                                      ),
                                      backgroundColor: Color(0xFF16A34A),
                                      behavior: SnackBarBehavior.floating,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              }
                            : null,
                        icon: const Icon(Icons.save_rounded, size: 18),
                        label: const Text(
                          'Guardar Venta',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
