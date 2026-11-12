enum POStatus {
  draft('Draft'),
  sent('Sent'),
  received('Received'),
  cancelled('Cancelled');

  final String label;
  const POStatus(this.label);
}

class POLineItem {
  final String medicineId;
  final String medicineName;
  final int packQuantity;
  final double purchasePricePerPack;

  const POLineItem({
    required this.medicineId,
    required this.medicineName,
    required this.packQuantity,
    required this.purchasePricePerPack,
  });

  double get lineTotal => packQuantity * purchasePricePerPack;
}

class PurchaseOrder {
  final String id;
  final String poNumber; // e.g. PO-2001
  final String supplierId;
  final String supplierName;
  final DateTime orderDate;
  final DateTime? expectedDeliveryDate;
  final POStatus status;
  final List<POLineItem> items;
  final double totalAmount;
  final String notes;

  const PurchaseOrder({
    required this.id,
    required this.poNumber,
    required this.supplierId,
    required this.supplierName,
    required this.orderDate,
    this.expectedDeliveryDate,
    required this.status,
    required this.items,
    required this.totalAmount,
    this.notes = '',
  });

  PurchaseOrder copyWith({
    String? id,
    String? poNumber,
    String? supplierId,
    String? supplierName,
    DateTime? orderDate,
    DateTime? expectedDeliveryDate,
    POStatus? status,
    List<POLineItem>? items,
    double? totalAmount,
    String? notes,
  }) {
    return PurchaseOrder(
      id: id ?? this.id,
      poNumber: poNumber ?? this.poNumber,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      orderDate: orderDate ?? this.orderDate,
      expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
      status: status ?? this.status,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      notes: notes ?? this.notes,
    );
  }
}

class PurchaseReturn {
  final String id;
  final String returnNumber; // e.g. PR-3001
  final String supplierId;
  final String supplierName;
  final String medicineId;
  final String medicineName;
  final String batchNumber;
  final int packQuantity;
  final double unitPrice;
  final double totalAmount;
  final String reason;
  final DateTime date;

  const PurchaseReturn({
    required this.id,
    required this.returnNumber,
    required this.supplierId,
    required this.supplierName,
    required this.medicineId,
    required this.medicineName,
    required this.batchNumber,
    required this.packQuantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.reason,
    required this.date,
  });
}

