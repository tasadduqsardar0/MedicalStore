import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/validators.dart';
import '../../core/formatters.dart';
import '../../core/stock_rules.dart';
import '../../widgets/app_text_field.dart';
import '../../data/models/batch_model.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/auth_provider.dart';

class AddBatchScreen extends StatefulWidget {
  final String? preselectedMedicineId;

  const AddBatchScreen({super.key, this.preselectedMedicineId});

  @override
  State<AddBatchScreen> createState() => _AddBatchScreenState();
}

class _AddBatchScreenState extends State<AddBatchScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedMedicineId;
  final _batchNumberController = TextEditingController();
  final _quantityPacksController = TextEditingController();
  final _purchasePriceController = TextEditingController();

  DateTime? _selectedExpiryDate;

  @override
  void initState() {
    super.initState();
    _selectedMedicineId = widget.preselectedMedicineId;
  }

  @override
  void dispose() {
    _batchNumberController.dispose();
    _quantityPacksController.dispose();
    _purchasePriceController.dispose();
    super.dispose();
  }

  Future<void> _pickExpiryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 365)),
      firstDate: DateTime(2020), // Allow picking any date so validation triggers!
      lastDate: DateTime(2040),
    );

    if (picked != null) {
      // Validate rule: past date is rejected!
      if (!StockRules.isValidBatchExpiry(picked)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A new batch with an expiry date in the past is not accepted.'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }
      setState(() => _selectedExpiryDate = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMedicineId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a medicine'), backgroundColor: AppColors.danger),
      );
      return;
    }
    if (_selectedExpiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an expiry date'), backgroundColor: AppColors.danger),
      );
      return;
    }

    // Rule: past date rejected
    if (!StockRules.isValidBatchExpiry(_selectedExpiryDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A new batch with an expiry date in the past is not accepted.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final inventory = Provider.of<InventoryProvider>(context, listen: false);
    final med = inventory.getMedicineById(_selectedMedicineId!);
    final packs = int.tryParse(_quantityPacksController.text.trim()) ?? 0;
    final unitsPerPack = med?.unitsPerPack ?? 1;
    final totalUnits = packs * unitsPerPack;
    final purchasePrice = double.tryParse(_purchasePriceController.text.trim()) ?? 0.0;

    final batch = Batch(
      id: 'bat-${DateTime.now().millisecondsSinceEpoch}',
      medicineId: _selectedMedicineId!,
      batchNumber: _batchNumberController.text.trim().toUpperCase(),
      expiryDate: _selectedExpiryDate!,
      quantityUnits: totalUnits,
      purchasePrice: purchasePrice,
    );

    final success = inventory.addBatch(batch);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Batch registered successfully'), backgroundColor: AppColors.success),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();
    final auth = context.watch<AuthProvider>();
    final isOwner = auth.isOwner;
    final medicines = inventory.allMedicines;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Medicine Batch'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Medicine Selector
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Medicine *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      key: ValueKey(_selectedMedicineId),
                      initialValue: _selectedMedicineId,
                      hint: const Text('Choose medicine...'),
                      items: medicines.map((m) {
                        return DropdownMenuItem(value: m.id, child: Text(m.name));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedMedicineId = val),
                      validator: (v) => v == null ? 'Please select a medicine' : null,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Batch Number
                AppTextField(
                  controller: _batchNumberController,
                  label: 'Batch Number *',
                  hint: 'e.g. B-2401 or AUG-625',
                  validator: (v) => AppValidators.requiredField(v, 'Enter batch number'),
                ),
                const SizedBox(height: 16),

                // Expiry Date Picker
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Expiry Date *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _pickExpiryDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedExpiryDate != null
                                  ? AppFormatters.date(_selectedExpiryDate!)
                                  : 'Select Expiry Date (Future date only)',
                              style: TextStyle(
                                fontSize: 14,
                                color: _selectedExpiryDate != null ? AppColors.textPrimary : AppColors.textTertiary,
                                fontWeight: _selectedExpiryDate != null ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                            const Icon(Icons.calendar_today, size: 20, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Quantity (Packs)
                AppTextField(
                  controller: _quantityPacksController,
                  label: 'Initial Quantity (Packs) *',
                  hint: 'e.g. 50 packs',
                  keyboardType: TextInputType.number,
                  validator: AppValidators.positiveInteger,
                ),
                const SizedBox(height: 16),

                // Purchase Price (OWNER ONLY)
                if (isOwner) ...[
                  AppTextField(
                    controller: _purchasePriceController,
                    label: 'Purchase Price per Pack (Rs) [Owner Only]',
                    hint: 'e.g. 32',
                    keyboardType: TextInputType.number,
                    validator: AppValidators.positiveNumber,
                  ),
                  const SizedBox(height: 16),
                ],

                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Register Batch'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

