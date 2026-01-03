import 'package:flutter/material.dart';
import 'package:frontend_soderia/services/lista_precio_service.dart';

class PrecioComboModal extends StatefulWidget {
  final int idLista;
  final Map<String, dynamic>? comboInicial;

  const PrecioComboModal({super.key, required this.idLista, this.comboInicial});

  @override
  State<PrecioComboModal> createState() => _PrecioComboModalState();
}

class _PrecioComboModalState extends State<PrecioComboModal> {
  final _service = ListaPrecioService();
  final _precioCtrl = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.comboInicial != null && widget.comboInicial!['precio'] != null) {
      _precioCtrl.text = widget.comboInicial!['precio'].toString();
    }
  }

  @override
  void dispose() {
    _precioCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final txt = _precioCtrl.text.replaceAll(',', '.');
    final precio = double.tryParse(txt);

    if (precio == null || precio <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingrese un precio válido')));
      return;
    }

    setState(() => _saving = true);
    try {
      await _service.upsertPrecioCombo(
        idLista: widget.idLista,
        idCombo: widget.comboInicial!['id_item'],
        precio: precio,
      );

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error guardando precio: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final combo = widget.comboInicial;

    return AlertDialog(
      title: const Text('Precio del combo'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (combo != null) ...[
            Text(
              '📦 ${combo['nombre']}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _precioCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Precio',
              prefixText: '\$ ',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saving ? null : _guardar,
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}
