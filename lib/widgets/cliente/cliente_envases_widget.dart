// lib/widgets/cliente/cliente_envases_widget.dart

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
// Con botón de edición por fila
// ─────────────────────────────────────────────────────────────
class EnvasesSectionCard extends StatefulWidget {
  final int legajo;

  const EnvasesSectionCard({super.key, required this.legajo});

  @override
  State<EnvasesSectionCard> createState() => _EnvasesSectionCardState();
}

class _EnvasesSectionCardState extends State<EnvasesSectionCard> {
  final _service = ClienteService();
  List<ProductoCliente> _productos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    try {
      final raw = await _service.listarProductosCliente(widget.legajo);
      if (mounted) {
        setState(() {
          _productos = raw.map(ProductoCliente.fromJson).toList();
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _editarProducto(ProductoCliente producto) async {
    final cantidadCtrl = TextEditingController(
      text: producto.cantidad.toString(),
    );
    final estadoCtrl = TextEditingController(text: producto.estado ?? '');

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Editar — ${producto.nombre}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: cantidadCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: estadoCtrl,
              decoration: const InputDecoration(
                labelText: 'Estado (opcional)',
                hintText: 'ej: en uso, roto...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    final cantidad = int.tryParse(cantidadCtrl.text.trim());
    if (cantidad == null || cantidad < 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cantidad invalida')));
      return;
    }

    try {
      await _service.upsertProductoCliente(
        widget.legajo,
        producto.idProducto,
        cantidad: cantidad,
        estado: estadoCtrl.text.trim().isEmpty ? null : estadoCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Actualizado correctamente')),
      );
      _cargar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Envases en posesion',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_productos.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('Sin envases registrados'),
              )
            else
              ..._productos.map(
                (p) => _EnvaseEditRow(
                  producto: p,
                  onEdit: () => _editarProducto(p),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Versión INLINE — para _CuentaMiniCard (datos ya cargados)
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
// Row con botón de edición — usado en EnvasesSectionCard
// ─────────────────────────────────────────────────────────────
class _EnvaseEditRow extends StatelessWidget {
  final ProductoCliente producto;
  final VoidCallback onEdit;

  const _EnvaseEditRow({required this.producto, required this.onEdit});

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
            const SizedBox(width: 6),
            Text(
              producto.estado!,
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
            ),
          ],
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            tooltip: 'Editar',
            visualDensity: VisualDensity.compact,
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}
