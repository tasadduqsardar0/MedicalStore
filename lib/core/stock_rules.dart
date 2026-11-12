import '../data/models/batch_model.dart';

/// StockRules centralizes all pharmacy stock calculations, status evaluations,
/// units conversion, and FEFO allocation as required by business rules.
class StockRules {
  /// Check if a batch is expired today or earlier
  static bool isBatchExpired(DateTime expiryDate, [DateTime? now]) {
    final reference = now ?? DateTime.now();
    final today = DateTime(reference.year, reference.month, reference.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return expiry.isBefore(today);
  }

  /// Check if a batch is near expiry (within [thresholdDays], default 30 days)
  /// and NOT already expired.
  static bool isBatchNearExpiry(
    DateTime expiryDate, {
    int thresholdDays = 30,
    DateTime? now,
  }) {
    if (isBatchExpired(expiryDate, now)) return false;
    final reference = now ?? DateTime.now();
    final today = DateTime(reference.year, reference.month, reference.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    final daysUntilExpiry = expiry.difference(today).inDays;
    return daysUntilExpiry <= thresholdDays && daysUntilExpiry >= 0;
  }

  /// Total units across ALL batches (including expired)
  static int totalStockUnits(List<Batch> batches) {
    return batches.fold(0, (sum, b) => sum + b.quantityUnits);
  }

  /// Sellable units = ONLY non-expired batches!
  /// Expired stock is never sold and never counted as sellable.
  static int sellableStockUnits(List<Batch> batches, [DateTime? now]) {
    return batches
        .where((b) => !isBatchExpired(b.expiryDate, now))
        .fold(0, (sum, b) => sum + b.quantityUnits);
  }

  /// Expired units
  static int expiredStockUnits(List<Batch> batches, [DateTime? now]) {
    return batches
        .where((b) => isBatchExpired(b.expiryDate, now))
        .fold(0, (sum, b) => sum + b.quantityUnits);
  }

  /// Near expiry units
  static int nearExpiryStockUnits(
    List<Batch> batches, {
    int thresholdDays = 30,
    DateTime? now,
  }) {
    return batches
        .where((b) => isBatchNearExpiry(b.expiryDate, thresholdDays: thresholdDays, now: now))
        .fold(0, (sum, b) => sum + b.quantityUnits);
  }

  /// Format stock in smallest units as "Packs + Loose",
  /// e.g. "3 Strips + 4 Tablets" or "2 Bottles" or "0 Tablets"
  static String formatStockDisplay({
    required int totalUnits,
    required int unitsPerPack,
    required String packTypeName,
    required String unitName,
  }) {
    if (totalUnits <= 0) {
      return '0 $unitName';
    }

    if (unitsPerPack <= 1) {
      return '$totalUnits $packTypeName${totalUnits > 1 ? 's' : ''}';
    }

    final packs = totalUnits ~/ unitsPerPack;
    final loose = totalUnits % unitsPerPack;

    if (packs > 0 && loose > 0) {
      final pLabel = packs == 1 ? packTypeName : '${packTypeName}s';
      final uLabel = loose == 1 ? unitName : '${unitName}s';
      return '$packs $pLabel + $loose $uLabel';
    } else if (packs > 0) {
      final pLabel = packs == 1 ? packTypeName : '${packTypeName}s';
      return '$packs $pLabel';
    } else {
      final uLabel = loose == 1 ? unitName : '${unitName}s';
      return '$loose $uLabel';
    }
  }

  /// Evaluates the stock status of a medicine based on sellable units and batches.
  static StockStatus evaluateStatus({
    required List<Batch> batches,
    required int unitsPerPack,
    required int minimumStockPacks,
    int thresholdDays = 30,
    DateTime? now,
  }) {
    final sellableUnits = sellableStockUnits(batches, now);
    final hasExpired = batches.any((b) => isBatchExpired(b.expiryDate, now) && b.quantityUnits > 0);
    final hasNearExpiry = batches.any(
      (b) => isBatchNearExpiry(b.expiryDate, thresholdDays: thresholdDays, now: now) && b.quantityUnits > 0,
    );

    if (sellableUnits <= 0) {
      if (hasExpired) return StockStatus.expiredStock;
      return StockStatus.outOfStock;
    }

    final minStockUnits = minimumStockPacks * unitsPerPack;
    if (sellableUnits <= minStockUnits) {
      return StockStatus.lowStock;
    }

    if (hasNearExpiry) {
      return StockStatus.nearExpiry;
    }

    return StockStatus.inStock;
  }

  /// Can medicine unitsPerPack be edited?
  /// Rule: Units per pack cannot be changed while the medicine has stock.
  static bool canEditUnitsPerPack(List<Batch> batches) {
    return totalStockUnits(batches) == 0;
  }

  /// Can medicine be deleted?
  /// Rule: Only the owner can delete. A medicine can be deleted only when its stock is 0.
  static bool canDeleteMedicine(List<Batch> batches) {
    return totalStockUnits(batches) == 0;
  }

  /// Can category be deleted?
  /// Rule: Only the owner can delete. A category only when it has no medicines.
  static bool canDeleteCategory(int medicineCount) {
    return medicineCount == 0;
  }

  /// Validate new batch expiry date.
  /// Rule: A new batch with an expiry date in the past is not accepted.
  static bool isValidBatchExpiry(DateTime expiryDate, [DateTime? now]) {
    final reference = now ?? DateTime.now();
    final today = DateTime(reference.year, reference.month, reference.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return !expiry.isBefore(today);
  }

  /// FEFO Allocation (First Expired, First Out)
  /// Deducts [requestedUnits] from non-expired batches sorted by earliest expiry date.
  /// Returns a map of Batch -> allocatedUnits, or throws an exception if insufficient stock.
  static Map<Batch, int> allocateFEFO({
    required List<Batch> batches,
    required int requestedUnits,
    DateTime? now,
  }) {
    final sellable = batches
        .where((b) => !isBatchExpired(b.expiryDate, now) && b.quantityUnits > 0)
        .toList();

    // Sort by earliest expiry date first (FEFO)
    sellable.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

    int remaining = requestedUnits;
    final allocation = <Batch, int>{};

    for (final batch in sellable) {
      if (remaining <= 0) break;
      final toTake = batch.quantityUnits >= remaining ? remaining : batch.quantityUnits;
      allocation[batch] = toTake;
      remaining -= toTake;
    }

    if (remaining > 0) {
      throw Exception('Insufficient sellable stock for allocation');
    }

    return allocation;
  }
}

enum StockStatus {
  inStock,
  lowStock,
  outOfStock,
  expiredStock,
  nearExpiry,
}
