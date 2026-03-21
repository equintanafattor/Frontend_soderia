import 'package:flutter/material.dart';
import 'package:frontend_soderia/services/lista_precio_service.dart';

class PrecioServicioModal extends StatefulWidget {
  final int idLista;
  final Map<String, dynamic> servicioInicial;

  const PrecioServicioModal({
    super.key,
    required this.idLista,
    required this.servicioInicial,
  });

  @override
  State<PrecioServicioModal> createState() => _PrecioServicioModalState();
}

class _PrecioServicioModalState extends State<PrecioServicioModal> {
  final _service = ListaPrecioService();
  final _formKey = GlobalKey<FormState>();
  final _precioCtrl = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final precio = widget.servicioInicial['precio'];
    if (precio != null) _precioCtrl.text = precio.toString();
  }

  @override
  void dispose() {
    _precioCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final idClienteServicio =
        widget.servicioInicial['id_cliente_servicio'] as int;
    final precio = double.parse(_precioCtrl.text.replaceAll(',', '.'));

    setState(() => _saving = true);
    try {
      await _service.upsertPrecioServicio(
        idLista: widget.idLista,
        idClienteServicio: idClienteServicio,
        precio: precio,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo guardar el precio del servicio'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tipo = (widget.servicioInicial['servicio_tipo'] ?? 'SERVICIO')
        .toString();

    return AlertDialog(
      title: Text('Precio servicio: $tipo'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _precioCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Precio',
            prefixText: '\$ ',
          ),
          validator: (v) {
            final s = (v ?? '').trim();
            if (s.isEmpty) return 'Ingresá un precio';
            final n = double.tryParse(s.replaceAll(',', '.'));
            if (n == null) return 'Precio inválido';
            if (n <= 0) return 'Debe ser mayor a 0';
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}
