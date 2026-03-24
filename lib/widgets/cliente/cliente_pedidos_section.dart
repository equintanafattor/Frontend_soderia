// lib/widgets/cliente/cliente_pedidos_section.dart

import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/net/api_client.dart';
import 'package:frontend_soderia/services/documento_service.dart';
import 'package:frontend_soderia/utils/open_pdf.dart';
import 'package:frontend_soderia/utils/share_whatsapp.dart';

class ClientePedidosSection extends StatelessWidget {
  final List<dynamic> pedidos;
  final String? phone;
  final DocumentoService documentoService;

  const ClientePedidosSection({
    super.key,
    required this.pedidos,
    required this.phone,
    required this.documentoService,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Últimos pedidos',
      child: pedidos.isEmpty
          ? const Text('Sin pedidos')
          : Column(
              children: pedidos.map((p0) {
                final p = p0 as Map;
                final id = (p['id_pedido'] as num?)?.toInt();
                final fecha = (p['fecha'] ?? '').toString();

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.shopping_bag_outlined),
                  title: Text(
                    id == null ? 'Pedido' : 'Pedido #$id',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(fecha),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (id == null) return;

                      try {
                        final doc = await documentoService
                            .generarComprobantePedido(id);
                        final url =
                            '${ApiClient.dio.options.baseUrl}${doc['url']}';

                        if (v == 'ver') {
                          await openPdf(url);
                          return;
                        }

                        if (v == 'whatsapp') {
                          if (phone == null) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'El cliente no tiene teléfono cargado',
                                ),
                              ),
                            );
                            return;
                          }

                          await shareWhatsApp(
                            phone: phone!,
                            message:
                                'Hola!\nTe comparto el comprobante del pedido #$id:\n\n$url',
                          );
                        }
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'ver',
                        child: Text('Ver comprobante'),
                      ),
                      PopupMenuItem(
                        value: 'whatsapp',
                        child: Text('Compartir link por WhatsApp'),
                      ),
                    ],
                  ),
                );
              }).toList(),
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
