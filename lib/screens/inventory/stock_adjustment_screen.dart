import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/validators.dart';
import '../../core/formatters.dart';
import '../../data/models/audit_model.dart';
import '../../data/models/batch_model.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/empty_state.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/auth_provider.dart';

class StockAdjustmentScreen extends StatefulWidget {
  const StockAdjustmentScreen({super.key});

  @override
  State<StockAdjustmentScreen> createState() => _StockAdjustmentScreenState();
}

class _StockAdjustmentScreenState extends State<StockAdjustmentScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedMedicineId;
  String? _selectedBatchNumber;
  StockAdjustmentType _selectedType = StockAdjustmentType.correction;
  bool _isAddition = false;
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMedicineId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select medicine'), backgroundColor: AppColors.danger),
      );
      return;
    }

    final inventory = Provider.of<InventoryProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final med = inventory.getMedicineById(_selectedMedicineId!);

    final rawQty = int.tryParse(_quantityController.text.trim()) ?? 0;
    final totalUnits = rawQty * (med?.unitsPerPack ?? 1);
    final adjustedUnits = _isAddition ? totalUnits : -totalUnits;

    inventory.addAdjustment(
      medicineId: _selectedMedicineId!,
      medicineName: med?.name ?? 'Medicine',
      batchNumber: _selectedBatchNumber ?? 'General',
      type: _selectedType,
      quantityUnits: adjustedUnits,
      reason: _reasonController.text.trim(),
      adjustedBy: auth.currentUser?.name ?? 'Staff',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Stock adjustment recorded successfully'), backgroundColor: AppColors.success),
    );

    _quantityController.clear();
    _reasonController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();
    final medicines = inventory.allMedicines;
    final adjustments = inventory.adjustments;
    final List<Batch> batches = _selectedMedicineId != null ? inventory.getBatchesForMedicine(_selectedMedicineId!) : <Batch>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Stock Adjustment'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Adjustment Form Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Record Stock Adjustment',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 12),

                    // Type Selector
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Adjustment Type *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<StockAdjustmentType>(
                          key: ValueKey(_selectedType),
                          initialValue: _selectedType,
                          items: StockAdjustmentType.values.map((t) {
                            return DropdownMenuItem(value: t, child: Text(t.label));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedType = val;
                                if (val == StockAdjustmentType.damage || val == StockAdjustmentType.disposal) {
                                  _isAddition = false; // Always subtraction for damage/disposal
                                }
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Medicine Selector
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Select Medicine *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          key: ValueKey('med_$_selectedMedicineId'),
                          initialValue: _selectedMedicineId,
                          hint: const Text('Choose medicine...'),
                          items: medicines.map((m) {
                            return DropdownMenuItem(value: m.id, child: Text(m.name));
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedMedicineId = val;
                              _selectedBatchNumber = null;
                            });
                          },
                          validator: (v) => v == null ? 'Please select a medicine' : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Batch Selector
                    if (batches.isNotEmpty) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Select Batch', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            key: ValueKey('bat_$_selectedBatchNumber'),
                            initialValue: _selectedBatchNumber,
                            hint: const Text('Choose batch...'),
                            items: batches.map((b) {
                              return DropdownMenuItem(
                                value: b.batchNumber,
                                child: Text('Batch ${b.batchNumber} (${b.quantityUnits} units)'),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedBatchNumber = val),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Quantity & Operation Direction
                    Row(
                      children: [
                        if (_selectedType == StockAdjustmentType.correction)
                          Container(
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Action', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                ToggleButtons(
                                  isSelected: [_isAddition, !_isAddition],
                                  borderRadius: BorderRadius.circular(10),
                                  selectedColor: Colors.white,
                                  fillColor: _isAddition ? AppColors.success : AppColors.danger,
                                  children: const [
                                    Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('+ Add')),
                                    Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('- Deduct')),
                                  ],
                                  onPressed: (index) {
                                    setState(() => _isAddition = index == 0);
                                  },
                                ),
                              ],
                            ),
                          ),
                        Expanded(
                          child: AppTextField(
                            controller: _quantityController,
                            label: 'Quantity (Packs) *',
                            hint: 'e.g. 5',
                            keyboardType: TextInputType.number,
                            validator: AppValidators.positiveInteger,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Reason Field
                    AppTextField(
                      controller: _reasonController,
                      label: 'Adjustment Reason *',
                      hint: 'e.g. Physical count discrepancy, damaged packaging, dropped bottle',
                      validator: (v) => AppValidators.requiredField(v, 'Please state reason'),
                    ),
                    const SizedBox(height: 18),

                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Save Stock Adjustment'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Adjustment History Section
          const Text(
            'Adjustment History',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),

          if (adjustments.isEmpty)
            const EmptyState(
              icon: Icons.history,
              title: 'No Adjustments Recorded',
              message: 'Stock adjustments and count updates will be logged here with date, user, and reason.',
            )
          else
            ...adjustments.map((adj) {
              final isPositive = adj.quantityUnits > 0;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isPositive ? AppColors.successLight : AppColors.dangerLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isPositive ? Icons.add_circle_outline : Icons.remove_circle_outline,
                      color: isPositive ? AppColors.success : AppColors.danger,
                      size: 20,
                    ),
                  ),
                  title: Text(adj.medicineName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text(
                    '${adj.type.label} • Batch: ${adj.batchNumber}\nReason: ${adj.reason} • By ${adj.adjustedBy}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isPositive ? '+' : ''}${adj.quantityUnits} units',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isPositive ? AppColors.success : AppColors.danger,
                        ),
                      ),
                      Text(
                        AppFormatters.shortDate(adj.date),
                        style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            }),
        ],
      ),
    );
  }
}

