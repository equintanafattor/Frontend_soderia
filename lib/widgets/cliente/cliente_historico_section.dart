// lib/widgets/cliente/cliente_historico_section.dart

import 'package:flutter/material.dart';
import 'package:frontend_soderia/utils/historico_cliente_formatter.dart';

class ClienteHistoricoSection extends StatelessWidget {
  final List<dynamic> historicos;

  const ClienteHistoricoSection({super.key, required this.historicos});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Histórico',
      child: historicos.isEmpty
          ? const Text('Sin eventos')
          : Column(
              children: historicos.map((h0) {
                final h = h0 as Map;
                final ev = h['evento'];
                final evNombre = ev is Map
                    ? (ev['nombre'] ?? 'Evento')
                    : (ev?.toString() ?? 'Evento');

                final subtitleText = buildHistoricoSubtitle(h);

                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.history),
                  title: Text(evNombre),
                  subtitle: subtitleText.isEmpty
                      ? null
                      : Text(
                          subtitleText,
                          maxLines: 6,
                          overflow: TextOverflow.ellipsis,
                        ),
                  trailing: Text('${h['fecha'] ?? ''}'),
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
