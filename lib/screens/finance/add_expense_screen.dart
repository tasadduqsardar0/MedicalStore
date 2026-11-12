import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/validators.dart';
import '../../core/role_guard.dart';
import '../../data/models/finance_model.dart';
import '../../widgets/app_text_field.dart';
import '../../providers/finance_provider.dart';
import '../../providers/auth_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  ExpenseCategory _category = ExpenseCategory.teaSnacks;
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _paymentMethod = 'Cash';

  final List<String> _methods = ['Cash', 'Bank Transfer', 'Personal Wallet'];

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final finance = Provider.of<FinanceProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    finance.addExpense(
      category: _category,
      amount: amount,
      description: _descriptionController.text.trim(),
      paymentMethod: _paymentMethod,
      recordedBy: auth.currentUser?.name ?? 'Owner',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense recorded successfully'), backgroundColor: AppColors.success),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Add Store Expense'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Expense Category *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<ExpenseCategory>(
                        key: ValueKey(_category),
                        initialValue: _category,
                        items: ExpenseCategory.values.map((cat) {
                          return DropdownMenuItem(value: cat, child: Text(cat.label));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _category = val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  AppTextField(
                    controller: _amountController,
                    label: 'Expense Amount (Rs) *',
                    hint: 'e.g. 500',
                    keyboardType: TextInputType.number,
                    validator: AppValidators.positiveNumber,
                  ),
                  const SizedBox(height: 14),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Paid Via *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
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
                    controller: _descriptionController,
                    label: 'Description / Purpose (optional)',
                    hint: 'e.g. Staff tea and guest refreshments',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Record Expense'),
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

