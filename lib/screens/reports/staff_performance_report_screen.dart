import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../core/role_guard.dart';
import '../../providers/billing_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/reports_provider.dart';

class StaffPerformanceReportScreen extends StatefulWidget {
  const StaffPerformanceReportScreen({super.key});

  @override
  State<StaffPerformanceReportScreen> createState() => _StaffPerformanceReportScreenState();
}

class _StaffPerformanceReportScreenState extends State<StaffPerformanceReportScreen> {
  ReportDateRange _range = ReportDateRange.last30Days;

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Staff Performance Report'),
        ),
        body: Consumer3<BillingProvider, SettingsProvider, ReportsProvider>(
          builder: (context, billing, settings, reports, _) {
            final startDate = reports.getStartDateForRange(_range);
            final sales = billing.sales.where((s) => s.date.isAfter(startDate)).toList();
            final staffMembers = settings.staffList;

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

                const Text('Staff Sales Volume & Counter Metrics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),

                if (staffMembers.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(child: Text('No staff members registered. Load demo data in Dev Tools.')),
                    ),
                  )
                else
                  ...staffMembers.map((user) {
                    final staffSales = sales.where((s) => s.staffId == user.id || s.staffName.toLowerCase() == user.name.toLowerCase()).toList();
                    final volume = staffSales.fold(0.0, (sum, s) => sum + s.netTotal);
                    final avgTicket = staffSales.isNotEmpty ? (volume / staffSales.length) : 0.0;

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
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppColors.primaryLight,
                                      child: Text(user.name[0], style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                        Text('Role: ${user.role.name.toUpperCase()}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                      ],
                                    ),
                                  ],
                                ),
                                Text(
                                  AppFormatters.currency(volume),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryDark),
                                ),
                              ],
                            ),
                            const Divider(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Invoices Billed: ${staffSales.length}', style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                                Text('Avg Ticket Size: ${AppFormatters.currency(avgTicket)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            );
          },
        ),
      ),
    );
  }
}

