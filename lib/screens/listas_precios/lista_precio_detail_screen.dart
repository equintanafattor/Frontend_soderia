import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/navigation/app_shell_actions.dart';
import 'package:frontend_soderia/services/lista_precio_service.dart';
import 'package:frontend_soderia/screens/productos/precio_producto_modal.dart';

class ListaPrecioDetailScreen extends StatefulWidget {
  final int idLista;
  final String nombreLista;

  const ListaPrecioDetailScreen({
    super.key,
    required this.idLista,
    required this.nombreLista,
  });

  @override
  State<ListaPrecioDetailScreen> createState() =>
      _ListaPrecioDetailScreenState();
}

class _ListaPrecioDetailScreenState extends State<ListaPrecioDetailScreen> {
  final _service = ListaPrecioService();
  bool _loading = false;

  List<dynamic> _productos = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _productos = await _service.listarProductosConPrecio(widget.idLista);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _openModal({Map<String, dynamic>? producto}) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => PrecioProductoModal(
        idLista: widget.idLista,
        productoInicial: producto,
      ),
    );

    if (ok == true) {
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista: ${widget.nombreLista}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory_2),
            tooltip: 'Precios de combos',
            onPressed: () {
              AppShellActions.push(
                context,
                '/listas-precios/combos-precios',
                arguments: {
                  'idLista': widget.idLista,
                  'nombreLista': widget.nombreLista,
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar lista',
            onPressed: () => AppShellActions.push(
              context,
              '/listas-precios/edit',
              arguments: widget.idLista,
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Agregar producto'),
        onPressed: () => _openModal(),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _productos.isEmpty
          ? const Center(child: Text('No hay productos cargados en esta lista'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _productos.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (_, i) {
                final p = _productos[i];

                return ListTile(
                  title: Text(p['nombre']),
                  subtitle: Text(
                    '\$${p['precio']}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),

                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Editar precio',
                    onPressed: () => _openModal(producto: p),
                  ),
                );
              },
            ),
    );
  }
}
