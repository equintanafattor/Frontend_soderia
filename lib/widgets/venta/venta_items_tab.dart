import 'package:flutter/material.dart';
import 'package:frontend_soderia/models/venta/venta_carrito_item.dart';

class VentaItemsTab extends StatelessWidget {
  final int? idListaSeleccionada;
  final Future<List<dynamic>> futureItems;

  final bool Function(Map<String, dynamic> item) comboTienePrecio;
  final double Function(dynamic value) parsePrecio;

  final void Function(TipoItemVenta tipo, int id, String nombre, double precio)
  onAgregarItem;

  const VentaItemsTab({
    super.key,
    required this.idListaSeleccionada,
    required this.futureItems,
    required this.comboTienePrecio,
    required this.parsePrecio,
    required this.onAgregarItem,
  });

  @override
  Widget build(BuildContext context) {
    if (idListaSeleccionada == null) {
      return const Center(child: Text('Seleccioná una lista de precios'));
    }

    return FutureBuilder<List<dynamic>>(
      future: futureItems,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snap.hasError) {
          return const Center(child: Text('No se pudieron cargar los ítems'));
        }

        final items = snap.data ?? const [];

        if (items.isEmpty) {
          return const Center(
            child: Text('Esta lista no tiene ítems con precio'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final raw = items[i];

            final Map<String, dynamic> it = raw is Map<String, dynamic>
                ? raw
                : {
                    'tipo': raw.tipo,
                    'id_item': raw.idItem,
                    'nombre': raw.nombre,
                    'precio': raw.precio,
                    'estado': raw.estado,
                  };

            final tipo = it['tipo'] == 'combo'
                ? TipoItemVenta.combo
                : TipoItemVenta.producto;

            final esCombo = tipo == TipoItemVenta.combo;
            final tienePrecio = comboTienePrecio(it);
            final precio = parsePrecio(it['precio']);

            final activo = esCombo
                ? (it['estado'] == true ||
                      it['estado'] == 'true' ||
                      it['estado'] == 1 ||
                      it['estado']?.toString().toLowerCase() == 'activo')
                : true;

            final puedeVender = activo && (!esCombo || tienePrecio);
            final icon = esCombo ? Icons.inventory_2 : Icons.local_drink;

            return Card(
              child: ListTile(
                enabled: puedeVender,
                leading: Icon(icon, color: puedeVender ? null : Colors.grey),
                title: Text(
                  (it['nombre'] ?? '').toString(),
                  style: TextStyle(
                    color: puedeVender ? null : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: !activo && esCombo
                    ? const Text(
                        'Combo inactivo',
                        style: TextStyle(color: Colors.red),
                      )
                    : (esCombo && !tienePrecio)
                    ? const Text(
                        'Combo sin precio en esta lista',
                        style: TextStyle(color: Colors.redAccent),
                      )
                    : Text('\$${precio.toStringAsFixed(0)}'),
                trailing: FilledButton(
                  onPressed: puedeVender
                      ? () => onAgregarItem(
                          tipo,
                          (it['id_item'] as num).toInt(),
                          (it['nombre'] ?? '').toString(),
                          precio,
                        )
                      : null,
                  child: const Text('Agregar'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
