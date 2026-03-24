// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:frontend_soderia/services/stock_service.dart';

class StockAjusteSheet extends StatefulWidget {
  final int idProducto;
  final String nombreProducto;
  final int cantidadActual;

  const StockAjusteSheet({
    super.key,
    required this.idProducto,
    required this.nombreProducto,
    required this.cantidadActual,
  });

  @override
  State<StockAjusteSheet> createState() => _StockAjusteSheetState();
}

class _StockAjusteSheetState extends State<StockAjusteSheet> {
  final _service = StockService();
  final _cantidadCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  String _tipo = 'ajuste'; // 👈 ya en minúscula

  @override
  void initState() {
    super.initState();
    _cantidadCtrl.text = widget.cantidadActual.toString();
  }

  @override
  void dispose() {
    _cantidadCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.nombreProducto,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _tipo,
            items: const [
              DropdownMenuItem(value: 'ingreso', child: Text('Ingreso')),
              DropdownMenuItem(value: 'egreso', child: Text('Egreso')),
              DropdownMenuItem(value: 'ajuste', child: Text('Ajuste')),
            ],
            onChanged: (v) => setState(() => _tipo = v!),
            decoration: const InputDecoration(labelText: 'Tipo movimiento'),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: _cantidadCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Cantidad'),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: _obsCtrl,
            decoration: const InputDecoration(labelText: 'Observación'),
          ),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            icon: const Icon(Icons.check),
            label: const Text('Confirmar'),
            onPressed: _confirmar,
          ),
        ],
      ),
    );
  }

  Future<void> _confirmar() async {
    final cantidad = int.tryParse(_cantidadCtrl.text);

    if (_tipo == 'egreso' && cantidad! > widget.cantidadActual) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay stock suficiente para realizar el egreso'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (cantidad == null || cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese una cantidad válida')),
      );
      return;
    }

    if (_tipo == 'egreso') {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Confirmar egreso'),
          content: const Text(
            'Este movimiento reducirá el stock.\n¿Desea continuar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Confirmar'),
            ),
          ],
        ),
      );

      if (ok != true) return;
    }

    await _service.ajustarStock(
      idProducto: widget.idProducto,
      tipoMovimiento: _tipo,
      cantidad: cantidad,
      observacion: _obsCtrl.text,
    );

    Navigator.pop(context, true); // 👈 avisa refresh
  }
}
