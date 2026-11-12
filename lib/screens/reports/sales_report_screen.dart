import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../core/role_guard.dart';
import '../../providers/billing_provider.dart';
import '../../providers/reports_provider.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  ReportDateRange _range = ReportDateRange.last7Days;

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Sales & Revenue Report'),
        ),
        body: Consumer2<BillingProvider, ReportsProvider>(
          builder: (context, billing, reports, _) {
            final startDate = reports.getStartDateForRange(_range);
            final sales = billing.sales.where((s) => s.date.isAfter(startDate)).toList();

            final totalRevenue = sales.fold(0.0, (sum, s) => sum + s.netTotal);
            final totalDiscount = sales.fold(0.0, (sum, s) => sum + s.discount);
            final avgOrder = sales.isNotEmpty ? (totalRevenue / sales.length) : 0.0;

            final cashSales = sales.where((s) => s.paymentMethod.name == 'cash').fold(0.0, (sum, s) => sum + s.netTotal);
            final cardSales = sales.where((s) => s.paymentMethod.name == 'card').fold(0.0, (sum, s) => sum + s.netTotal);
            final splitSales = sales.where((s) => s.paymentMethod.name == 'split').fold(0.0, (sum, s) => sum + s.netTotal);

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Date Range Filter
                DropdownButtonFormField<ReportDateRange>(
                  key: ValueKey(_range),
                  initialValue: _range,
                  decoration: const InputDecoration(labelText: 'Timeframe Period'),
                  items: ReportDateRange.values.map((r) {
                    return DropdownMenuItem(value: r, child: Text(r.label));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _range = val);
                  },
                ),
                const SizedBox(height: 16),

                // Top Metrics
                Row(
                  children: [
                    Expanded(
                      child: _MetricTile(
                        label: 'Total Revenue',
                        value: AppFormatters.currency(totalRevenue),
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricTile(
                        label: 'Orders Count',
                        value: '${sales.length}',
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _MetricTile(
                        label: 'Avg Ticket Value',
                        value: AppFormatters.currency(avgOrder),
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricTile(
                        label: 'Total Discounts',
                        value: AppFormatters.currency(totalDiscount),
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Payment Breakdown Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Payment Methods Share', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 12),
                        _PaymentShareRow(label: 'Cash Payments:', amount: cashSales, total: totalRevenue, color: AppColors.success),
                        _PaymentShareRow(label: 'Card / Digital:', amount: cardSales, total: totalRevenue, color: AppColors.info),
                        _PaymentShareRow(label: 'Split Payments:', amount: splitSales, total: totalRevenue, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricTile({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class _PaymentShareRow extends StatelessWidget {
  final String label;
  final double amount;
  final double total;
  final Color color;

  const _PaymentShareRow({
    required this.label,
    required this.amount,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (amount / total * 100) : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
              Text('${AppFormatters.currency(amount)} (${pct.toStringAsFixed(1)}%)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: total > 0 ? (amount / total) : 0.0,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

