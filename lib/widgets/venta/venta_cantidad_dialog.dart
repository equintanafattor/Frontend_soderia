import 'package:flutter/material.dart';

class VentaCantidadDialog extends StatefulWidget {
  final int cantidadInicial;

  const VentaCantidadDialog({super.key, required this.cantidadInicial});

  @override
  State<VentaCantidadDialog> createState() => _VentaCantidadDialogState();
}

class _VentaCantidadDialogState extends State<VentaCantidadDialog> {
  late int _cant;

  @override
  void initState() {
    super.initState();
    _cant = widget.cantidadInicial;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar cantidad'),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            tooltip: 'Menos',
            onPressed: () => setState(() => _cant = (_cant - 1).clamp(0, 999)),
            icon: const Icon(Icons.remove),
          ),
          Text(
            '$_cant',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          IconButton(
            tooltip: 'Más',
            onPressed: () => setState(() => _cant = (_cant + 1).clamp(0, 999)),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop<int>(context, _cant),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}