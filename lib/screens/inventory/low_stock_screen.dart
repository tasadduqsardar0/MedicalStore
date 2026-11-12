import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../widgets/alert_chip.dart';
import '../../widgets/empty_state.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/auth_provider.dart';

class LowStockScreen extends StatelessWidget {
  const LowStockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();
    final auth = context.watch<AuthProvider>();
    final isOwner = auth.isOwner;
    final lowStockItems = inventory.lowStockMedicines;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Low Stock Alerts'),
      ),
      body: lowStockItems.isEmpty
          ? const EmptyState(
              icon: Icons.check_circle_outline,
              title: 'Stock Levels are Healthy',
              message: 'No medicines are currently at or below their minimum stock thresholds.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: lowStockItems.length,
              itemBuilder: (context, index) {
                final med = lowStockItems[index];
                final sellableUnits = inventory.getSellableUnits(med.id);
                final status = inventory.getStockStatus(med);
                final stockText = inventory.getStockDisplayText(med);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    med.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  Text(
                                    med.genericName,
                                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                                  ),
                                  Text(
                                    '${med.company} • ${med.form.label}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                                  ),
                                ],
                              ),
                            ),
                            AlertChip.fromStatus(status),
                          ],
                        ),
                        const Divider(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Current Sellable Stock', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                const SizedBox(height: 2),
                                Text(
                                  stockText,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: sellableUnits == 0 ? AppColors.danger : AppColors.warning,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Minimum Required', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                const SizedBox(height: 2),
                                Text(
                                  '${med.minimumStockPacks} packs (${med.minimumStockPacks * med.unitsPerPack} units)',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (isOwner) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.add_shopping_cart, size: 16),
                              label: const Text('Create Purchase Order'),
                              onPressed: () {
                                Navigator.pushNamed(context, '/new-po');
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

