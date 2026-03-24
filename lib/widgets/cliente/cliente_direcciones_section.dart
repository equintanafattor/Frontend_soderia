// lib/widgets/cliente/cliente_direcciones_section.dart

import 'package:flutter/material.dart';

class ClienteDireccionesSection extends StatelessWidget {
  final List<dynamic> direcciones;

  const ClienteDireccionesSection({super.key, required this.direcciones});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Direcciones',
      child: direcciones.isEmpty
          ? const Text('Sin direcciones')
          : Column(
              children: direcciones.map((d0) {
                final d = d0 as Map;
                final entre =
                    d['entre_calle1'] != null &&
                        (d['entre_calle1'] as String).isNotEmpty
                    ? 'Entre ${d['entre_calle1']} y ${d['entre_calle2'] ?? ''}'
                    : null;

                final sub = [
                  d['localidad'],
                  d['zona'],
                  entre,
                ].whereType<String>().where((s) => s.isNotEmpty).join(' · ');

                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text('${d['direccion'] ?? '-'}'),
                  subtitle: sub.isEmpty ? null : Text(sub),
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
