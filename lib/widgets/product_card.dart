import 'package:flutter/material.dart';
import '../models/product.dart';
import '../providers/sales_provider.dart';

class ProductCard extends StatelessWidget {
  final DairyProduct product;
  final SalesProvider provider;

  const ProductCard({
    super.key,
    required this.product,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final isVendor = provider.isVendorMode;
    final selectedVendor = isVendor ? provider.selectedVendor : null;
    final unitPrice = product.getPrice(isVendor, selectedVendor);
    final subtotal = product.getSubtotal(isVendor, selectedVendor);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: product.quantity > 0
                ? product.themeColor.withValues(alpha: 0.16)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: product.quantity > 0 ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: product.quantity > 0
              ? product.themeColor.withValues(alpha: 0.5)
              : Colors.grey.shade200,
          width: product.quantity > 0 ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Column(
          children: [
            Row(
              children: [
                // Product Image Container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade200, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/product_thumb.png',
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Product Title & Price
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D2D44),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: isVendor ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              (isVendor && product.id == 'requeson')
                                  ? '2 x \$1.15 (\$${unitPrice.toStringAsFixed(2)} c/u)'
                                  : '\$${unitPrice.toStringAsFixed(2)} c/u',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isVendor ? const Color(0xFFE65100) : const Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                          if (isVendor) ...[
                            const SizedBox(width: 4),
                            Text(
                              '(\$${product.clientPrice.toStringAsFixed(2)})',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade500,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Subtotal Badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Subtotal',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    Text(
                      '\$${subtotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: product.quantity > 0 ? const Color(0xFF023047) : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Stepper and Quick Action Buttons Row
            Row(
              children: [
                // Quick Increment Chips (+1, +5, +10)
                Wrap(
                  spacing: 4,
                  children: [1, 5, 10].map((addVal) {
                    return InkWell(
                      onTap: () => provider.incrementQuantity(product.id, addVal),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          '+$addVal',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const Spacer(),

                // Stepper Counter Controls
                Container(
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Minus Button
                      IconButton(
                        onPressed: product.quantity > 0
                            ? () => provider.decrementQuantity(product.id)
                            : null,
                        icon: const Icon(Icons.remove_rounded),
                        color: Colors.redAccent,
                        iconSize: 18,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: EdgeInsets.zero,
                      ),

                      // Quantity Display & Direct Editing
                      GestureDetector(
                        onTap: () => _showDirectQuantityDialog(context),
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 38),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            '${product.quantity}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1D2D44),
                            ),
                          ),
                        ),
                      ),

                      // Plus Button
                      IconButton(
                        onPressed: () => provider.incrementQuantity(product.id),
                        icon: const Icon(Icons.add_rounded),
                        color: const Color(0xFF2E7D32),
                        iconSize: 18,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDirectQuantityDialog(BuildContext context) {
    final controller = TextEditingController(text: product.quantity == 0 ? '' : '${product.quantity}');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cantidad - ${product.name}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Número de unidades',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final newQty = int.tryParse(controller.text.trim()) ?? 0;
              provider.setQuantity(product.id, newQty);
              Navigator.of(ctx).pop();
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}
