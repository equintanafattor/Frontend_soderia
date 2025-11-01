import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/navigation/destinations.dart';
import 'package:frontend_soderia/core/navigation/shell_state.dart'; // 👈 NUEVO
import 'package:frontend_soderia/core/navigation/destinations.dart'; // 👈 para kIndexCalendario

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
            // 👇 NUEVO ITEM
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Abrir calendario'),
              onTap: () {
                Navigator.of(
                  sheetCtx,
                  rootNavigator: true,
                ).pop(); // cerrar el modal
                jumpToTab(context, kIndexCalendario); // ir a pestaña Calendario
              },
            ),
            const Divider(),

            // Resto de opciones existentes
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

  /// Permite cambiar de tab desde cualquier lugar.
  /// Requiere que AppShell esté arriba en el árbol.
  //static void _jumpToTab(BuildContext context, int index) {
  // Como tu AppShell expone _select internamente, la forma simple
  // es pasar el callback “select” a HomeScreen (ya lo hacés).
  // Si querés hacerlo global, podés usar un InheritedWidget/Provider.
  // En tu caso actual, lo más directo es:
  //Navigator.of(context).popUntil((route) => route.isFirst);
  // y luego, si HomeScreen tiene onRequestTab, llamarla desde ahí.
  //}

  /// Cambia a una pestaña del AppShell desde cualquier parte de la app.
  static void jumpToTab(BuildContext context, int index) {
    // Primero cerramos cualquier modal o ruta que esté arriba
    Navigator.of(
      context,
      rootNavigator: true,
    ).popUntil((route) => route.isFirst);

    // Luego actualizamos el índice global
    shellState.selectTab(index);
  }

  static Future<Object?> push(BuildContext context, String route) {
    return Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamed(route); // 👈 sin <bool>
  }

  static void _closeAndPush(BuildContext sheetCtx, String route) {
    Navigator.of(sheetCtx, rootNavigator: true).pop();
    Future.microtask(() async {
      final res = await Navigator.of(
        sheetCtx,
        rootNavigator: true,
      ).pushNamed(route); // 👈 sin <bool>
      if (res == true) {
        ScaffoldMessenger.of(
          sheetCtx,
        ).showSnackBar(const SnackBar(content: Text('Guardado correctamente')));
      }
    });
  }
}
