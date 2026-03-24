import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/navigation/destinations.dart';
import 'package:frontend_soderia/core/navigation/shell_state.dart';

class AppShellActions {
  static Future<void> showAddSheet(BuildContext context) async {
    final rootCtx = context; // 👈 guardamos el contexto "vivo" (pantalla)

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Abrir calendario'),
              onTap: () {
                Navigator.of(sheetCtx, rootNavigator: true).pop();
                jumpToTab(rootCtx, kIndexCalendario);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Nuevo cliente'),
              onTap: () => _closeAndPush(rootCtx, sheetCtx, '/cliente/new'),
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2),
              title: const Text('Nuevo producto'),
              onTap: () => _closeAndPush(rootCtx, sheetCtx, '/producto/new'),
            ),
            ListTile(
              leading: const Icon(Icons.group_add),
              title: const Text('Nuevo usuario'),
              onTap: () => _closeAndPush(rootCtx, sheetCtx, '/usuario/new'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  static void jumpToTab(BuildContext context, int index) {
    Navigator.of(context, rootNavigator: true).popUntil((r) => r.isFirst);
    shellState.selectTab(index);
  }

  static Future<Object?> push(
    BuildContext context,
    String route, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamed(route, arguments: arguments);
  }

  static void _closeAndPush(
    BuildContext rootCtx,
    BuildContext sheetCtx,
    String route, {
    Object? arguments,
  }) {
    // 1) Cerramos el sheet con su propio context (válido acá)
    Navigator.of(sheetCtx, rootNavigator: true).pop();

    // 2) Después navegamos usando rootCtx (que sigue montado)
    Future.microtask(() async {
      if (!rootCtx.mounted) return;

      final res = await Navigator.of(
        rootCtx,
        rootNavigator: true,
      ).pushNamed(route, arguments: arguments);

      if (!rootCtx.mounted) return;

      if (res == true) {
        ScaffoldMessenger.of(
          rootCtx,
        ).showSnackBar(const SnackBar(content: Text('Guardado correctamente')));
      }
    });
  }
}
