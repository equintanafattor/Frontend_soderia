// lib/widgets/cliente/cliente_envases_widget.dart
//
// Widget reutilizable que muestra los envases/bidones/sifones
// que el cliente tiene en posesión. Se usa en:
//   - VentaScreen  (compacto, una sola línea de chips)
//   - ClienteDetailScreen  (sección completa con lista)
//   - ClienteCuentasSection  (dentro de la card de cuenta)

import 'package:flutter/material.dart';
import 'package:frontend_soderia/models/producto_cliente.dart';
import 'package:frontend_soderia/services/cliente_service.dart';

// ─────────────────────────────────────────────────────────────
// Versión COMPACTA — para VentaScreen (una fila de chips)
// ─────────────────────────────────────────────────────────────
class EnvasesCompacto extends StatefulWidget {
  final int legajo;

  const EnvasesCompacto({super.key, required this.legajo});

  @override
  State<EnvasesCompacto> createState() => _EnvasesCompactoState();
}

class _EnvasesCompactoState extends State<EnvasesCompacto> {
  final _service = ClienteService();
  late Future<List<ProductoCliente>> _future;

  @override
  void initState() {
    super.initState();
    _future = _cargar();
  }

  Future<List<ProductoCliente>> _cargar() async {
    final raw = await _service.listarProductosCliente(widget.legajo);
    return raw
        .map(ProductoCliente.fromJson)
        .where((p) => p.cantidad > 0)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return FutureBuilder<List<ProductoCliente>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        final items = snap.data ?? [];
        if (items.isEmpty) return const SizedBox.shrink();

        return Wrap(
          spacing: 6,
          runSpacing: 4,
          children: items.map((p) {
            return Chip(
              avatar: Icon(
                Icons.water_drop_outlined,
                size: 14,
                color: cs.primary,
              ),
              label: Text(
                '${p.nombre}: ${p.cantidad}',
                style: const TextStyle(fontSize: 12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              visualDensity: VisualDensity.compact,
              backgroundColor: cs.primaryContainer,
              side: BorderSide.none,
            );
          }).toList(),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Versión SECCIÓN — para ClienteDetailScreen
// ─────────────────────────────────────────────────────────────
class EnvasesSectionCard extends StatefulWidget {
  final int legajo;

  const EnvasesSectionCard({super.key, required this.legajo});

  @override
  State<EnvasesSectionCard> createState() => _EnvasesSectionCardState();
}

class _EnvasesSectionCardState extends State<EnvasesSectionCard> {
  final _service = ClienteService();
  late Future<List<ProductoCliente>> _future;

  @override
  void initState() {
    super.initState();
    _future = _cargar();
  }

  Future<List<ProductoCliente>> _cargar() async {
    final raw = await _service.listarProductosCliente(widget.legajo);
    return raw.map(ProductoCliente.fromJson).toList();
  }

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
            Text(
              'Envases en posesión',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<ProductoCliente>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Text(
                    'Error al cargar envases',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  );
                }

                final items = snap.data ?? [];
                if (items.isEmpty) {
                  return const Text('Sin envases registrados');
                }

                return Column(
                  children: items.map((p) => _EnvaseRow(p)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Versión INLINE — para usar dentro de _CuentaMiniCard
// Recibe la lista ya cargada para no hacer otra llamada HTTP
// ─────────────────────────────────────────────────────────────
class EnvasesInline extends StatelessWidget {
  final List<ProductoCliente> productos;

  const EnvasesInline({super.key, required this.productos});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final conCantidad = productos.where((p) => p.cantidad > 0).toList();

    if (conCantidad.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 12),
        Text(
          'Envases',
          style: TextStyle(
            fontSize: 11,
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        ...conCantidad.map(
          (p) => Text(
            '• ${p.nombre}: ${p.cantidad}',
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Row interno compartido
// ─────────────────────────────────────────────────────────────
class _EnvaseRow extends StatelessWidget {
  final ProductoCliente producto;

  const _EnvaseRow(this.producto);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.water_drop_outlined, size: 16, color: cs.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(producto.nombre, style: const TextStyle(fontSize: 14)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${producto.cantidad}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: cs.onPrimaryContainer,
              ),
            ),
          ),
          if (producto.estado != null && producto.estado!.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(
              producto.estado!,
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}
