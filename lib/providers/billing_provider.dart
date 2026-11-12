import 'package:flutter/material.dart';
import '../data/models/sale_model.dart';
import '../data/models/medicine_model.dart';
import '../data/models/prescription_model.dart';
import '../data/repositories/billing_repository.dart';
import '../core/stock_rules.dart';
import 'inventory_provider.dart';
import 'prescription_provider.dart';

class BillingProvider extends ChangeNotifier {
  final BillingRepository _billingRepository;

  // Active Sale State
  final List<SaleItem> _cartItems = [];
  String _customerName = '';
  double _discount = 0.0;
  double _cashTendered = 0.0;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  SplitPaymentDetails _splitPaymentDetails = const SplitPaymentDetails();

  BillingProvider({required BillingRepository billingRepository})
      : _billingRepository = billingRepository;

  List<SaleItem> get cartItems => List.unmodifiable(_cartItems);
  String get customerName => _customerName;
  String get displayCustomerName =>
      _customerName.trim().isNotEmpty ? _customerName.trim() : 'Walk-in Customer';
  double get discount => _discount;
  double get cashTendered => _cashTendered;
  PaymentMethod get selectedPaymentMethod => _selectedPaymentMethod;
  SplitPaymentDetails get splitPaymentDetails => _splitPaymentDetails;

  double get subtotal => _cartItems.fold(0.0, (sum, item) => sum + item.lineTotal);
  double get netTotal => (subtotal - _discount).clamp(0.0, double.infinity);
  double get changeAmount => (_cashTendered - netTotal).clamp(0.0, double.infinity);

  void setCustomerName(String name) {
    _customerName = name;
    notifyListeners();
  }

  void setDiscount(double discount) {
    _discount = discount.clamp(0.0, subtotal);
    notifyListeners();
  }

  void setCashTendered(double amount) {
    _cashTendered = amount;
    notifyListeners();
  }

