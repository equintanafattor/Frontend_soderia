import 'package:flutter/material.dart';
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
}
