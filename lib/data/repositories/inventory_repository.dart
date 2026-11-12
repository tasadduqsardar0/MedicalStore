import '../models/medicine_model.dart';
import '../models/batch_model.dart';
import '../models/category_model.dart';
import '../models/audit_model.dart';
import 'demo_data.dart';

abstract class InventoryRepository {
  List<MedicineCategory> getCategories();
  MedicineCategory? getCategoryById(String id);
  void addCategory(MedicineCategory category);
  void updateCategory(MedicineCategory category);
  bool deleteCategory(String id);

  List<Medicine> getMedicines();
  Medicine? getMedicineById(String id);
  Medicine? getMedicineByBarcode(String barcode);
  void addMedicine(Medicine medicine);
  void updateMedicine(Medicine medicine);
  bool deleteMedicine(String id);

  List<Batch> getBatches();
  List<Batch> getBatchesForMedicine(String medicineId);
  void addBatch(Batch batch);
  void updateBatch(Batch batch);
  void deleteBatch(String id);

  List<StockAdjustment> getAdjustments();
  void addAdjustment(StockAdjustment adjustment);

  void loadDemoData();
  void clearData();
}

class MockInventoryRepository implements InventoryRepository {
  final List<MedicineCategory> _categories = [];
  final List<Medicine> _medicines = [];
  final List<Batch> _batches = [];
  final List<StockAdjustment> _adjustments = [];

  @override
  List<MedicineCategory> getCategories() => List.unmodifiable(_categories);

  @override
  MedicineCategory? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void addCategory(MedicineCategory category) {
    _categories.add(category);
  }

  @override
  void updateCategory(MedicineCategory category) {
    final idx = _categories.indexWhere((c) => c.id == category.id);
    if (idx != -1) _categories[idx] = category;
  }

  @override
  bool deleteCategory(String id) {
    final hasMeds = _medicines.any((m) => m.categoryId == id);
    if (hasMeds) return false;
    _categories.removeWhere((c) => c.id == id);
    return true;
  }

  @override
  List<Medicine> getMedicines() => List.unmodifiable(_medicines);

  @override
  Medicine? getMedicineById(String id) {
    try {
      return _medicines.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Medicine? getMedicineByBarcode(String barcode) {
    try {
      return _medicines.firstWhere((m) => m.barcode == barcode.trim());
    } catch (_) {
      return null;
    }
  }

  @override
  void addMedicine(Medicine medicine) {
    _medicines.add(medicine);
  }

  @override
  void updateMedicine(Medicine medicine) {
    final idx = _medicines.indexWhere((m) => m.id == medicine.id);
    if (idx != -1) _medicines[idx] = medicine;
  }

  @override
  bool deleteMedicine(String id) {
    final batches = getBatchesForMedicine(id);
    final totalUnits = batches.fold(0, (sum, b) => sum + b.quantityUnits);
    if (totalUnits > 0) return false;
    _medicines.removeWhere((m) => m.id == id);
    _batches.removeWhere((b) => b.medicineId == id);
    return true;
  }

  @override
  List<Batch> getBatches() => List.unmodifiable(_batches);

  @override
  List<Batch> getBatchesForMedicine(String medicineId) {
    return _batches.where((b) => b.medicineId == medicineId).toList();
  }

  @override
  void addBatch(Batch batch) {
    _batches.add(batch);
  }

  @override
  void updateBatch(Batch batch) {
    final idx = _batches.indexWhere((b) => b.id == batch.id);
    if (idx != -1) _batches[idx] = batch;
  }

  @override
  void deleteBatch(String id) {
    _batches.removeWhere((b) => b.id == id);
  }

  @override
  List<StockAdjustment> getAdjustments() => List.unmodifiable(_adjustments);

  @override
  void addAdjustment(StockAdjustment adjustment) {
    _adjustments.insert(0, adjustment);
    // Apply adjustment to batch units
    final batchIdx = _batches.indexWhere((b) => b.medicineId == adjustment.medicineId && b.batchNumber == adjustment.batchNumber);
    if (batchIdx != -1) {
      final current = _batches[batchIdx];
      final newQty = (current.quantityUnits + adjustment.quantityUnits).clamp(0, 999999);
      _batches[batchIdx] = current.copyWith(quantityUnits: newQty);
    }
  }

  @override
  void loadDemoData() {
    clearData();
    _categories.addAll(DemoData.categories);
    _medicines.addAll(DemoData.medicines);
    _batches.addAll(DemoData.batches);
  }

  @override
  void clearData() {
    _categories.clear();
    _medicines.clear();
    _batches.clear();
    _adjustments.clear();
  }
}

