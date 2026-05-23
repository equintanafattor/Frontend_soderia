import 'package:flutter/material.dart';

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

        final fechaStr = (h['fecha'] ?? '').toString();
        final obs = (h['observacion'] ?? '').toString();

        final evento = (h['evento'] as Map<String, dynamic>?) ?? {};

        final nombreEvento = (evento['nombre'] ?? evento['descripcion'] ?? '')
            .toString();

        return Card(
          child: ListTile(
            leading: const Icon(Icons.history),
            title: Text(nombreEvento.isNotEmpty ? nombreEvento : 'Evento'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (fechaStr.isNotEmpty) Text(fechaStr),
                if (obs.isNotEmpty) Text(obs),
              ],
            ),
          ),
        );
      },
    );
  }
}
