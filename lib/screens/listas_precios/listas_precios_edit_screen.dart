import 'package:flutter/material.dart';
import 'package:frontend_soderia/services/lista_precio_service.dart';

class ListaPrecioEditScreen extends StatefulWidget {
  final int idLista;

  const ListaPrecioEditScreen({super.key, required this.idLista});

  @override
  State<ListaPrecioEditScreen> createState() => _ListaPrecioEditScreenState();
}

class _ListaPrecioEditScreenState extends State<ListaPrecioEditScreen> {
  final _service = ListaPrecioService();
  final _nombreCtrl = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String _estado = "activo"; // "activo" | "inactivo"

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _service.obtenerLista(widget.idLista);
      _nombreCtrl.text = (data["nombre"] ?? "").toString();
      _estado = (data["estado"] ?? "activo").toString();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error cargando lista: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _guardar() async {
    final nombre = _nombreCtrl.text.trim();
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre no puede estar vacío')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await _service.actualizarLista(
        idLista: widget.idLista,
        nombre: nombre,
        estado: _estado,
      );

      if (!mounted) return;
      Navigator.pop(context, true); // ✅ para refrescar pantalla anterior
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error guardando: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _eliminar() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar lista'),
        content: const Text(
          'Esto va a desactivar la lista (no se borra definitivamente). ¿Continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    setState(() => _saving = true);
    try {
      await _service.eliminarLista(widget.idLista);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error eliminando: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activa = _estado.toLowerCase() == "activo";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar lista de precios'),
        actions: [
          IconButton(
            tooltip: 'Desactivar lista',
            icon: const Icon(Icons.delete_outline),
            onPressed: (_loading || _saving) ? null : _eliminar,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  controller: _nombreCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  value: activa,
                  title: const Text('Lista activa'),
                  onChanged: _saving
                      ? null
                      : (v) =>
                            setState(() => _estado = v ? "activo" : "inactivo"),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _saving ? null : _guardar,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: const Text('Guardar cambios'),
                ),
              ],
            ),
    );
  }
}
