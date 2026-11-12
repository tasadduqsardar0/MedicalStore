class Doctor {
  final String id;
  final String name;
  final String clinicHospital;
  final String phone;
  final String licenseNumber; // PMDC number

  const Doctor({
    required this.id,
    required this.name,
    required this.clinicHospital,
    this.phone = '',
    this.licenseNumber = '',
  });

  Doctor copyWith({
    String? id,
    String? name,
    String? clinicHospital,
    String? phone,
    String? licenseNumber,
  }) {
    return Doctor(
      id: id ?? this.id,
      name: name ?? this.name,
      clinicHospital: clinicHospital ?? this.clinicHospital,
      phone: phone ?? this.phone,
      licenseNumber: licenseNumber ?? this.licenseNumber,
    );
  }
}

class PrescriptionMedicineItem {
  final String medicineId;
  final String medicineName;
  final String dosage; // e.g. 1-0-1 after food
  final int durationDays;
  final int quantity;

  const PrescriptionMedicineItem({
    required this.medicineId,
    required this.medicineName,
    required this.dosage,
    required this.durationDays,
    required this.quantity,
  });
}

class Prescription {
  final String id;
  final String rxNumber; // e.g. RX-5001
  final String patientName;
  final int patientAge;
  final String patientGender;
  final String doctorId;
  final String doctorName;
  final DateTime date;
  final String instructions;
  final List<PrescriptionMedicineItem> medicines;
  final bool isDispensed;

  const Prescription({
    required this.id,
    required this.rxNumber,
    required this.patientName,
    required this.patientAge,
    required this.patientGender,
    required this.doctorId,
    required this.doctorName,
    required this.date,
    this.instructions = '',
    required this.medicines,
    this.isDispensed = false,
  });

  Prescription copyWith({
    String? id,
    String? rxNumber,
    String? patientName,
    int? patientAge,
    String? patientGender,
    String? doctorId,
    String? doctorName,
    DateTime? date,
    String? instructions,
    List<PrescriptionMedicineItem>? medicines,
    bool? isDispensed,
  }) {
    return Prescription(
      id: id ?? this.id,
      rxNumber: rxNumber ?? this.rxNumber,
      patientName: patientName ?? this.patientName,
      patientAge: patientAge ?? this.patientAge,
      patientGender: patientGender ?? this.patientGender,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      date: date ?? this.date,
      instructions: instructions ?? this.instructions,
      medicines: medicines ?? this.medicines,
      isDispensed: isDispensed ?? this.isDispensed,
    );
  }
}

class ControlledDrugEntry {
  final String id;
  final DateTime date;
  final String medicineId;
  final String medicineName;
  final String patientName;
  final String doctorName;
  final String prescriptionNumber;
  final int quantityDispensed; // Smallest units
  final int remainingStockUnits;
  final String pharmacistName;

  const ControlledDrugEntry({
    required this.id,
    required this.date,
    required this.medicineId,
    required this.medicineName,
    required this.patientName,
    required this.doctorName,
    required this.prescriptionNumber,
    required this.quantityDispensed,
    required this.remainingStockUnits,
    required this.pharmacistName,
  });
}

