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
              const SizedBox(height: 8),
              const Text(
                "Seleccioná un mes o buscá por cliente o fecha",
                style: TextStyle(color: AppColors.grisTexto, fontSize: 14),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      // Cambiar a la pestaña de Inicio dentro del AppShell
                      AppShellActions.jumpToTab(context, kIndexInicio);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.azul,
                      size: 28,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.blanco,
                      shape: const CircleBorder(),
                    ),
                  ),

                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Día, mes o cliente...',
                          hintStyle: const TextStyle(
                            color: AppColors.grisTexto,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.grisTexto,
                          ),
                          filled: true,
                          fillColor: AppColors.blanco,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40),
                            borderSide: const BorderSide(
                              color: AppColors.bordeSuave,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      /* abrir alta si corresponde */
                    },
                    icon: const Icon(Icons.add, color: AppColors.blanco),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.verde,
                      shape: const CircleBorder(),
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
                        nombre: _meses[i],
                        year: year,
                        monthOneBased: i + 1,
                        color: _mesColor(i),
                        onTap: () {
                          // 1) Seteamos filtro global
                          todosMonthFilter.value = MonthFilter(year, i + 1);
                          // 2) Saltamos a pestaña Tareas
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
    const desiredHeight = 260.0; // un poco más alto para 6 filas x 7 cols
    return tileWidth / desiredHeight;
  }
}

class _MesCard extends StatelessWidget {
  final String nombre;
  final int year;
  final int monthOneBased; // 1..12
  final Color color;
  final VoidCallback onTap;

  const _MesCard({
    required this.nombre,
    required this.year,
    required this.monthOneBased,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final matrix = _monthMatrixMonFirst(year, monthOneBased); // 42 celdas

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, bc) {
            // ---- Constantes de layout (podés afinarlas) ----
            const rows = 6;
            const cols = 7;
            const gap = 3.0; // espacio entre celdas
            const titleHeight = 22.0; // alto estimado del título
            const weekHdrHeight = 18.0; // alto de "L M M J V S"
            const vSpacing =
                8.0 + 6.0; // separadores verticales entre secciones
            // ------------------------------------------------

            // Área interna disponible para la grilla
            final innerW = bc.maxWidth;
            final innerH = bc.maxHeight;

            final reservedH = titleHeight + weekHdrHeight + vSpacing;
            final gridAvailH = (innerH - reservedH).clamp(60.0, innerH);

            // Tamaño de celda máximo que entra en 6x7
            final cellW = (innerW - (cols - 1) * gap) / cols;
            final cellH = (gridAvailH - (rows - 1) * gap) / rows;
            final cellSize = math.max(
              16.0,
              math.min(cellW, cellH),
            ); // piso 16px

            final gridHeight = rows * cellSize + (rows - 1) * gap;

            // Fuente proporcional pero con topes
            final dayFont = cellSize <= 18
                ? 9.0
                : (cellSize <= 22 ? 10.0 : 11.0);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado del mes
                Text(
                  '$nombre $year',
                  style: const TextStyle(
                    color: AppColors.blanco,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Encabezado de días (L a D)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final w in _weekdaysMonFirst)
                      SizedBox(
                        width: cellSize, // igual que la celda
                        child: Text(
                          w,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.blanco,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),

                // Grilla del mini-mes con altura fija calculada
                SizedBox(
                  height: gridHeight,
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: rows * cols,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      mainAxisSpacing: gap,
                      crossAxisSpacing: gap,
                      childAspectRatio: 1, // celdas cuadradas
                    ),
                    itemBuilder: (_, idx) {
                      final day = matrix[idx];
                      final disabled = day == null;
                      return _DayCell(
                        day: day,
                        disabled: disabled,
                        fontSize: dayFont,
                      );
                    },
                  ),
                ),
              ],
            );
          },
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
