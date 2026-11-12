import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../core/role_guard.dart';
import '../../widgets/empty_state.dart';
import '../../providers/finance_provider.dart';

class DailyClosingSummaryScreen extends StatelessWidget {
  const DailyClosingSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Daily Closing Summaries'),
        ),
        body: Consumer<FinanceProvider>(
          builder: (context, financeProvider, _) {
            final closings = financeProvider.dailyClosings;

            if (closings.isEmpty) {
              return const EmptyState(
                icon: Icons.summarize_outlined,
                title: 'No Closings Logged Yet',
                message: 'Daily cash register reconciliation summaries will be preserved here.',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: closings.length,
              itemBuilder: (context, index) {
                final dcs = closings[index];
                final isMatch = dcs.difference == 0;
                final isShortage = dcs.difference < 0;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppFormatters.date(dcs.date),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isMatch
                                    ? AppColors.successLight
                                    : (isShortage ? AppColors.dangerLight : AppColors.infoLight),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                isMatch ? 'Balanced (Exact)' : (isShortage ? 'Shortage' : 'Excess'),
                                style: TextStyle(
                                  color: isMatch ? AppColors.success : (isShortage ? AppColors.danger : AppColors.info),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Reconciled by: ${dcs.closedBy}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const Divider(height: 18),

                        _SummaryRow(label: 'Total Sales Revenue:', value: AppFormatters.currency(dcs.totalSales), isBold: true),
                        _SummaryRow(label: '• Cash Sales:', value: AppFormatters.currency(dcs.cashSales)),
                        _SummaryRow(label: '• Card Sales:', value: AppFormatters.currency(dcs.cardSales)),
                        _SummaryRow(label: 'Total Shift Expenses:', value: '- ${AppFormatters.currency(dcs.totalExpenses)}', color: AppColors.danger),
                        const Divider(height: 14),

                        _SummaryRow(label: 'Opening Cash Float:', value: AppFormatters.currency(dcs.openingCash)),
                        _SummaryRow(label: 'Expected Till Cash:', value: AppFormatters.currency(dcs.expectedCashInDrawer)),
                        _SummaryRow(label: 'Physical Counted Cash:', value: AppFormatters.currency(dcs.actualCashCounted), isBold: true),
                        _SummaryRow(
                          label: 'Discrepancy / Variance:',
                          value: '${dcs.difference >= 0 ? "+" : ""}${AppFormatters.currency(dcs.difference)}',
                          isBold: true,
                          color: isMatch ? AppColors.success : (isShortage ? AppColors.danger : AppColors.info),
                        ),
                        if (dcs.notes.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text('Notes: ${dcs.notes}', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textTertiary)),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? color;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

