import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/colors.dart';
import 'package:frontend_soderia/screens/combos/combo_productos_screen.dart';
import 'package:frontend_soderia/services/combo_service.dart';
import 'package:frontend_soderia/services/lista_precio_service.dart';

class ComboFormScreen extends StatefulWidget {
  final int? idCombo;

  const ComboFormScreen({super.key, this.idCombo});

  @override
  State<ComboFormScreen> createState() => _ComboFormScreenState();
}

class _ComboFormScreenState extends State<ComboFormScreen> {
  final _comboService = ComboService();
  final _listaPrecioService = ListaPrecioService();
  final _formKey = GlobalKey<FormState>();

  final _nombreCtrl = TextEditingController();
  bool _estado = true;
  bool _loading = false;

  List<dynamic> _listas = [];
  Map<int, double?> _preciosPorLista = {};

  bool get _esEdicion => widget.idCombo != null;

  @override
  void initState() {
    super.initState();
    if (_esEdicion) {
      _cargar();
    }
  }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    try {
      final combo = await _comboService.obtener(widget.idCombo!);
      _nombreCtrl.text = combo['nombre'] ?? '';
      _estado = combo['estado'] == true;

      _listas = await _listaPrecioService.listarListas();

      for (final l in _listas) {
        final precio = combo['precios']?[l['id_lista']];
        if (precio != null) {
          _preciosPorLista[l['id_lista']] = double.tryParse(precio.toString());
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _editarPrecioCombo(int idLista, String nombreLista) async {
    final ctrl = TextEditingController(
      text: _preciosPorLista[idLista]?.toStringAsFixed(0) ?? '',
    );

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Precio en $nombreLista'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Precio',
            prefixText: '\$ ',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (ok == true) {
      final precio = double.tryParse(ctrl.text);
      if (precio == null || precio <= 0) return;

      await _listaPrecioService.upsertPrecioCombo(
        idLista: idLista,
        idCombo: widget.idCombo!,
        precio: precio,
      );

      setState(() {
        _preciosPorLista[idLista] = precio;
      });
    }
  }

  /// 🔹 Guarda SOLO datos del combo (no productos)
  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      if (_esEdicion) {
        await _comboService.actualizar(
          idCombo: widget.idCombo!,
          nombre: _nombreCtrl.text.trim(),
          estado: _estado,
        );
      } else {
        await _comboService.crear(
          nombre: _nombreCtrl.text.trim(),
          estado: _estado,
        );
      }

      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.azul,
        foregroundColor: Colors.white,
        title: Text(_esEdicion ? 'Editar combo' : 'Nuevo combo'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // ---------------- Datos ----------------
                    TextFormField(
                      controller: _nombreCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del combo',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Ingresá un nombre'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Combo activo'),
                      subtitle: const Text('Los combos inactivos no se venden'),
                      value: _estado,
                      onChanged: (v) => setState(() => _estado = v),
                    ),
                    const SizedBox(height: 24),

                    // ---------------- Productos ----------------
                    if (_esEdicion) ...[
                      Text(
                        'Productos del combo',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.inventory_2),
                          title: const Text('Administrar productos'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            final changed = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ComboProductosScreen(
                                  idCombo: widget.idCombo!,
                                  nombreCombo: _nombreCtrl.text,
                                ),
                              ),
                            );

                            if (changed == true && mounted) {
                              // 👉 opcional pero recomendado
                              await _cargar();
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ---------------- Precios ----------------
                      Text(
                        'Precios por lista',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ..._listas.where((l) => l['estado'] == 'ACTIVA').map((l) {
                        final precio = _preciosPorLista[l['id_lista']];
                        return Card(
                          child: ListTile(
                            title: Text(l['nombre']),
                            subtitle: Text(
                              precio != null
                                  ? '\$${precio.toStringAsFixed(0)}'
                                  : 'Sin precio',
                              style: TextStyle(
                                color: precio == null ? Colors.red : null,
                              ),
                            ),
                            trailing: const Icon(Icons.edit),
                            onTap: () =>
                                _editarPrecioCombo(l['id_lista'], l['nombre']),
                          ),
                        );
                      }),
                      const SizedBox(height: 24),
                    ],

                    // ---------------- Guardar combo ----------------
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _guardar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: Text(
                          _esEdicion ? 'Guardar cambios' : 'Crear combo',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
