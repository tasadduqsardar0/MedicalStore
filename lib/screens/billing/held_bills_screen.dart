import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../widgets/empty_state.dart';
import '../../providers/billing_provider.dart';

class HeldBillsScreen extends StatelessWidget {
  const HeldBillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final billing = context.watch<BillingProvider>();
    final heldBills = billing.heldBills;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Held / Parked Bills'),
      ),
      body: heldBills.isEmpty
          ? const EmptyState(
              icon: Icons.pause_circle_outline,
              title: 'No Held Bills',
              message: 'Parked bills will appear here when you need to serve another customer in the queue.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: heldBills.length,
              itemBuilder: (context, index) {
                final bill = heldBills[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              bill.customerName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Text(
                              AppFormatters.time(bill.timestamp),
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${bill.items.length} items • ${bill.items.map((i) => i.medicineName).join(', ')}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Divider(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppFormatters.currency(bill.netTotal),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                            ),
                            Row(
                              children: [
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger)),
                                  onPressed: () => billing.removeHeldBill(bill.id),
                                  child: const Text('Delete'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    billing.restoreHeldBill(bill);
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Bill restored to active sale'), backgroundColor: AppColors.success),
                                    );
                                  },
                                  child: const Text('Resume Bill'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

