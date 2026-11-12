import 'package:flutter/material.dart';

enum ReportDateRange {
  today('Today'),
  last7Days('Last 7 Days'),
  last30Days('Last 30 Days'),
  thisMonth('This Month'),
  allTime('All Time');

  final String label;
  const ReportDateRange(this.label);
}

class ReportsProvider extends ChangeNotifier {
  ReportDateRange _selectedRange = ReportDateRange.last7Days;

  ReportDateRange get selectedRange => _selectedRange;

  void setDateRange(ReportDateRange range) {
    _selectedRange = range;
    notifyListeners();
  }

  DateTime getStartDateForRange(ReportDateRange range) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (range) {
      case ReportDateRange.today:
        return today;
      case ReportDateRange.last7Days:
        return today.subtract(const Duration(days: 7));
      case ReportDateRange.last30Days:
        return today.subtract(const Duration(days: 30));
      case ReportDateRange.thisMonth:
        return DateTime(now.year, now.month, 1);
      case ReportDateRange.allTime:
        return DateTime(2020);
    }
  }
}

