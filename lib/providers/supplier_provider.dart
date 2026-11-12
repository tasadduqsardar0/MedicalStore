import 'package:flutter/material.dart';
import '../data/models/supplier_model.dart';
import '../data/models/purchase_order_model.dart';
import '../data/models/batch_model.dart';
import '../data/repositories/supplier_repository.dart';
import 'inventory_provider.dart';

class SupplierProvider extends ChangeNotifier {
  final SupplierRepository _supplierRepository;
  String _searchQuery = '';

  SupplierProvider({required SupplierRepository supplierRepository})
      : _supplierRepository = supplierRepository;

  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<Supplier> get allSuppliers => _supplierRepository.getSuppliers();

  List<Supplier> get filteredSuppliers {
    if (_searchQuery.trim().isEmpty) return _supplierRepository.getSuppliers();
    final q = _searchQuery.trim().toLowerCase();
    return _supplierRepository.getSuppliers().where((s) {
      return s.companyName.toLowerCase().contains(q) ||
          s.contactPerson.toLowerCase().contains(q) ||
          s.phone.contains(q);
    }).toList();
  }

  Supplier? getSupplierById(String id) => _supplierRepository.getSupplierById(id);

  void addSupplier(Supplier supplier) {
    _supplierRepository.addSupplier(supplier);
    notifyListeners();
  }

  void updateSupplier(Supplier supplier) {
    _supplierRepository.updateSupplier(supplier);
    notifyListeners();
  }

  void deleteSupplier(String id) {
    _supplierRepository.deleteSupplier(id);
    notifyListeners();
  }

  // --- Ledger ---
  List<SupplierLedgerEntry> getLedgerForSupplier(String supplierId) {
    return _supplierRepository.getLedgerForSupplier(supplierId);
  }

  void recordPayment({
    required String supplierId,
    required double amount,
    required String reference,
    required String notes,
  }) {
    final sup = getSupplierById(supplierId);
    if (sup == null) return;

    final newBalance = (sup.balancePayable - amount).clamp(0.0, double.infinity);
    final entry = SupplierLedgerEntry(
      id: 'ledg-${DateTime.now().millisecondsSinceEpoch}',
      supplierId: supplierId,
      type: SupplierLedgerType.paymentMade,
      amount: amount,
      date: DateTime.now(),
      reference: reference.isNotEmpty ? reference : 'Payment Receipt',
      notes: notes,
      balanceAfter: newBalance,
    );
    _supplierRepository.addLedgerEntry(entry);
    notifyListeners();
  }

  // --- Purchase Orders ---
  List<PurchaseOrder> get purchaseOrders => _supplierRepository.getPurchaseOrders();

  PurchaseOrder? getPurchaseOrderById(String id) => _supplierRepository.getPurchaseOrderById(id);

  void createPurchaseOrder(PurchaseOrder order) {
    _supplierRepository.addPurchaseOrder(order);
    notifyListeners();
  }

  void updatePurchaseOrderStatus(String orderId, POStatus status) {
    final po = getPurchaseOrderById(orderId);
    if (po != null) {
      _supplierRepository.updatePurchaseOrder(po.copyWith(status: status));
      notifyListeners();
    }
  }

  int get nextPOSuffix => _supplierRepository.getNextPOSequence();

  // --- Goods Received (Creates Batches in Inventory!) ---
  void receiveGoods({
    required String? poId,
    required String supplierId,
    required String medicineId,
    required String medicineName,
    required String batchNumber,
    required DateTime expiryDate,
    required int packQuantity,
    required int unitsPerPack,
    required double purchasePrice,
    required InventoryProvider inventoryProvider,
  }) {
    final totalUnits = packQuantity * unitsPerPack;
    final totalBill = packQuantity * purchasePrice;

    // 1. Create or update batch in inventory
    final newBatch = Batch(
      id: 'bat-${DateTime.now().millisecondsSinceEpoch}',
      medicineId: medicineId,
      batchNumber: batchNumber,
      expiryDate: expiryDate,
      quantityUnits: totalUnits,
      purchasePrice: purchasePrice,
    );
    inventoryProvider.addBatch(newBatch);

    // 2. Update Supplier balance payable & ledger
    final sup = getSupplierById(supplierId);
    final newBal = (sup?.balancePayable ?? 0.0) + totalBill;
    final ledgerEntry = SupplierLedgerEntry(
      id: 'ledg-${DateTime.now().millisecondsSinceEpoch}',
      supplierId: supplierId,
      type: SupplierLedgerType.goodsReceived,
      amount: totalBill,
      date: DateTime.now(),
      reference: 'GRN-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      notes: 'Received $packQuantity packs of $medicineName (Batch: $batchNumber)',
      balanceAfter: newBal,
    );
    _supplierRepository.addLedgerEntry(ledgerEntry);

    // 3. Mark PO as received if attached
    if (poId != null) {
      updatePurchaseOrderStatus(poId, POStatus.received);
    }

    notifyListeners();
  }

  // --- Purchase Return ---
  List<PurchaseReturn> get purchaseReturns => _supplierRepository.getPurchaseReturns();

  void createPurchaseReturn({
    required String supplierId,
    required String supplierName,
    required String medicineId,
    required String medicineName,
    required String batchNumber,
    required int packQuantity,
    required int unitsPerPack,
    required double unitPrice,
    required String reason,
    required InventoryProvider inventoryProvider,
  }) {
    final totalAmount = packQuantity * unitPrice;
    final ret = PurchaseReturn(
      id: 'pr-${DateTime.now().millisecondsSinceEpoch}',
      returnNumber: 'PR-${2000 + _supplierRepository.getNextPRSequence()}',
      supplierId: supplierId,
      supplierName: supplierName,
      medicineId: medicineId,
      medicineName: medicineName,
      batchNumber: batchNumber,
      packQuantity: packQuantity,
      unitPrice: unitPrice,
      totalAmount: totalAmount,
      reason: reason,
      date: DateTime.now(),
    );
    _supplierRepository.addPurchaseReturn(ret);

    // Deduct stock from the batch
    final batches = inventoryProvider.getBatchesForMedicine(medicineId);
    final bIdx = batches.indexWhere((b) => b.batchNumber == batchNumber);
    if (bIdx != -1) {
      final batch = batches[bIdx];
      final deduction = packQuantity * unitsPerPack;
      final newQty = (batch.quantityUnits - deduction).clamp(0, 999999);
      inventoryProvider.updateBatch(batch.copyWith(quantityUnits: newQty));
    }

    // Update supplier ledger (credit note)
    final sup = getSupplierById(supplierId);
    final newBal = ((sup?.balancePayable ?? 0.0) - totalAmount).clamp(0.0, double.infinity);
    final ledgerEntry = SupplierLedgerEntry(
      id: 'ledg-${DateTime.now().millisecondsSinceEpoch}',
      supplierId: supplierId,
      type: SupplierLedgerType.purchaseReturn,
      amount: totalAmount,
      date: DateTime.now(),
      reference: ret.returnNumber,
      notes: 'Returned $packQuantity packs of $medicineName ($reason)',
      balanceAfter: newBal,
    );
    _supplierRepository.addLedgerEntry(ledgerEntry);

    notifyListeners();
  }

  double get totalBalancePayable {
    return _supplierRepository.getSuppliers().fold(0.0, (sum, s) => sum + s.balancePayable);
  }

  void loadDemoData() {
    _supplierRepository.loadDemoData();
    notifyListeners();
  }

  void clearData() {
    _supplierRepository.clearData();
    notifyListeners();
  }
}

