import 'package:flutter/foundation.dart';

class MonthFilter {
  final int year; 
  final int month; 
  const MonthFilter(this.year, this.month);
}

final todosMonthFilter = ValueNotifier<MonthFilter?>(null);