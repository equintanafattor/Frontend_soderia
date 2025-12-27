import 'package:flutter/material.dart';
import 'package:frontend_soderia/models/movimiento_stock.dart';
import 'package:frontend_soderia/services/stock_service.dart';

class StockMovimientosScreen extends StatefulWidget {
  final int idProducto;
  final String nombreProducto;

  const StockMovimientosScreen({
    super.key,
    required this.idProducto,
    required this.nombreProducto,
  });

  @override
  State<StockMovimientosScreen> createState() => _StockMovimientosScreenState();
}

class _StockMovimientosScreenState extends State<StockMovimientosScreen> {
  final _service = StockService();
  late Future<List<MovimientoStock>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getMovimientos(idProducto: widget.idProducto);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Movimientos • ${widget.nombreProducto}')),
      body: FutureBuilder<List<MovimientoStock>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar movimientos'));
          }

          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(child: Text('Sin movimientos registrados'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _future = _service.getMovimientos(
                  idProducto: widget.idProducto,
                );
              });
              await _future;
            },
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final m = items[i];
                final color = _colorPorTipo(m.tipo);

                return ListTile(
                  leading: Icon(_iconoPorTipo(m.tipo), color: color),
                  title: Text(
                    '${m.tipo == 'egreso' ? '-' : '+'}${m.cantidad} • ${_labelTipo(m.tipo)}',
                    style: TextStyle(fontWeight: FontWeight.bold, color: color),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatearFecha(m.fecha),
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (m.observacion != null && m.observacion!.isNotEmpty)
                        Text(
                          m.observacion!,
                          style: const TextStyle(fontSize: 12),
                        ),
                      if (m.idPedido != null)
                        Text(
                          'Pedido #${m.idPedido}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      if (m.idRecorrido != null)
                        Text(
                          'Recorrido #${m.idRecorrido}',
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // ---------------- helpers ----------------

  Color _colorPorTipo(String tipo) {
    switch (tipo) {
      case 'ingreso':
        return Colors.green;
      case 'egreso':
        return Colors.red;
      case 'ajuste':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _iconoPorTipo(String tipo) {
    switch (tipo) {
      case 'ingreso':
        return Icons.add_circle_outline;
      case 'egreso':
        return Icons.remove_circle_outline;
      case 'ajuste':
        return Icons.tune;
      default:
        return Icons.help_outline;
    }
  }

  String _labelTipo(String tipo) {
    switch (tipo) {
      case 'ingreso':
        return 'Ingreso';
      case 'egreso':
        return 'Egreso';
      case 'ajuste':
        return 'Ajuste';
      default:
        return tipo;
    }
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year} '
        '${fecha.hour.toString().padLeft(2, '0')}:'
        '${fecha.minute.toString().padLeft(2, '0')}';
  }
}
