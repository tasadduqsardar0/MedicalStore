import 'package:flutter/material.dart';
import '../data/models/settings_model.dart';
import '../data/models/user_model.dart';
import '../data/models/audit_model.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/staff_repository.dart';
import 'inventory_provider.dart';
import 'billing_provider.dart';
import 'supplier_provider.dart';
import 'prescription_provider.dart';
import 'finance_provider.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _settingsRepository;
  final StaffRepository _staffRepository;

  SettingsProvider({
    required SettingsRepository settingsRepository,
    required StaffRepository staffRepository,
  })  : _settingsRepository = settingsRepository,
        _staffRepository = staffRepository;

  StoreSettings get settings => _settingsRepository.getSettings();

  void updateSettings(StoreSettings newSettings) {
    _settingsRepository.updateSettings(newSettings);
    notifyListeners();
  }

  // --- Staff Management ---
  List<User> get staffList => _staffRepository.getStaffList();

  void addStaff(User user) {
    _staffRepository.addUser(user);
    notifyListeners();
  }

  void updateStaff(User user) {
    _staffRepository.updateUser(user);
    notifyListeners();
  }

  void deleteStaff(String id) {
    _staffRepository.deleteUser(id);
    notifyListeners();
  }

  // --- Activity Logs ---
  List<ActivityLog> get activityLogs => _staffRepository.getActivityLogs();

  void logActivity({
    required String userName,
    required String role,
    required String action,
    required String details,
  }) {
    final log = ActivityLog(
      id: 'act-${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      userName: userName,
      role: role,
      action: action,
      details: details,
    );
    _staffRepository.logActivity(log);
    notifyListeners();
  }

  // --- Global Demo Data Operations ---
  void loadAllDemoData({
    required InventoryProvider inventory,
    required BillingProvider billing,
    required SupplierProvider supplier,
    required PrescriptionProvider prescription,
    required FinanceProvider finance,
  }) {
    inventory.loadDemoData();
    billing.loadDemoData();
    supplier.loadDemoData();
    prescription.loadDemoData();
    finance.loadDemoData();
    _staffRepository.loadDemoData();
    notifyListeners();
  }

  void clearAllDemoData({
    required InventoryProvider inventory,
    required BillingProvider billing,
    required SupplierProvider supplier,
    required PrescriptionProvider prescription,
    required FinanceProvider finance,
  }) {
    inventory.clearData();
    billing.clearData();
    supplier.clearData();
    prescription.clearData();
    finance.clearData();
    _staffRepository.clearData();
    notifyListeners();
  }
}

