import 'package:flutter/material.dart';
import 'package:frontend_soderia/services/lista_precio_service.dart';
import 'package:frontend_soderia/services/producto_service.dart';
import 'package:frontend_soderia/models/producto.dart';

class PrecioProductoModal extends StatefulWidget {
  final int idLista;
  final Map<String, dynamic>? productoInicial;

  const PrecioProductoModal({
    super.key,
    required this.idLista,
    this.productoInicial,
  });

  @override
  State<PrecioProductoModal> createState() => _PrecioProductoModalState();
}

class _PrecioProductoModalState extends State<PrecioProductoModal> {
  final _precioCtrl = TextEditingController();
  int? _idProducto;
  bool _loading = false;

  final _listaPrecioService = ListaPrecioService();
  final _productoService = ProductoService();

  bool get _esEdicion => widget.productoInicial != null;

  @override
  void initState() {
    super.initState();
    if (_esEdicion) {
      _idProducto = widget.productoInicial!['id_producto'];
      _precioCtrl.text = widget.productoInicial!['precio'].toString();
    }
  }

  Future<void> _guardar() async {
    if (_idProducto == null || _precioCtrl.text.isEmpty) return;

    final precio = double.tryParse(_precioCtrl.text);
    if (precio == null || precio <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Precio inválido')));
      return;
    }

    setState(() => _loading = true);

    try {
      await _listaPrecioService.upsertPrecio(
        idLista: widget.idLista,
        idProducto: _idProducto!,
        precio: precio,
      );

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _precioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_esEdicion ? 'Editar precio' : 'Agregar producto'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_esEdicion)
              FutureBuilder<List<Producto>>(
                future: _productoService.listar(),
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snap.hasData || snap.data!.isEmpty) {
                    return const Text('No hay productos disponibles');
                  }

                  return DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Producto',
                      border: OutlineInputBorder(),
                    ),
                    items: snap.data!
                        .map(
                          (p) => DropdownMenuItem<int>(
                            value: p.idProducto,
                            child: Text(p.nombre),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _idProducto = v),
                  );
                },
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _precioCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Precio',
                border: OutlineInputBorder(),
                prefixText: '\$ ',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _loading ? null : _guardar,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
