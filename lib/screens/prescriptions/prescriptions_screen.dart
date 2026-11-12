import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../data/models/prescription_model.dart';
import '../../widgets/empty_state.dart';
import '../../providers/prescription_provider.dart';
import '../../providers/inventory_provider.dart';

class PrescriptionsScreen extends StatefulWidget {
  const PrescriptionsScreen({super.key});

  @override
  State<PrescriptionsScreen> createState() => _PrescriptionsScreenState();
}

class _PrescriptionsScreenState extends State<PrescriptionsScreen> {
  void _showAddPrescriptionDialog(BuildContext context) {
    final prescriptionProvider = Provider.of<PrescriptionProvider>(context, listen: false);
    final inventory = Provider.of<InventoryProvider>(context, listen: false);

    final patientController = TextEditingController();
    final ageController = TextEditingController(text: '45');
    String gender = 'Male';
    String? selectedDoctorId = prescriptionProvider.doctors.isNotEmpty ? prescriptionProvider.doctors.first.id : null;
    final instructionsController = TextEditingController(text: 'Take medicines after meals.');

    String? selectedMedId;
    final dosageController = TextEditingController(text: '1 tab twice daily');
    final durationController = TextEditingController(text: '5');
    final quantityController = TextEditingController(text: '10');
    final List<PrescriptionMedicineItem> items = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.88,
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ListView(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Add Prescription (Rx)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Patient Name & Age
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: patientController,
                          decoration: const InputDecoration(labelText: 'Patient Name *', hintText: 'e.g. Aslam Ali'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: ageController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Age'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          key: ValueKey('gen_$gender'),
                          initialValue: gender,
                          items: ['Male', 'Female', 'Child'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                          onChanged: (val) => setModalState(() => gender = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Doctor Selector
                  DropdownButtonFormField<String>(
                    key: ValueKey('doc_$selectedDoctorId'),
                    initialValue: selectedDoctorId,
                    hint: const Text('Select Prescribing Doctor *'),
                    items: prescriptionProvider.doctors.map((d) {
                      return DropdownMenuItem(value: d.id, child: Text('${d.name} (${d.clinicHospital})'));
                    }).toList(),
                    onChanged: (val) => setModalState(() => selectedDoctorId = val),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: instructionsController,
                    decoration: const InputDecoration(labelText: 'Doctor Instructions / Notes', hintText: 'Dietary or dosage advice'),
                  ),
                  const SizedBox(height: 16),

                  // Medicine Item Builder
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Prescribed Medicine', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          key: ValueKey('med_$selectedMedId'),
                          initialValue: selectedMedId,
                          hint: const Text('Choose medicine...'),
                          items: inventory.allMedicines.map((m) => DropdownMenuItem(value: m.id, child: Text(m.name))).toList(),
                          onChanged: (val) => setModalState(() => selectedMedId = val),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: dosageController,
                                decoration: const InputDecoration(labelText: 'Dosage', hintText: '1-0-1'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: durationController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Days', hintText: '5'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: quantityController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Units', hintText: '10'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Medicine Line'),
                          onPressed: () {
                            if (selectedMedId == null) return;
                            final med = inventory.getMedicineById(selectedMedId!);
                            setModalState(() {
                              items.add(
                                PrescriptionMedicineItem(
                                  medicineId: selectedMedId!,
                                  medicineName: med?.name ?? 'Medicine',
                                  dosage: dosageController.text,
                                  durationDays: int.tryParse(durationController.text) ?? 5,
                                  quantity: int.tryParse(quantityController.text) ?? 10,
                                ),
                              );
                              selectedMedId = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (items.isNotEmpty) ...[
                    const Text('Medicines in this Rx:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    ...items.map((i) => Text('• ${i.medicineName} (${i.dosage}, ${i.durationDays} days) - ${i.quantity} units')),
                    const SizedBox(height: 16),
                  ],

                  ElevatedButton(
                    onPressed: () {
                      if (patientController.text.trim().isEmpty || selectedDoctorId == null || items.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter patient, doctor and at least 1 medicine'), backgroundColor: AppColors.danger),
                        );
                        return;
                      }

                      final doctor = prescriptionProvider.getDoctorById(selectedDoctorId!);
                      final rxNum = 'RX-${5000 + prescriptionProvider.nextRxSuffix}';

                      prescriptionProvider.addPrescription(
                        Prescription(
                          id: 'rx-${DateTime.now().millisecondsSinceEpoch}',
                          rxNumber: rxNum,
                          patientName: patientController.text.trim(),
                          patientAge: int.tryParse(ageController.text) ?? 30,
                          patientGender: gender,
                          doctorId: selectedDoctorId!,
                          doctorName: doctor?.name ?? 'Doctor',
                          date: DateTime.now(),
                          instructions: instructionsController.text.trim(),
                          medicines: items,
                        ),
                      );

                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Prescription $rxNum saved'), backgroundColor: AppColors.success),
                      );
                    },
                    child: const Text('Save Prescription'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final prescriptionProvider = context.watch<PrescriptionProvider>();
    final prescriptions = prescriptionProvider.prescriptions;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Prescriptions (Rx)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline),
            tooltip: 'Doctors Registry',
            onPressed: () => Navigator.pushNamed(context, '/doctors'),
          ),
          IconButton(
            icon: const Icon(Icons.lock_clock),
            tooltip: 'Controlled Drug Register',
            onPressed: () => Navigator.pushNamed(context, '/controlled-drugs'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Rx'),
        onPressed: () => _showAddPrescriptionDialog(context),
      ),
      body: prescriptions.isEmpty
          ? EmptyState(
              icon: Icons.medical_services_outlined,
              title: 'No Prescriptions Logged',
              message: 'Log doctor prescriptions to track dispensed medications and patient treatment histories.',
              buttonText: 'Add First Prescription',
              onButtonPressed: () => _showAddPrescriptionDialog(context),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
              itemCount: prescriptions.length,
              itemBuilder: (context, index) {
                final rx = prescriptions[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              rx.rxNumber,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryDark),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: rx.isDispensed ? AppColors.successLight : AppColors.warningLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                rx.isDispensed ? 'Dispensed' : 'Pending Dispense',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: rx.isDispensed ? AppColors.success : AppColors.warning,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${rx.patientName} (${rx.patientAge}y, ${rx.patientGender})',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          'Prescribed by: ${rx.doctorName} • ${AppFormatters.date(rx.date)}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        if (rx.instructions.isNotEmpty)
                          Text('Advice: ${rx.instructions}', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                        const Divider(height: 18),

                        const Text('Medicines:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                        const SizedBox(height: 4),
                        ...rx.medicines.map((m) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              children: [
                                const Icon(Icons.circle, size: 6, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Expanded(child: Text('${m.medicineName} • ${m.dosage} (${m.durationDays} days)')),
                                Text('${m.quantity} units', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          );
                        }),
                        if (!rx.isDispensed) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.check, size: 16),
                              label: const Text('Mark as Dispensed'),
                              onPressed: () {
                                prescriptionProvider.markAsDispensed(rx.id);
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

