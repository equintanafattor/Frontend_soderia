import 'package:flutter/material.dart';

class AppShellActions {
  static Future<void> showAddSheet(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Nuevo cliente'),
              onTap: () => _closeAndPush(sheetCtx, '/cliente/new'),
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2),
              title: const Text('Nuevo producto'),
              onTap: () => _closeAndPush(sheetCtx, '/producto/new'),
            ),
            ListTile(
              leading: const Icon(Icons.group_add),
              title: const Text('Nuevo usuario'),
              onTap: () => _closeAndPush(sheetCtx, '/usuario/new'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  static Future<Object?> push(BuildContext context, String route) {
    return Navigator.of(context, rootNavigator: true).pushNamed(route); // 👈 sin <bool>
  }

  static void _closeAndPush(BuildContext sheetCtx, String route) {
    Navigator.of(sheetCtx, rootNavigator: true).pop();
    Future.microtask(() async {
      final res = await Navigator.of(sheetCtx, rootNavigator: true).pushNamed(route); // 👈 sin <bool>
      if (res == true) {
        ScaffoldMessenger.of(sheetCtx).showSnackBar(
          const SnackBar(content: Text('Guardado correctamente')),
        );
      }
    });
  }
}

