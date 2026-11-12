class CashRegister {
  final String id;
  final DateTime openingTime;
  final DateTime? closingTime;
  final double openingCash;
  final double totalCashSales;
  final double totalCashExpenses;
  final double expectedCash;
  final double actualCash;
  final double difference;
  final bool isOpen;
  final String notes;
  final String openedBy;
  final String? closedBy;

  const CashRegister({
    required this.id,
    required this.openingTime,
    this.closingTime,
    required this.openingCash,
    this.totalCashSales = 0.0,
    this.totalCashExpenses = 0.0,
    this.expectedCash = 0.0,
    this.actualCash = 0.0,
    this.difference = 0.0,
    this.isOpen = true,
    this.notes = '',
    required this.openedBy,
    this.closedBy,
  });

  CashRegister copyWith({
    String? id,
    DateTime? openingTime,
    DateTime? closingTime,
    double? openingCash,
    double? totalCashSales,
    double? totalCashExpenses,
    double? expectedCash,
    double? actualCash,
    double? difference,
    bool? isOpen,
    String? notes,
    String? openedBy,
    String? closedBy,
  }) {
    return CashRegister(
      id: id ?? this.id,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      openingCash: openingCash ?? this.openingCash,
      totalCashSales: totalCashSales ?? this.totalCashSales,
      totalCashExpenses: totalCashExpenses ?? this.totalCashExpenses,
      expectedCash: expectedCash ?? this.expectedCash,
      actualCash: actualCash ?? this.actualCash,
      difference: difference ?? this.difference,
      isOpen: isOpen ?? this.isOpen,
      notes: notes ?? this.notes,
      openedBy: openedBy ?? this.openedBy,
      closedBy: closedBy ?? this.closedBy,
    );
  }
}

enum ExpenseCategory {
  rent('Shop Rent'),
  utilities('Utilities (Electricity, Water)'),
  salary('Staff Salary'),
  maintenance('Shop Maintenance'),
  teaSnacks('Tea & Refreshments'),
  supplies('Packaging & Stationery'),
  misc('Miscellaneous');

  final String label;
  const ExpenseCategory(this.label);
}

class Expense {
  final String id;
  final ExpenseCategory category;
  final double amount;
  final String description;
  final String paymentMethod; // Cash, Bank
  final DateTime date;
  final String recordedBy;

  const Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.description,
    this.paymentMethod = 'Cash',
    required this.date,
    required this.recordedBy,
  });
}

class DailyClosingSummary {
  final String id;
  final DateTime date;
  final double openingCash;
  final double cashSales;
  final double cardSales;
  final double totalSales;
  final double totalExpenses;
  final double expectedCashInDrawer;
  final double actualCashCounted;
  final double difference;
  final String notes;
  final String closedBy;
  final bool isFinalized;

  const DailyClosingSummary({
    required this.id,
    required this.date,
    required this.openingCash,
    required this.cashSales,
    required this.cardSales,
    required this.totalSales,
    required this.totalExpenses,
    required this.expectedCashInDrawer,
    required this.actualCashCounted,
    required this.difference,
    this.notes = '',
    required this.closedBy,
    this.isFinalized = false,
  });
}

