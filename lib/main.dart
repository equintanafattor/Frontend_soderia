/* import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme.dart';
import 'core/navigation/app_shell.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/todos_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_AR', null); // intl en español (AR)
  runApp(const FrontendSoderiaApp());
}

class FrontendSoderiaApp extends StatelessWidget {
  const FrontendSoderiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sodería',
      debugShowCheckedModeBanner: false,
      theme: soderiaTheme,
      // Punto de entrada: valida token y decide a dónde ir
      home: const SplashScreen(),
      // Si luego querés rutas nombradas:
      // routes: {
      //   '/login': (_) => const LoginScreen(),
      //   '/app':   (_) => _buildAppShell(), // ver helper abajo
      // },
    );
  }
}

/// Helper para construir el AppShell con tus páginas (mismo orden que kDestinations)
AppShell _buildAppShell({String usuario = 'Gastón'}) {
  return AppShell(
    pages: [
      HomeScreen(nombreUsuario: usuario),
      TodosScreen(nombreUsuario: usuario),
      const Placeholder(), // Reportes
      const Placeholder(), // Usuarios
      const Placeholder(), // Clientes
    ],
    initialIndex: 0,
    // fabBuilder, titleBuilder opcionales
  );
}
 */

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme.dart';
import 'core/navigation/app_shell.dart';
import 'screens/home_screen.dart';
import 'screens/todos_screen.dart';

// 👇 importa tus screens nuevos
import 'screens/clientes/cliente_add_screen.dart';
import 'screens/productos/producto_add_screen.dart';
import 'screens/usuarios/usuario_add_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_AR', null);
  runApp(const FrontendSoderiaApp());
}

class FrontendSoderiaApp extends StatelessWidget {
  const FrontendSoderiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sodería',
      debugShowCheckedModeBanner: false,
      theme: soderiaTheme,

      // 👇 rutas nombradas para abrir las pantallas de "agregar"
      routes: {
        '/cliente/new': (_) => const ClienteAddScreen(),
        '/producto/new': (_) => const ProductoAddScreen(),
        '/usuario/new': (_) => const UsuarioAddScreen(),
      },

      home: AppShell(
        initialIndex: 0,
        pagesBuilder: (select) => [
          HomeScreen(nombreUsuario: 'Gastón', onRequestTab: select),
          const TodosScreen(nombreUsuario: 'Gastón'),
          const Placeholder(), // Reportes
          const Placeholder(), // Usuarios
          const Placeholder(), // Clientes
        ],
        // 👇 título dinámico
        titleBuilder: (index, dest) => index == 0 ? '' : dest.label,

        // 👇 FAB por sección
        fabBuilder: (ctx, index) {
          // En Inicio mostramos un FAB que abre el "launcher" de altas
          if (index == 0) {
            return FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('Agregar'),
              onPressed: () => _showAddSheet(ctx),
            );
          }
          // En Usuarios: alta directa de usuario
          if (index == 3) {
            return FloatingActionButton(
              onPressed: () => _pushAndRefresh(ctx, '/usuario/new'),
              child: const Icon(Icons.person_add),
            );
          }
          // En Clientes: alta directa de cliente
          if (index == 4) {
            return FloatingActionButton(
              onPressed: () => _pushAndRefresh(ctx, '/cliente/new'),
              child: const Icon(Icons.person_add_alt_1),
            );
          }
          return null;
        },
      ),
    );
  }
}

// ===== Helpers privados (pueden ir aquí en main.dart) =====

Future<void> _showAddSheet(BuildContext context) async {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (_) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Nuevo cliente'),
            onTap: () async {
              Navigator.pop(context);
              await _pushAndRefresh(context, '/cliente/new');
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2),
            title: const Text('Nuevo producto'),
            onTap: () async {
              Navigator.pop(context);
              await _pushAndRefresh(context, '/producto/new');
            },
          ),
          ListTile(
            leading: const Icon(Icons.group_add),
            title: const Text('Nuevo usuario'),
            onTap: () async {
              Navigator.pop(context);
              await _pushAndRefresh(context, '/usuario/new');
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

Future<void> _pushAndRefresh(BuildContext context, String route) async {
  final ok = await Navigator.pushNamed<bool>(context, route);
  if (ok == true && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Guardado correctamente')));
    // Si necesitás refrescar una lista, hacelo donde corresponda (list screen / provider / bloc).
  }
}
