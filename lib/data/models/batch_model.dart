class Batch {
  final String id;
  final String medicineId;
  final String batchNumber;
  final DateTime expiryDate;
  final int quantityUnits; // Stock stored in smallest unit (e.g. tablets)
  final double purchasePrice; // Purchase price per pack

  const Batch({
    required this.id,
    required this.medicineId,
    required this.batchNumber,
    required this.expiryDate,
    required this.quantityUnits,
    required this.purchasePrice,
  });

  Batch copyWith({
    String? id,
    String? medicineId,
    String? batchNumber,
    DateTime? expiryDate,
    int? quantityUnits,
    double? purchasePrice,
  }) {
    return Batch(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      quantityUnits: quantityUnits ?? this.quantityUnits,
      purchasePrice: purchasePrice ?? this.purchasePrice,
    );
  }
}

