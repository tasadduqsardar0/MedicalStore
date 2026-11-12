import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../widgets/alert_chip.dart';
import '../../widgets/empty_state.dart';
import '../../providers/prescription_provider.dart';

class ControlledDrugRegisterScreen extends StatelessWidget {
  const ControlledDrugRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prescriptionProvider = context.watch<PrescriptionProvider>();
    final entries = prescriptionProvider.controlledEntries;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Controlled Drug Register'),
      ),
      body: Column(
        children: [
          // Legal Notice Card
          Container(
            padding: const EdgeInsets.all(14),
            color: AppColors.controlledLight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lock, color: AppColors.controlled, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Government Schedule Drug Register',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.controlled),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Rule: Every sale of a controlled substance (e.g. Lexotanil, Rivotril) automatically logs patient, doctor, prescription, quantity, remaining stock, and dispensing pharmacist for health department audit.',
                        style: TextStyle(fontSize: 11, color: AppColors.textPrimary, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: entries.isEmpty
                ? const EmptyState(
                    icon: Icons.lock_clock,
                    title: 'No Controlled Drugs Dispensed',
                    message: 'When controlled medications like Lexotanil or Rivotril are billed, the system logs compliance entries here.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];

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
                                    entry.medicineName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.controlled),
                                  ),
                                  AlertChip.controlled(),
                                ],
                              ),
                              const SizedBox(height: 6),
                              _RegisterRow(label: 'Date & Time:', value: AppFormatters.dateTime(entry.date)),
                              _RegisterRow(label: 'Patient Name:', value: entry.patientName),
                              _RegisterRow(label: 'Doctor Prescribed:', value: entry.doctorName),
                              _RegisterRow(label: 'Prescription / Invoice #:', value: entry.prescriptionNumber),
                              const Divider(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Quantity Dispensed', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                      Text('${entry.quantityDispensed} units', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.danger)),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text('Remaining Store Stock', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                      Text('${entry.remainingStockUnits} units', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Dispensed By: ${entry.pharmacistName}',
                                style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _RegisterRow extends StatelessWidget {
  final String label;
  final String value;

  const _RegisterRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

