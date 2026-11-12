import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/app_search_bar.dart';
import '../../providers/billing_provider.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final billing = context.watch<BillingProvider>();
    final sales = billing.sales.where((s) {
      if (_searchQuery.isEmpty) return true;
      final inv = s.invoiceNumber.toLowerCase();
      final cust = s.customerName.toLowerCase();
      return inv.contains(_searchQuery) || cust.contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sales & Invoices History'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AppSearchBar(
              controller: _searchController,
              hintText: 'Search by invoice number (e.g. INV-1001) or customer...',
              onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
              onClear: () => setState(() => _searchQuery = ''),
            ),
          ),
          Expanded(
            child: sales.isEmpty
                ? const EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No Sales Recorded',
                    message: 'Past sales invoices will be displayed here for auditing and return processing.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: sales.length,
                    itemBuilder: (context, index) {
                      final sale = sales[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.receipt_outlined, color: AppColors.primaryDark),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                sale.invoiceNumber,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                AppFormatters.currency(sale.netTotal),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryDark),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 2),
                              Text(
                                '${sale.customerName} • ${sale.paymentMethod.label}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                              ),
                              Text(
                                '${AppFormatters.dateTime(sale.date)} • ${sale.items.length} items',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textTertiary),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/invoice-detail',
                              arguments: sale.id,
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

