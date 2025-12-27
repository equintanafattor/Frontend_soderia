// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:frontend_soderia/models/stock.dart';
import 'package:frontend_soderia/models/stock_detalle.dart';
import 'package:frontend_soderia/screens/stock/stock_ajuste_sheet.dart';
import 'package:frontend_soderia/screens/stock/stock_movimientos_screen.dart';
import 'package:frontend_soderia/services/stock_service.dart';

class StockListScreen extends StatefulWidget {
  const StockListScreen({super.key});

  @override
  State<StockListScreen> createState() => _StockListScreenState();
}

class _StockListScreenState extends State<StockListScreen> {
  final _service = StockService();
  late Future<List<StockDetalle>> _future;

  final int _idEmpresa = 1; // ⚠️ luego vendrá del usuario

  Future<void> _refrescarStock() async {
    setState(() {
      _future = _service.getStockDetalle(idEmpresa: _idEmpresa);
    });

    // esperamos a que termine el future para que el indicador se cierre prolijo
    await _future;
  }

  @override
  void initState() {
    super.initState();
    _future = _service.getStockDetalle(idEmpresa: _idEmpresa);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stock')),
      body: FutureBuilder<List<StockDetalle>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar stock'));
          }

          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(child: Text('No hay stock cargado'));
          }

          return RefreshIndicator(
            onRefresh: _refrescarStock,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final s = items[i];
                final color = _colorPorCantidad(s.cantidad);

                return ListTile(
                  leading: Icon(Icons.inventory_2, color: color),
                  title: Text(
                    s.nombreProducto,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    [
                      if (s.litros != null) '${s.litros}L',
                      if (s.tipoDispenser != null) s.tipoDispenser,
                    ].join(' • '),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _stockBadge(s.cantidad),
                      IconButton(
                        tooltip: 'Ajustar stock',
                        icon: const Icon(Icons.tune),
                        onPressed: () => _abrirAjuste(s),
                      ),
                      IconButton(
                        tooltip: 'Ver movimientos',
                        icon: const Icon(Icons.history),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StockMovimientosScreen(
                                idProducto: s.idProducto,
                                nombreProducto: s.nombreProducto,
                              ),
                            ),
                          );
                        },
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

  Widget _stockBadge(int cantidad) {
    final color = _colorPorCantidad(cantidad);
    final isCritico = cantidad > 0 && cantidad <= 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            cantidad.toString(),
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
        if (isCritico)
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Text(
              'Stock crítico',
              style: TextStyle(
                fontSize: 10,
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Color _colorPorCantidad(int cantidad) {
    if (cantidad <= 0) return Colors.red;
    if (cantidad < 10) return Colors.orange;
    return Colors.green;
  }

  void _abrirAjuste(StockDetalle stock) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => StockAjusteSheet(
        idProducto: stock.idProducto,
        nombreProducto: stock.nombreProducto,
        cantidadActual: stock.cantidad,
      ),
    ).then((result) {
      if (result == true) {
        _refrescarStock();
      }
    });
  }
}
