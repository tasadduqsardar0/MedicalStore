import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../core/validators.dart';
import '../../core/stock_rules.dart';
import '../../core/role_guard.dart';
import '../../widgets/app_text_field.dart';
import '../../providers/supplier_provider.dart';
import '../../providers/inventory_provider.dart';

class GoodsReceivedScreen extends StatefulWidget {
  final String? purchaseOrderId;

  const GoodsReceivedScreen({super.key, this.purchaseOrderId});

  @override
  State<GoodsReceivedScreen> createState() => _GoodsReceivedScreenState();
}

class _GoodsReceivedScreenState extends State<GoodsReceivedScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedSupplierId;
  String? _selectedMedicineId;
  final _batchNumberController = TextEditingController();
  final _packsController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  DateTime? _selectedExpiryDate;

  @override
  void initState() {
    super.initState();
    if (widget.purchaseOrderId != null) {
      final supplierProvider = Provider.of<SupplierProvider>(context, listen: false);
      final po = supplierProvider.getPurchaseOrderById(widget.purchaseOrderId!);
      if (po != null) {
        _selectedSupplierId = po.supplierId;
        if (po.items.isNotEmpty) {
          _selectedMedicineId = po.items.first.medicineId;
          _packsController.text = po.items.first.packQuantity.toString();
          _purchasePriceController.text = po.items.first.purchasePricePerPack.toStringAsFixed(0);
        }
      }
    }
  }

  @override
  void dispose() {
    _batchNumberController.dispose();
    _packsController.dispose();
    _purchasePriceController.dispose();
    super.dispose();
  }

  Future<void> _pickExpiryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 365)),
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );

    if (picked != null) {
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
    if (_selectedSupplierId == null || _selectedMedicineId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select supplier and medicine'), backgroundColor: AppColors.danger),
      );
      return;
    }
    if (_selectedExpiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a valid expiry date'), backgroundColor: AppColors.danger),
      );
      return;
    }

    final supplierProvider = Provider.of<SupplierProvider>(context, listen: false);
    final inventory = Provider.of<InventoryProvider>(context, listen: false);
    final med = inventory.getMedicineById(_selectedMedicineId!);

    final packs = int.tryParse(_packsController.text.trim()) ?? 0;
    final purchasePrice = double.tryParse(_purchasePriceController.text.trim()) ?? 0.0;

    supplierProvider.receiveGoods(
      poId: widget.purchaseOrderId,
      supplierId: _selectedSupplierId!,
      medicineId: _selectedMedicineId!,
      medicineName: med?.name ?? 'Medicine',
      batchNumber: _batchNumberController.text.trim().toUpperCase(),
      expiryDate: _selectedExpiryDate!,
      packQuantity: packs,
      unitsPerPack: med?.unitsPerPack ?? 1,
      purchasePrice: purchasePrice,
      inventoryProvider: inventory,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Goods received! Batch created and added to sellable stock.'),
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

    return RoleGuard(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Goods Received Note (GRN)'),
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
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.inventory, color: AppColors.primaryDark),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Recording Goods Received automatically creates new stock batches in Inventory and updates the supplier ledger account.',
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
                    hint: const Text('Select Supplier *'),
                    items: suppliers.map((s) => DropdownMenuItem(value: s.id, child: Text(s.companyName))).toList(),
                    onChanged: (val) => setState(() => _selectedSupplierId = val),
                    validator: (v) => v == null ? 'Select supplier' : null,
                  ),
                  const SizedBox(height: 14),

                  // Medicine
                  DropdownButtonFormField<String>(
                    key: ValueKey('med_$_selectedMedicineId'),
                    initialValue: _selectedMedicineId,
                    hint: const Text('Select Medicine Received *'),
                    items: medicines.map((m) => DropdownMenuItem(value: m.id, child: Text(m.name))).toList(),
                    onChanged: (val) => setState(() => _selectedMedicineId = val),
                    validator: (v) => v == null ? 'Select medicine' : null,
                  ),
                  const SizedBox(height: 14),

                  // Batch Number
                  AppTextField(
                    controller: _batchNumberController,
                    label: 'Batch Number (printed on box) *',
                    hint: 'e.g. B-2405',
                    validator: (v) => AppValidators.requiredField(v, 'Enter batch number'),
                  ),
                  const SizedBox(height: 14),

                  // Expiry Date
                  InkWell(
                    onTap: _pickExpiryDate,
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
                                ? 'Expiry Date: ${AppFormatters.date(_selectedExpiryDate!)}'
                                : 'Select Expiry Date * (Future date only)',
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
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _packsController,
                          label: 'Received Packs *',
                          hint: 'e.g. 50',
                          keyboardType: TextInputType.number,
                          validator: AppValidators.positiveInteger,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          controller: _purchasePriceController,
                          label: 'Purchase Rate / Pack (Rs) *',
                          hint: 'e.g. 40',
                          keyboardType: TextInputType.number,
                          validator: AppValidators.positiveNumber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Receive Goods & Create Batch'),
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

