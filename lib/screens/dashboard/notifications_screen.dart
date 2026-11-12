import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../widgets/empty_state.dart';
import '../../providers/inventory_provider.dart';

class NotificationsScreen extends StatefulWidget {
  final VoidCallback? onOpenDrawer;

  const NotificationsScreen({super.key, this.onOpenDrawer});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();

    final lowStock = inventory.lowStockMedicines;
    final nearExpiry = inventory.nearExpiryBatches;
    final expired = inventory.expiredBatches;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: widget.onOpenDrawer != null
            ? IconButton(
                icon: const Icon(Icons.menu),
                tooltip: 'Open Menu',
                onPressed: widget.onOpenDrawer,
              )
            : null,
        title: const Text('Store Notifications & Alerts'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: 'All (${lowStock.length + nearExpiry.length + expired.length})'),
            Tab(text: 'Stock (${lowStock.length})'),
            Tab(text: 'Expiry (${nearExpiry.length + expired.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All
          _buildAllList(lowStock, nearExpiry, expired, inventory),
          // Stock
          _buildStockList(lowStock, inventory),
          // Expiry
          _buildExpiryList(nearExpiry, expired, inventory),
        ],
      ),
    );
  }

  Widget _buildAllList(List lowStock, List nearExpiry, List expired, InventoryProvider inventory) {
    if (lowStock.isEmpty && nearExpiry.isEmpty && expired.isEmpty) {
      return const EmptyState(
        icon: Icons.notifications_none,
        title: 'No Active Notifications',
        message: 'Everything is running smoothly! Stock levels and expiry dates are up to date.',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (expired.isNotEmpty) ...[
          _sectionHeader('Expired Stock Alerts (Immediate Action)'),
          ...expired.map((b) => _buildExpiryTile(b, inventory, isExpired: true)),
          const SizedBox(height: 12),
        ],
        if (nearExpiry.isNotEmpty) ...[
          _sectionHeader('Near Expiry Batches'),
          ...nearExpiry.map((b) => _buildExpiryTile(b, inventory, isExpired: false)),
          const SizedBox(height: 12),
        ],
        if (lowStock.isNotEmpty) ...[
          _sectionHeader('Low Stock Alerts'),
          ...lowStock.map((m) => _buildStockTile(m, inventory)),
        ],
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildStockList(List lowStock, InventoryProvider inventory) {
    if (lowStock.isEmpty) {
      return const EmptyState(
        icon: Icons.check_circle_outline,
        title: 'All Stock Levels Normal',
        message: 'No medicines have breached the minimum pack limit.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lowStock.length,
      itemBuilder: (context, idx) => _buildStockTile(lowStock[idx], inventory),
    );
  }

  Widget _buildExpiryList(List nearExpiry, List expired, InventoryProvider inventory) {
    final combined = [...expired, ...nearExpiry];
    if (combined.isEmpty) {
      return const EmptyState(
        icon: Icons.schedule,
        title: 'No Expiry Issues',
        message: 'All medicine batches have valid future expiry dates.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: combined.length,
      itemBuilder: (context, idx) {
        final b = combined[idx];
        final isExp = idx < expired.length;
        return _buildExpiryTile(b, inventory, isExpired: isExp);
      },
    );
  }

  Widget _buildStockTile(dynamic med, InventoryProvider inventory) {
    final stockText = inventory.getStockDisplayText(med);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
        title: Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text('Current: $stockText • Min: ${med.minimumStockPacks} packs'),
        trailing: const Icon(Icons.chevron_right, size: 18),
        onTap: () => Navigator.pushNamed(context, '/medicine-detail', arguments: med.id),
      ),
    );
  }

  Widget _buildExpiryTile(dynamic batch, InventoryProvider inventory, {required bool isExpired}) {
    final med = inventory.getMedicineById(batch.medicineId);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          isExpired ? Icons.cancel_outlined : Icons.schedule,
          color: isExpired ? AppColors.danger : AppColors.warning,
        ),
        title: Text(med?.name ?? 'Medicine', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text('Batch: ${batch.batchNumber} • Expiry: ${AppFormatters.date(batch.expiryDate)}'),
        trailing: Text(
          isExpired ? 'EXPIRED' : 'Near Expiry',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isExpired ? AppColors.danger : AppColors.warning,
          ),
        ),
        onTap: () => Navigator.pushNamed(context, '/expiry', arguments: isExpired ? 1 : 0),
      ),
    );
  }
}

