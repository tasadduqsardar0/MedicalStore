import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../core/role_guard.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/app_search_bar.dart';
import '../../providers/supplier_provider.dart';

class SuppliersListScreen extends StatefulWidget {
  const SuppliersListScreen({super.key});

  @override
  State<SuppliersListScreen> createState() => _SuppliersListScreenState();
}

class _SuppliersListScreenState extends State<SuppliersListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Suppliers & Distributors'),
          actions: [
            IconButton(
              icon: const Icon(Icons.receipt_long),
              tooltip: 'Purchase Orders',
              onPressed: () => Navigator.pushNamed(context, '/purchase-orders'),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Add Supplier'),
          onPressed: () => Navigator.pushNamed(context, '/add-supplier'),
        ),
        body: Consumer<SupplierProvider>(
          builder: (context, supplierProvider, _) {
            final suppliers = supplierProvider.filteredSuppliers;

            return Column(
              children: [
                // Quick Purchasing Actions Strip
                Container(
                  height: 52,
                  color: AppColors.surface,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ActionChip(
                          avatar: const Icon(Icons.assignment_outlined, size: 16, color: AppColors.primaryDark),
                          label: const Text('Purchase Orders'),
                          onPressed: () => Navigator.pushNamed(context, '/purchase-orders'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ActionChip(
                          avatar: const Icon(Icons.add_box_outlined, size: 16, color: AppColors.success),
                          label: const Text('Receive Goods (GRN)'),
                          onPressed: () => Navigator.pushNamed(context, '/goods-received'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ActionChip(
                          avatar: const Icon(Icons.keyboard_return, size: 16, color: AppColors.warning),
                          label: const Text('Purchase Return'),
                          onPressed: () => Navigator.pushNamed(context, '/purchase-return'),
                        ),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.payment, size: 16, color: AppColors.primary),
                        label: const Text('Supplier Payment'),
                        onPressed: () => Navigator.pushNamed(context, '/supplier-payment'),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: AppSearchBar(
                    controller: _searchController,
                    hintText: 'Search supplier company or contact...',
                    onChanged: (val) => supplierProvider.setSearchQuery(val),
                    onClear: () => supplierProvider.setSearchQuery(''),
                  ),
                ),
                Expanded(
                  child: suppliers.isEmpty
                      ? EmptyState(
                          icon: Icons.local_shipping_outlined,
                          title: 'No Suppliers Found',
                          message: 'Add medicine distributors and pharmaceutical suppliers to manage orders and payables.',
                          buttonText: 'Add First Supplier',
                          onButtonPressed: () => Navigator.pushNamed(context, '/add-supplier'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                          itemCount: suppliers.length,
                          itemBuilder: (context, index) {
                            final sup = suppliers[index];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.business_outlined, color: AppColors.primaryDark),
                                ),
                                title: Text(
                                  sup.companyName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 2),
                                    Text(
                                      'Contact: ${sup.contactPerson} • ${sup.phone}',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                    ),
                                    if (sup.address.isNotEmpty)
                                      Text(
                                        sup.address,
                                        style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text('Payable Balance', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                    const SizedBox(height: 2),
                                    Text(
                                      AppFormatters.currency(sup.balancePayable),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: sup.balancePayable > 0 ? AppColors.danger : AppColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/supplier-profile',
                                    arguments: sup.id,
                                  );
                                },
                              ),
                            );
                          },
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

