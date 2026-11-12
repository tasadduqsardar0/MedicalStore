import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../core/role_guard.dart';
import '../../providers/supplier_provider.dart';
import '../../providers/reports_provider.dart';

class PurchaseReportScreen extends StatefulWidget {
  const PurchaseReportScreen({super.key});

  @override
  State<PurchaseReportScreen> createState() => _PurchaseReportScreenState();
}

class _PurchaseReportScreenState extends State<PurchaseReportScreen> {
  ReportDateRange _range = ReportDateRange.allTime;

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Purchase & Supplier Report'),
        ),
        body: Consumer2<SupplierProvider, ReportsProvider>(
          builder: (context, supplierProvider, reports, _) {
            final startDate = reports.getStartDateForRange(_range);
            final orders = supplierProvider.purchaseOrders.where((po) => po.orderDate.isAfter(startDate)).toList();
            final totalPurchases = orders.fold(0.0, (sum, o) => sum + o.totalAmount);
            final totalPayables = supplierProvider.totalBalancePayable;

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

                Row(
                  children: [
                    Expanded(
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
                            const Text('Total Procurement', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            const SizedBox(height: 6),
                            Text(
                              AppFormatters.currency(totalPurchases),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
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
                            const Text('Current Payables', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            const SizedBox(height: 6),
                            Text(
                              AppFormatters.currency(totalPayables),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.danger),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                const Text('Supplier Procurement Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),

                ...supplierProvider.allSuppliers.map((sup) {
                  final supOrders = orders.where((o) => o.supplierId == sup.id);
                  final supTotal = supOrders.fold(0.0, (sum, o) => sum + o.totalAmount);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(sup.companyName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text('${supOrders.length} orders placed • Balance: ${AppFormatters.currency(sup.balancePayable)}'),
                      trailing: Text(
                        AppFormatters.currency(supTotal),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryDark),
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

