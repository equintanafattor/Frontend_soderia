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
import 'package:frontend_soderia/core/navigation/destinations.dart';
import 'package:frontend_soderia/screens/venta_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/theme.dart';
import 'core/navigation/app_shell.dart';
import 'core/navigation/app_shell_actions.dart';
import 'screens/home_screen.dart';
import 'screens/todos_screen.dart';
import 'screens/calendario_screen.dart';

// Altas
import 'screens/clientes/cliente_add_screen.dart';
import 'screens/productos/producto_add_screen.dart';
import 'screens/usuarios/usuario_add_screen.dart';

// Listar
import 'screens/usuarios/usuarios_list_screen.dart';
import 'screens/clientes/clientes_list_screen.dart';
import 'screens/clientes/cliente_detail_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_AR', null);
  await dotenv.load(fileName: ".env");
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

      routes: {
        '/cliente/new': (_) => const ClienteAddScreen(),
        '/producto/new': (_) => const ProductoAddScreen(),
        '/usuario/new': (_) => const UsuarioAddScreen(),

        // DETALLE DE CLIENTE BLINDADO
        '/cliente/detail': (ctx) {
          final args = ModalRoute.of(ctx)!.settings.arguments;
          if (args is int) {
            return ClienteDetailScreen(legajo: args);
          }
          // si vino sin legajo, mostramos algo visible y NO rompemos
          return const Scaffold(
            body: Center(child: Text('Falta el legajo del cliente')),
          );
        },

        // VENTA BLINDADA
        '/venta': (ctx) {
          final args = ModalRoute.of(ctx)!.settings.arguments;
          if (args is Map && args['legajo'] is int) {
            return VentaScreen(legajoCliente: args['legajo'] as int);
          }
          return const Scaffold(
            body: Center(
              child: Text('Falta el legajo del cliente para abrir la venta'),
            ),
          );
        },
      },

      home: AppShell(
        initialIndex: 0,
        pagesBuilder: (select) => [
          HomeScreen(nombreUsuario: 'Gastón', onRequestTab: select),
          const TodosScreen(nombreUsuario: 'Gastón'),
          const Placeholder(),
          const UsuariosListScreen(),
          const ClientesListScreen(),
          const CalendarioScreen(),
        ],
        titleBuilder: (index, dest) => index == 0 ? '' : dest.label,
        fabBuilder: (ctx, index) {
          if (index == kIndexInicio) {
            return FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('Agregar'),
              onPressed: () => AppShellActions.showAddSheet(ctx),
            );
          }
          if (index == kIndexUsuarios) {
            return FloatingActionButton(
              onPressed: () => AppShellActions.push(ctx, '/usuario/new'),
              child: const Icon(Icons.person_add),
            );
          }
          if (index == kIndexClientes) {
            return FloatingActionButton(
              onPressed: () => AppShellActions.push(ctx, '/cliente/new'),
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
  final res = await Navigator.pushNamed(context, route);
  if (res == true && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Guardado correctamente')));
    // Si necesitás refrescar una lista, hacelo donde corresponda (list screen / provider / bloc).
  }
}