  void setPaymentMethod(PaymentMethod method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  void setSplitPaymentDetails(SplitPaymentDetails split) {
    _splitPaymentDetails = split;
    notifyListeners();
  }

  /// Add or update item in cart
  String? addItem({
    required Medicine medicine,
    required bool isLoose,
    required int quantity,
    required InventoryProvider inventoryProvider,
  }) {
    final requestedSmallestUnits = isLoose ? quantity : (quantity * medicine.unitsPerPack);
    final availableUnits = inventoryProvider.getSellableUnits(medicine.id);

    // Calculate existing quantity already in cart for this medicine
    final existingUnitsInCart = _cartItems
        .where((item) => item.medicineId == medicine.id)
        .fold(0, (sum, item) => sum + item.totalSmallestUnits);

    if (existingUnitsInCart + requestedSmallestUnits > availableUnits) {
      return 'Insufficient stock. Available: $availableUnits units.';
    }

    final unitPrice = isLoose ? medicine.loosePrice : medicine.salePrice;
    final lineTotal = unitPrice * quantity;

    // Check if matching item exists in cart
    final existingIdx = _cartItems.indexWhere(
      (item) => item.medicineId == medicine.id && item.isLoose == isLoose,
    );

    if (existingIdx != -1) {
      final existing = _cartItems[existingIdx];
      final newQty = existing.quantity + quantity;
      _cartItems[existingIdx] = SaleItem(
        medicineId: medicine.id,
        medicineName: medicine.name,
        genericName: medicine.genericName,
        isLoose: isLoose,
        quantity: newQty,
        unitsPerPack: medicine.unitsPerPack,
        unitPrice: unitPrice,
        lineTotal: unitPrice * newQty,
      );
    } else {
      _cartItems.add(
        SaleItem(
          medicineId: medicine.id,
          medicineName: medicine.name,
          genericName: medicine.genericName,
          isLoose: isLoose,
          quantity: quantity,
          unitsPerPack: medicine.unitsPerPack,
          unitPrice: unitPrice,
          lineTotal: lineTotal,
        ),
      );
    }

    notifyListeners();
    return null;
  }

  void updateItemQuantity(int index, int newQuantity, InventoryProvider inventory) {
    if (index >= 0 && index < _cartItems.length) {
      if (newQuantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        final item = _cartItems[index];
        final lineTotal = item.unitPrice * newQuantity;
        _cartItems[index] = SaleItem(
          medicineId: item.medicineId,
          medicineName: item.medicineName,
          genericName: item.genericName,
          isLoose: item.isLoose,
          quantity: newQuantity,
          unitsPerPack: item.unitsPerPack,
          unitPrice: item.unitPrice,
          lineTotal: lineTotal,
        );
      }
      notifyListeners();
    }
  }

  void removeItem(int index) {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems.removeAt(index);
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    _customerName = '';
    _discount = 0.0;
    _cashTendered = 0.0;
    _selectedPaymentMethod = PaymentMethod.cash;
    _splitPaymentDetails = const SplitPaymentDetails();
    notifyListeners();
  }

  /// Complete and Finalize Sale
  Sale? finalizeSale({
    required String staffId,
    required String staffName,
    required InventoryProvider inventoryProvider,
    required PrescriptionProvider prescriptionProvider,
  }) {
    if (_cartItems.isEmpty) return null;

    final invoiceNumber = 'INV-${1000 + _billingRepository.getNextInvoiceSequence()}';
    double estimatedCost = 0.0;

    // Deduct stock using FEFO from Inventory
    final finalItems = <SaleItem>[];

    for (final item in _cartItems) {
      final batches = inventoryProvider.getBatchesForMedicine(item.medicineId);
      final allocation = StockRules.allocateFEFO(
        batches: batches,
        requestedUnits: item.totalSmallestUnits,
      );

      final batchAllocMap = <String, int>{};
      for (final entry in allocation.entries) {
        batchAllocMap[entry.key.id] = entry.value;
        // Deduct from batch
        final newBatchQty = entry.key.quantityUnits - entry.value;
        inventoryProvider.updateBatch(entry.key.copyWith(quantityUnits: newBatchQty));

        // Estimate cost based on batch purchase price
        final packFraction = entry.value / item.unitsPerPack;
        estimatedCost += packFraction * entry.key.purchasePrice;
      }

      finalItems.add(
        SaleItem(
          medicineId: item.medicineId,
          medicineName: item.medicineName,
          genericName: item.genericName,
          isLoose: item.isLoose,
          quantity: item.quantity,
          unitsPerPack: item.unitsPerPack,
          unitPrice: item.unitPrice,
          lineTotal: item.lineTotal,
          batchAllocations: batchAllocMap,
        ),
      );

      // Check if controlled drug -> Record in Controlled Drug Register
      final med = inventoryProvider.getMedicineById(item.medicineId);
      if (med != null && med.isControlled) {
        prescriptionProvider.addControlledEntry(
          ControlledDrugEntry(
            id: 'ctrl-${DateTime.now().millisecondsSinceEpoch}',
            date: DateTime.now(),
            medicineId: med.id,
            medicineName: med.name,
            patientName: _customerName.trim().isNotEmpty ? _customerName.trim() : 'Walk-in Patient',
            doctorName: 'Prescription Doctor',
            prescriptionNumber: invoiceNumber,
            quantityDispensed: item.totalSmallestUnits,
            remainingStockUnits: inventoryProvider.getSellableUnits(med.id),
            pharmacistName: staffName,
          ),
        );
      }
    }

    final sale = Sale(
      id: 'sale-${DateTime.now().millisecondsSinceEpoch}',
      invoiceNumber: invoiceNumber,
      date: DateTime.now(),
      customerName: displayCustomerName,
      items: finalItems,
      subtotal: subtotal,
      discount: _discount,
      netTotal: netTotal,
      paymentMethod: _selectedPaymentMethod,
      splitPayment: _selectedPaymentMethod == PaymentMethod.split ? _splitPaymentDetails : null,
      cashTendered: _cashTendered,
      changeAmount: changeAmount,
      staffId: staffId,
      staffName: staffName,
      estimatedCost: estimatedCost,
    );

    _billingRepository.addSale(sale);
    clearCart();
    return sale;
  }

  // --- Held Bills ---
  List<HeldBill> get heldBills => _billingRepository.getHeldBills();

  void holdCurrentBill() {
    if (_cartItems.isEmpty) return;
    final held = HeldBill(
      id: 'held-${DateTime.now().millisecondsSinceEpoch}',
      customerName: displayCustomerName,
      items: List.from(_cartItems),
      discount: _discount,
      timestamp: DateTime.now(),
    );
    _billingRepository.addHeldBill(held);
    clearCart();
  }

  void restoreHeldBill(HeldBill bill) {
    _cartItems.clear();
    _cartItems.addAll(bill.items);
    _customerName = bill.customerName == 'Walk-in Customer' ? '' : bill.customerName;
    _discount = bill.discount;
    _billingRepository.removeHeldBill(bill.id);
    notifyListeners();
  }

  void removeHeldBill(String id) {
    _billingRepository.removeHeldBill(id);
    notifyListeners();
  }

  // --- Sales History & Returns ---
  List<Sale> get sales => _billingRepository.getSales();

  Sale? getSaleById(String id) => _billingRepository.getSaleById(id);

  Sale? getSaleByInvoiceNumber(String inv) => _billingRepository.getSaleByInvoiceNumber(inv);

  List<SaleReturn> get returns => _billingRepository.getReturns();

  void processReturn({
    required String invoiceNumber,
    required String customerName,
    required List<SaleReturnItem> items,
    required double totalRefund,
    required String reason,
    required String refundMethod,
    required InventoryProvider inventoryProvider,
  }) {
    final retNumber = 'RET-${3000 + _billingRepository.getNextReturnSequence()}';
    final saleReturn = SaleReturn(
      id: 'ret-${DateTime.now().millisecondsSinceEpoch}',
      returnNumber: retNumber,
      invoiceNumber: invoiceNumber,
      date: DateTime.now(),
      customerName: customerName,
      items: items,
      totalRefund: totalRefund,
      reason: reason,
      refundMethod: refundMethod,
    );
    _billingRepository.addReturn(saleReturn);

    // Restock returned items to the latest batch
    for (final rItem in items) {
      final batches = inventoryProvider.getBatchesForMedicine(rItem.medicineId);
      if (batches.isNotEmpty) {
        final batch = batches.first;
        final med = inventoryProvider.getMedicineById(rItem.medicineId);
        final units = rItem.isLoose ? rItem.returnQuantity : (rItem.returnQuantity * (med?.unitsPerPack ?? 1));
        inventoryProvider.updateBatch(batch.copyWith(quantityUnits: batch.quantityUnits + units));
      }
    }

    notifyListeners();
  }

  void loadDemoData() {
    _billingRepository.loadDemoData();
    notifyListeners();
  }

  void clearData() {
    _billingRepository.clearData();
    clearCart();
  }
}

