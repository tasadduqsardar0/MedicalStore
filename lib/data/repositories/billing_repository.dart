import '../models/sale_model.dart';
import 'demo_data.dart';

abstract class BillingRepository {
  List<Sale> getSales();
  Sale? getSaleById(String id);
  Sale? getSaleByInvoiceNumber(String invoiceNumber);
  void addSale(Sale sale);

  List<HeldBill> getHeldBills();
  void addHeldBill(HeldBill bill);
  void removeHeldBill(String id);

  List<SaleReturn> getReturns();
  void addReturn(SaleReturn saleReturn);

  int getNextInvoiceSequence();
  int getNextReturnSequence();

  void loadDemoData();
  void clearData();
}

class MockBillingRepository implements BillingRepository {
  final List<Sale> _sales = [];
  final List<HeldBill> _heldBills = [];
  final List<SaleReturn> _returns = [];

  @override
  List<Sale> getSales() => List.unmodifiable(_sales);

  @override
  Sale? getSaleById(String id) {
    try {
      return _sales.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Sale? getSaleByInvoiceNumber(String invoiceNumber) {
    try {
      return _sales.firstWhere((s) => s.invoiceNumber.toLowerCase() == invoiceNumber.trim().toLowerCase());
    } catch (_) {
      return null;
    }
  }

  @override
  void addSale(Sale sale) {
    _sales.insert(0, sale);
  }

  @override
  List<HeldBill> getHeldBills() => List.unmodifiable(_heldBills);

  @override
  void addHeldBill(HeldBill bill) {
    _heldBills.insert(0, bill);
  }

  @override
  void removeHeldBill(String id) {
    _heldBills.removeWhere((b) => b.id == id);
  }

  @override
  List<SaleReturn> getReturns() => List.unmodifiable(_returns);

  @override
  void addReturn(SaleReturn saleReturn) {
    _returns.insert(0, saleReturn);
  }

  @override
  int getNextInvoiceSequence() => _sales.length + 1;

  @override
  int getNextReturnSequence() => _returns.length + 1;

  @override
  void loadDemoData() {
    clearData();
    _sales.addAll(DemoData.sales);
  }

  @override
  void clearData() {
    _sales.clear();
    _heldBills.clear();
    _returns.clear();
  }
}

