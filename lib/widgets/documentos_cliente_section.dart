import 'package:flutter/material.dart';
import 'package:frontend_soderia/services/documento_service.dart';
import 'package:frontend_soderia/utils/open_pdf.dart';

class DocumentosClienteSection extends StatelessWidget {
  final int legajo;

  const DocumentosClienteSection({super.key, required this.legajo});

  @override
  Widget build(BuildContext context) {
    final service = DocumentoService();

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: service.listarPorCliente(legajo),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: LinearProgressIndicator(),
          );
        }

        if (snap.hasError) {
          return const Text('Error cargando documentos');
        }

        final docs = snap.data ?? [];

        final comprobantes = docs
            .where((d) => d['tipo_archivo'] == 'COMPROBANTE_PAGO')
            .toList();

        if (comprobantes.isEmpty) {
          return const Text('Sin comprobantes');
        }

        return Column(
          children: comprobantes.map((d) {
            final fecha = d['fecha']?.toString().split('T').first ?? '';

            return ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: Text(d['nombre_archivo']),
              subtitle: Text(fecha),
              trailing: const Icon(Icons.open_in_new),
              onTap: () async {
                final url = 'http://localhost:8500${d['url']}';

                try {
                  await openPdf(url);
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No se pudo abrir el PDF: $e')),
                  );
                }
              },
            );
          }).toList(),
        );
      },
    );
  }
}
