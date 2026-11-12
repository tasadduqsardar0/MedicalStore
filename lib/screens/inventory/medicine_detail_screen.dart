import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../core/stock_rules.dart';
import '../../widgets/alert_chip.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/auth_provider.dart';

class MedicineDetailScreen extends StatelessWidget {
  final String medicineId;

  const MedicineDetailScreen({super.key, required this.medicineId});

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();
    final auth = context.watch<AuthProvider>();
    final isOwner = auth.isOwner;

    final med = inventory.getMedicineById(medicineId);
    if (med == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Medicine Detail')),
        body: const Center(child: Text('Medicine not found')),
      );
    }

    final batches = inventory.getBatchesForMedicine(med.id);
    final category = inventory.getCategoryById(med.categoryId);
    final status = inventory.getStockStatus(med);
    final sellableUnits = inventory.getSellableUnits(med.id);
    final totalUnits = inventory.getTotalUnits(med.id);
    final stockText = inventory.getStockDisplayText(med);

    // Rule: Can delete only if Owner AND stock == 0!
    final canDelete = isOwner && StockRules.canDeleteMedicine(batches);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(med.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Medicine',
            onPressed: () {
              Navigator.pushNamed(context, '/edit-medicine', arguments: med.id);
            },
          ),
          // Delete button: ONLY FOR OWNER!
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              tooltip: canDelete ? 'Delete Medicine' : 'Cannot delete (Stock > 0)',
              onPressed: canDelete
                  ? () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Medicine?'),
                          content: Text('Are you sure you want to delete "${med.name}"?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        inventory.deleteMedicine(med.id);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Medicine deleted'), backgroundColor: AppColors.danger),
                        );
                      }
                    }
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cannot delete medicine with active or remaining stock. Adjust stock to 0 first.'),
                          backgroundColor: AppColors.warning,
                        ),
                      );
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
                      Expanded(
                        child: Text(
                          med.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ),
                      AlertChip.fromStatus(status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    med.genericName,
                    style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        label: Text(category?.name ?? 'Category'),
                        backgroundColor: AppColors.surfaceVariant,
                        labelStyle: const TextStyle(fontSize: 11),
                        visualDensity: VisualDensity.compact,
                      ),
                      Chip(
                        label: Text(med.company),
                        backgroundColor: AppColors.surfaceVariant,
                        labelStyle: const TextStyle(fontSize: 11),
                        visualDensity: VisualDensity.compact,
                      ),
                      if (med.isControlled) AlertChip.controlled(),
                    ],
                  ),
                  const Divider(height: 24),
                  // Key Metrics
                  Row(
                    children: [
                      Expanded(
                        child: _DetailMetric(
                          label: 'Sellable Stock',
                          value: stockText,
                          subvalue: '$sellableUnits total units',
                          color: AppColors.primaryDark,
                        ),
                      ),
                      Expanded(
                        child: _DetailMetric(
                          label: 'Pack Price',
                          value: AppFormatters.currency(med.salePrice),
                          subvalue: med.isLooseEnabled ? '${AppFormatters.currency(med.loosePrice)} / loose' : 'Loose disabled',
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Packaging and Dosage Details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Dosage & Packaging', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _RowInfo(label: 'Dosage Form', value: med.form.label),
                  _RowInfo(label: 'Pack Type', value: med.packType.label),
                  _RowInfo(label: 'Units Per Pack', value: '${med.unitsPerPack} ${med.unitName}s'),
                  _RowInfo(label: 'Minimum Stock Level', value: '${med.minimumStockPacks} packs'),
                  _RowInfo(label: 'Barcode', value: med.barcode.isNotEmpty ? med.barcode : 'None'),
                  _RowInfo(label: 'Total Stock (all batches)', value: '$totalUnits ${med.unitName}s'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Batches Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Batches (${batches.length})',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              TextButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Batch'),
                onPressed: () {
                  Navigator.pushNamed(context, '/add-batch', arguments: med.id);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (batches.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(
                  child: Text('No batches registered. Add a batch or record Goods Received.'),
                ),
              ),
            )
          else
            ...batches.map((batch) {
              final isExp = StockRules.isBatchExpired(batch.expiryDate);
              final isNear = StockRules.isBatchNearExpiry(batch.expiryDate);
              final packs = med.unitsPerPack > 0 ? (batch.quantityUnits ~/ med.unitsPerPack) : 0;
              final loose = med.unitsPerPack > 0 ? (batch.quantityUnits % med.unitsPerPack) : 0;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isExp
                              ? AppColors.dangerLight
                              : (isNear ? AppColors.warningLight : AppColors.primaryLight),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isExp ? Icons.error_outline : (isNear ? Icons.schedule : Icons.check_circle_outline),
                          color: isExp
                              ? AppColors.danger
                              : (isNear ? AppColors.warning : AppColors.primary),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Batch: ${batch.batchNumber}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const SizedBox(width: 6),
                                if (isExp)
                                  const AlertChip(
                                    label: 'Expired',
                                    backgroundColor: AppColors.dangerLight,
                                    textColor: AppColors.danger,
                                  )
                                else if (isNear)
                                  const AlertChip(
                                    label: 'Near Expiry',
                                    backgroundColor: AppColors.warningLight,
                                    textColor: AppColors.warning,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Expiry: ${AppFormatters.date(batch.expiryDate)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isExp ? AppColors.danger : AppColors.textSecondary,
                              ),
                            ),
                            // Purchase Price: OWNER ONLY!
                            if (isOwner) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Purchase: ${AppFormatters.currency(batch.purchasePrice)} / pack',
                                style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$packs packs',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          if (loose > 0)
                            Text(
                              '+ $loose loose',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.find_replace_outlined, size: 18),
            label: Text('Find Substitutes for ${med.genericName}'),
            onPressed: () {
              Navigator.pushNamed(context, '/substitutes', arguments: med.genericName);
            },
          ),
          const SizedBox(height: 20),

          // Stock History Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Stock History & Adjustments',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/stock-adjustment'),
                child: const Text('Adjust Stock'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Builder(
            builder: (context) {
              final medAdjustments = inventory.adjustments.where((a) => a.medicineId == med.id).toList();
              if (medAdjustments.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                      child: Text(
                        'No stock adjustments or disposals recorded for this medicine yet.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                );
              }
              return Column(
                children: medAdjustments.map((adj) {
                  final isPositive = adj.quantityUnits > 0;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      dense: true,
                      leading: Icon(
                        isPositive ? Icons.add_circle_outline : Icons.remove_circle_outline,
                        color: isPositive ? AppColors.success : AppColors.danger,
                      ),
                      title: Text('${adj.type.label} (${adj.batchNumber})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text('${adj.reason} • By ${adj.adjustedBy} • ${AppFormatters.shortDate(adj.date)}', style: const TextStyle(fontSize: 11)),
                      trailing: Text(
                        '${isPositive ? '+' : ''}${adj.quantityUnits} units',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isPositive ? AppColors.success : AppColors.danger),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DetailMetric extends StatelessWidget {
  final String label;
  final String value;
  final String subvalue;
  final Color color;

  const _DetailMetric({
    required this.label,
    required this.value,
    required this.subvalue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 1),
        Text(subvalue, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
      ],
    );
  }
}

class _RowInfo extends StatelessWidget {
  final String label;
  final String value;

  const _RowInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

