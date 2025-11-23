import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend_soderia/models/usuario.dart';
import 'package:frontend_soderia/screens/usuarios/usuario_edit_screen.dart';

class UsuarioDetailScreen extends StatelessWidget {
  const UsuarioDetailScreen({super.key, required this.usuario});

  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(usuario.nombre),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updated = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => UsuarioEditScreen(usuario: usuario),
                ),
              );
              // Opcional: podrías manejar un refresh aquí
              if (updated == true && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Usuario actualizado')),
                );
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    usuario.nombre,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    usuario.email.isEmpty ? 'Sin email' : usuario.email,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Chip(
                        avatar: const Icon(Icons.badge, size: 18),
                        label: Text(
                          usuario.rol.isEmpty ? 'Sin rol' : usuario.rol,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        avatar: Icon(
                          usuario.activo
                              ? Icons.check_circle
                              : Icons.cancel_outlined,
                          size: 18,
                        ),
                        label:
                            Text(usuario.activo ? 'Activo' : 'Inactivo'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Creado: ${dateFmt.format(usuario.createdAt)}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Theme.of(context).hintColor),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Reservado para más secciones (histórico, auditoría, etc.)
        ],
      ),
    );
  }
}
