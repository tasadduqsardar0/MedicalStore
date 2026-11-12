import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../data/models/sale_model.dart';
import '../../widgets/app_text_field.dart';
import '../../providers/billing_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/prescription_provider.dart';
import '../../providers/auth_provider.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _cashTenderedController = TextEditingController();
  final _splitCashController = TextEditingController();
  final _splitCardController = TextEditingController();

  PaymentMethod _method = PaymentMethod.cash;

  @override
  void initState() {
    super.initState();
    final billing = Provider.of<BillingProvider>(context, listen: false);
    _cashTenderedController.text = billing.netTotal.toStringAsFixed(0);
    billing.setCashTendered(billing.netTotal);
  }

  @override
  void dispose() {
    _cashTenderedController.dispose();
    _splitCashController.dispose();
    _splitCardController.dispose();
    super.dispose();
  }

  void _completePayment() {
    final billing = Provider.of<BillingProvider>(context, listen: false);
    final inventory = Provider.of<InventoryProvider>(context, listen: false);
    final prescriptionProvider = Provider.of<PrescriptionProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    billing.setPaymentMethod(_method);

    if (_method == PaymentMethod.split) {
      final cash = double.tryParse(_splitCashController.text) ?? 0.0;
      final card = double.tryParse(_splitCardController.text) ?? 0.0;

      if ((cash + card) < billing.netTotal) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cash and Card amounts must sum to at least the net total.'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }

      billing.setSplitPaymentDetails(
        SplitPaymentDetails(cashAmount: cash, cardAmount: card),
      );
    }

    final sale = billing.finalizeSale(
      staffId: auth.currentUser?.id ?? 'staff-1',
      staffName: auth.currentUser?.name ?? 'Staff',
      inventoryProvider: inventory,
      prescriptionProvider: prescriptionProvider,
    );

    if (sale != null) {
      Navigator.pushReplacementNamed(
        context,
        '/receipt-preview',
        arguments: sale,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final billing = context.watch<BillingProvider>();
    final netTotal = billing.netTotal;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Payment & Checkout'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Net Total Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'CUSTOMER: ${billing.displayCustomerName.toUpperCase()}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppFormatters.currency(netTotal),
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    if (billing.discount > 0)
                      Text(
                        'Discount applied: ${AppFormatters.currency(billing.discount)}',
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Payment Method Choices
              const Text(
                'Select Payment Method',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _MethodCard(
                      icon: Icons.payments_outlined,
                      label: 'Cash',
                      isSelected: _method == PaymentMethod.cash,
                      onTap: () => setState(() => _method = PaymentMethod.cash),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MethodCard(
                      icon: Icons.credit_card_outlined,
                      label: 'Card',
                      isSelected: _method == PaymentMethod.card,
                      onTap: () => setState(() => _method = PaymentMethod.card),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MethodCard(
                      icon: Icons.call_split_outlined,
                      label: 'Split (Cash+Card)',
                      isSelected: _method == PaymentMethod.split,
                      onTap: () => setState(() => _method = PaymentMethod.split),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Dynamic Payment Inputs based on method
              if (_method == PaymentMethod.cash) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Cash Tendered (Rs)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _cashTenderedController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            prefixText: 'Rs ',
                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          onChanged: (val) {
                            final amount = double.tryParse(val) ?? 0.0;
                            billing.setCashTendered(amount);
                          },
                        ),
                        const SizedBox(height: 16),
                        // Quick Cash Buttons
                        Wrap(
                          spacing: 8,
                          children: [netTotal, 500.0, 1000.0, 2000.0, 5000.0].map((quick) {
                            if (quick < netTotal && quick != netTotal) return const SizedBox.shrink();
                            return ActionChip(
                              label: Text(AppFormatters.currency(quick)),
                              backgroundColor: AppColors.surfaceVariant,
                              onPressed: () {
                                _cashTenderedController.text = quick.toStringAsFixed(0);
                                billing.setCashTendered(quick);
                              },
                            );
                          }).toList(),
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Change to Return:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            Text(
                              AppFormatters.currency(billing.changeAmount),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.success),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ] else if (_method == PaymentMethod.split) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Split Amount Breakdown', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _splitCashController,
                          label: 'Cash Amount (Rs)',
                          hint: '0',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 10),
                        AppTextField(
                          controller: _splitCardController,
                          label: 'Card Amount (Rs)',
                          hint: '0',
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(Icons.credit_card, size: 40, color: AppColors.primary),
                        const SizedBox(height: 12),
                        const Text('Card Terminal Payment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text(
                          'Swipe / Insert customer card for ${AppFormatters.currency(netTotal)}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                onPressed: _completePayment,
                child: const Text('Complete Sale & Print Receipt'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MethodCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppColors.primaryDark : AppColors.textSecondary, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

