import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../core/role_guard.dart';
import '../../providers/inventory_provider.dart';

class ExpiryReportScreen extends StatelessWidget {
  const ExpiryReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Expiry Risk & Loss Report'),
        ),
        body: Consumer<InventoryProvider>(
          builder: (context, inventory, _) {
            final nearExpiryBatches = inventory.nearExpiryBatches;
            final expiredBatches = inventory.expiredBatches;

            double nearExpiryValuation = 0.0;
            double expiredLossValuation = 0.0;

            for (final b in nearExpiryBatches) {
              final med = inventory.getMedicineById(b.medicineId);
              final uPerPack = med?.unitsPerPack ?? 1;
              nearExpiryValuation += (b.quantityUnits / uPerPack) * b.purchasePrice;
            }

            for (final b in expiredBatches) {
              final med = inventory.getMedicineById(b.medicineId);
              final uPerPack = med?.unitsPerPack ?? 1;
              expiredLossValuation += (b.quantityUnits / uPerPack) * b.purchasePrice;
            }

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Near Expiry at Risk', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            const SizedBox(height: 6),
                            Text(
                              AppFormatters.currency(nearExpiryValuation),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.warning),
                            ),
                            const SizedBox(height: 2),
                            Text('${nearExpiryBatches.length} batches within 30 days', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Expired Stock Loss', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            const SizedBox(height: 6),
                            Text(
                              AppFormatters.currency(expiredLossValuation),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.danger),
                            ),
                            const SizedBox(height: 2),
                            Text('${expiredBatches.length} batches quarantined', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                const Text('Near Expiry Batches at Risk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),

                if (nearExpiryBatches.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: Text('No batches expiring in the next 30 days.')),
                    ),
                  )
                else
                  ...nearExpiryBatches.map((b) {
                    final med = inventory.getMedicineById(b.medicineId);
                    final uPerPack = med?.unitsPerPack ?? 1;
                    final cost = (b.quantityUnits / uPerPack) * b.purchasePrice;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.schedule, color: AppColors.warning),
                        title: Text(med?.name ?? 'Medicine', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text('Batch: ${b.batchNumber} • Expires: ${AppFormatters.date(b.expiryDate)}'),
                        trailing: Text(
                          AppFormatters.currency(cost),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.warning),
                        ),
                      ),
                    );
                  }),
              ],
            );
          },
        ),
      ),
    );
  }
}

