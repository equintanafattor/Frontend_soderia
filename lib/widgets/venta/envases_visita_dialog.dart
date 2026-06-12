// lib/widgets/venta/envases_visita_dialog.dart
//
// Dialog que permite registrar movimientos de envases (entrega/devolución)
// durante una visita donde el cliente no compra o postergó la visita.
// Devuelve una lista de EnvaseMovimientoVisita (vacía si no hubo movimientos
// o si el usuario decide omitir el paso).

import 'package:flutter/material.dart';

import 'package:frontend_soderia/models/producto_cliente.dart';
import 'package:frontend_soderia/repositories/visita_repository.dart';
import 'package:frontend_soderia/services/cliente_service.dart';

class EnvasesVisitaDialog extends StatefulWidget {
  final int legajo;

  const EnvasesVisitaDialog({super.key, required this.legajo});

  @override
  State<EnvasesVisitaDialog> createState() => _EnvasesVisitaDialogState();
}

class _EnvasesVisitaDialogState extends State<EnvasesVisitaDialog> {
  final _service = ClienteService();
  late Future<List<ProductoCliente>> _future;

  // idProducto -> {entregados, devueltos}
  final Map<int, Map<String, int>> _movimientos = {};

  @override
  void initState() {
    super.initState();
    _future = _cargar();
  }

  Future<List<ProductoCliente>> _cargar() async {
    final raw = await _service.listarProductosCliente(widget.legajo);
    return raw.map(ProductoCliente.fromJson).toList();
  }

  void _ajustar(int idProducto, String campo, int delta, int max) {
    setState(() {
      final actual =
          _movimientos[idProducto] ?? {'entregados': 0, 'devueltos': 0};
      final nuevo = (actual[campo] ?? 0) + delta;
      if (nuevo < 0 || nuevo > max) return;
      actual[campo] = nuevo;
      _movimientos[idProducto] = actual;
    });
  }

  List<EnvaseMovimientoVisita> _buildResultado() {
    return _movimientos.entries
        .where(
          (e) =>
              (e.value['entregados'] ?? 0) > 0 ||
              (e.value['devueltos'] ?? 0) > 0,
        )
        .map(
          (e) => EnvaseMovimientoVisita(
            idProducto: e.key,
            entregados: e.value['entregados'] ?? 0,
            devueltos: e.value['devueltos'] ?? 0,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Envases'),
      content: SizedBox(
        width: 360,
        child: FutureBuilder<List<ProductoCliente>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final productos = snap.data ?? [];

            if (productos.isEmpty) {
              return const Text('El cliente no tiene envases registrados.');
            }

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Entregaste o retiraste envases en esta visita?',
                    style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  ...productos.map((p) {
                    final mov =
                        _movimientos[p.idProducto] ??
                        {'entregados': 0, 'devueltos': 0};
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${p.nombre}\n(tiene: ${p.cantidad})',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          _Counter(
                            label: 'Entrega',
                            value: mov['entregados'] ?? 0,
                            onChanged: (delta) => _ajustar(
                              p.idProducto,
                              'entregados',
                              delta,
                              999,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _Counter(
                            label: 'Retira',
                            value: mov['devueltos'] ?? 0,
                            onChanged: (delta) => _ajustar(
                              p.idProducto,
                              'devueltos',
                              delta,
                              p.cantidad,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, <EnvaseMovimientoVisita>[]),
          child: const Text('Omitir'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _buildResultado()),
          child: const Text('Continuar'),
        ),
      ],
    );
  }
}

class _Counter extends StatelessWidget {
  final String label;
  final int value;
  final void Function(int delta) onChanged;

  const _Counter({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 10)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: value > 0 ? () => onChanged(-1) : null,
              child: Icon(
                Icons.remove_circle_outline,
                size: 18,
                color: value > 0 ? cs.primary : cs.outlineVariant,
              ),
            ),
            SizedBox(
              width: 22,
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            InkWell(
              onTap: () => onChanged(1),
              child: Icon(
                Icons.add_circle_outline,
                size: 18,
                color: cs.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
