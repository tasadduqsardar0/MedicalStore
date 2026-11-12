import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../core/role_guard.dart';
import '../../providers/inventory_provider.dart';

class StockReportScreen extends StatelessWidget {
  const StockReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Inventory Valuation Report'),
        ),
        body: Consumer<InventoryProvider>(
          builder: (context, inventory, _) {
            final medicines = inventory.allMedicines;
            final batches = inventory.allBatches;

            double totalRetailValuation = 0.0;
            double totalCostValuation = 0.0;
            int totalSellablePacks = 0;

            for (final med in medicines) {
              final sellableUnits = inventory.getSellableUnits(med.id);
              if (med.unitsPerPack > 0) {
                totalSellablePacks += sellableUnits ~/ med.unitsPerPack;
                totalRetailValuation += (sellableUnits / med.unitsPerPack) * med.salePrice;
              }
            }

            for (final b in batches) {
              final med = inventory.getMedicineById(b.medicineId);
              final uPerPack = med?.unitsPerPack ?? 1;
              totalCostValuation += (b.quantityUnits / uPerPack) * b.purchasePrice;
            }

            final potentialGrossMargin = totalRetailValuation - totalCostValuation;

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Summary Valuation Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Inventory Worth', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 12),
                        _Row(label: 'Retail Valuation (Sale Price):', value: AppFormatters.currency(totalRetailValuation), isBold: true, color: AppColors.primaryDark),
                        _Row(label: 'Cost Valuation (Purchase Cost):', value: AppFormatters.currency(totalCostValuation), color: AppColors.textPrimary),
                        const Divider(height: 16),
                        _Row(label: 'Estimated Unrealized Margin:', value: AppFormatters.currency(potentialGrossMargin), isBold: true, color: AppColors.success),
                        _Row(label: 'Total Sellable Stock Packs:', value: '$totalSellablePacks packs', color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text('Category Valuation Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),

                ...inventory.categories.map((cat) {
                  final catMeds = medicines.where((m) => m.categoryId == cat.id);
                  double catValue = 0.0;
                  int catPacks = 0;

                  for (final med in catMeds) {
                    final sellable = inventory.getSellableUnits(med.id);
                    if (med.unitsPerPack > 0) {
                      catPacks += sellable ~/ med.unitsPerPack;
                      catValue += (sellable / med.unitsPerPack) * med.salePrice;
                    }
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text('${catMeds.length} medicines • $catPacks packs in stock'),
                      trailing: Text(
                        AppFormatters.currency(catValue),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
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

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? color;

  const _Row({required this.label, required this.value, this.isBold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: color ?? AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

