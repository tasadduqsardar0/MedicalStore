import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../core/validators.dart';
import '../../data/models/audit_model.dart';
import '../../data/models/batch_model.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/empty_state.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/auth_provider.dart';

class DisposalScreen extends StatefulWidget {
  const DisposalScreen({super.key});

  @override
  State<DisposalScreen> createState() => _DisposalScreenState();
}

class _DisposalScreenState extends State<DisposalScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedMedicineId;
  String? _selectedBatchNumber;
  final _quantityPacksController = TextEditingController();
  final _reasonController = TextEditingController(text: 'Expired medicine safely destroyed');
  final _witnessController = TextEditingController();

  @override
  void dispose() {
    _quantityPacksController.dispose();
    _reasonController.dispose();
    _witnessController.dispose();
    super.dispose();
  }

  void _recordDisposal() {
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

    final packs = int.tryParse(_quantityPacksController.text.trim()) ?? 0;
    final totalUnits = packs * (med?.unitsPerPack ?? 1);

    inventory.addAdjustment(
      medicineId: _selectedMedicineId!,
      medicineName: med?.name ?? 'Medicine',
      batchNumber: _selectedBatchNumber ?? 'General',
      type: StockAdjustmentType.disposal,
      quantityUnits: -totalUnits, // Deduct disposed units
      reason: '${_reasonController.text.trim()} (Witness: ${_witnessController.text.trim().isNotEmpty ? _witnessController.text.trim() : "None"})',
      adjustedBy: auth.currentUser?.name ?? 'Owner',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Disposal record saved successfully'), backgroundColor: AppColors.success),
    );

    _quantityPacksController.clear();
    _reasonController.clear();
    _witnessController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();
    final medicines = inventory.allMedicines;
    final List<Batch> batches = _selectedMedicineId != null ? inventory.getBatchesForMedicine(_selectedMedicineId!) : <Batch>[];
    final disposalLogs = inventory.adjustments.where((a) => a.type == StockAdjustmentType.disposal).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Stock Disposal & Destruction'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Disposal Registration Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.delete_forever, color: AppColors.danger),
                        SizedBox(width: 8),
                        Text(
                          'Record Medicine Disposal',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Medicine Selector
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Medicine *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          key: ValueKey('med_$_selectedMedicineId'),
                          initialValue: _selectedMedicineId,
                          hint: const Text('Choose medicine to dispose...'),
                          items: medicines.map((m) {
                            return DropdownMenuItem(value: m.id, child: Text(m.name));
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedMedicineId = val;
                              _selectedBatchNumber = null;
                            });
                          },
                          validator: (v) => v == null ? 'Select medicine' : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Batch Selector
                    if (batches.isNotEmpty) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Select Batch *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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

                    AppTextField(
                      controller: _quantityPacksController,
                      label: 'Packs to Dispose *',
                      hint: 'e.g. 5',
                      keyboardType: TextInputType.number,
                      validator: AppValidators.positiveInteger,
                    ),
                    const SizedBox(height: 14),

                    AppTextField(
                      controller: _reasonController,
                      label: 'Disposal Reason *',
                      hint: 'e.g. Expired stock / Broken seal / Chemical degradation',
                      validator: (v) => AppValidators.requiredField(v, 'Enter reason'),
                    ),
                    const SizedBox(height: 14),

                    AppTextField(
                      controller: _witnessController,
                      label: 'Witness / Verified By (optional)',
                      hint: 'e.g. Pharmacist Tariq Mahmood',
                    ),
                    const SizedBox(height: 18),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Confirm Disposal & Remove From Stock'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                      onPressed: _recordDisposal,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Log section
          const Text(
            'Disposal History & Audit Log',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),

          if (disposalLogs.isEmpty)
            const EmptyState(
              icon: Icons.delete_outline,
              title: 'No Disposals Recorded',
              message: 'Quarantined and destroyed stock records will appear here for audit compliance.',
            )
          else
            ...disposalLogs.map((log) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.delete_sweep, color: AppColors.danger),
                  title: Text(log.medicineName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text(
                    'Batch: ${log.batchNumber}\n${log.reason}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${log.quantityUnits} units',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger, fontSize: 13),
                      ),
                      Text(AppFormatters.shortDate(log.date), style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
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

