import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../core/role_guard.dart';
import '../../providers/billing_provider.dart';
import '../../providers/finance_provider.dart';

class ProfitAndLossScreen extends StatefulWidget {
  const ProfitAndLossScreen({super.key});

  @override
  State<ProfitAndLossScreen> createState() => _ProfitAndLossScreenState();
}

class _ProfitAndLossScreenState extends State<ProfitAndLossScreen> {
  int _selectedPeriod = 0; // 0: Today, 1: Last 7 Days, 2: This Month, 3: All Time

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Profit & Loss Statement'),
        ),
        body: Consumer2<BillingProvider, FinanceProvider>(
          builder: (context, billing, finance, _) {
            final now = DateTime.now();
            DateTime startDate;

            switch (_selectedPeriod) {
              case 0: // Today
                startDate = DateTime(now.year, now.month, now.day);
                break;
              case 1: // Last 7 Days
                startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7));
                break;
              case 2: // This Month
                startDate = DateTime(now.year, now.month, 1);
                break;
              default:
                startDate = DateTime(2020);
            }

            final sales = billing.sales.where((s) => s.date.isAfter(startDate)).toList();
            final expenses = finance.expenses.where((e) => e.date.isAfter(startDate)).toList();

            final totalRevenue = sales.fold(0.0, (sum, s) => sum + s.netTotal);
            final cogs = sales.fold(0.0, (sum, s) => sum + s.estimatedCost);
            final grossProfit = (totalRevenue - cogs).clamp(0.0, double.infinity);
            final totalExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount);
            final netProfit = totalRevenue - cogs - totalExpenses;
            final grossMargin = totalRevenue > 0 ? (grossProfit / totalRevenue * 100) : 0.0;

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Period Segment
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 0, label: Text('Today')),
                    ButtonSegment(value: 1, label: Text('7 Days')),
                    ButtonSegment(value: 2, label: Text('Month')),
                    ButtonSegment(value: 3, label: Text('All Time')),
                  ],
                  selected: {_selectedPeriod},
                  onSelectionChanged: (val) {
                    setState(() => _selectedPeriod = val.first);
                  },
                ),
                const SizedBox(height: 20),

                // Net Profit Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: netProfit >= 0 ? AppColors.success : AppColors.danger,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'NET EARNINGS / PROFIT',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppFormatters.currency(netProfit),
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gross Margin: ${grossMargin.toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Comprehensive Financial Statement Breakdown
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Income Statement Breakdown',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 8),

                        _PnLRow(label: 'Total Medicine Sales (Revenue):', value: AppFormatters.currency(totalRevenue), color: AppColors.primaryDark),
                        _PnLRow(label: 'Cost of Goods Sold (COGS):', value: '- ${AppFormatters.currency(cogs)}', color: AppColors.danger),
                        const Divider(height: 16),
                        _PnLRow(
                          label: 'GROSS PROFIT:',
                          value: AppFormatters.currency(grossProfit),
                          isBold: true,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 6),
                        _PnLRow(label: 'Store Operating Expenses:', value: '- ${AppFormatters.currency(totalExpenses)}', color: AppColors.danger),
                        const Divider(height: 16),
                        _PnLRow(
                          label: 'NET PROFIT (Final):',
                          value: AppFormatters.currency(netProfit),
                          isBold: true,
                          fontSize: 16,
                          color: netProfit >= 0 ? AppColors.success : AppColors.danger,
                        ),
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

class _PnLRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final double fontSize;
  final Color? color;

  const _PnLRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.fontSize = 13,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

