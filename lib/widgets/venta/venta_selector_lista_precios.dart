// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class VentaSelectorListaPrecios extends StatelessWidget {
  final Future<List<dynamic>> futureListasPrecios;
  final int? idListaSeleccionada;
  final ValueChanged<int> onChanged;
  final ValueChanged<int> onDefaultSelected;

  const VentaSelectorListaPrecios({
    super.key,
    required this.futureListasPrecios,
    required this.idListaSeleccionada,
    required this.onChanged,
    required this.onDefaultSelected,
  });

  int _getIdLista(dynamic l) {
    if (l is Map<String, dynamic>) {
      return (l['id_lista'] as num).toInt();
    }
    return l.idLista as int;
  }

  String _getNombre(dynamic l) {
    if (l is Map<String, dynamic>) {
      return (l['nombre'] ?? '').toString();
    }
    return l.nombre as String;
  }

  String _getEstado(dynamic l) {
    if (l is Map<String, dynamic>) {
      return (l['estado'] ?? '').toString().toLowerCase().trim();
    }
    return (l.estado ?? '').toString().toLowerCase().trim();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: futureListasPrecios,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: LinearProgressIndicator(),
          );
        }

        if (snap.hasError) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: Text('No se pudieron cargar listas de precios'),
          );
        }

        final listas = snap.data ?? const [];

        final activas = listas.where((l) {
          final estado = _getEstado(l);
          return estado == 'activo';
        }).toList();

        if (activas.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: Text('No hay listas de precios activas'),
          );
        }

        final existeYActiva =
            idListaSeleccionada != null &&
            activas.any((l) => _getIdLista(l) == idListaSeleccionada);

        int? selected = idListaSeleccionada;

        if (!existeYActiva) {
          final primera = activas.first;
          selected = _getIdLista(primera);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            onDefaultSelected(selected!);
          });
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: DropdownButtonFormField<int>(
            value: selected,
            decoration: const InputDecoration(
              labelText: 'Lista de precios',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: activas.map((l) {
              final id = _getIdLista(l);
              final nombre = _getNombre(l);

              return DropdownMenuItem<int>(
                value: id,
                child: Text(nombre),
              );
            }).toList(),
            onChanged: (v) {
              if (v == null || v == idListaSeleccionada) return;
              onChanged(v);
            },
          ),
        );
      },
    );
  }
}