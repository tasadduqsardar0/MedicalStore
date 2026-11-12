import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../core/role_guard.dart';
import '../../providers/billing_provider.dart';
import '../../providers/finance_provider.dart';
import '../../providers/reports_provider.dart';

class ProfitReportScreen extends StatefulWidget {
  const ProfitReportScreen({super.key});

  @override
  State<ProfitReportScreen> createState() => _ProfitReportScreenState();
}

class _ProfitReportScreenState extends State<ProfitReportScreen> {
  ReportDateRange _range = ReportDateRange.last30Days;

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Profit Margin Analysis'),
        ),
        body: Consumer3<BillingProvider, FinanceProvider, ReportsProvider>(
          builder: (context, billing, finance, reports, _) {
            final startDate = reports.getStartDateForRange(_range);
            final sales = billing.sales.where((s) => s.date.isAfter(startDate)).toList();
            final expenses = finance.expenses.where((e) => e.date.isAfter(startDate)).toList();

            final totalRev = sales.fold(0.0, (sum, s) => sum + s.netTotal);
            final totalCOGS = sales.fold(0.0, (sum, s) => sum + s.estimatedCost);
            final grossProfit = totalRev - totalCOGS;
            final totalExp = expenses.fold(0.0, (sum, e) => sum + e.amount);
            final netProfit = grossProfit - totalExp;
            final marginPct = totalRev > 0 ? (grossProfit / totalRev * 100) : 0.0;

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                DropdownButtonFormField<ReportDateRange>(
                  key: ValueKey(_range),
                  initialValue: _range,
                  decoration: const InputDecoration(labelText: 'Timeframe Period'),
                  items: ReportDateRange.values.map((r) => DropdownMenuItem(value: r, child: Text(r.label))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _range = val);
                  },
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: netProfit >= 0 ? AppColors.success : AppColors.danger,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      const Text('NET PHARMACY PROFIT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 1.2)),
                      const SizedBox(height: 6),
                      Text(
                        AppFormatters.currency(netProfit),
                        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text('Gross Profit Margin: ${marginPct.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _Row(label: 'Total Net Sales Revenue:', value: AppFormatters.currency(totalRev)),
                        _Row(label: 'Cost of Sold Stock (COGS):', value: '- ${AppFormatters.currency(totalCOGS)}', color: AppColors.danger),
                        const Divider(height: 16),
                        _Row(label: 'Gross Trading Profit:', value: AppFormatters.currency(grossProfit), isBold: true, color: AppColors.primary),
                        _Row(label: 'Store Operating Expenses:', value: '- ${AppFormatters.currency(totalExp)}', color: AppColors.danger),
                        const Divider(height: 16),
                        _Row(label: 'Final Net Income:', value: AppFormatters.currency(netProfit), isBold: true, color: netProfit >= 0 ? AppColors.success : AppColors.danger),
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

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? color;

  const _Row({required this.label, required this.value, this.isBold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
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

