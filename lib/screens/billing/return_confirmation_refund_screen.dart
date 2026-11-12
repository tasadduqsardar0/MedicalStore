import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../data/models/sale_model.dart';
import '../../providers/billing_provider.dart';
import '../../providers/inventory_provider.dart';

class ReturnConfirmationRefundScreen extends StatefulWidget {
  final Map<String, dynamic> returnData;

  const ReturnConfirmationRefundScreen({super.key, required this.returnData});

  @override
  State<ReturnConfirmationRefundScreen> createState() => _ReturnConfirmationRefundScreenState();
}

class _ReturnConfirmationRefundScreenState extends State<ReturnConfirmationRefundScreen> {
  String _refundMethod = 'Cash Refund';
  bool _restockItems = true;

  void _finalizeReturn() {
    final billing = Provider.of<BillingProvider>(context, listen: false);
    final inventory = Provider.of<InventoryProvider>(context, listen: false);

    billing.processReturn(
      invoiceNumber: widget.returnData['invoiceNumber'] as String,
      customerName: widget.returnData['customerName'] as String,
      items: widget.returnData['items'] as List<SaleReturnItem>,
      totalRefund: widget.returnData['totalRefund'] as double,
      reason: widget.returnData['reason'] as String,
      refundMethod: _refundMethod,
      inventoryProvider: inventory,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: 8),
            Text('Refund Processed'),
          ],
        ),
        content: Text(
          'Refund of ${AppFormatters.currency(widget.returnData['totalRefund'] as double)} processed via $_refundMethod. Returned stock has been restored to sellable inventory.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
            },
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final invoiceNumber = widget.returnData['invoiceNumber'] as String;
    final customerName = widget.returnData['customerName'] as String;
    final items = widget.returnData['items'] as List<SaleReturnItem>;
    final totalRefund = widget.returnData['totalRefund'] as double;
    final reason = widget.returnData['reason'] as String;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Confirm Return & Refund'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Original Invoice: $invoiceNumber', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('Customer: $customerName', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      Text('Reason: $reason', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const Divider(height: 20),

                      const Text('Items Returned:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      ...items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${item.returnQuantity}x ${item.medicineName} (${item.isLoose ? "Loose" : "Pack"})'),
                              Text(AppFormatters.currency(item.refundAmount), style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        );
                      }),
                      const Divider(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Refund Payable:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          Text(
                            AppFormatters.currency(totalRefund),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.danger),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Refund Options Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Refund Method', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      RadioGroup<String>(
                        groupValue: _refundMethod,
                        onChanged: (val) {
                          if (val != null) setState(() => _refundMethod = val);
                        },
                        child: const Column(
                          children: [
                            RadioListTile<String>(
                              title: Text('Cash Refund (Give cash back)'),
                              value: 'Cash Refund',
                            ),
                            RadioListTile<String>(
                              title: Text('Medicine Replacement / Exchange'),
                              value: 'Medicine Replacement',
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('Restock Returned Items'),
                        subtitle: const Text('Return non-damaged medicines to shelf stock'),
                        value: _restockItems,
                        onChanged: (val) => setState(() => _restockItems = val),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: _finalizeReturn,
                child: const Text('Confirm Return & Issue Refund Slip'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

