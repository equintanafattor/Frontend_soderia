// lib/screens/productos/productos_list_screen.dart
import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/navigation/app_shell_actions.dart';
import 'package:frontend_soderia/core/navigation/destinations.dart';
import 'package:frontend_soderia/models/producto.dart';
import 'package:frontend_soderia/services/producto_service.dart';
import 'package:frontend_soderia/screens/productos/producto_add_screen.dart';

class ProductosListScreen extends StatefulWidget {
  const ProductosListScreen({super.key});

  @override
  State<ProductosListScreen> createState() => _ProductosListScreenState();
}

class _ProductosListScreenState extends State<ProductosListScreen> {
  final _search = TextEditingController();
  final _service = ProductoService();

  String _orden = 'Nombre (A→Z)';
  bool _cargando = false;

  List<Producto> _data = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _cargando = true);
    try {
      final list = await _service.listar();
      setState(() => _data = list);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  List<Producto> get _filtered {
    final q = _search.text.trim().toLowerCase();

    var list = _data.where((p) {
      if (q.isEmpty) return true;
      final nombre = p.nombre.toLowerCase();
      final litros = (p.litros ?? 0).toString();
      final tipo = (p.tipoDispenser ?? '').toLowerCase();
      return nombre.contains(q) || litros.contains(q) || tipo.contains(q);
    }).toList();

    switch (_orden) {
      case 'Nombre (A→Z)':
        list.sort((a, b) => a.nombre.compareTo(b.nombre));
        break;
      case 'Nombre (Z→A)':
        list.sort((a, b) => b.nombre.compareTo(a.nombre));
        break;
      case 'Activos primero':
        list.sort((a, b) {
          final ea = a.estado == true ? 1 : 0;
          final eb = b.estado == true ? 1 : 0;
          return eb.compareTo(ea); // true antes que false
        });
        break;
      case 'Inactivos primero':
        list.sort((a, b) {
          final ea = a.estado == true ? 1 : 0;
          final eb = b.estado == true ? 1 : 0;
          return ea.compareTo(eb); // false antes que true
        });
        break;
    }

    return list;
  }

  Future<void> _refresh() async {
    await _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Buscar por nombre, litros o tipo de producto...',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              PopupMenuButton<String>(
                tooltip: 'Ordenar',
                initialValue: _orden,
                onSelected: (v) => setState(() => _orden = v),
                itemBuilder: (ctx) => const [
                  PopupMenuItem(
                    value: 'Nombre (A→Z)',
                    child: Text('Nombre (A→Z)'),
                  ),
                  PopupMenuItem(
                    value: 'Nombre (Z→A)',
                    child: Text('Nombre (Z→A)'),
                  ),
                  PopupMenuItem(
                    value: 'Activos primero',
                    child: Text('Activos primero'),
                  ),
                  PopupMenuItem(
                    value: 'Inactivos primero',
                    child: Text('Inactivos primero'),
                  ),
                ],
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.sort),
                  label: Text(_orden, overflow: TextOverflow.ellipsis),
                ),
              ),
              const SizedBox(width: 8),

              // 👉 Botón Listas de precios
              OutlinedButton.icon(
                icon: const Icon(Icons.request_quote),
                label: const Text('Listas de precios'),
                onPressed: () {
                  AppShellActions.push(context, '/listas-precios');
                },
              ),

              const SizedBox(width: 8),

              FilledButton.icon(
                onPressed: () async {
                  final result = await AppShellActions.push(
                    context,
                    '/producto/new',
                  );
                  if (result == true && mounted) {
                    _load();
                  }
                },
                icon: const Icon(Icons.inventory_2),
                label: const Text('Nuevo'),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final p = _filtered[i];

                      final litrosTxt = p.litros != null
                          ? '${p.litros!.toStringAsFixed(1)} Lts'
                          : 'Sin litros';
                      final tipoTxt = (p.tipoDispenser ?? '').isNotEmpty
                          ? p.tipoDispenser!
                          : 'Sin tipo';

                      final estadoTxt = p.estado == null
                          ? ''
                          : (p.estado! ? 'Activo' : 'Inactivo');

                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        tileColor: cs.surface,
                        leading: CircleAvatar(
                          child: Text(
                            (p.nombre.isNotEmpty ? p.nombre[0] : '?')
                                .toUpperCase(),
                          ),
                        ),
                        title: Text(p.nombre),
                        subtitle: Text(
                          '$litrosTxt · $tipoTxt'
                          '${estadoTxt.isNotEmpty ? ' · $estadoTxt' : ''}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: 'Editar',
                              onPressed: () async {
                                // Para edición usamos push directo al screen
                                final result = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProductoAddScreen(initial: p),
                                  ),
                                );
                                if (result == true && mounted) {
                                  _refresh();
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              tooltip: 'Eliminar',
                              onPressed: () async {
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Eliminar producto'),
                                    content: Text(
                                      '¿Seguro que querés eliminar "${p.nombre}"?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(false),
                                        child: const Text('Cancelar'),
                                      ),
                                      FilledButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(true),
                                        child: const Text('Eliminar'),
                                      ),
                                    ],
                                  ),
                                );

                                if (ok != true) return;

                                try {
                                  await _service.borrar(p.idProducto);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Producto eliminado'),
                                      ),
                                    );
                                    _refresh();
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e')),
                                    );
                                  }
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.warehouse),
                              tooltip: 'Ver stock',
                              onPressed: () {
                                AppShellActions.jumpToTab(context, kIndexStock);
                              },
                            ),
                          ],
                        ),
                        // Por ahora onTap no hace nada especial.
                        // Si después querés un detalle de producto, lo agregamos acá.
                        onTap: () {},
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
