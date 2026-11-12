import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../data/models/prescription_model.dart';
import '../../widgets/empty_state.dart';
import '../../providers/prescription_provider.dart';

class DoctorsScreen extends StatelessWidget {
  const DoctorsScreen({super.key});

  void _showAddEditDoctorDialog(BuildContext context, [Doctor? doctor]) {
    final nameController = TextEditingController(text: doctor?.name ?? '');
    final clinicController = TextEditingController(text: doctor?.clinicHospital ?? '');
    final phoneController = TextEditingController(text: doctor?.phone ?? '');
    final licenseController = TextEditingController(text: doctor?.licenseNumber ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(doctor == null ? 'Add Prescribing Doctor' : 'Edit Doctor Details'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Doctor Name *', hintText: 'e.g. Dr. Muhammad Irfan'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter doctor name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: clinicController,
                decoration: const InputDecoration(labelText: 'Hospital / Clinic *', hintText: 'e.g. THQ Hospital Hujra'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter clinic name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Contact Phone', hintText: '0300-1234567'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: licenseController,
                decoration: const InputDecoration(labelText: 'PMDC License No.', hintText: 'e.g. PMDC-44211-P'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final pProvider = Provider.of<PrescriptionProvider>(context, listen: false);

              if (doctor == null) {
                pProvider.addDoctor(
                  Doctor(
                    id: 'doc-${DateTime.now().millisecondsSinceEpoch}',
                    name: nameController.text.trim(),
                    clinicHospital: clinicController.text.trim(),
                    phone: phoneController.text.trim(),
                    licenseNumber: licenseController.text.trim(),
                  ),
                );
              } else {
                pProvider.updateDoctor(
                  doctor.copyWith(
                    name: nameController.text.trim(),
                    clinicHospital: clinicController.text.trim(),
                    phone: phoneController.text.trim(),
                    licenseNumber: licenseController.text.trim(),
                  ),
                );
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save Doctor'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prescriptionProvider = context.watch<PrescriptionProvider>();
    final doctors = prescriptionProvider.doctors;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Doctors Directory'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Doctor'),
        onPressed: () => _showAddEditDoctorDialog(context),
      ),
      body: doctors.isEmpty
          ? EmptyState(
              icon: Icons.person_outline,
              title: 'No Doctors Registered',
              message: 'Add local general physicians, consultants, and maternity clinic doctors.',
              buttonText: 'Add First Doctor',
              onButtonPressed: () => _showAddEditDoctorDialog(context),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final doc = doctors[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primaryLight,
                      child: Icon(Icons.medical_services, color: AppColors.primaryDark),
                    ),
                    title: Text(doc.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(doc.clinicHospital, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                        if (doc.phone.isNotEmpty)
                          Text('Phone: ${doc.phone}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        if (doc.licenseNumber.isNotEmpty)
                          Text('Reg: ${doc.licenseNumber}', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _showAddEditDoctorDialog(context, doc),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

