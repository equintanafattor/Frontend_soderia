import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/navigation/push_and_refresh.dart';
import 'package:frontend_soderia/services/lista_precio_service.dart';
import 'package:frontend_soderia/screens/productos/precio_producto_modal.dart';
import 'package:frontend_soderia/screens/combos/precio_combo_modal.dart';

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
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Lista: ${widget.nombreLista}'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.inventory_2), text: 'Productos'),
              Tab(icon: Icon(Icons.all_inbox), text: 'Combos'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Editar lista',
              onPressed: () async {
                await pushAndRefresh(
                  context: context,
                  route: '/listas-precios/edit',
                  arguments: widget.idLista,
                  onRefresh: () {
                    Navigator.pop(context, true);
                  },
                );
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _ProductosTab(idLista: widget.idLista),
            _CombosTab(idLista: widget.idLista),
          ],
        ),
      ),
    );
  }
}

// =======================
// TAB PRODUCTOS
// =======================

class _ProductosTab extends StatefulWidget {
  final int idLista;
  const _ProductosTab({required this.idLista});

  @override
  State<_ProductosTab> createState() => _ProductosTabState();
}

class _ProductosTabState extends State<_ProductosTab> {
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
      final data = await _service.listarProductosConPrecio(widget.idLista);
      if (mounted) setState(() => _productos = data);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openModal({Map<String, dynamic>? producto}) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => PrecioProductoModal(
        idLista: widget.idLista,
        productoInicial: producto, // null => alta
      ),
    );

    if (ok == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Agregar producto'),
        onPressed: () => _openModal(), // ✅ alta
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
                    onPressed: () => _openModal(producto: p), // ✅ edición
                  ),
                );
              },
            ),
    );
  }
}

// =======================
// TAB COMBOS
// =======================

class _CombosTab extends StatefulWidget {
  final int idLista;
  const _CombosTab({required this.idLista});

  @override
  State<_CombosTab> createState() => _CombosTabState();
}

class _CombosTabState extends State<_CombosTab> {
  final _service = ListaPrecioService();
  bool _loading = false;
  List<dynamic> _combos = [];
  List<int> get _idsCombosYaCargados =>
      _combos.map((c) => c['id_combo'] as int).toList();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _service.listarCombosConPrecio(widget.idLista);
      if (mounted) setState(() => _combos = data);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openModal({Map<String, dynamic>? combo}) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => PrecioComboModal(
        idLista: widget.idLista,
        comboInicial: combo, // null => alta
        idsYaEnLista: _idsCombosYaCargados, // ✅ NUEVO
      ),
    );

    if (ok == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Agregar combo'),
        onPressed: () => _openModal(), // ✅ alta
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _combos.isEmpty
          ? const Center(child: Text('No hay combos disponibles'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _combos.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (_, i) {
                final c = _combos[i];
                final hasPrecio = c['precio'] != null;

                return ListTile(
                  title: Text('📦 ${c['nombre']}'),
                  subtitle: Text(
                    hasPrecio ? '\$${c['precio']}' : 'Sin precio',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: hasPrecio ? Colors.black : Colors.red,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Editar precio',
                    onPressed: () => _openModal(combo: c), // ✅ edición
                  ),
                );
              },
            ),
    );
  }
}

