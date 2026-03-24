import 'package:flutter/material.dart';
import 'package:frontend_soderia/services/lista_precio_service.dart';

class ListaPrecioFormScreen extends StatefulWidget {
  const ListaPrecioFormScreen({super.key});

  @override
  State<ListaPrecioFormScreen> createState() => _ListaPrecioFormScreenState();
}

class _ListaPrecioFormScreenState extends State<ListaPrecioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();

  bool _activa = true;
  bool _loading = false;

  final _service = ListaPrecioService();

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await _service.crearLista(
        nombre: _nombreCtrl.text.trim(),
        estado: _activa ? 'ACTIVA' : 'INACTIVA',
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
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
        title: const Text('Nueva lista de precios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Guardar',
            onPressed: _loading ? null : _guardar,
          ),
        ],
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
                    TextFormField(
                      controller: _nombreCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la lista',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Campo obligatorio'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Lista activa'),
                      subtitle: Text(
                        _activa
                            ? 'Disponible para ventas'
                            : 'No se podrá usar en ventas',
                      ),
                      value: _activa,
                      onChanged: (v) => setState(() => _activa = v),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
