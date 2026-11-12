import 'package:flutter/material.dart';
import '../data/models/medicine_model.dart';
import '../data/models/batch_model.dart';
import '../data/models/category_model.dart';
import '../data/models/audit_model.dart';
import '../data/repositories/inventory_repository.dart';
import '../core/stock_rules.dart';

class InventoryProvider extends ChangeNotifier {
  final InventoryRepository _inventoryRepository;

  String _searchQuery = '';
  String? _selectedCategoryId;
  int _nearExpiryThresholdDays = 30;

  InventoryProvider({required InventoryRepository inventoryRepository})
      : _inventoryRepository = inventoryRepository;

  void updateNearExpiryDays(int days) {
    _nearExpiryThresholdDays = days;
    notifyListeners();
  }

  // --- Categories ---
  List<MedicineCategory> get categories => _inventoryRepository.getCategories();

  MedicineCategory? getCategoryById(String id) => _inventoryRepository.getCategoryById(id);

  void addCategory(String name, String description) {
    final cat = MedicineCategory(
      id: 'cat-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      description: description.trim(),
    );
    _inventoryRepository.addCategory(cat);
    notifyListeners();
  }

  void updateCategory(MedicineCategory category) {
    _inventoryRepository.updateCategory(category);
    notifyListeners();
  }

  bool deleteCategory(String id) {
    final success = _inventoryRepository.deleteCategory(id);
    if (success) notifyListeners();
    return success;
  }

  int getMedicineCountForCategory(String categoryId) {
    return _inventoryRepository.getMedicines().where((m) => m.categoryId == categoryId).length;
  }

  // --- Search & Filters ---
  String get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  // --- Medicines ---
  List<Medicine> get allMedicines => _inventoryRepository.getMedicines();

  List<Medicine> get filteredMedicines {
    var list = _inventoryRepository.getMedicines();
    if (_selectedCategoryId != null && _selectedCategoryId!.isNotEmpty) {
      list = list.where((m) => m.categoryId == _selectedCategoryId).toList();
    }
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((m) =>
          m.name.toLowerCase().contains(q) ||
          m.genericName.toLowerCase().contains(q) ||
          m.company.toLowerCase().contains(q) ||
          m.barcode.contains(q)).toList();
    }
    return list;
  }

  Medicine? getMedicineById(String id) => _inventoryRepository.getMedicineById(id);
  Medicine? getMedicineByBarcode(String barcode) => _inventoryRepository.getMedicineByBarcode(barcode);

  void addMedicine(Medicine medicine) {
    _inventoryRepository.addMedicine(medicine);
    notifyListeners();
  }

  void updateMedicine(Medicine medicine) {
    _inventoryRepository.updateMedicine(medicine);
    notifyListeners();
  }

  bool deleteMedicine(String id) {
    final success = _inventoryRepository.deleteMedicine(id);
    if (success) notifyListeners();
    return success;
  }

  // --- Batches ---
  List<Batch> get allBatches => _inventoryRepository.getBatches();

  List<Batch> getBatchesForMedicine(String medicineId) {
    return _inventoryRepository.getBatchesForMedicine(medicineId);
  }

  bool addBatch(Batch batch) {
    // Validate past expiry date
    if (!StockRules.isValidBatchExpiry(batch.expiryDate)) {
      return false;
    }
    _inventoryRepository.addBatch(batch);
    notifyListeners();
    return true;
  }

  void updateBatch(Batch batch) {
    _inventoryRepository.updateBatch(batch);
    notifyListeners();
  }

  void deleteBatch(String id) {
    _inventoryRepository.deleteBatch(id);
    notifyListeners();
  }

  // --- Stock Calculations & Helpers ---
  int getSellableUnits(String medicineId) {
    final batches = getBatchesForMedicine(medicineId);
    return StockRules.sellableStockUnits(batches);
  }

  int getTotalUnits(String medicineId) {
    final batches = getBatchesForMedicine(medicineId);
    return StockRules.totalStockUnits(batches);
  }

  StockStatus getStockStatus(Medicine medicine) {
    final batches = getBatchesForMedicine(medicine.id);
    return StockRules.evaluateStatus(
      batches: batches,
      unitsPerPack: medicine.unitsPerPack,
      minimumStockPacks: medicine.minimumStockPacks,
      thresholdDays: _nearExpiryThresholdDays,
    );
  }

  String getStockDisplayText(Medicine medicine) {
    final totalUnits = getSellableUnits(medicine.id);
    return StockRules.formatStockDisplay(
      totalUnits: totalUnits,
      unitsPerPack: medicine.unitsPerPack,
      packTypeName: medicine.packType.label,
      unitName: medicine.unitName,
    );
  }

  // --- Low Stock & Expiry Lists ---
  List<Medicine> get lowStockMedicines {
    return _inventoryRepository.getMedicines().where((m) {
      final status = getStockStatus(m);
      return status == StockStatus.lowStock || status == StockStatus.outOfStock;
    }).toList();
  }

  List<Batch> get nearExpiryBatches {
    return _inventoryRepository.getBatches().where((b) {
      return StockRules.isBatchNearExpiry(b.expiryDate, thresholdDays: _nearExpiryThresholdDays) && b.quantityUnits > 0;
    }).toList();
  }

  List<Batch> get expiredBatches {
    return _inventoryRepository.getBatches().where((b) {
      return StockRules.isBatchExpired(b.expiryDate) && b.quantityUnits > 0;
    }).toList();
  }

  // --- Adjustments ---
  List<StockAdjustment> get adjustments => _inventoryRepository.getAdjustments();

  void addAdjustment({
    required String medicineId,
    required String medicineName,
    required String batchNumber,
    required StockAdjustmentType type,
    required int quantityUnits,
    required String reason,
    required String adjustedBy,
  }) {
    final adj = StockAdjustment(
      id: 'adj-${DateTime.now().millisecondsSinceEpoch}',
      medicineId: medicineId,
      medicineName: medicineName,
      batchNumber: batchNumber,
      type: type,
      quantityUnits: quantityUnits,
      reason: reason,
      date: DateTime.now(),
      adjustedBy: adjustedBy,
    );
    _inventoryRepository.addAdjustment(adj);
    notifyListeners();
  }

  // --- Substitutes Search ---
  List<Medicine> searchSubstitutes(String genericName, {String? excludeMedicineId}) {
    final q = genericName.trim().toLowerCase();
    return _inventoryRepository.getMedicines().where((m) {
      if (excludeMedicineId != null && m.id == excludeMedicineId) return false;
      return m.genericName.toLowerCase().contains(q);
    }).toList();
  }

  void loadDemoData() {
    _inventoryRepository.loadDemoData();
    notifyListeners();
  }

  void clearData() {
    _inventoryRepository.clearData();
    notifyListeners();
  }
}

