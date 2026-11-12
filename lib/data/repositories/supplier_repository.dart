import '../models/supplier_model.dart';
import '../models/purchase_order_model.dart';
import 'demo_data.dart';

abstract class SupplierRepository {
  List<Supplier> getSuppliers();
  Supplier? getSupplierById(String id);
  void addSupplier(Supplier supplier);
  void updateSupplier(Supplier supplier);
  void deleteSupplier(String id);

  List<SupplierLedgerEntry> getLedgerEntries();
  List<SupplierLedgerEntry> getLedgerForSupplier(String supplierId);
  void addLedgerEntry(SupplierLedgerEntry entry);

  List<PurchaseOrder> getPurchaseOrders();
  PurchaseOrder? getPurchaseOrderById(String id);
  void addPurchaseOrder(PurchaseOrder order);
  void updatePurchaseOrder(PurchaseOrder order);

  List<PurchaseReturn> getPurchaseReturns();
  void addPurchaseReturn(PurchaseReturn pReturn);

  int getNextPOSequence();
  int getNextPRSequence();

  void loadDemoData();
  void clearData();
}

class MockSupplierRepository implements SupplierRepository {
  final List<Supplier> _suppliers = [];
  final List<SupplierLedgerEntry> _ledger = [];
  final List<PurchaseOrder> _purchaseOrders = [];
  final List<PurchaseReturn> _purchaseReturns = [];

  @override
  List<Supplier> getSuppliers() => List.unmodifiable(_suppliers);

  @override
  Supplier? getSupplierById(String id) {
    try {
      return _suppliers.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void addSupplier(Supplier supplier) {
    _suppliers.add(supplier);
  }

  @override
  void updateSupplier(Supplier supplier) {
    final idx = _suppliers.indexWhere((s) => s.id == supplier.id);
    if (idx != -1) _suppliers[idx] = supplier;
  }

  @override
  void deleteSupplier(String id) {
    _suppliers.removeWhere((s) => s.id == id);
  }

  @override
  List<SupplierLedgerEntry> getLedgerEntries() => List.unmodifiable(_ledger);

  @override
  List<SupplierLedgerEntry> getLedgerForSupplier(String supplierId) {
    return _ledger.where((e) => e.supplierId == supplierId).toList();
  }

  @override
  void addLedgerEntry(SupplierLedgerEntry entry) {
    _ledger.insert(0, entry);
    // Update supplier balance payable
    final sIdx = _suppliers.indexWhere((s) => s.id == entry.supplierId);
    if (sIdx != -1) {
      _suppliers[sIdx] = _suppliers[sIdx].copyWith(balancePayable: entry.balanceAfter);
    }
  }

  @override
  List<PurchaseOrder> getPurchaseOrders() => List.unmodifiable(_purchaseOrders);

  @override
  PurchaseOrder? getPurchaseOrderById(String id) {
    try {
      return _purchaseOrders.firstWhere((po) => po.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void addPurchaseOrder(PurchaseOrder order) {
    _purchaseOrders.insert(0, order);
  }

  @override
  void updatePurchaseOrder(PurchaseOrder order) {
    final idx = _purchaseOrders.indexWhere((po) => po.id == order.id);
    if (idx != -1) _purchaseOrders[idx] = order;
  }

  @override
  List<PurchaseReturn> getPurchaseReturns() => List.unmodifiable(_purchaseReturns);

  @override
  void addPurchaseReturn(PurchaseReturn pReturn) {
    _purchaseReturns.insert(0, pReturn);
  }

  @override
  int getNextPOSequence() => _purchaseOrders.length + 1;

  @override
  int getNextPRSequence() => _purchaseReturns.length + 1;

  @override
  void loadDemoData() {
    clearData();
    _suppliers.addAll(DemoData.suppliers);
    _purchaseOrders.addAll(DemoData.purchaseOrders);
  }

  @override
  void clearData() {
    _suppliers.clear();
    _ledger.clear();
    _purchaseOrders.clear();
    _purchaseReturns.clear();
  }
}

