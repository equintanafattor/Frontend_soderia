import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/navigation/app_shell_actions.dart';

class ClientesListScreen extends StatefulWidget {
  const ClientesListScreen({super.key});

  @override
  State<ClientesListScreen> createState() => _ClientesListScreenState();
}

class _ClientesListScreenState extends State<ClientesListScreen> {
  final _search = TextEditingController();
  String _orden = 'Apellido (A→Z)';
  bool _cargando = false;

  // Mock – reemplazar por repo/API
  List<Map<String, dynamic>> _data = [
    {
      'nombre': 'Juan',
      'apellido': 'Pérez',
      'tel': '343-555111',
      'zona': 'Centro',
      'visitadia': 'Lun, Jue',
      'created': DateTime(2025, 9, 10),
    },
    {
      'nombre': 'María',
      'apellido': 'López',
      'tel': '343-555222',
      'zona': 'Norte',
      'visitadia': 'Mar, Vie',
      'created': DateTime(2025, 9, 3),
    },
    {
      'nombre': 'Carlos',
      'apellido': 'García',
      'tel': '343-555333',
      'zona': 'Sur',
      'visitadia': 'Mié',
      'created': DateTime(2025, 8, 22),
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    final q = _search.text.trim().toLowerCase();
    var list = _data.where((c) {
      if (q.isEmpty) return true;
      final nombreCompleto = '${c['nombre']} ${c['apellido']}'.toLowerCase();
      return nombreCompleto.contains(q) ||
          (c['tel'] as String).toLowerCase().contains(q) ||
          (c['zona'] as String).toLowerCase().contains(q);
    }).toList();

    switch (_orden) {
      case 'Apellido (A→Z)':
        list.sort(
          (a, b) =>
              (a['apellido'] as String).compareTo(b['apellido'] as String),
        );
        break;
      case 'Apellido (Z→A)':
        list.sort(
          (a, b) =>
              (b['apellido'] as String).compareTo(a['apellido'] as String),
        );
        break;
      case 'Más nuevos':
        list.sort(
          (a, b) =>
              (b['created'] as DateTime).compareTo(a['created'] as DateTime),
        );
        break;
      case 'Más antiguos':
        list.sort(
          (a, b) =>
              (a['created'] as DateTime).compareTo(b['created'] as DateTime),
        );
        break;
    }
    return list;
  }

  Future<void> _refresh() async {
    setState(() => _cargando = true);
    // TODO: fetch backend
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _cargando = false);
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
                    hintText: 'Buscar por nombre, teléfono o zona...',
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
                onPressed: () => AppShellActions.push(context, '/cliente/new'),
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
                      final nombre = '${c['apellido']}, ${c['nombre']}';
                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(12),
                        ),
                        tileColor: Theme.of(context).colorScheme.surface,
                        leading: CircleAvatar(
                          child: Text(
                            (c['apellido'] as String).substring(0, 1),
                          ),
                        ),
                        title: Text(nombre),
                        subtitle: Text(
                          '${c['tel']} · Zona: ${c['zona']} · ${c['visitadia']}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: 'Editar',
                          onPressed: () {
                            // TODO: navegar a editar
                          },
                        ),
                        onTap: () {
                          // TODO: detalle cliente
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
