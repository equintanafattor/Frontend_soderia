import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VentaHistorialTab extends StatelessWidget {
  final ColorScheme cs;
  final List<dynamic> historicos;

  const VentaHistorialTab({
    super.key,
    required this.cs,
    required this.historicos,
  });

  @override
  Widget build(BuildContext context) {
    if (historicos.isEmpty) {
      return Center(
        child: Text(
          'Sin historial',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: historicos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final h = historicos[i] as Map<String, dynamic>;

        final fechaRaw = (h['fecha'] ?? '').toString();
        final fechaFmt = fechaRaw.isNotEmpty
            ? DateFormat(
                'dd/MM/yyyy HH:mm',
                'es_AR',
              ).format(DateTime.parse(fechaRaw).toLocal())
            : '';

        final obs = (h['observacion'] ?? '').toString();
        final detalle = (h['detalle'] ?? '').toString();
        final monto = h['monto'];

        final evento = (h['evento'] as Map<String, dynamic>?) ?? {};
        final nombreEvento = (evento['nombre'] ?? evento['descripcion'] ?? '')
            .toString();

        // El detalle ya incluye la información relevante armada por el
        // backend; si viene vacío, caemos a la observación como antes.
        final cuerpo = detalle.isNotEmpty ? detalle : obs;

        return Card(
          child: ListTile(
            leading: const Icon(Icons.history),
            title: Text(nombreEvento.isNotEmpty ? nombreEvento : 'Evento'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (cuerpo.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(cuerpo),
                  ),
                if (fechaFmt.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      fechaFmt,
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
            trailing: monto != null
                ? Text(
                    '\$${(monto as num).toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }
}
