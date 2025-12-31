import 'package:flutter/material.dart';
import 'package:frontend_soderia/models/producto.dart';
import 'package:frontend_soderia/services/combo_producto_service.dart';
import 'package:frontend_soderia/core/colors.dart';
import 'package:frontend_soderia/services/producto_service.dart';

class ComboProductosScreen extends StatefulWidget {
  final int idCombo;
  final String nombreCombo;

  const ComboProductosScreen({
    super.key,
    required this.idCombo,
    required this.nombreCombo,
  });

  @override
  State<ComboProductosScreen> createState() => _ComboProductosScreenState();
}

class _ComboProductosScreenState extends State<ComboProductosScreen> {
  final _service = ComboProductoService();
  bool _loading = false;
  List<dynamic> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _items = await _service.listar(widget.idCombo);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _editarCantidad(Map<String, dynamic> item) async {
    final ctrl = TextEditingController(text: item['cantidad'].toString());

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item['producto']['nombre']),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Cantidad'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await _service.actualizar(
        idCombo: widget.idCombo,
        idProducto: item['id_producto'],
        cantidad: int.parse(ctrl.text),
      );
      _load();
    }
  }

  Future<void> _eliminar(Map<String, dynamic> item) async {
    await _service.eliminar(
      idCombo: widget.idCombo,
      idProducto: item['id_producto'],
    );
    _load();
  }

  Future<void> _agregarProducto() async {
    final res = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _AgregarProductoDialog(),
    );

    if (res == null) return;

    try {
      await _service.agregar(
        idCombo: widget.idCombo,
        idProducto: res['id_producto'] as int,
        cantidad: res['cantidad'] as int,
      );
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.azul,
        foregroundColor: Colors.white,
        title: Text('Combo: ${widget.nombreCombo}'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Agregar producto'),
        onPressed: _agregarProducto,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? const Center(child: Text('Este combo no tiene productos'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (_, i) {
                final it = _items[i];
                return ListTile(
                  title: Text(it['producto']['nombre']),
                  subtitle: Text('Cantidad: ${it['cantidad']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editarCantidad(it),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _eliminar(it),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _AgregarProductoDialog extends StatefulWidget {
  @override
  State<_AgregarProductoDialog> createState() => _AgregarProductoDialogState();
}

class _AgregarProductoDialogState extends State<_AgregarProductoDialog> {
  final _productoService = ProductoService();

  int? _idProducto;
  int _cantidad = 1;
  List<Producto> _productos = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _productoService.listar();
    setState(() => _productos = list.where((p) => p.estado == true).toList());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar producto al combo'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(labelText: 'Producto'),
            items: _productos
                .map(
                  (p) => DropdownMenuItem(
                    value: p.idProducto,
                    child: Text(p.nombre),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _idProducto = v),
          ),
          const SizedBox(height: 12),
          TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Cantidad'),
            onChanged: (v) => _cantidad = int.tryParse(v) ?? 1,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _idProducto == null
              ? null
              : () => Navigator.pop(context, {
                  'id_producto': _idProducto,
                  'cantidad': _cantidad,
                }),
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}