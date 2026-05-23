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
          child: DropdownButtonFormField<int>(
            value: selected,
            decoration: const InputDecoration(
              labelText: 'Medio de pago',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: medios.map((m) {
              return DropdownMenuItem<int>(
                value: m.idMedioPago as int,
                child: Text(m.nombre as String),
              );
            }).toList(),
            onChanged: (v) {
              if (v == null) return;
              onChanged(v);
            },
          ),
        );
      },
    );
  }
}
