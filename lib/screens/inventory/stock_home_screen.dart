import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/settings_provider.dart';

class StockHomeScreen extends StatelessWidget {
  final VoidCallback? onOpenDrawer;

  const StockHomeScreen({super.key, this.onOpenDrawer});

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();
    final settings = context.watch<SettingsProvider>().settings;
    final medicines = inventory.allMedicines;
    final lowStockCount = inventory.lowStockMedicines.length;
    final nearExpiryCount = inventory.nearExpiryBatches.length;
    final expiredCount = inventory.expiredBatches.length;

    // Total sellable packs calculation
    int totalPacks = 0;
    for (final med in medicines) {
      final units = inventory.getSellableUnits(med.id);
      totalPacks += med.unitsPerPack > 0 ? (units ~/ med.unitsPerPack) : 0;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: onOpenDrawer != null
            ? IconButton(
                icon: const Icon(Icons.menu),
                tooltip: 'Open Menu',
                onPressed: onOpenDrawer,
              )
            : null,
        title: const Text('Inventory Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/medicines'),
            tooltip: 'Search Medicines',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Metrics Cards Grid
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Total Medicines',
                  value: '${medicines.length}',
                  subtitle: '$totalPacks sellable packs',
                  icon: Icons.medication_outlined,
                  color: AppColors.primary,
                  onTap: () => Navigator.pushNamed(context, '/medicines'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Low Stock',
                  value: '$lowStockCount',
                  subtitle: 'Needs replenishment',
                  icon: Icons.warning_amber_rounded,
                  color: AppColors.warning,
                  onTap: () => Navigator.pushNamed(context, '/low-stock'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Near Expiry',
                  value: '$nearExpiryCount',
                  subtitle: 'Within ${settings.nearExpiryDays} days',
                  icon: Icons.schedule,
                  color: AppColors.warning,
                  onTap: () => Navigator.pushNamed(context, '/expiry', arguments: 0),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Expired Stock',
                  value: '$expiredCount',
                  subtitle: 'Never sellable',
                  icon: Icons.cancel_outlined,
                  color: AppColors.danger,
                  onTap: () => Navigator.pushNamed(context, '/expiry', arguments: 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          const Text(
            'Inventory Modules',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Menu Grid
          _ModuleTile(
            icon: Icons.list_alt,
            title: 'Medicines List',
            subtitle: 'Browse, search, add and edit store medicines',
            onTap: () => Navigator.pushNamed(context, '/medicines'),
          ),
          _ModuleTile(
            icon: Icons.category_outlined,
            title: 'Categories',
            subtitle: 'Manage pharmaceutical categories and groups',
            onTap: () => Navigator.pushNamed(context, '/categories'),
          ),
          _ModuleTile(
            icon: Icons.calendar_view_week_outlined,
            title: 'Batches List',
            subtitle: 'View batch numbers, expiry dates and stock levels',
            onTap: () => Navigator.pushNamed(context, '/batches'),
          ),
          _ModuleTile(
            icon: Icons.tune_outlined,
            title: 'Stock Adjustment',
            subtitle: 'Record corrections, damages, and loss with reasons',
            onTap: () => Navigator.pushNamed(context, '/stock-adjustment'),
          ),
          _ModuleTile(
            icon: Icons.warning_amber_rounded,
            title: 'Low Stock Alerts',
            subtitle: 'Items at or below minimum pack threshold',
            badge: lowStockCount > 0 ? '$lowStockCount' : null,
            badgeColor: AppColors.warning,
            onTap: () => Navigator.pushNamed(context, '/low-stock'),
          ),
          _ModuleTile(
            icon: Icons.hourglass_bottom_outlined,
            title: 'Expiry Tracking',
            subtitle: 'Near expiry batches and expired stock quarantine',
            badge: (nearExpiryCount + expiredCount) > 0 ? '${nearExpiryCount + expiredCount}' : null,
            badgeColor: AppColors.danger,
            onTap: () => Navigator.pushNamed(context, '/expiry'),
          ),
          _ModuleTile(
            icon: Icons.delete_outline,
            title: 'Stock Disposal',
            subtitle: 'Quarantine and destroy expired or damaged stock',
            onTap: () => Navigator.pushNamed(context, '/disposal'),
          ),
          _ModuleTile(
            icon: Icons.find_replace_outlined,
            title: 'Substitutes Search',
            subtitle: 'Find generic medicine alternatives by formula',
            onTap: () => Navigator.pushNamed(context, '/substitutes'),
          ),
          _ModuleTile(
            icon: Icons.fact_check_outlined,
            title: 'Stock Audit',
            subtitle: 'Physical count vs system inventory verification',
            onTap: () => Navigator.pushNamed(context, '/stock-audit'),
          ),
          _ModuleTile(
            icon: Icons.qr_code_2_outlined,
            title: 'Barcode Labels',
            subtitle: 'Generate and print shelf and medicine barcodes',
            onTap: () => Navigator.pushNamed(context, '/barcode-labels'),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                Icon(icon, size: 20, color: color),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? badge;
  final Color? badgeColor;

  const _ModuleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryDark, size: 22),
        ),
        title: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (badgeColor ?? AppColors.primary).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    color: badgeColor ?? AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textTertiary),
        onTap: onTap,
      ),
    );
  }
}

