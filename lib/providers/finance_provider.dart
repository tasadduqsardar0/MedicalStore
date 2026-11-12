import 'package:flutter/material.dart';
import '../data/models/finance_model.dart';
import '../data/repositories/finance_repository.dart';
import 'billing_provider.dart';

class FinanceProvider extends ChangeNotifier {
  final FinanceRepository _financeRepository;

  FinanceProvider({required FinanceRepository financeRepository})
      : _financeRepository = financeRepository;

  CashRegister? get currentCashRegister => _financeRepository.getCurrentCashRegister();
  bool get isRegisterOpen => _financeRepository.getCurrentCashRegister()?.isOpen == true;

  void openRegister({
    required double openingCash,
    required String openedBy,
  }) {
    final reg = CashRegister(
      id: 'reg-${DateTime.now().millisecondsSinceEpoch}',
      openingTime: DateTime.now(),
      openingCash: openingCash,
      openedBy: openedBy,
      isOpen: true,
    );
    _financeRepository.openCashRegister(reg);
    notifyListeners();
  }

  void closeRegister({
    required double actualCash,
    required String notes,
    required String closedBy,
    required BillingProvider billingProvider,
  }) {
    final current = currentCashRegister;
    if (current == null) return;

    // Calculate cash sales since opening
    final salesSinceOpening = billingProvider.sales.where((s) => s.date.isAfter(current.openingTime));
    final cashSales = salesSinceOpening.where((s) => s.paymentMethod.name == 'cash').fold(0.0, (sum, s) => sum + s.netTotal);
    final splitCashSales = salesSinceOpening.where((s) => s.paymentMethod.name == 'split').fold(0.0, (sum, s) => sum + (s.splitPayment?.cashAmount ?? 0.0));
    final totalCashSales = cashSales + splitCashSales;

    // Cash expenses since opening
    final expensesSinceOpening = expenses.where((e) => e.date.isAfter(current.openingTime) && e.paymentMethod.toLowerCase() == 'cash');
    final totalCashExpenses = expensesSinceOpening.fold(0.0, (sum, e) => sum + e.amount);

    final expectedCash = current.openingCash + totalCashSales - totalCashExpenses;
    final difference = actualCash - expectedCash;

    final closed = current.copyWith(
      closingTime: DateTime.now(),
      totalCashSales: totalCashSales,
      totalCashExpenses: totalCashExpenses,
      expectedCash: expectedCash,
      actualCash: actualCash,
      difference: difference,
      isOpen: false,
      notes: notes,
      closedBy: closedBy,
    );

    _financeRepository.closeCashRegister(closed);

    // Also record a Daily Closing Summary
    final cardSales = salesSinceOpening.where((s) => s.paymentMethod.name == 'card').fold(0.0, (sum, s) => sum + s.netTotal) +
        salesSinceOpening.where((s) => s.paymentMethod.name == 'split').fold(0.0, (sum, s) => sum + (s.splitPayment?.cardAmount ?? 0.0));
    final summary = DailyClosingSummary(
      id: 'dcs-${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      openingCash: current.openingCash,
      cashSales: totalCashSales,
      cardSales: cardSales,
      totalSales: salesSinceOpening.fold(0.0, (sum, s) => sum + s.netTotal),
      totalExpenses: totalCashExpenses,
      expectedCashInDrawer: expectedCash,
      actualCashCounted: actualCash,
      difference: difference,
      notes: notes,
      closedBy: closedBy,
      isFinalized: true,
    );
    _financeRepository.addDailyClosing(summary);

    notifyListeners();
  }

  // --- Expenses ---
  List<Expense> get expenses => _financeRepository.getExpenses();

  void addExpense({
    required ExpenseCategory category,
    required double amount,
    required String description,
    String paymentMethod = 'Cash',
    required String recordedBy,
  }) {
    final exp = Expense(
      id: 'exp-${DateTime.now().millisecondsSinceEpoch}',
      category: category,
      amount: amount,
      description: description,
      paymentMethod: paymentMethod,
      date: DateTime.now(),
      recordedBy: recordedBy,
    );
    _financeRepository.addExpense(exp);
    notifyListeners();
  }

  double get totalExpensesToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return expenses
        .where((e) => e.date.isAfter(today))
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  // --- Daily Closings ---
  List<DailyClosingSummary> get dailyClosings => _financeRepository.getDailyClosings();

  void loadDemoData() {
    _financeRepository.loadDemoData();
    notifyListeners();
  }

  void clearData() {
    _financeRepository.clearData();
    notifyListeners();
  }
}

