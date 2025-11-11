import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/navigation/app_shell_actions.dart';
import 'package:frontend_soderia/services/cliente_service.dart';

class ClienteDetailScreen extends StatefulWidget {
  final int legajo;
  const ClienteDetailScreen({super.key, required this.legajo});

  @override
  State<ClienteDetailScreen> createState() => _ClienteDetailScreenState();
}

class _ClienteDetailScreenState extends State<ClienteDetailScreen> {
  final _service = ClienteService();
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.obtenerCliente(widget.legajo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cliente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // cuando tengas la pantalla de editar
              // Navigator.pushNamed(context, '/cliente/edit', arguments: widget.legajo);
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final data = snap.data!;
          final persona = data['persona'] ?? {};
          final nombre =
              '${persona['nombre'] ?? ''} ${persona['apellido'] ?? ''}'.trim();
          final dni =
              persona['dni']?.toString() ?? data['dni']?.toString() ?? '-';
          final observacion =
              persona['observacion']?.toString() ?? data['observacion']?.toString() ?? '-';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                nombre.isEmpty ? 'Sin nombre' : nombre,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text('Legajo: ${widget.legajo}'),
              const SizedBox(height: 4),
              Text('DNI: $dni'),
              const SizedBox(height: 16),
              Text(
                'Observaciones',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(observacion),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed: () => AppShellActions.push(
              context,
              '/venta',
              arguments: {'legajo': widget.legajo},
            ),
            icon: const Icon(Icons.point_of_sale),
            label: const Text('Iniciar venta fuera de recorrido'),
          ),
        ),
      ),
    );
  }
}
