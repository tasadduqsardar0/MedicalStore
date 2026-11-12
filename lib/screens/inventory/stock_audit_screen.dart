import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../data/models/audit_model.dart';
import '../../widgets/empty_state.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/auth_provider.dart';

class StockAuditScreen extends StatefulWidget {
  const StockAuditScreen({super.key});

  @override
  State<StockAuditScreen> createState() => _StockAuditScreenState();
}

class _StockAuditScreenState extends State<StockAuditScreen> {
  final Map<String, TextEditingController> _controllers = {};
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final inventory = Provider.of<InventoryProvider>(context, listen: false);
      for (final med in inventory.allMedicines) {
        final sellable = inventory.getSellableUnits(med.id);
        final packs = med.unitsPerPack > 0 ? (sellable ~/ med.unitsPerPack) : 0;
        _controllers[med.id] = TextEditingController(text: packs.toString());
      }
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _applyAuditReconcile() {
    final inventory = Provider.of<InventoryProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    int adjustmentsMade = 0;

    for (final med in inventory.allMedicines) {
      final c = _controllers[med.id];
      if (c == null) continue;
      final countedPacks = int.tryParse(c.text.trim()) ?? 0;
      final countedUnits = countedPacks * med.unitsPerPack;
      final systemUnits = inventory.getSellableUnits(med.id);
      final variance = countedUnits - systemUnits;

      if (variance != 0) {
        final batches = inventory.getBatchesForMedicine(med.id);
        final batchNo = batches.isNotEmpty ? batches.first.batchNumber : 'AUDIT';

        inventory.addAdjustment(
          medicineId: med.id,
          medicineName: med.name,
          batchNumber: batchNo,
          type: StockAdjustmentType.correction,
          quantityUnits: variance,
          reason: 'Physical Stock Audit Reconciliation',
          adjustedBy: auth.currentUser?.name ?? 'Pharmacist',
        );
        adjustmentsMade++;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Audit applied. $adjustmentsMade inventory discrepancies reconciled.'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();
    final medicines = inventory.allMedicines;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Physical Stock Audit'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.check, color: AppColors.primary),
            label: const Text('Apply Audit', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            onPressed: medicines.isEmpty ? null : _applyAuditReconcile,
          ),
        ],
      ),
      body: medicines.isEmpty
          ? const EmptyState(
              icon: Icons.fact_check_outlined,
              title: 'No Medicines To Audit',
              message: 'Add medicines or load demo data to start an inventory count audit.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: medicines.length,
              itemBuilder: (context, index) {
                final med = medicines[index];
                final systemUnits = inventory.getSellableUnits(med.id);
                final systemPacks = med.unitsPerPack > 0 ? (systemUnits ~/ med.unitsPerPack) : 0;
                final controller = _controllers[med.id] ??= TextEditingController(text: systemPacks.toString());

                final countedPacks = int.tryParse(controller.text) ?? systemPacks;
                final variancePacks = countedPacks - systemPacks;

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                med.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: variancePacks == 0
                                    ? AppColors.successLight
                                    : (variancePacks > 0 ? AppColors.infoLight : AppColors.dangerLight),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                variancePacks == 0
                                    ? 'Matches System'
                                    : (variancePacks > 0 ? '+$variancePacks packs excess' : '$variancePacks packs short'),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: variancePacks == 0
                                      ? AppColors.success
                                      : (variancePacks > 0 ? AppColors.info : AppColors.danger),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('System Record', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$systemPacks packs ($systemUnits ${med.unitName}s)',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 120,
                              child: TextField(
                                controller: controller,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Counted Packs',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                                onChanged: (val) {
                                  setState(() {});
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

