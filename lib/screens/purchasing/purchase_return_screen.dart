import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../core/validators.dart';
import '../../core/role_guard.dart';
import '../../data/models/batch_model.dart';
import '../../widgets/app_text_field.dart';
import '../../providers/supplier_provider.dart';
import '../../providers/inventory_provider.dart';

class PurchaseReturnScreen extends StatefulWidget {
  const PurchaseReturnScreen({super.key});

  @override
  State<PurchaseReturnScreen> createState() => _PurchaseReturnScreenState();
}

class _PurchaseReturnScreenState extends State<PurchaseReturnScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedSupplierId;
  String? _selectedMedicineId;
  String? _selectedBatchNumber;
  final _packsController = TextEditingController();
  final _reasonController = TextEditingController(text: 'Near-expiry stock returned for credit');

  @override
  void dispose() {
    _packsController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSupplierId == null || _selectedMedicineId == null || _selectedBatchNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select supplier, medicine and batch'), backgroundColor: AppColors.danger),
      );
      return;
    }

    final supplierProvider = Provider.of<SupplierProvider>(context, listen: false);
    final inventory = Provider.of<InventoryProvider>(context, listen: false);

    final sup = supplierProvider.getSupplierById(_selectedSupplierId!);
    final med = inventory.getMedicineById(_selectedMedicineId!);
    final batches = inventory.getBatchesForMedicine(_selectedMedicineId!);
    final batch = batches.firstWhere((b) => b.batchNumber == _selectedBatchNumber);

    final packs = int.tryParse(_packsController.text.trim()) ?? 0;

    supplierProvider.createPurchaseReturn(
      supplierId: _selectedSupplierId!,
      supplierName: sup?.companyName ?? 'Supplier',
      medicineId: _selectedMedicineId!,
      medicineName: med?.name ?? 'Medicine',
      batchNumber: _selectedBatchNumber!,
      packQuantity: packs,
      unitsPerPack: med?.unitsPerPack ?? 1,
      unitPrice: batch.purchasePrice,
      reason: _reasonController.text.trim(),
      inventoryProvider: inventory,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Purchase return processed. Stock deducted and debit note added to supplier ledger.'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final supplierProvider = context.watch<SupplierProvider>();
    final inventory = context.watch<InventoryProvider>();
    final suppliers = supplierProvider.allSuppliers;
    final medicines = inventory.allMedicines;
    final List<Batch> batches = _selectedMedicineId != null ? inventory.getBatchesForMedicine(_selectedMedicineId!) : <Batch>[];

    return RoleGuard(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Return to Supplier (Debit Note)'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warningLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.warning),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.keyboard_return, color: AppColors.warning),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Return near-expiry or damaged batches to distributors for credit adjustment on your outstanding payable ledger.',
                            style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Supplier
                  DropdownButtonFormField<String>(
                    key: ValueKey('sup_$_selectedSupplierId'),
                    initialValue: _selectedSupplierId,
                    hint: const Text('Select Supplier / Distributor *'),
                    items: suppliers.map((s) => DropdownMenuItem(value: s.id, child: Text(s.companyName))).toList(),
                    onChanged: (val) => setState(() => _selectedSupplierId = val),
                    validator: (v) => v == null ? 'Select supplier' : null,
                  ),
                  const SizedBox(height: 14),

                  // Medicine
                  DropdownButtonFormField<String>(
                    key: ValueKey('med_$_selectedMedicineId'),
                    initialValue: _selectedMedicineId,
                    hint: const Text('Select Medicine *'),
                    items: medicines.map((m) => DropdownMenuItem(value: m.id, child: Text(m.name))).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedMedicineId = val;
                        _selectedBatchNumber = null;
                      });
                    },
                    validator: (v) => v == null ? 'Select medicine' : null,
                  ),
                  const SizedBox(height: 14),

                  // Batch Selector
                  if (batches.isNotEmpty) ...[
                    DropdownButtonFormField<String>(
                      key: ValueKey('bat_$_selectedBatchNumber'),
                      initialValue: _selectedBatchNumber,
                      hint: const Text('Select Batch to Return *'),
                      items: batches.map<DropdownMenuItem<String>>((b) {
                        return DropdownMenuItem<String>(
                          value: b.batchNumber,
                          child: Text('Batch ${b.batchNumber} (Expires: ${AppFormatters.date(b.expiryDate)})'),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedBatchNumber = val),
                      validator: (v) => v == null ? 'Select batch' : null,
                    ),
                    const SizedBox(height: 14),
                  ],

                  AppTextField(
                    controller: _packsController,
                    label: 'Packs to Return *',
                    hint: 'e.g. 10',
                    keyboardType: TextInputType.number,
                    validator: AppValidators.positiveInteger,
                  ),
                  const SizedBox(height: 14),

                  AppTextField(
                    controller: _reasonController,
                    label: 'Return Reason *',
                    hint: 'e.g. Near-expiry within 30 days, damaged carton',
                    validator: (v) => AppValidators.requiredField(v, 'Enter reason'),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
                    onPressed: _submit,
                    child: const Text('Confirm Purchase Return'),
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

