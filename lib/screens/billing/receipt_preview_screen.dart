import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../data/models/sale_model.dart';
import '../../providers/settings_provider.dart';

class ReceiptPreviewScreen extends StatelessWidget {
  final Sale sale;

  const ReceiptPreviewScreen({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Receipt (80 mm Preview)'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Print Receipt',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sent receipt to 80mm thermal printer'), backgroundColor: AppColors.success),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Receipt',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing digital receipt...')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Center(
                          child: Column(
                            children: [
                              Text(
                                settings.storeName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                settings.address,
                                style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.black87),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                'Tel: ${settings.phone}',
                                style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text('------------------------------------------------', style: TextStyle(fontFamily: 'monospace', color: Colors.black54), textAlign: TextAlign.center),
                        const SizedBox(height: 4),

                        // Invoice metadata
                        _ReceiptRow(label: 'Invoice No:', value: sale.invoiceNumber),
                        _ReceiptRow(label: 'Date & Time:', value: AppFormatters.dateTime(sale.date)),
                        _ReceiptRow(label: 'Customer:', value: sale.customerName),
                        _ReceiptRow(label: 'Served by:', value: sale.staffName),

                        const SizedBox(height: 4),
                        const Text('------------------------------------------------', style: TextStyle(fontFamily: 'monospace', color: Colors.black54), textAlign: TextAlign.center),
                        const SizedBox(height: 8),

                        // Table header
                        const Row(
                          children: [
                            Expanded(flex: 5, child: Text('Item / Form', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'monospace'))),
                            Expanded(flex: 2, child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'monospace'))),
                            Expanded(flex: 3, child: Text('Rate', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'monospace'))),
                            Expanded(flex: 3, child: Text('Total', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'monospace'))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text('................................................', style: TextStyle(fontFamily: 'monospace', color: Colors.black38), textAlign: TextAlign.center),
                        const SizedBox(height: 4),

                        // Items
                        ...sale.items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.medicineName,
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        item.isLoose ? 'Loose' : 'Pack',
                                        style: const TextStyle(fontSize: 9, color: Colors.black54, fontFamily: 'monospace'),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text('${item.quantity}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(item.unitPrice.toStringAsFixed(0), textAlign: TextAlign.right, style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(item.lineTotal.toStringAsFixed(0), textAlign: TextAlign.right, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                                ),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: 6),
                        const Text('------------------------------------------------', style: TextStyle(fontFamily: 'monospace', color: Colors.black54), textAlign: TextAlign.center),
                        const SizedBox(height: 6),

                        // Totals
                        _ReceiptRow(label: 'Subtotal:', value: AppFormatters.currency(sale.subtotal)),
                        if (sale.discount > 0)
                          _ReceiptRow(label: 'Discount:', value: '- ${AppFormatters.currency(sale.discount)}'),
                        const SizedBox(height: 4),
                        _ReceiptRow(
                          label: 'NET TOTAL:',
                          value: AppFormatters.currency(sale.netTotal),
                          isBold: true,
                          fontSize: 15,
                        ),
                        const SizedBox(height: 6),

                        _ReceiptRow(label: 'Payment Method:', value: sale.paymentMethod.label),
                        if (sale.paymentMethod == PaymentMethod.cash) ...[
                          _ReceiptRow(label: 'Cash Tendered:', value: AppFormatters.currency(sale.cashTendered)),
                          _ReceiptRow(label: 'Change Due:', value: AppFormatters.currency(sale.changeAmount), isBold: true),
                        ],

                        const SizedBox(height: 12),
                        const Text('------------------------------------------------', style: TextStyle(fontFamily: 'monospace', color: Colors.black54), textAlign: TextAlign.center),
                        const SizedBox(height: 10),

                        // Footer Note
                        Center(
                          child: Text(
                            settings.receiptFooter,
                            style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.black87),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Center(
                          child: Text(
                            'Thank you for visiting Tariq Medical Store!',
                            style: TextStyle(fontSize: 10, fontFamily: 'monospace', fontStyle: FontStyle.italic, color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
                      },
                      child: const Text('Back to Home'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add_shopping_cart, size: 18),
                      label: const Text('New Sale'),
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final double fontSize;

  const _ReceiptRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontFamily: 'monospace',
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontFamily: 'monospace',
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

