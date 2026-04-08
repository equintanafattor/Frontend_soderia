/* import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/colors.dart';
import 'package:frontend_soderia/core/theme.dart';

class DayFilterButtons extends StatefulWidget {
  final Function(String) onFilterChanged;

  const DayFilterButtons({super.key, required this.onFilterChanged});

  @override
  State<DayFilterButtons> createState() => _DayFilterButtonsState();
}

class _DayFilterButtonsState extends State<DayFilterButtons> {
  // Día seleccionado
  String selected = 'Hoy';

  final List<String> opciones = ['Hoy', 'Mañana', 'Ayer', 'Todos'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var opcion in opciones)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  selected = opcion;
                  widget.onFilterChanged(opcion); // Notifica al padre
                });
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: selected == opcion
                    ? Theme.of(context).colorScheme.secondary
                    : null,
                side: BorderSide(
                  color: selected == opcion
                      ? Theme.of(context).colorScheme.secondary
                      : AppColors.azul,
                ),
              ),
              child: Text(
                opcion,
                style: TextStyle(
                  color: selected == opcion
                      ? Theme.of(context).colorScheme.onSecondary
                      : AppColors.azul,
                ),
              ),
            ),
          ),
        // Boton con icono "+"
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: OutlinedButton(
            onPressed: () {
              // TODO: accion del boton "+"
            },
            style: OutlinedButton.styleFrom(
              shape: const CircleBorder(),
              side: const BorderSide(color: Colors.black),
              padding: const EdgeInsets.all(12),
            ),
            child: const Icon(Icons.add, color: Colors.black),
          ),
        ),
      ],
    );
  }
} */

import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/colors.dart';

class DayFilterButtons extends StatelessWidget {
  final String selected; // 👈 filtro actual: 'Hoy' | 'Mañana' | 'Ayer' | 'Todos'
  final ValueChanged<String> onFilterChanged;

  const DayFilterButtons({
    super.key,
    required this.selected,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget buildChip(String label, IconData icon) {
      final bool isSelected = selected == label;
      return ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? cs.onPrimary : AppColors.grisTexto,
            ),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (_) => onFilterChanged(label),
        selectedColor: cs.primary,
        labelStyle: TextStyle(
          color: isSelected ? cs.onPrimary : AppColors.grisTexto,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
        backgroundColor: cs.surface,
        side: BorderSide(
          color: isSelected ? cs.primary : AppColors.bordeSuave,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      children: [
        buildChip('Ayer', Icons.arrow_back),
        buildChip('Hoy', Icons.today),
        buildChip('Mañana', Icons.arrow_forward),
        buildChip('Todos', Icons.calendar_month),
      ],
    );
  }
}

