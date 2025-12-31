import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/colors.dart';
import 'package:frontend_soderia/screens/combos/combo_productos_screen.dart';
import 'package:frontend_soderia/services/combo_service.dart';

class ComboFormScreen extends StatefulWidget {
  final int? idCombo;

  const ComboFormScreen({super.key, this.idCombo});

  @override
  State<ComboFormScreen> createState() => _ComboFormScreenState();
}

class _ComboFormScreenState extends State<ComboFormScreen> {
  final _service = ComboService();
  final _formKey = GlobalKey<FormState>();

  final _nombreCtrl = TextEditingController();
  bool _estado = true;
  bool _loading = false;

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
      final combo = await _service.obtener(widget.idCombo!);
      _nombreCtrl.text = combo['nombre'] ?? '';
      _estado = combo['estado'] == true;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      if (_esEdicion) {
        await _service.actualizar(
          idCombo: widget.idCombo!,
          nombre: _nombreCtrl.text.trim(),
          estado: _estado,
        );
      } else {
        await _service.crear(nombre: _nombreCtrl.text.trim(), estado: _estado);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------------- Datos del combo ----------------
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
                      subtitle: const Text(
                        'Los combos inactivos no se pueden vender',
                      ),
                      value: _estado,
                      onChanged: (v) => setState(() => _estado = v),
                    ),

                    const SizedBox(height: 24),

                    // ---------------- Productos del combo ----------------
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
                          subtitle: const Text(
                            'Agregar productos y cantidades al combo',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ComboProductosScreen(
                                idCombo: widget.idCombo!,
                                nombreCombo: _nombreCtrl.text,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    const Spacer(),

                    // ---------------- Guardar ----------------
                    SizedBox(
                      width: double.infinity,
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
