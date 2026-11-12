import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../core/role_guard.dart';
import '../../data/models/purchase_order_model.dart';
import '../../widgets/app_text_field.dart';
import '../../providers/supplier_provider.dart';
import '../../providers/inventory_provider.dart';

class NewPurchaseOrderScreen extends StatefulWidget {
  final String? preselectedSupplierId;

  const NewPurchaseOrderScreen({super.key, this.preselectedSupplierId});

  @override
  State<NewPurchaseOrderScreen> createState() => _NewPurchaseOrderScreenState();
}

class _NewPurchaseOrderScreenState extends State<NewPurchaseOrderScreen> {
  String? _selectedSupplierId;
  final _notesController = TextEditingController();

  final List<POLineItem> _items = [];

  // Item builder inputs
  String? _selectedMedicineId;
  final _packsController = TextEditingController(text: '20');
  final _purchasePriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedSupplierId = widget.preselectedSupplierId;
  }

  @override
  void dispose() {
    _notesController.dispose();
    _packsController.dispose();
    _purchasePriceController.dispose();
    super.dispose();
  }

  void _addItem() {
    if (_selectedMedicineId == null) return;
    final inventory = Provider.of<InventoryProvider>(context, listen: false);
    final med = inventory.getMedicineById(_selectedMedicineId!);
    final packs = int.tryParse(_packsController.text.trim()) ?? 1;
    final price = double.tryParse(_purchasePriceController.text.trim()) ?? (med?.salePrice ?? 50.0) * 0.8;

    setState(() {
      _items.add(
        POLineItem(
          medicineId: _selectedMedicineId!,
          medicineName: med?.name ?? 'Medicine',
          packQuantity: packs,
          purchasePricePerPack: price,
        ),
      );
      _selectedMedicineId = null;
      _purchasePriceController.clear();
    });
  }

  void _submit() {
    if (_selectedSupplierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select supplier'), backgroundColor: AppColors.danger),
      );
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one medicine item'), backgroundColor: AppColors.danger),
      );
      return;
    }

    final supplierProvider = Provider.of<SupplierProvider>(context, listen: false);
    final sup = supplierProvider.getSupplierById(_selectedSupplierId!);

    final totalAmount = _items.fold(0.0, (sum, i) => sum + i.lineTotal);
    final poNumber = 'PO-${2000 + supplierProvider.nextPOSuffix}';

    final order = PurchaseOrder(
      id: 'po-${DateTime.now().millisecondsSinceEpoch}',
      poNumber: poNumber,
      supplierId: _selectedSupplierId!,
      supplierName: sup?.companyName ?? 'Supplier',
      orderDate: DateTime.now(),
      status: POStatus.sent,
      items: _items,
      totalAmount: totalAmount,
      notes: _notesController.text.trim(),
    );

    supplierProvider.createPurchaseOrder(order);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$poNumber created and sent to supplier'), backgroundColor: AppColors.success),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final supplierProvider = context.watch<SupplierProvider>();
    final inventory = context.watch<InventoryProvider>();
    final suppliers = supplierProvider.allSuppliers;
    final medicines = inventory.allMedicines;

    final poTotal = _items.fold(0.0, (sum, i) => sum + i.lineTotal);

    return RoleGuard(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Create Purchase Order'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Supplier Details *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      key: ValueKey('sup_$_selectedSupplierId'),
                      initialValue: _selectedSupplierId,
                      hint: const Text('Select Supplier / Distributor'),
                      items: suppliers.map((s) {
                        return DropdownMenuItem(value: s.id, child: Text(s.companyName));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedSupplierId = val),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _notesController,
                      label: 'Order Notes (optional)',
                      hint: 'e.g. Urgent delivery requested by Friday',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Add Medicine Line Item
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Add Medicine Item', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      key: ValueKey('med_$_selectedMedicineId'),
                      initialValue: _selectedMedicineId,
                      hint: const Text('Choose medicine to order...'),
                      items: medicines.map((m) {
                        return DropdownMenuItem(value: m.id, child: Text('${m.name} (${m.company})'));
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedMedicineId = val;
                          final med = inventory.getMedicineById(val ?? '');
                          if (med != null) {
                            _purchasePriceController.text = (med.salePrice * 0.8).toStringAsFixed(0);
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _packsController,
                            label: 'Packs *',
                            hint: '20',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextField(
                            controller: _purchasePriceController,
                            label: 'Rate / Pack (Rs)',
                            hint: '40',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Item to Order'),
                      onPressed: _addItem,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Order Lines Summary
            if (_items.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Order Items Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      ...List.generate(_items.length, (idx) {
                        final item = _items[idx];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text('${item.packQuantity}x ${item.medicineName} @ ${AppFormatters.currency(item.purchasePricePerPack)}'),
                              ),
                              Text(AppFormatters.currency(item.lineTotal), style: const TextStyle(fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                                onPressed: () => setState(() => _items.removeAt(idx)),
                              ),
                            ],
                          ),
                        );
                      }),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Estimated Order Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(
                            AppFormatters.currency(poTotal),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryDark),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Save & Issue Purchase Order'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

