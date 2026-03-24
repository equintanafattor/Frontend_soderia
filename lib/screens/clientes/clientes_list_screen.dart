import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/navigation/app_shell_actions.dart';
import 'package:frontend_soderia/services/cliente_service.dart';

class ClientesListScreen extends StatefulWidget {
  const ClientesListScreen({super.key});

  @override
  State<ClientesListScreen> createState() => _ClientesListScreenState();
}

class _ClientesListScreenState extends State<ClientesListScreen> {
  final _search = TextEditingController();
  final _service = ClienteService();

  String _orden = 'Apellido (A→Z)';
  bool _cargando = false;

  // ahora viene del backend
  List<dynamic> _data = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _cargando = true);
    try {
      final list = await _service.listarClientes();
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

  List<dynamic> get _filtered {
    final q = _search.text.trim().toLowerCase();
    // cada item del back tiene: legajo, dni, observacion, persona:{nombre,apellido,...}
    var list = _data.where((c) {
      if (q.isEmpty) return true;
      final persona = c['persona'] ?? {};
      final nombreCompleto =
          '${persona['nombre'] ?? ''} ${persona['apellido'] ?? ''}'
              .toLowerCase();
      final dni = '${c['dni'] ?? ''}'.toLowerCase();
      return nombreCompleto.contains(q) || dni.contains(q);
    }).toList();

    switch (_orden) {
      case 'Apellido (A→Z)':
        list.sort((a, b) {
          final apA = (a['persona']?['apellido'] ?? '') as String;
          final apB = (b['persona']?['apellido'] ?? '') as String;
          return apA.compareTo(apB);
        });
        break;
      case 'Apellido (Z→A)':
        list.sort((a, b) {
          final apA = (a['persona']?['apellido'] ?? '') as String;
          final apB = (b['persona']?['apellido'] ?? '') as String;
          return apB.compareTo(apA);
        });
        break;
      case 'Más nuevos':
        break;
      case 'Más antiguos':
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
                    hintText: 'Buscar por nombre o DNI...',
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
                    value: 'Apellido (A→Z)',
                    child: Text('Apellido (A→Z)'),
                  ),
                  PopupMenuItem(
                    value: 'Apellido (Z→A)',
                    child: Text('Apellido (Z→A)'),
                  ),
                  PopupMenuItem(value: 'Más nuevos', child: Text('Más nuevos')),
                  PopupMenuItem(
                    value: 'Más antiguos',
                    child: Text('Más antiguos'),
                  ),
                ],
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.sort),
                  label: Text(_orden, overflow: TextOverflow.ellipsis),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () async {
                  final result = await AppShellActions.push(
                    context,
                    '/cliente/new',
                  );
                  if (result == true && mounted) {
                    _load();
                  }
                },
                icon: const Icon(Icons.person_add_alt_1),
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
                      final c = _filtered[i];
                      final persona = c['persona'] ?? {};
                      final apellido = persona['apellido'] ?? '';
                      final nombre = persona['nombre'] ?? '';
                      final legajo = c['legajo'];

                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        tileColor: cs.surface,
                        leading: CircleAvatar(
                          child: Text(
                            (apellido.isNotEmpty
                                    ? apellido[0]
                                    : (nombre.isNotEmpty ? nombre[0] : '?'))
                                .toUpperCase(),
                          ),
                        ),
                        title: Text('$apellido, $nombre'),
                        subtitle: Text('DNI: ${c['dni']}'),
                        // 👇 solo este trailing
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: 'Editar',
                              onPressed: () async {
                                final result = await AppShellActions.push(
                                  context,
                                  '/cliente/edit',
                                  arguments: {'legajo': legajo, 'data': c},
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
                                    title: const Text('Eliminar cliente'),
                                    content: Text(
                                      '¿Seguro que querés eliminar al cliente $legajo?',
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
                                  await _service.borrarCliente(legajo);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Cliente eliminado'),
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
                          ],
                        ),
                        onTap: () =>
                            AppShellActions.push(
                              context,
                              '/cliente/detail',
                              arguments: legajo,
                            ).then((res) {
                              if (res == true) {
                                _refresh();
                              }
                            }),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
