import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../providers/billing_provider.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final String saleId;

  const InvoiceDetailScreen({super.key, required this.saleId});

  @override
  Widget build(BuildContext context) {
    final billing = context.watch<BillingProvider>();
    final sale = billing.getSaleById(saleId);

    if (sale == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Invoice Details')),
        body: const Center(child: Text('Invoice not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(sale.invoiceNumber),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Print Thermal Receipt',
            onPressed: () {
              Navigator.pushNamed(context, '/receipt-preview', arguments: sale);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Header Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        sale.invoiceNumber,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          sale.paymentMethod.label,
                          style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Customer: ${sale.customerName}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text('Date: ${AppFormatters.dateTime(sale.date)}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  Text('Cashier / Staff: ${sale.staffName}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Items Table Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Purchased Items', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  ...sale.items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.medicineName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                Text(
                                  '${item.isLoose ? "Loose" : "Pack"} • ${item.quantity} x ${AppFormatters.currency(item.unitPrice)}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            AppFormatters.currency(item.lineTotal),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryDark),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      Text(AppFormatters.currency(sale.subtotal), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  if (sale.discount > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Discount:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        Text('- ${AppFormatters.currency(sale.discount)}', style: const TextStyle(fontSize: 13, color: AppColors.danger, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Net Total:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(
                        AppFormatters.currency(sale.netTotal),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Return action button
          ElevatedButton.icon(
            icon: const Icon(Icons.assignment_return_outlined, size: 18),
            label: const Text('Process Sales Return / Refund'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              Navigator.pushNamed(context, '/sales-return', arguments: sale);
            },
          ),
        ],
      ),
    );
  }
}

