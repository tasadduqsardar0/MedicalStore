import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../core/stock_rules.dart';
import '../../widgets/alert_chip.dart';
import '../../widgets/empty_state.dart';
import '../../data/models/batch_model.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/auth_provider.dart';

class ExpiryScreen extends StatefulWidget {
  final int initialTabIndex;

  const ExpiryScreen({super.key, this.initialTabIndex = 0});

  @override
  State<ExpiryScreen> createState() => _ExpiryScreenState();
}

class _ExpiryScreenState extends State<ExpiryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();
    final auth = context.watch<AuthProvider>();
    final isOwner = auth.isOwner;

    final nearExpiryBatches = inventory.nearExpiryBatches;
    final expiredBatches = inventory.expiredBatches;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Expiry Management'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: 'Near Expiry (${nearExpiryBatches.length})'),
            Tab(text: 'Expired Stock (${expiredBatches.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBatchList(nearExpiryBatches, inventory, isOwner, isExpired: false),
          _buildBatchList(expiredBatches, inventory, isOwner, isExpired: true),
        ],
      ),
    );
  }

  Widget _buildBatchList(
    List<Batch> batches,
    InventoryProvider inventory,
    bool isOwner, {
    required bool isExpired,
  }) {
    if (batches.isEmpty) {
      return EmptyState(
        icon: isExpired ? Icons.check_circle_outline : Icons.schedule,
        title: isExpired ? 'No Expired Stock' : 'No Batches Near Expiry',
        message: isExpired
            ? 'Great! There are no expired medicine batches in your pharmacy.'
            : 'No medicine batches are expiring within the next 30 days.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: batches.length,
      itemBuilder: (context, index) {
        final batch = batches[index];
        final med = inventory.getMedicineById(batch.medicineId);
        final unitsPerPack = med?.unitsPerPack ?? 1;
        final packs = batch.quantityUnits ~/ unitsPerPack;
        final loose = batch.quantityUnits % unitsPerPack;

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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            med?.name ?? 'Medicine',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Text(
                            'Batch: ${batch.batchNumber}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                    AlertChip.fromStatus(isExpired ? StockStatus.expiredStock : StockStatus.nearExpiry),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Expiry Date: ${AppFormatters.date(batch.expiryDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isExpired ? AppColors.danger : AppColors.warning,
                      ),
                    ),
                    Text(
                      '$packs packs ${loose > 0 ? '+ $loose loose' : ''}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (isExpired) ...[
                  const SizedBox(height: 4),
                  const Text(
                    '⚠️ Rule: Expired stock is never sold and never counted as sellable.',
                    style: TextStyle(fontSize: 11, color: AppColors.danger),
                  ),
                ],
                const Divider(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.danger),
                        label: const Text('Dispose Stock', style: TextStyle(color: AppColors.danger)),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.danger)),
                        onPressed: () {
                          Navigator.pushNamed(context, '/disposal');
                        },
                      ),
                    ),
                    if (isOwner) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.keyboard_return, size: 16),
                          label: const Text('Return to Supplier'),
                          onPressed: () {
                            Navigator.pushNamed(context, '/purchase-return');
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

