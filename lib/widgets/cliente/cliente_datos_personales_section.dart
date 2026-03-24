// lib/widgets/cliente/cliente_datos_personales_section.dart

import 'package:flutter/material.dart';

class ClienteDatosPersonalesSection extends StatelessWidget {
  final List<dynamic> telefonos;

  const ClienteDatosPersonalesSection({super.key, required this.telefonos});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Datos personales',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (telefonos.isEmpty)
            const Text('Sin teléfonos')
          else
            ...telefonos.map((t0) {
              final t = t0 as Map;
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.phone),
                title: Text('${t['nro_telefono'] ?? ''}'.trim()),
                subtitle:
                    (t['observacion'] != null &&
                        (t['observacion'] as String).isNotEmpty)
                    ? Text('${t['observacion']}')
                    : null,
                trailing:
                    (t['estado'] != null && (t['estado'] as String).isNotEmpty)
                    ? Text('${t['estado']}')
                    : null,
              );
            }),
        ],
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
