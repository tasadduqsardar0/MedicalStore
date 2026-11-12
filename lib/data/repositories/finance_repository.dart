import '../models/finance_model.dart';
import 'demo_data.dart';

abstract class FinanceRepository {
  CashRegister? getCurrentCashRegister();
  void openCashRegister(CashRegister register);
  void closeCashRegister(CashRegister register);

  List<Expense> getExpenses();
  void addExpense(Expense expense);

  List<DailyClosingSummary> getDailyClosings();
  void addDailyClosing(DailyClosingSummary summary);

  void loadDemoData();
  void clearData();
}

class MockFinanceRepository implements FinanceRepository {
  CashRegister? _currentRegister;
  final List<Expense> _expenses = [];
  final List<DailyClosingSummary> _closings = [];

  @override
  CashRegister? getCurrentCashRegister() => _currentRegister;

  @override
  void openCashRegister(CashRegister register) {
    _currentRegister = register;
  }

  @override
  void closeCashRegister(CashRegister register) {
    _currentRegister = register;
  }

  @override
  List<Expense> getExpenses() => List.unmodifiable(_expenses);

  @override
  void addExpense(Expense expense) {
    _expenses.insert(0, expense);
  }

  @override
  List<DailyClosingSummary> getDailyClosings() => List.unmodifiable(_closings);

  @override
  void addDailyClosing(DailyClosingSummary summary) {
    _closings.insert(0, summary);
  }

  @override
  void loadDemoData() {
    clearData();
    _expenses.addAll(DemoData.expenses);
    _currentRegister = CashRegister(
      id: 'reg-1',
      openingTime: DateTime.now().subtract(const Duration(hours: 6)),
      openingCash: 5000.0,
      totalCashSales: 470.0,
      totalCashExpenses: 1150.0,
      expectedCash: 4320.0,
      actualCash: 0.0,
      difference: 0.0,
      isOpen: true,
      openedBy: 'Tariq Mahmood',
    );
  }

  @override
  void clearData() {
    _currentRegister = null;
    _expenses.clear();
    _closings.clear();
  }
}

