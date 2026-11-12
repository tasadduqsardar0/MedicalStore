import 'package:flutter/material.dart';
import '../data/models/prescription_model.dart';
import '../data/repositories/prescription_repository.dart';

class PrescriptionProvider extends ChangeNotifier {
  final PrescriptionRepository _prescriptionRepository;

  PrescriptionProvider({required PrescriptionRepository prescriptionRepository})
      : _prescriptionRepository = prescriptionRepository;

  // --- Doctors ---
  List<Doctor> get doctors => _prescriptionRepository.getDoctors();

  Doctor? getDoctorById(String id) => _prescriptionRepository.getDoctorById(id);

  void addDoctor(Doctor doctor) {
    _prescriptionRepository.addDoctor(doctor);
    notifyListeners();
  }

  void updateDoctor(Doctor doctor) {
    _prescriptionRepository.updateDoctor(doctor);
    notifyListeners();
  }

  void deleteDoctor(String id) {
    _prescriptionRepository.deleteDoctor(id);
    notifyListeners();
  }

  // --- Prescriptions ---
  List<Prescription> get prescriptions => _prescriptionRepository.getPrescriptions();

  Prescription? getPrescriptionById(String id) => _prescriptionRepository.getPrescriptionById(id);

  void addPrescription(Prescription rx) {
    _prescriptionRepository.addPrescription(rx);
    notifyListeners();
  }

  void markAsDispensed(String rxId) {
    final rx = getPrescriptionById(rxId);
    if (rx != null) {
      _prescriptionRepository.updatePrescription(rx.copyWith(isDispensed: true));
      notifyListeners();
    }
  }

  int get nextRxSuffix => _prescriptionRepository.getNextRxSequence();

  // --- Controlled Drug Register ---
  List<ControlledDrugEntry> get controlledEntries => _prescriptionRepository.getControlledEntries();

  void addControlledEntry(ControlledDrugEntry entry) {
    _prescriptionRepository.addControlledEntry(entry);
    notifyListeners();
  }

  void loadDemoData() {
    _prescriptionRepository.loadDemoData();
    notifyListeners();
  }

  void clearData() {
    _prescriptionRepository.clearData();
    notifyListeners();
  }
}

