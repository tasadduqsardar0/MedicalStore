import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../core/stock_rules.dart';
import '../../widgets/alert_chip.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/app_search_bar.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/auth_provider.dart';

class BatchesListScreen extends StatefulWidget {
  const BatchesListScreen({super.key});

  @override
  State<BatchesListScreen> createState() => _BatchesListScreenState();
}

class _BatchesListScreenState extends State<BatchesListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();
    final auth = context.watch<AuthProvider>();
    final isOwner = auth.isOwner;

    final allBatches = inventory.allBatches;
    final nearExpiryBatches = inventory.nearExpiryBatches;
    final expiredBatches = inventory.expiredBatches;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Batches Registry'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: 'All (${allBatches.length})'),
            Tab(text: 'Near Expiry (${nearExpiryBatches.length})'),
            Tab(text: 'Expired (${expiredBatches.length})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Batch'),
        onPressed: () => Navigator.pushNamed(context, '/add-batch'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: AppSearchBar(
              controller: _searchController,
              hintText: 'Search batch number or medicine...',
              onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
              onClear: () => setState(() => _searchQuery = ''),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBatchListView(allBatches, inventory, isOwner),
                _buildBatchListView(nearExpiryBatches, inventory, isOwner),
                _buildBatchListView(expiredBatches, inventory, isOwner),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchListView(List batches, InventoryProvider inventory, bool isOwner) {
    final filtered = batches.where((b) {
      if (_searchQuery.isEmpty) return true;
      final med = inventory.getMedicineById(b.medicineId);
      final medName = med?.name.toLowerCase() ?? '';
      final batchNo = b.batchNumber.toLowerCase();
      return medName.contains(_searchQuery) || batchNo.contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return const EmptyState(
        icon: Icons.calendar_view_week_outlined,
        title: 'No Batches Found',
        message: 'No medicine batches found in this category.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final batch = filtered[index];
        final med = inventory.getMedicineById(batch.medicineId);
        final isExp = StockRules.isBatchExpired(batch.expiryDate);
        final isNear = StockRules.isBatchNearExpiry(batch.expiryDate);

        final unitsPerPack = med?.unitsPerPack ?? 1;
        final packs = batch.quantityUnits ~/ unitsPerPack;
        final loose = batch.quantityUnits % unitsPerPack;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isExp
                        ? AppColors.dangerLight
                        : (isNear ? AppColors.warningLight : AppColors.primaryLight),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isExp ? Icons.error_outline : (isNear ? Icons.schedule : Icons.check_circle_outline),
                    color: isExp
                        ? AppColors.danger
                        : (isNear ? AppColors.warning : AppColors.primary),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        med?.name ?? 'Unknown Medicine',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            'Batch: ${batch.batchNumber}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
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
                      if (isOwner) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Purchase Price: ${AppFormatters.currency(batch.purchasePrice)} / pack',
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
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryDark),
                    ),
                    if (loose > 0)
                      Text(
                        '+ $loose loose',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    Text(
                      '${batch.quantityUnits} total units',
                      style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
                    ),
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

