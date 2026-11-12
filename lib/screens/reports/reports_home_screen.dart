import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/role_guard.dart';

class ReportsHomeScreen extends StatelessWidget {
  const ReportsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Reports & Analytics (Owner)'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _ReportCard(
              icon: Icons.point_of_sale,
              title: 'Sales & Revenue Report',
              subtitle: 'Revenue, payment method breakdown and average ticket size',
              color: AppColors.primary,
              route: '/sales-report',
            ),
            _ReportCard(
              icon: Icons.local_shipping_outlined,
              title: 'Purchase & Supplier Report',
              subtitle: 'Inventory procurement volume and distributor payables',
              color: AppColors.primaryDark,
              route: '/purchase-report',
            ),
            _ReportCard(
              icon: Icons.inventory_2_outlined,
              title: 'Stock Valuation Report',
              subtitle: 'Total inventory investment at cost vs retail valuation',
              color: AppColors.info,
              route: '/stock-report',
            ),
            _ReportCard(
              icon: Icons.schedule,
              title: 'Expiry Valuation & Loss Report',
              subtitle: 'Value at risk of expiring batches and expired stock quarantine',
              color: AppColors.danger,
              route: '/expiry-report',
            ),
            _ReportCard(
              icon: Icons.trending_up,
              title: 'Profit Margins & Earnings Report',
              subtitle: 'Net income statement, COGS and profit margins by timeframe',
              color: AppColors.success,
              route: '/profit-report',
            ),
            _ReportCard(
              icon: Icons.people_outline,
              title: 'Staff Performance Report',
              subtitle: 'Sales volume, invoice count, and counter speed per employee',
              color: AppColors.controlled,
              route: '/staff-performance-report',
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String route;

  const _ReportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}

