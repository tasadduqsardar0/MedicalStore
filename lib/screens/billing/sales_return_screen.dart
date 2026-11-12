import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../data/models/sale_model.dart';
import '../../providers/billing_provider.dart';

class SalesReturnScreen extends StatefulWidget {
  final Sale? preloadedSale;

  const SalesReturnScreen({super.key, this.preloadedSale});

  @override
  State<SalesReturnScreen> createState() => _SalesReturnScreenState();
}

class _SalesReturnScreenState extends State<SalesReturnScreen> {
  final _searchController = TextEditingController();
  Sale? _activeSale;
  final Map<int, int> _returnQuantities = {};
  String _returnReason = 'Customer Returned (Unused)';
  final List<String> _reasons = [
    'Customer Returned (Unused)',
    'Wrong Medicine Sold',
    'Customer Returned (Damaged)',
    'Doctor Changed Prescription',
    'Adverse Reaction Reported',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.preloadedSale != null) {
      _selectSale(widget.preloadedSale!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectSale(Sale sale) {
    setState(() {
      _activeSale = sale;
      _returnQuantities.clear();
      for (int i = 0; i < sale.items.length; i++) {
        _returnQuantities[i] = 0;
      }
    });
  }

  void _searchInvoice(String query) {
    if (query.trim().isEmpty) return;
    final billing = Provider.of<BillingProvider>(context, listen: false);
    final sale = billing.getSaleByInvoiceNumber(query.trim());
    if (sale != null) {
      _selectSale(sale);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice number not found'), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalRefundAmount = 0.0;
    if (_activeSale != null) {
      _returnQuantities.forEach((idx, qty) {
        if (idx < _activeSale!.items.length) {
          totalRefundAmount += _activeSale!.items[idx].unitPrice * qty;
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sales Return'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Lookup Bar
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Invoice Lookup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Enter Invoice No. (e.g. INV-1001)',
                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          onSubmitted: _searchInvoice,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _searchInvoice(_searchController.text),
                        child: const Text('Find'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (_activeSale != null) ...[
            // Sale Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_activeSale!.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(AppFormatters.date(_activeSale!.date), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Customer: ${_activeSale!.customerName}'),
                    Text('Total Billed: ${AppFormatters.currency(_activeSale!.netTotal)} (${_activeSale!.paymentMethod.label})'),
                    const Divider(height: 20),

                    const Text(
                      'Select Items and Quantity to Return:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 8),

                    ...List.generate(_activeSale!.items.length, (idx) {
                      final item = _activeSale!.items[idx];
                      final currentReturnQty = _returnQuantities[idx] ?? 0;

                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: AppColors.border)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.medicineName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text(
                                    'Sold: ${item.quantity} ${item.isLoose ? "loose" : "pack"} @ ${AppFormatters.currency(item.unitPrice)}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                                  onPressed: currentReturnQty > 0
                                      ? () => setState(() => _returnQuantities[idx] = currentReturnQty - 1)
                                      : null,
                                ),
                                Text('$currentReturnQty', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, size: 20),
                                  onPressed: currentReturnQty < item.quantity
                                      ? () => setState(() => _returnQuantities[idx] = currentReturnQty + 1)
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),

                    // Return Reason Dropdown
                    const Text('Reason for Return *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      key: ValueKey(_returnReason),
                      initialValue: _returnReason,
                      items: _reasons.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _returnReason = val);
                      },
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Calculated Refund:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        Text(
                          AppFormatters.currency(totalRefundAmount),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.danger),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: totalRefundAmount > 0
                          ? () {
                              final returnItems = <SaleReturnItem>[];
                              _returnQuantities.forEach((idx, qty) {
                                if (qty > 0) {
                                  final item = _activeSale!.items[idx];
                                  returnItems.add(
                                    SaleReturnItem(
                                      medicineId: item.medicineId,
                                      medicineName: item.medicineName,
                                      isLoose: item.isLoose,
                                      returnQuantity: qty,
                                      unitPrice: item.unitPrice,
                                      refundAmount: item.unitPrice * qty,
                                    ),
                                  );
                                }
                              });

                              Navigator.pushNamed(
                                context,
                                '/return-refund-confirmation',
                                arguments: {
                                  'invoiceNumber': _activeSale!.invoiceNumber,
                                  'customerName': _activeSale!.customerName,
                                  'items': returnItems,
                                  'totalRefund': totalRefundAmount,
                                  'reason': _returnReason,
                                },
                              );
                            }
                          : null,
                      child: const Text('Proceed to Refund Confirmation'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

