import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/navigation/app_shell_actions.dart';
import 'package:frontend_soderia/models/usuario.dart';
import 'package:frontend_soderia/services/usuario_service.dart';
import 'package:frontend_soderia/screens/usuarios/usuario_detail_screen.dart';
import 'package:intl/intl.dart';

class UsuariosListScreen extends StatefulWidget {
  const UsuariosListScreen({super.key});

  @override
  State<UsuariosListScreen> createState() => _UsuariosListScreenState();
}

class _UsuariosListScreenState extends State<UsuariosListScreen> {
  final _search = TextEditingController();
  final _service = UsuarioService();
  String _orden = 'Nombre (A→Z)';
  bool _cargando = false;
  List<Usuario> _data = [];

  List<Usuario> get _filtered {
    final q = _search.text.trim().toLowerCase();
    var list = _data.where((u) {
      if (q.isEmpty) return true;
      return u.nombre.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q) ||
          u.rol.toLowerCase().contains(q);
    }).toList();

    switch (_orden) {
      case 'Nombre (A→Z)':
        list.sort((a, b) => a.nombre.compareTo(b.nombre));
        break;
      case 'Nombre (Z→A)':
        list.sort((a, b) => b.nombre.compareTo(a.nombre));
        break;
      case 'Más nuevos':
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Más antiguos':
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final items = await _service.obtenerUsuarios();
      if (!mounted) return;
      setState(() {
        _data = items;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar usuarios: $e')),
      );
    }
  }

  Future<void> _refresh() async {
    await _cargar();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dateFmt = DateFormat('dd/MM/yyyy');

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
                    hintText: 'Buscar por nombre, email o rol...',
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
                  final created = await AppShellActions.push(
                    context,
                    '/usuario/new',
                  );
                  // Si el alta devolvió true, recargamos
                  if (created == true && mounted) {
                    _cargar();
                  }
                },
                icon: const Icon(Icons.person_add),
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
                      final u = _filtered[i];
                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        tileColor: Theme.of(context).colorScheme.surface,
                        leading: CircleAvatar(
                          child: Text(
                            u.nombre.isNotEmpty
                                ? u.nombre.substring(0, 1).toUpperCase()
                                : '?',
                          ),
                        ),
                        title: Text(u.nombre),
                        subtitle: Text(
                          '${u.email.isEmpty ? 'Sin email' : u.email} · ${u.rol.isEmpty ? 'Sin rol' : u.rol}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Tooltip(
                              message: u.activo ? 'Activo' : 'Inactivo',
                              child: Icon(
                                u.activo
                                    ? Icons.check_circle
                                    : Icons.cancel_outlined,
                                color: u.activo ? cs.primary : cs.error,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              dateFmt.format(u.createdAt),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: cs.outline),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  UsuarioDetailScreen(usuario: u),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
