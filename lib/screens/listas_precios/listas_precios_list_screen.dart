import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/navigation/app_shell_actions.dart';
import 'package:frontend_soderia/core/navigation/push_and_refresh.dart';
import 'package:frontend_soderia/services/lista_precio_service.dart';

class ListasPreciosListScreen extends StatefulWidget {
  const ListasPreciosListScreen({super.key});

  @override
  State<ListasPreciosListScreen> createState() =>
      _ListasPreciosListScreenState();
}

class _ListasPreciosListScreenState extends State<ListasPreciosListScreen> {
  final _search = TextEditingController();
  final _service = ListaPrecioService();

  bool _cargando = false;
  List<dynamic> _data = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _cargando = true);
    try {
      final list = await _service.listarListas();
      if (mounted) setState(() => _data = list);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtro = _search.text.toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listas de precios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
            onPressed: _load,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nueva lista',
        onPressed: () => pushAndRefresh(
          context: context,
          route: '/listas-precios/new',
          onRefresh: _load,
        ),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _search,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Buscar lista...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    itemCount: _data.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final l = _data[i];

                      final nombre = (l['nombre'] ?? '').toString();
                      if (!nombre.toLowerCase().contains(filtro)) {
                        return const SizedBox.shrink();
                      }

                      final estadoRaw = (l['estado'] ?? '').toString();
                      final estado = estadoRaw.toLowerCase().trim();
                      final inactiva = estado != 'activo';

                      final chipText = inactiva ? 'inactivo' : 'activo';
                      final chipColor = inactiva
                          ? Colors.grey.shade300
                          : Colors.green.shade100;

                      return ListTile(
                        title: Text(
                          nombre,
                          style: TextStyle(
                            color: inactiva ? Colors.grey : null,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: l['fecha_creacion'] != null
                            ? Text(
                                'Creada: ${l['fecha_creacion']}',
                                style: TextStyle(
                                  color: inactiva ? Colors.grey : null,
                                ),
                              )
                            : null,
                        trailing: Chip(
                          label: Text(chipText),
                          backgroundColor: chipColor,
                        ),
                        onTap: () async {
                          final changed = await AppShellActions.push(
                            context,
                            '/listas-precios/detail',
                            arguments: {'id': l['id_lista'], 'nombre': nombre},
                          );

                          if (changed == true && mounted) _load();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
