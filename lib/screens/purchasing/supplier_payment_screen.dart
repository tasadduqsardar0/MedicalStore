import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../core/validators.dart';
import '../../core/role_guard.dart';
import '../../widgets/app_text_field.dart';
import '../../providers/supplier_provider.dart';

class SupplierPaymentScreen extends StatefulWidget {
  final String? preselectedSupplierId;

  const SupplierPaymentScreen({super.key, this.preselectedSupplierId});

  @override
  State<SupplierPaymentScreen> createState() => _SupplierPaymentScreenState();
}

class _SupplierPaymentScreenState extends State<SupplierPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedSupplierId;
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();
  String _paymentMethod = 'Bank Transfer';

  final List<String> _methods = ['Bank Transfer', 'Cash', 'Cheque'];

  @override
  void initState() {
    super.initState();
    _selectedSupplierId = widget.preselectedSupplierId;
    if (_selectedSupplierId != null) {
      final supplierProvider = Provider.of<SupplierProvider>(context, listen: false);
      final sup = supplierProvider.getSupplierById(_selectedSupplierId!);
      if (sup != null && sup.balancePayable > 0) {
        _amountController.text = sup.balancePayable.toStringAsFixed(0);
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSupplierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select supplier'), backgroundColor: AppColors.danger),
      );
      return;
    }

    final supplierProvider = Provider.of<SupplierProvider>(context, listen: false);
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    supplierProvider.recordPayment(
      supplierId: _selectedSupplierId!,
      amount: amount,
      reference: '${_referenceController.text.trim()} ($_paymentMethod)',
      notes: _notesController.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Supplier payment recorded. Ledger updated.'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final supplierProvider = context.watch<SupplierProvider>();
    final suppliers = supplierProvider.allSuppliers;
    final sup = _selectedSupplierId != null ? supplierProvider.getSupplierById(_selectedSupplierId!) : null;

    return RoleGuard(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Record Supplier Payment'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    key: ValueKey('sup_$_selectedSupplierId'),
                    initialValue: _selectedSupplierId,
                    hint: const Text('Select Supplier / Distributor *'),
                    items: suppliers.map((s) => DropdownMenuItem(value: s.id, child: Text(s.companyName))).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedSupplierId = val;
                        final selected = supplierProvider.getSupplierById(val ?? '');
                        if (selected != null) {
                          _amountController.text = selected.balancePayable.toStringAsFixed(0);
                        }
                      });
                    },
                    validator: (v) => v == null ? 'Select supplier' : null,
                  ),
                  const SizedBox(height: 14),

                  if (sup != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Outstanding Payable Balance:'),
                          Text(
                            AppFormatters.currency(sup.balancePayable),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  AppTextField(
                    controller: _amountController,
                    label: 'Payment Amount (Rs) *',
                    hint: 'e.g. 25000',
                    keyboardType: TextInputType.number,
                    validator: AppValidators.positiveNumber,
                  ),
                  const SizedBox(height: 14),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Payment Method *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        key: ValueKey(_paymentMethod),
                        initialValue: _paymentMethod,
                        items: _methods.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _paymentMethod = val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  AppTextField(
                    controller: _referenceController,
                    label: 'Reference / Cheque / Tx ID',
                    hint: 'e.g. HBL-99210 or Cheque # 4512',
                  ),
                  const SizedBox(height: 14),

                  AppTextField(
                    controller: _notesController,
                    label: 'Payment Remarks (optional)',
                    hint: 'e.g. Monthly bill partial clearance',
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Record Payment in Ledger'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

