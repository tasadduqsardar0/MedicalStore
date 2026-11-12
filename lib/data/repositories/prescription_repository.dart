import '../models/prescription_model.dart';
import 'demo_data.dart';

abstract class PrescriptionRepository {
  List<Doctor> getDoctors();
  Doctor? getDoctorById(String id);
  void addDoctor(Doctor doctor);
  void updateDoctor(Doctor doctor);
  void deleteDoctor(String id);

  List<Prescription> getPrescriptions();
  Prescription? getPrescriptionById(String id);
  void addPrescription(Prescription prescription);
  void updatePrescription(Prescription prescription);

  List<ControlledDrugEntry> getControlledEntries();
  void addControlledEntry(ControlledDrugEntry entry);

  int getNextRxSequence();

  void loadDemoData();
  void clearData();
}

class MockPrescriptionRepository implements PrescriptionRepository {
  final List<Doctor> _doctors = [];
  final List<Prescription> _prescriptions = [];
  final List<ControlledDrugEntry> _controlled = [];

  @override
  List<Doctor> getDoctors() => List.unmodifiable(_doctors);

  @override
  Doctor? getDoctorById(String id) {
    try {
      return _doctors.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void addDoctor(Doctor doctor) {
    _doctors.add(doctor);
  }

  @override
  void updateDoctor(Doctor doctor) {
    final idx = _doctors.indexWhere((d) => d.id == doctor.id);
    if (idx != -1) _doctors[idx] = doctor;
  }

  @override
  void deleteDoctor(String id) {
    _doctors.removeWhere((d) => d.id == id);
  }

  @override
  List<Prescription> getPrescriptions() => List.unmodifiable(_prescriptions);

  @override
  Prescription? getPrescriptionById(String id) {
    try {
      return _prescriptions.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void addPrescription(Prescription prescription) {
    _prescriptions.insert(0, prescription);
  }

  @override
  void updatePrescription(Prescription prescription) {
    final idx = _prescriptions.indexWhere((p) => p.id == prescription.id);
    if (idx != -1) _prescriptions[idx] = prescription;
  }

  @override
  List<ControlledDrugEntry> getControlledEntries() => List.unmodifiable(_controlled);

  @override
  void addControlledEntry(ControlledDrugEntry entry) {
    _controlled.insert(0, entry);
  }

  @override
  int getNextRxSequence() => _prescriptions.length + 1;

  @override
  void loadDemoData() {
    clearData();
    _doctors.addAll(DemoData.doctors);
    _prescriptions.addAll(DemoData.prescriptions);
    _controlled.addAll(DemoData.controlledEntries);
  }

  @override
  void clearData() {
    _doctors.clear();
    _prescriptions.clear();
    _controlled.clear();
  }
}

