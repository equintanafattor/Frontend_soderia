// widgets/productos/producto_listas_precio_editor.dart
import 'package:flutter/material.dart';
import 'package:frontend_soderia/models/lista_precio_ref.dart';
import 'package:frontend_soderia/models/producto_precio_input.dart';

class ProductoListasPrecioEditor extends StatefulWidget {
  const ProductoListasPrecioEditor({
    super.key,
    required this.listasDisponibles,
    required this.initial,
    required this.onChanged,
  });

  /// Todas las listas existentes
  final List<ListaPrecioRef> listasDisponibles;

  /// Precios actuales del producto (puede ser vacío)
  final List<ProductoPrecioInput> initial;

  /// Callback cada vez que cambia algo
  final ValueChanged<List<ProductoPrecioInput>> onChanged;

  @override
  State<ProductoListasPrecioEditor> createState() =>
      _ProductoListasPrecioEditorState();
}

class _ProductoListasPrecioEditorState
    extends State<ProductoListasPrecioEditor> {
  late final Map<int, ProductoPrecioInput> _state;

  @override
  void initState() {
    super.initState();

    _state = {for (final p in widget.initial) p.idListaPrecio: p};
  }

  void _emit() {
    widget.onChanged(_state.values.where((e) => e.activo).toList());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: widget.listasDisponibles.map((lista) {
        final current = _state[lista.id];

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Checkbox(
                  value: current?.activo ?? false,
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        _state[lista.id] = ProductoPrecioInput(
                          idListaPrecio: lista.id,
                          activo: true,
                        );
                      } else {
                        _state.remove(lista.id);
                      }
                      _emit();
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    lista.nombre,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: TextFormField(
                    enabled: current != null,
                    initialValue: current?.precio?.toStringAsFixed(2) ?? '',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Precio',
                      isDense: true,
                    ),
                    onChanged: (v) {
                      final parsed = double.tryParse(v.replaceAll(',', '.'));
                      if (parsed != null && current != null) {
                        current.precio = parsed;
                        _emit();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
