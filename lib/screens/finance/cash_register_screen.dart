import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../core/validators.dart';
import '../../core/role_guard.dart';
import '../../widgets/app_text_field.dart';
import '../../providers/finance_provider.dart';
import '../../providers/billing_provider.dart';
import '../../providers/auth_provider.dart';

class CashRegisterScreen extends StatefulWidget {
  const CashRegisterScreen({super.key});

  @override
  State<CashRegisterScreen> createState() => _CashRegisterScreenState();
}

class _CashRegisterScreenState extends State<CashRegisterScreen> {
  final _openingCashController = TextEditingController(text: '5000');
  final _actualCashController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _openingCashController.dispose();
    _actualCashController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _openRegister() {
    final finance = Provider.of<FinanceProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final opening = double.tryParse(_openingCashController.text.trim()) ?? 0.0;

    finance.openRegister(
      openingCash: opening,
      openedBy: auth.currentUser?.name ?? 'Owner',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cash drawer opened for today\'s shift'), backgroundColor: AppColors.success),
    );
  }

  void _closeRegister() {
    final finance = Provider.of<FinanceProvider>(context, listen: false);
    final billing = Provider.of<BillingProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final actual = double.tryParse(_actualCashController.text.trim()) ?? 0.0;

    finance.closeRegister(
      actualCash: actual,
      notes: _notesController.text.trim(),
      closedBy: auth.currentUser?.name ?? 'Owner',
      billingProvider: billing,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Shift closed. Daily closing summary recorded.'), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final billing = context.watch<BillingProvider>();
    final isRegisterOpen = finance.isRegisterOpen;
    final register = finance.currentCashRegister;

    // Shift sales
    double cashSales = 0.0;
    if (isRegisterOpen && register != null) {
      final sales = billing.sales.where((s) => s.date.isAfter(register.openingTime));
      cashSales = sales.where((s) => s.paymentMethod.name == 'cash').fold(0.0, (sum, s) => sum + s.netTotal);
    }

    final double expectedInDrawer = register != null ? (register.openingCash + cashSales) : 0.0;

    return RoleGuard(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Cash Register & Till'),
          actions: [
            IconButton(
              icon: const Icon(Icons.summarize_outlined),
              tooltip: 'Daily Closing Summaries',
              onPressed: () => Navigator.pushNamed(context, '/daily-closing'),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Status Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isRegisterOpen ? AppColors.successLight : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isRegisterOpen ? AppColors.success : AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(
                    isRegisterOpen ? Icons.lock_open : Icons.lock_outline,
                    color: isRegisterOpen ? AppColors.success : AppColors.textSecondary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isRegisterOpen ? 'Cash Register is OPEN' : 'Cash Register is CLOSED',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isRegisterOpen ? AppColors.success : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          isRegisterOpen
                            ? 'Opened at ${AppFormatters.time(register!.openingTime)} by ${register.openedBy}'
                            : 'Open register with initial cash before sales.',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (!isRegisterOpen) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Open Shift Cash Drawer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _openingCashController,
                        label: 'Opening Cash in Till (Rs) *',
                        hint: 'e.g. 5000',
                        keyboardType: TextInputType.number,
                        validator: AppValidators.nonNegativeNumber,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.lock_open),
                        label: const Text('Open Register Till'),
                        onPressed: _openRegister,
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Active Till Metrics
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Shift Live Cash Metrics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 12),
                      _Row(label: 'Opening Float Cash:', value: AppFormatters.currency(register!.openingCash)),
                      _Row(label: 'Cash Sales (since shift start):', value: AppFormatters.currency(cashSales), color: AppColors.success),
                      const Divider(height: 16),
                      _Row(
                        label: 'Expected Cash in Drawer:',
                        value: AppFormatters.currency(expectedInDrawer),
                        isBold: true,
                        fontSize: 15,
                        color: AppColors.primaryDark,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Close Till Form
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Close Register & Reconcile Count', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _actualCashController,
                        label: 'Physical Counted Cash in Drawer (Rs) *',
                        hint: 'Count currency notes and coins',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _notesController,
                        label: 'Closing Remarks / Reason for difference',
                        hint: 'e.g. Exact match or shortage reason',
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                        onPressed: _closeRegister,
                        child: const Text('Close Shift & Generate Summary'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'Finance & Accounting Modules',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.summarize_outlined, color: AppColors.primaryDark),
                title: const Text('Daily Closing Summary', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text('Review shift counts and cash discrepancies'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(context, '/daily-closing'),
              ),
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.money_off_outlined, color: AppColors.danger),
                title: const Text('Store Expenses', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text('View and record rent, utilities, tea & supplies'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(context, '/expenses'),
              ),
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.trending_up, color: AppColors.success),
                title: const Text('Profit & Loss Statement', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text('Revenue, COGS, gross margin and net profit'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(context, '/profit-and-loss'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final double fontSize;
  final Color? color;

  const _Row({
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
          Text(label, style: TextStyle(fontSize: fontSize, color: AppColors.textSecondary)),
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

