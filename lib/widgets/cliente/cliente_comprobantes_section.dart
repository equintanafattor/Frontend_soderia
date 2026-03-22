// lib/widgets/cliente/cliente_comprobantes_section.dart

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/net/api_client.dart';
import 'package:frontend_soderia/services/documento_service.dart';
import 'package:frontend_soderia/utils/open_pdf.dart';
import 'package:frontend_soderia/utils/share_whatsapp.dart';

class ClienteComprobantesSection extends StatefulWidget {
  final int legajo;
  final List<Map> telefonos;

  const ClienteComprobantesSection({
    super.key,
    required this.legajo,
    required this.telefonos,
  });

  @override
  State<ClienteComprobantesSection> createState() =>
      _ClienteComprobantesSectionState();
}

class _ClienteComprobantesSectionState
    extends State<ClienteComprobantesSection> {
  final _service = DocumentoService();
  late Future<List<Map<String, dynamic>>> _futureDocs;

  @override
  void initState() {
    super.initState();
    _futureDocs = _service.listarPorCliente(widget.legajo);
  }

  String? _telefonoParaWhatsapp() {
    if (widget.telefonos.isEmpty) return null;

    final principal = widget.telefonos.firstWhere(
      (t) => t['principal'] == true,
      orElse: () => {},
    );

    final raw =
        (principal.isNotEmpty
                ? principal['nro_telefono']
                : widget.telefonos.first['nro_telefono'])
            ?.toString();

    if (raw == null || raw.trim().isEmpty) return null;

    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('549')) return digits;
    if (digits.startsWith('54')) return '549${digits.substring(2)}';

    var d = digits;
    if (d.startsWith('0')) d = d.substring(1);
    if (d.startsWith('15')) d = d.substring(2);
    return '549$d';
  }

  @override
  Widget build(BuildContext context) {
    final phone = _telefonoParaWhatsapp();

    return _SectionCard(
      title: 'Comprobantes',
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureDocs,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: LinearProgressIndicator(),
            );
          }

          if (snap.hasError) {
            return const Text('Error cargando comprobantes');
          }

          final docs = snap.data ?? [];
          final comprobantes = docs
              .where((d) => d['tipo_archivo'] == 'COMPROBANTE_PAGO')
              .toList();

          if (comprobantes.isEmpty) {
            return const Text('Sin comprobantes registrados');
          }

          return Column(
            children: comprobantes.map((d) {
              final fecha = d['fecha']?.toString().split('T').first ?? '';
              final url = '${ApiClient.dio.options.baseUrl}${d['url']}';

              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.picture_as_pdf),
                title: Text(d['nombre_archivo']),
                subtitle: Text(fecha),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) async {
                    if (v == 'ver') {
                      await openPdf(url);
                      return;
                    }

                    if (v == 'whatsapp') {
                      if (phone == null) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'El cliente no tiene teléfono cargado',
                            ),
                          ),
                        );
                        return;
                      }

                      if (kIsWeb) {
                        await shareWhatsApp(
                          phone: phone,
                          message:
                              'Hola! \nTe comparto el comprobante de pago:\n\n$url',
                        );
                        return;
                      }

                      // MOBILE: más adelante podés adjuntar PDF real
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'ver',
                      child: Text('Ver comprobante'),
                    ),
                    PopupMenuItem(
                      value: 'whatsapp',
                      child: Text(
                        kIsWeb
                            ? 'Compartir link por WhatsApp'
                            : 'Compartir PDF por WhatsApp',
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
