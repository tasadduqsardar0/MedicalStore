import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../core/role_guard.dart';
import '../../widgets/empty_state.dart';
import '../../providers/supplier_provider.dart';

class SupplierProfileLedgerScreen extends StatelessWidget {
  final String supplierId;

  const SupplierProfileLedgerScreen({super.key, required this.supplierId});

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      child: Consumer<SupplierProvider>(
        builder: (context, supplierProvider, _) {
          final sup = supplierProvider.getSupplierById(supplierId);
          if (sup == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Supplier Profile')),
              body: const Center(child: Text('Supplier not found')),
            );
          }

          final ledger = supplierProvider.getLedgerForSupplier(sup.id);

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: Text(sup.companyName),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () {
                    Navigator.pushNamed(context, '/edit-supplier', arguments: sup.id);
                  },
                ),
              ],
            ),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: const Text('New Order'),
                      onPressed: () => Navigator.pushNamed(context, '/new-po', arguments: sup.id),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.payment),
                      label: const Text('Record Payment'),
                      onPressed: () => Navigator.pushNamed(context, '/supplier-payment', arguments: sup.id),
                    ),
                  ),
                ],
              ),
            ),
            body: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Info Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                sup.companyName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: sup.balancePayable > 0 ? AppColors.dangerLight : AppColors.successLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Payable: ${AppFormatters.currency(sup.balancePayable)}',
                                style: TextStyle(
                                  color: sup.balancePayable > 0 ? AppColors.danger : AppColors.success,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Contact Person: ${sup.contactPerson}', style: const TextStyle(fontSize: 13)),
                        Text('Phone: ${sup.phone}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        if (sup.email.isNotEmpty)
                          Text('Email: ${sup.email}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        if (sup.address.isNotEmpty)
                          Text('Address: ${sup.address}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Supplier Ledger Statements',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),

                if (ledger.isEmpty)
                  const EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No Ledger Entries',
                    message: 'Purchases, received shipments, and recorded payments will be listed here.',
                  )
                    else ...ledger.map((entry) {
                    final isPayment = entry.type.name == 'paymentMade';
                    final isReturn = entry.type.name == 'purchaseReturn';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isPayment
                                ? AppColors.successLight
                                : (isReturn ? AppColors.warningLight : AppColors.primaryLight),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isPayment ? Icons.arrow_downward : (isReturn ? Icons.keyboard_return : Icons.inventory_2),
                            color: isPayment
                                ? AppColors.success
                                : (isReturn ? AppColors.warning : AppColors.primaryDark),
                            size: 20,
                          ),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.type.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(
                              '${isPayment || isReturn ? "-" : "+"}${AppFormatters.currency(entry.amount)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isPayment ? AppColors.success : (isReturn ? AppColors.warning : AppColors.danger),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${entry.reference} • ${AppFormatters.date(entry.date)}', style: const TextStyle(fontSize: 11)),
                            if (entry.notes.isNotEmpty)
                              Text(entry.notes, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            Text(
                              'Balance After: ${AppFormatters.currency(entry.balanceAfter)}',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}

