class Supplier {
  final String id;
  final String companyName;
  final String contactPerson;
  final String phone;
  final String email;
  final String address;
  final double balancePayable; // Store owes supplier

  const Supplier({
    required this.id,
    required this.companyName,
    required this.contactPerson,
    required this.phone,
    this.email = '',
    this.address = '',
    this.balancePayable = 0.0,
  });

  Supplier copyWith({
    String? id,
    String? companyName,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
    double? balancePayable,
  }) {
    return Supplier(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      balancePayable: balancePayable ?? this.balancePayable,
    );
  }
}

enum SupplierLedgerType {
  goodsReceived('Goods Received (Bill)'),
  paymentMade('Payment Made'),
  purchaseReturn('Purchase Return');

  final String label;
  const SupplierLedgerType(this.label);
}

class SupplierLedgerEntry {
  final String id;
  final String supplierId;
  final SupplierLedgerType type;
  final double amount;
  final DateTime date;
  final String reference; // e.g. PO-2001 or GRN-2001 or PAY-5001
  final String notes;
  final double balanceAfter;

  const SupplierLedgerEntry({
    required this.id,
    required this.supplierId,
    required this.type,
    required this.amount,
    required this.date,
    required this.reference,
    this.notes = '',
    required this.balanceAfter,
  });
}

