import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../core/role_guard.dart';
import '../../data/models/purchase_order_model.dart';
import '../../widgets/empty_state.dart';
import '../../providers/supplier_provider.dart';

class PurchaseOrdersScreen extends StatelessWidget {
  const PurchaseOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Purchase Orders (PO)'),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('New Order'),
          onPressed: () => Navigator.pushNamed(context, '/new-po'),
        ),
        body: Consumer<SupplierProvider>(
          builder: (context, supplierProvider, _) {
            final orders = supplierProvider.purchaseOrders;

            if (orders.isEmpty) {
              return EmptyState(
                icon: Icons.assignment_outlined,
                title: 'No Purchase Orders',
                message: 'Create purchase orders for medicine distributors to restock low and out-of-stock items.',
                buttonText: 'Create First PO',
                onButtonPressed: () => Navigator.pushNamed(context, '/new-po'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final po = orders[index];
                final isReceived = po.status == POStatus.received;

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
                            Text(
                              po.poNumber,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isReceived ? AppColors.successLight : AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                po.status.label,
                                style: TextStyle(
                                  color: isReceived ? AppColors.success : AppColors.primaryDark,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('Supplier: ${po.supplierName}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        Text('Date: ${AppFormatters.date(po.orderDate)} • ${po.items.length} items ordered', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        if (po.notes.isNotEmpty)
                          Text('Notes: ${po.notes}', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                        const Divider(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppFormatters.currency(po.totalAmount),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryDark),
                            ),
                            if (!isReceived)
                              ElevatedButton.icon(
                                icon: const Icon(Icons.check_circle_outline, size: 16),
                                label: const Text('Receive Goods'),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/goods-received', arguments: po.id);
                                },
                              ),
                          ],
                        ),
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

