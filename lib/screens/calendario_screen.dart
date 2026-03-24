// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/colors.dart';
import 'package:frontend_soderia/core/navigation/app_shell_actions.dart';
import 'package:frontend_soderia/core/navigation/destinations.dart'; // kIndexTareas
import 'package:frontend_soderia/core/state/todos_filter.dart';

const _meses = [
  'Enero',
  'Febrero',
  'Marzo',
  'Abril',
  'Mayo',
  'Junio',
  'Julio',
  'Agosto',
  'Septiembre',
  'Octubre',
  'Noviembre',
  'Diciembre',
];

const _weekdaysMonFirst = [
  'L',
  'M',
  'M',
  'J',
  'V',
  'S',
  'D',
]; // Lunes a Domingo

class CalendarioScreen extends StatelessWidget {
  const CalendarioScreen({super.key, this.nombreUsuario = 'Usuario'});

  final String nombreUsuario;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final year = now.year;

    return Scaffold(
      backgroundColor: AppColors.fondoSuave,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hola, $nombreUsuario!",
                style: const TextStyle(
                  // color: AppColors.azul,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      AppShellActions.jumpToTab(context, kIndexInicio);
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Calendario',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.azul,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Seleccioná un mes para ver tareas y recorridos',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.grisTexto,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(color: AppColors.bordeSuave, thickness: 1),
              const SizedBox(height: 12),

              // ---------- Grid responsive ----------
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const minTileWidth = 260.0; // ancho ideal por tarjeta
                    final crossAxisCount = math.max(
                      2,
                      (constraints.maxWidth / minTileWidth).floor(),
                    );
                    final childAspectRatio = _calcAspectRatio(
                      constraints.maxWidth,
                      crossAxisCount,
                    );

                    return GridView.builder(
                      itemCount: _meses.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: childAspectRatio,
                      ),
                      itemBuilder: (context, i) => _MesCard(
                        mes: i + 1,
                        onTap: () {
                          todosMonthFilter.value = MonthFilter(year, i + 1);
                          AppShellActions.jumpToTab(context, kIndexTareas);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Colores alternados en la grilla (misma familia que tu azul)
  static Color _mesColor(int i) {
    const shades = [
      AppColors.azul,
      Color(0xFF1E3A55),
      Color(0xFF2C4A63),
      Color(0xFF375C78),
      Color(0xFF436B8B),
      Color(0xFF517CA0),
    ];
    return shades[i % shades.length];
  }

  // Mantiene una altura cómoda según columnas y ancho disponible
  static double _calcAspectRatio(double maxWidth, int cols) {
    final tileWidth = (maxWidth - (12.0 * (cols - 1))) / cols;
    // Queremos que cada tarjeta entre título + mini-mes sin scroll
    const desiredHeight = 320.0; // un poco más alto para 6 filas x 7 cols
    return tileWidth / desiredHeight;
  }
}

class _MesCard extends StatelessWidget {
  final int mes;
  final VoidCallback onTap;

  const _MesCard({required this.mes, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ahora = DateTime.now();
    final year = ahora.year;
    final esMesActual = mes == ahora.month;
    final matrix = _monthMatrixMonFirst(year, mes);

    final nombreMes = const [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ][mes - 1];

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: esMesActual ? Colors.white : const Color(0xFFF8FBFD),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: esMesActual ? AppColors.azul : AppColors.bordeSuave,
            width: esMesActual ? 2 : 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              blurRadius: 8,
              offset: Offset(0, 2),
              color: Color(0x11000000),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    nombreMes,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.azul,
                    ),
                  ),
                ),
                if (esMesActual)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.azul.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Actual',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.azul,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            /// Días de la semana
            Row(
              children: _weekdaysMonFirst.map((d) {
                return Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grisTexto,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 6),

            /// Grilla del mes
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 42,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemBuilder: (context, i) {
                  final day = matrix[i];

                  final esHoy =
                      day != null &&
                      ahora.year == year &&
                      ahora.month == mes &&
                      ahora.day == day;

                  return Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: day == null
                          ? Colors.transparent
                          : esHoy
                          ? AppColors.verde.withOpacity(0.22)
                          : AppColors.celeste.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: esHoy
                          ? Border.all(color: AppColors.verde, width: 1.2)
                          : null,
                    ),
                    child: day == null
                        ? null
                        : Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: esHoy
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: esHoy ? AppColors.verde : AppColors.azul,
                            ),
                          ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Ver tareas',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.grisTexto,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int? day;
  final bool disabled;
  final double fontSize;

  const _DayCell({
    required this.day,
    required this.disabled,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final bg = disabled
        // ignore: deprecated_member_use
        ? Colors.white.withOpacity(0.06)
        // ignore: deprecated_member_use
        : AppColors.blanco.withOpacity(0.14);

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: disabled
          ? null
          : Text(
              '$day',
              style: TextStyle(
                color: AppColors.blanco,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}

/// ---------- Helpers de calendario (lunes a domingo) ----------

int _daysInMonth(int year, int month) {
  return DateTime(year, month + 1, 0).day; // día 0 del mes siguiente
}

/// Devuelve un array de 42 posiciones (6 filas × 7 cols) con los días del mes,
/// colocando `null` para los huecos previos/siguientes. Semana inicia en Lunes.
List<int?> _monthMatrixMonFirst(int year, int month) {
  final total = _daysInMonth(year, month);
  final first = DateTime(year, month, 1);

  // Dart: Monday=1..Sunday=7
  final weekdayFirst = first.weekday; // 1..7
  // Si Monday=1, el offset es weekday-1
  final leadingNulls = weekdayFirst - 1;

  final out = List<int?>.filled(42, null);
  for (int d = 1; d <= total; d++) {
    out[leadingNulls + (d - 1)] = d;
  }
  return out;
}
