// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:frontend_soderia/services/lista_precio_service.dart';
import 'package:frontend_soderia/services/combo_service.dart';

class PrecioComboModal extends StatefulWidget {
  final int idLista;
  final Map<String, dynamic>? comboInicial;
  final List<int> idsYaEnLista; // ✅ NUEVO

  const PrecioComboModal({
    super.key,
    required this.idLista,
    this.comboInicial,
    this.idsYaEnLista = const [], // ✅ default
  });

  @override
  State<PrecioComboModal> createState() => _PrecioComboModalState();
}

class _PrecioComboModalState extends State<PrecioComboModal> {
  final _service = ListaPrecioService();
  final _comboService = ComboService();

  final _precioCtrl = TextEditingController();
  int? _idCombo;
  bool _saving = false;

  bool get _esEdicion => widget.comboInicial != null;

  late final Future<List<dynamic>> _combosFuture;

  @override
  void initState() {
    super.initState();
    _combosFuture = _comboService.listar();

    if (_esEdicion) {
      final c = widget.comboInicial!;
      _idCombo = c['id_combo'] as int?;
      if (c['precio'] != null) _precioCtrl.text = c['precio'].toString();
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

    if (_idCombo == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Seleccioná un combo')));
      return;
    }

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
        idCombo: _idCombo!,
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
      title: Text(_esEdicion ? 'Editar precio del combo' : 'Agregar combo'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_esEdicion && combo != null) ...[
              Text(
                '📦 ${combo['nombre']}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
            ],

            if (!_esEdicion) ...[
              FutureBuilder<List<dynamic>>(
                future: _combosFuture,
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (!snap.hasData || snap.data!.isEmpty) {
                    return const Text('No hay combos disponibles');
                  }

                  final combos = snap.data!;

                  // ✅ si es alta: saco los que ya están en la lista
                  final disponibles = combos.where((c) {
                    final id = c['id_combo'] as int;
                    return !widget.idsYaEnLista.contains(id);
                  }).toList();

                  if (disponibles.isEmpty) {
                    return const Text(
                      'Ya agregaste todos los combos a esta lista',
                    );
                  }

                  return DropdownButtonFormField<int>(
                    value: _idCombo,
                    decoration: const InputDecoration(
                      labelText: 'Combo',
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Seleccioná un combo'),
                    items: disponibles.map((c) {
                      return DropdownMenuItem<int>(
                        value: c['id_combo'] as int,
                        child: Text(c['nombre'] as String),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _idCombo = v),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],

            TextField(
              controller: _precioCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Precio',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
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
