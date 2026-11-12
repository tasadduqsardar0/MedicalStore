enum PaymentMethod {
  cash('Cash'),
  card('Card'),
  split('Split Payment');

  final String label;
  const PaymentMethod(this.label);
}

class SplitPaymentDetails {
  final double cashAmount;
  final double cardAmount;

  const SplitPaymentDetails({
    this.cashAmount = 0.0,
    this.cardAmount = 0.0,
  });

  double get total => cashAmount + cardAmount;
}

class SaleItem {
  final String medicineId;
  final String medicineName;
  final String genericName;
  final bool isLoose;
  final int quantity; // Number of packs or number of loose units
  final int unitsPerPack;
  final double unitPrice;
  final double lineTotal;
  final Map<String, int> batchAllocations; // batchId -> units taken

  const SaleItem({
    required this.medicineId,
    required this.medicineName,
    required this.genericName,
    required this.isLoose,
    required this.quantity,
    required this.unitsPerPack,
    required this.unitPrice,
    required this.lineTotal,
    this.batchAllocations = const {},
  });

  int get totalSmallestUnits => isLoose ? quantity : (quantity * unitsPerPack);
}

class Sale {
  final String id;
  final String invoiceNumber; // e.g. INV-1001
  final DateTime date;
  final String customerName;
  final List<SaleItem> items;
  final double subtotal;
  final double discount; // Flat discount
  final double netTotal;
  final PaymentMethod paymentMethod;
  final SplitPaymentDetails? splitPayment;
  final double cashTendered;
  final double changeAmount;
  final String staffId;
  final String staffName;
  final double estimatedCost; // For profit calculation (Owner only)

  const Sale({
    required this.id,
    required this.invoiceNumber,
    required this.date,
    this.customerName = 'Walk-in Customer',
    required this.items,
    required this.subtotal,
    this.discount = 0.0,
    required this.netTotal,
    required this.paymentMethod,
    this.splitPayment,
    this.cashTendered = 0.0,
    this.changeAmount = 0.0,
    required this.staffId,
    required this.staffName,
    this.estimatedCost = 0.0,
  });

  double get profit => (netTotal - estimatedCost).clamp(0, double.infinity);
}

class HeldBill {
  final String id;
  final String customerName;
  final List<SaleItem> items;
  final double discount;
  final DateTime timestamp;

  const HeldBill({
    required this.id,
    required this.customerName,
    required this.items,
    this.discount = 0.0,
    required this.timestamp,
  });

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.lineTotal);
  double get netTotal => (subtotal - discount).clamp(0, double.infinity);
}

class SaleReturnItem {
  final String medicineId;
  final String medicineName;
  final bool isLoose;
  final int returnQuantity;
  final double unitPrice;
  final double refundAmount;

  const SaleReturnItem({
    required this.medicineId,
    required this.medicineName,
    required this.isLoose,
    required this.returnQuantity,
    required this.unitPrice,
    required this.refundAmount,
  });
}

class SaleReturn {
  final String id;
  final String returnNumber; // e.g. RET-3001
  final String invoiceNumber;
  final DateTime date;
  final String customerName;
  final List<SaleReturnItem> items;
  final double totalRefund;
  final String reason;
  final String refundMethod; // Cash or Credit Adjustment

  const SaleReturn({
    required this.id,
    required this.returnNumber,
    required this.invoiceNumber,
    required this.date,
    required this.customerName,
    required this.items,
    required this.totalRefund,
    required this.reason,
    required this.refundMethod,
  });
}

