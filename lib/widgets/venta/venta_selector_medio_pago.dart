// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class VentaSelectorMedioPago extends StatelessWidget {
  final Future<List<dynamic>> futureMediosPago;
  final int? idMedioPagoSeleccionado;
  final ValueChanged<int> onChanged;
  final ValueChanged<int> onDefaultSelected;

  const VentaSelectorMedioPago({
    super.key,
    required this.futureMediosPago,
    required this.idMedioPagoSeleccionado,
    required this.onChanged,
    required this.onDefaultSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: futureMediosPago,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: LinearProgressIndicator(),
          );
        }

        final medios = snap.data ?? const [];

        if (medios.isEmpty) {
          return const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text('No hay medios de pago cargados localmente'),
          );
        }

        int? selected = idMedioPagoSeleccionado;

        if (selected == null) {
          final primero = medios.first;
          selected = primero.idMedioPago as int;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onDefaultSelected(selected!);
          });
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Medio de pago',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: medios.map((m) {
                  final id = m.idMedioPago as int;
                  final nombre = m.nombre as String;
                  final isSelected = selected == id;
                  final cs = Theme.of(context).colorScheme;

                  return ChoiceChip(
                    label: Text(nombre),
                    selected: isSelected,
                    onSelected: (_) => onChanged(id),
                    selectedColor: cs.primaryContainer,
                    labelStyle: TextStyle(
                      color: isSelected ? cs.onPrimaryContainer : cs.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? cs.primary : cs.outlineVariant,
                    ),
                    backgroundColor: cs.surface,
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
