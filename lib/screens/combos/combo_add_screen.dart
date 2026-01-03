import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend_soderia/models/combo_producto_draft.dart';
import 'package:frontend_soderia/services/combo_service.dart';
import 'package:frontend_soderia/services/producto_service.dart';
import 'package:http/http.dart' as http;

class ComboAddScreen extends StatefulWidget {
  const ComboAddScreen({super.key});

  @override
  State<ComboAddScreen> createState() => _ComboAddScreenState();
}

class _ComboAddScreenState extends State<ComboAddScreen> {
  final _nombreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  final List<ComboProductoDraft> _productos = [];

  bool _loading = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _agregarProducto() async {
    final res = await showDialog<ComboProductoDraft>(
      context: context,
      builder: (_) => const _AgregarProductoDialog(),
    );

    if (res == null) return;

    setState(() {
      final index = _productos.indexWhere(
        (p) => p.idProducto == res.idProducto,
      );

      if (index >= 0) {
        _productos[index].cantidad += res.cantidad;
      } else {
        _productos.add(res);
      }
    });
  }

  Future<void> _guardarCombo() async {
    if (_nombreCtrl.text.trim().isEmpty || _productos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombre y productos son obligatorios')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final comboService = ComboService();

      // 1️⃣ Crear combo
      final combo = await comboService.crear(
        nombre: _nombreCtrl.text.trim(),
        estado: true,
      );

      final int idCombo = combo['id_combo'];

      // 2️⃣ Agregar productos al combo
      for (final p in _productos) {
        await comboService.agregarProducto(
          idCombo: idCombo,
          idProducto: p.idProducto,
          cantidad: p.cantidad,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo combo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nombreCtrl,
            decoration: const InputDecoration(
              labelText: 'Nombre del combo',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descCtrl,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text('Productos', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ..._productos.map(
            (p) => Card(
              child: ListTile(
                title: Text(p.nombre),
                subtitle: Text('Cantidad: ${p.cantidad}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => setState(() => _productos.remove(p)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _agregarProducto,
            icon: const Icon(Icons.add),
            label: const Text('Agregar producto'),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _loading ? null : _guardarCombo,
            child: _loading
                ? const CircularProgressIndicator()
                : const Text('Guardar combo'),
          ),
        ],
      ),
    );
  }
}

class _AgregarProductoDialog extends StatefulWidget {
  const _AgregarProductoDialog();

  @override
  State<_AgregarProductoDialog> createState() => _AgregarProductoDialogState();
}

class _AgregarProductoDialogState extends State<_AgregarProductoDialog> {
  final _productoService = ProductoService();

  int? _idProducto;
  String _nombreProducto = '';
  int _cantidad = 1;

  late Future<List<dynamic>> _futureProductos;

  @override
  void initState() {
    super.initState();
    _futureProductos = _productoService.listar();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar producto al combo'),
      content: FutureBuilder<List<dynamic>>(
        future: _futureProductos,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final productos = snap.data!;

          if (productos.isEmpty) {
            return const Text('No hay productos activos');
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Producto',
                  border: OutlineInputBorder(),
                ),
                items: productos.map((p) {
                  return DropdownMenuItem<int>(
                    value: p['id_producto'],
                    child: Text(p['nombre']),
                  );
                }).toList(),
                onChanged: (v) {
                  final prod = productos.firstWhere(
                    (p) => p['id_producto'] == v,
                  );
                  setState(() {
                    _idProducto = v;
                    _nombreProducto = prod['nombre'];
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: '1',
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) {
                  _cantidad = int.tryParse(v) ?? 1;
                },
              ),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _idProducto == null
              ? null
              : () {
                  Navigator.pop(
                    context,
                    ComboProductoDraft(
                      idProducto: _idProducto!,
                      nombre: _nombreProducto,
                      cantidad: _cantidad,
                    ),
                  );
                },
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}
