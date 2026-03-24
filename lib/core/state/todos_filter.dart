import 'package:flutter/foundation.dart';

class MonthFilter {
  final int year;
  final int month;
  MonthFilter(this.year, this.month);
}

/// Ya lo tenías
final ValueNotifier<MonthFilter?> todosMonthFilter =
    ValueNotifier<MonthFilter?>(null);

/// NUEVO: para decirle a HomeScreen qué filtro de día usar
/// Valores esperados: 'Hoy' | 'Mañana' | 'Ayer' | 'Todos' | null
final ValueNotifier<String?> homeDayFilter =
    ValueNotifier<String?>(null);
