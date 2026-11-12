enum StockAdjustmentType {
  correction('Quantity Correction'),
  damage('Damaged Stock'),
  disposal('Expired / Disposal');

  final String label;
  const StockAdjustmentType(this.label);
}

class StockAdjustment {
  final String id;
  final String medicineId;
  final String medicineName;
  final String batchNumber;
  final StockAdjustmentType type;
  final int quantityUnits; // Positive (added) or negative (subtracted)
  final String reason;
  final DateTime date;
  final String adjustedBy;

  const StockAdjustment({
    required this.id,
    required this.medicineId,
    required this.medicineName,
    required this.batchNumber,
    required this.type,
    required this.quantityUnits,
    required this.reason,
    required this.date,
    required this.adjustedBy,
  });
}

class StockAuditItem {
  final String medicineId;
  final String medicineName;
  final int systemUnits;
  int countedUnits;
  final int unitsPerPack;
  final String packType;
  final String unitName;

  StockAuditItem({
    required this.medicineId,
    required this.medicineName,
    required this.systemUnits,
    required this.countedUnits,
    required this.unitsPerPack,
    required this.packType,
    required this.unitName,
  });

  int get varianceUnits => countedUnits - systemUnits;
}

class ActivityLog {
  final String id;
  final DateTime timestamp;
  final String userName;
  final String role;
  final String action;
  final String details;

  const ActivityLog({
    required this.id,
    required this.timestamp,
    required this.userName,
    required this.role,
    required this.action,
    required this.details,
  });
}

