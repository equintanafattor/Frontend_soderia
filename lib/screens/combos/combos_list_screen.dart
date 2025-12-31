import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/colors.dart';
import 'package:frontend_soderia/core/navigation/app_shell_actions.dart';
import 'package:frontend_soderia/services/combo_service.dart';

class CombosListScreen extends StatefulWidget {
  const CombosListScreen({super.key});

  @override
  State<CombosListScreen> createState() => _CombosListScreenState();
}

class _CombosListScreenState extends State<CombosListScreen> {
  final _service = ComboService();
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    _future = _service.listar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.azul,
        foregroundColor: Colors.white,
        title: const Text('Combos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Nuevo combo',
            onPressed: () {
              AppShellActions.push(context, '/combos/new').then((v) {
                if (v == true && mounted) {
                  setState(_cargar);
                }
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final combos = snap.data!;
          if (combos.isEmpty) {
            return const Center(child: Text('No hay combos cargados'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: combos.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, i) {
              final c = combos[i] as Map<String, dynamic>;
              final activo = c['estado'] == true;

              return ListTile(
                leading: Icon(
                  Icons.inventory_2,
                  color: activo ? Colors.green : Colors.grey,
                ),
                title: Text(c['nombre']),
                subtitle: Text(
                  activo ? 'Activo' : 'Inactivo',
                  style: TextStyle(color: activo ? Colors.green : Colors.red),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    AppShellActions.push(
                      context,
                      '/combos/edit',
                      arguments: c['id_combo'],
                    ).then((v) {
                      if (v == true && mounted) {
                        setState(_cargar);
                      }
                    });
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
