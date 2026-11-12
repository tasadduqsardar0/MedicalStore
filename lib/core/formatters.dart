import 'package:intl/intl.dart';

class AppFormatters {
  static final NumberFormat _currencyFormat = NumberFormat('#,##0', 'en_US');
  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _shortDateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');
  static final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');

  /// Formats currency strictly as specified: "Rs 1,250"
  static String currency(num amount) {
    return 'Rs ${_currencyFormat.format(amount)}';
  }

  /// Formats currency with optional decimals if needed
  static String currencyWithDecimals(num amount) {
    if (amount % 1 == 0) {
      return currency(amount.toInt());
    }
    final format = NumberFormat('#,##0.00', 'en_US');
    return 'Rs ${format.format(amount)}';
  }

  /// Formats date: "12 Nov 2026"
  static String date(DateTime dt) {
    return _dateFormat.format(dt);
  }

  /// Formats short date: "12/11/2026"
  static String shortDate(DateTime dt) {
    return _shortDateFormat.format(dt);
  }

  /// Formats time: "02:45 PM"
  static String time(DateTime dt) {
    return _timeFormat.format(dt);
  }

  /// Formats date and time: "12 Nov 2026, 02:45 PM"
  static String dateTime(DateTime dt) {
    return _dateTimeFormat.format(dt);
  }

  /// Format invoice number e.g. INV-1001
  static String invoiceNumber(int sequence) {
    return 'INV-${1000 + sequence}';
  }

  /// Format purchase order number e.g. PO-2001
  static String purchaseOrderNumber(int sequence) {
    return 'PO-${2000 + sequence}';
  }

  /// Format prescription number e.g. RX-5001
  static String prescriptionNumber(int sequence) {
    return 'RX-${5000 + sequence}';
  }

  /// Format return number e.g. RET-3001
  static String returnNumber(int sequence) {
    return 'RET-${3000 + sequence}';
  }
}

