import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/colors.dart';
import 'package:frontend_soderia/models/venta/venta_carrito_item.dart';
import 'package:frontend_soderia/widgets/venta/venta_header_info.dart';

class VentaActualTab extends StatelessWidget {
  final ColorScheme cs;
  final String legajo;
  final double deuda;
  final double saldoAFavor;
  final String nombreCliente;

  final Map<String, CarritoItem> carrito;

  final VoidCallback onPostergar;
  final VoidCallback onNoCompra;

  final Function(String key) onEditarCantidad;
  final Function(String key) onEliminarItem;
  final Widget? selectorMedioPago;

  const VentaActualTab({
    super.key,
    required this.cs,
    required this.legajo,
    required this.deuda,
    required this.saldoAFavor,
    required this.nombreCliente,
    required this.carrito,
    required this.onPostergar,
    required this.onNoCompra,
    required this.onEditarCantidad,
    required this.onEliminarItem,
    this.selectorMedioPago,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        VentaHeaderInfo(legajo: legajo, deuda: deuda, saldoAFavor: saldoAFavor),

        const SizedBox(height: 12),

        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: onNoCompra,
              icon: const Icon(Icons.close),
              label: const Text('No compra'),
            ),
            OutlinedButton.icon(
              onPressed: onPostergar,
              icon: const Icon(Icons.refresh),
              label: const Text('Postergar visita'),
            ),
          ],
        ),

        const SizedBox(height: 16),

        if (selectorMedioPago != null) ...[
          selectorMedioPago!,
          const SizedBox(height: 12),
        ],
        Text('Ítems', style: Theme.of(context).textTheme.titleMedium),

        const SizedBox(height: 8),

        if (carrito.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: cs.primary),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('No hay productos en la venta actual.'),
                ),
              ],
            ),
          ),

        ...carrito.entries.map((entry) {
          final key = entry.key;
          final item = entry.value;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: Icon(
                item.tipo == TipoItemVenta.combo
                    ? Icons.inventory_2
                    : Icons.local_drink,
              ),
              title: Text(item.nombre),
              subtitle: Text(
                '${item.tipo == TipoItemVenta.combo ? "Combo" : "Producto"} · '
                'Cantidad: ${item.cantidad} · '
                '\$${item.precioUnitario.toStringAsFixed(0)} c/u',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Editar cantidad',
                    icon: const Icon(Icons.edit),
                    onPressed: () => onEditarCantidad(key),
                  ),
                  IconButton(
                    tooltip: 'Quitar',
                    icon: const Icon(Icons.close),
                    onPressed: () => onEliminarItem(key),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
