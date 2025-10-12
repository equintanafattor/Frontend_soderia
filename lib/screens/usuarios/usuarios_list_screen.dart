import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/navigation/app_shell_actions.dart';

class UsuariosListScreen extends StatefulWidget {
  const UsuariosListScreen({super.key});

  @override
  State<UsuariosListScreen> createState() => _UsuariosListScreenState();
}

class _UsuariosListScreenState extends State<UsuariosListScreen> {
  final _search = TextEditingController();
  String _orden = 'Nombre (A→Z)';
  bool _cargando = false;

  // Mock inicial – luego lo reemplazás con tu repo/API
  List<Map<String, dynamic>> _data = [
    {
      'nombre': 'Ana Torres',
      'email': 'ana@soderia.com',
      'rol': 'Ventas',
      'activo': true,
      'created': DateTime(2025, 9, 1),
    },
    {
      'nombre': 'Bruno Díaz',
      'email': 'bruno@soderia.com',
      'rol': 'Repartidor',
      'activo': true,
      'created': DateTime(2025, 9, 5),
    },
    {
      'nombre': 'Carla Gómez',
      'email': 'carla@soderia.com',
      'rol': 'Admin',
      'activo': false,
      'created': DateTime(2025, 8, 20),
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    final q = _search.text.trim().toLowerCase();
    var list = _data.where((u) {
      if (q.isEmpty) return true;
      return (u['nombre'] as String).toLowerCase().contains(q) ||
          (u['email'] as String).toLowerCase().contains(q) ||
          (u['rol'] as String).toLowerCase().contains(q);
    }).toList();

    switch (_orden) {
      case 'Nombre (A→Z)':
        list.sort(
          (a, b) => (a['nombre'] as String).compareTo(b['nombre'] as String),
        );
        break;
      case 'Nombre (Z→A)':
        list.sort(
          (a, b) => (b['nombre'] as String).compareTo(a['nombre'] as String),
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
    // TODO: cargar desde backend
    // Acá iría la llamada al repo/API
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _cargando = false);
  }

  @override
  void Dispose() {
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
                    hintText: 'Buscar por nombre, email o rol',
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
                onPressed: () => AppShellActions.push(context, '/usuario/new'),
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
                
          ),

        )
        
        
      ],
    );
  }
}
