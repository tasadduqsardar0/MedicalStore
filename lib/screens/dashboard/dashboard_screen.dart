import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../widgets/alert_chip.dart';
import '../../widgets/empty_state.dart';
import '../../providers/billing_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';

class DashboardScreen extends StatelessWidget {
  final ValueChanged<int>? onNavigateTab;
  final VoidCallback? onOpenDrawer;

  const DashboardScreen({super.key, this.onNavigateTab, this.onOpenDrawer});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final inventory = context.watch<InventoryProvider>();
    final billing = context.watch<BillingProvider>();
    final settings = context.watch<SettingsProvider>().settings;

    final isOwner = auth.isOwner;
    final user = auth.currentUser;

    // Today's Sales Calculation
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todaySales = billing.sales.where((s) => s.date.isAfter(today)).toList();
    final todaySalesTotal = todaySales.fold(0.0, (sum, s) => sum + s.netTotal);
    final todayProfitTotal = todaySales.fold(0.0, (sum, s) => sum + s.profit);

    final lowStockItems = inventory.lowStockMedicines;
    final nearExpiryBatches = inventory.nearExpiryBatches;
    final last5Sales = billing.sales.take(5).toList();

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              settings.storeName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              settings.address,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan Barcode',
            onPressed: () => Navigator.pushNamed(context, '/barcode-scanner'),
          ),
          if (auth.isRealOwner)
            IconButton(
              icon: const Icon(Icons.developer_mode, color: AppColors.primary),
              tooltip: 'Developer Tools',
              onPressed: () => Navigator.pushNamed(context, '/dev-tools'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // In-memory refresh
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Welcome Greeting Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 16,
                    child: Text(
                      user?.name.isNotEmpty == true ? user!.name[0] : 'U',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${user?.name ?? "User"}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryDark),
                        ),
                        Text(
                          isOwner ? 'Store Owner Access (Full Control)' : 'Pharmacy Staff Access',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  AlertChip.role(isOwner ? 'Owner' : 'Staff', isOwner: isOwner),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Top Sales & Profit Metrics (Owner only sees profit!)
            Row(
              children: [
                Expanded(
                  child: _DashboardMetricCard(
                    title: "Today's Sales",
                    value: AppFormatters.currency(todaySalesTotal),
                    subtitle: '${todaySales.length} invoices generated',
                    icon: Icons.payments_outlined,
                    color: AppColors.primary,
                    onTap: () {
                      if (onNavigateTab != null) onNavigateTab!(1); // Go to Sale
                    },
                  ),
                ),
                // Rule: Staff must NOT see profit figures!
                if (isOwner) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DashboardMetricCard(
                      title: "Today's Profit",
                      value: AppFormatters.currency(todayProfitTotal),
                      subtitle: 'Owner Only Metric',
                      icon: Icons.trending_up,
                      color: AppColors.success,
                      onTap: () => Navigator.pushNamed(context, '/profit-and-loss'),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // Stock Alert Count Cards
            Row(
              children: [
                Expanded(
                  child: _DashboardMetricCard(
                    title: 'Low Stock',
                    value: '${lowStockItems.length}',
                    subtitle: 'Needs replenishment',
                    icon: Icons.warning_amber_rounded,
                    color: AppColors.warning,
                    onTap: () => Navigator.pushNamed(context, '/low-stock'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DashboardMetricCard(
                    title: 'Near Expiry',
                    value: '${nearExpiryBatches.length}',
                    subtitle: 'Within ${settings.nearExpiryDays} days',
                    icon: Icons.schedule,
                    color: AppColors.danger,
                    onTap: () => Navigator.pushNamed(context, '/expiry'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Quick Actions Row
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.point_of_sale,
                    label: 'New Sale',
                    color: AppColors.primary,
                    onTap: () {
                      if (onNavigateTab != null) onNavigateTab!(1);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.medication,
                    label: 'Add Med',
                    color: AppColors.primaryDark,
                    onTap: () => Navigator.pushNamed(context, '/add-medicine'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.medical_services_outlined,
                    label: 'Rx / Drugs',
                    color: AppColors.info,
                    onTap: () => Navigator.pushNamed(context, '/prescriptions'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.receipt_long,
                    label: 'History',
                    color: AppColors.success,
                    onTap: () => Navigator.pushNamed(context, '/sales-history'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Top Stock Alerts Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Top Stock Alerts',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/low-stock'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 4),

            if (lowStockItems.isEmpty && nearExpiryBatches.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.success, size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'All stocks and expiry dates are within normal parameters.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              ...lowStockItems.take(3).map((med) {
                final status = inventory.getStockStatus(med);
                final stockText = inventory.getStockDisplayText(med);

                return Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: ListTile(
                    dense: true,
                    leading: const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
                    title: Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text('Stock: $stockText (Min: ${med.minimumStockPacks} packs)', style: const TextStyle(fontSize: 11)),
                    trailing: AlertChip.fromStatus(status),
                    onTap: () => Navigator.pushNamed(context, '/medicine-detail', arguments: med.id),
                  ),
                );
              }),
            ],
            const SizedBox(height: 24),

            // Last 5 Sales Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Sales',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/sales-history'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 4),

            if (last5Sales.isEmpty)
              const EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No Recent Sales',
                message: 'Invoices created today will be listed here.',
              )
            else
              ...last5Sales.map((sale) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    dense: true,
                    leading: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.receipt_outlined, color: AppColors.primaryDark, size: 18),
                    ),
                    title: Text(sale.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text('${sale.customerName} • ${AppFormatters.time(sale.date)}', style: const TextStyle(fontSize: 11)),
                    trailing: Text(
                      AppFormatters.currency(sale.netTotal),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryDark),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/invoice-detail', arguments: sale.id);
                    },
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _DashboardMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardMetricCard({
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
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
                Icon(icon, size: 18, color: color),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

