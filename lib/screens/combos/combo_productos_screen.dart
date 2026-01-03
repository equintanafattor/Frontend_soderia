// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/colors.dart';
import 'package:frontend_soderia/models/producto.dart';
import 'package:frontend_soderia/services/combo_service.dart';
import 'package:frontend_soderia/services/producto_service.dart';
import 'package:frontend_soderia/services/combo_producto_service.dart';

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
  final _comboService = ComboService();
  final _comboProductoService = ComboProductoService();
  final _productoService = ProductoService();

  bool _loading = true;
  bool _dirty = false; // 🔴 cambios sin guardar

  List<Map<String, dynamic>> _productos = [];
  List<Producto> _catalogo = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final combo = await _comboProductoService.obtener(widget.idCombo);
    final productos = (combo['productos'] as List?) ?? [];

    final catalogo = await _productoService.listar();

    setState(() {
      _productos = productos
          .map(
            (p) => {
              'id_producto': p['id_producto'],
              'cantidad': p['cantidad'],
              'nombre': p['producto']['nombre'],
            },
          )
          .toList();

      _catalogo = catalogo.where((p) => p.estado == true).toList();
      _loading = false;
      _dirty = false;
    });
  }

  // -------------------- acciones locales --------------------

  void _agregarProducto(int idProducto, String nombre, int cantidad) {
    final idx = _productos.indexWhere((p) => p['id_producto'] == idProducto);

    setState(() {
      if (idx >= 0) {
        _productos[idx]['cantidad'] += cantidad;
      } else {
        _productos.add({
          'id_producto': idProducto,
          'nombre': nombre,
          'cantidad': cantidad,
        });
      }
      _dirty = true;
    });
  }

  void _editarCantidad(int index, int cantidad) {
    setState(() {
      _productos[index]['cantidad'] = cantidad;
      _dirty = true;
    });
  }

  void _eliminarProducto(int index) {
    setState(() {
      _productos.removeAt(index);
      _dirty = true;
    });
  }

  // -------------------- guardar --------------------

  Future<void> _guardar() async {
    try {
      await _comboProductoService.actualizarProductos(
        idCombo: widget.idCombo,
        productos: _productos
            .map(
              (p) => {
                'id_producto': p['id_producto'],
                'cantidad': p['cantidad'],
              },
            )
            .toList(),
      );

      if (!mounted) return;

      Navigator.pop(context, true); // UX limpia
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    }
  }

  // -------------------- acciones locales --------------------

  Future<bool> _onWillPop() async {
    if (!_dirty) return true;

    final salir = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cambios sin guardar'),
        content: const Text('Hay cambios sin guardar. ¿Querés salir igual?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );

    return salir == true;
  }

  // -------------------- UI --------------------

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.azul,
          foregroundColor: Colors.white,
          title: Text('Combo: ${widget.nombreCombo}'),
          actions: [
            if (_dirty)
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(Icons.warning, color: Colors.amber),
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openAgregarDialog,
          icon: const Icon(Icons.add),
          label: const Text('Agregar producto'),
        ),
        bottomNavigationBar: _dirty
            ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    icon: const Icon(Icons.save),
                    label: const Text(
                      'Guardar cambios',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: _guardar,
                  ),
                ),
              )
            : null,
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _productos.isEmpty
            ? const Center(child: Text('Este combo no tiene productos'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _productos.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, i) {
                  final p = _productos[i];
                  return ListTile(
                    title: Text(p['nombre']),
                    subtitle: Text('Cantidad: ${p['cantidad']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _openEditarCantidad(i),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _eliminarProducto(i),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  // -------------------- dialogs --------------------

  Future<void> _openEditarCantidad(int index) async {
    final ctrl = TextEditingController(
      text: _productos[index]['cantidad'].toString(),
    );

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar cantidad'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
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
      final v = int.tryParse(ctrl.text);
      if (v != null && v > 0) _editarCantidad(index, v);
    }
  }

  Future<void> _openAgregarDialog() async {
    int? idProducto;
    int cantidad = 1;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Agregar producto'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Producto'),
                    items: _catalogo
                        .map(
                          (p) => DropdownMenuItem(
                            value: p.idProducto,
                            child: Text(p.nombre),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      setStateDialog(() {
                        idProducto = v;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Cantidad'),
                    onChanged: (v) {
                      cantidad = int.tryParse(v) ?? 1;
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: idProducto == null
                      ? null
                      : () => Navigator.pop(context, true),
                  child: const Text('Agregar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (ok == true && idProducto != null) {
      final prod = _catalogo.firstWhere((p) => p.idProducto == idProducto);
      _agregarProducto(prod.idProducto, prod.nombre, cantidad);
    }
  }
}
