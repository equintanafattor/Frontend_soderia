import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:frontend_soderia/core/navigation/destinations.dart';
import 'package:frontend_soderia/core/navigation/app_shell.dart';
import 'package:frontend_soderia/core/navigation/app_shell_actions.dart';
import 'package:frontend_soderia/core/theme.dart';

// Screens
import 'package:frontend_soderia/screens/splash_screen.dart';
import 'package:frontend_soderia/screens/login_screen.dart';
import 'package:frontend_soderia/screens/home_screen.dart';
import 'package:frontend_soderia/screens/todos_screen.dart';
import 'package:frontend_soderia/screens/calendario_screen.dart';
import 'package:frontend_soderia/screens/venta_screen.dart';

// Altas
import 'package:frontend_soderia/screens/clientes/cliente_add_screen.dart';
import 'package:frontend_soderia/screens/productos/producto_add_screen.dart';
import 'package:frontend_soderia/screens/usuarios/usuario_add_screen.dart';

// Listar / detalle / edición
import 'package:frontend_soderia/screens/usuarios/usuarios_list_screen.dart';
import 'package:frontend_soderia/screens/clientes/clientes_list_screen.dart';
import 'package:frontend_soderia/screens/clientes/cliente_detail_screen.dart';
import 'package:frontend_soderia/screens/clientes/cliente_edit_screen.dart';

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
        // === Auth / navegación principal ===
        '/login': (_) => const LoginScreen(),

        '/app': (ctx) {
          final args = ModalRoute.of(ctx)!.settings.arguments;
          final nombreUsuario = (args is String && args.isNotEmpty)
              ? args
              : 'Usuario';

          return _buildAppShell(nombreUsuario);
        },

        // === Altas ===
        '/cliente/new': (_) => const ClienteAddScreen(),
        '/producto/new': (_) => const ProductoAddScreen(),
        '/usuario/new': (_) => const UsuarioAddScreen(),

        // === Detalle de cliente (blindado) ===
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

        // === Venta (blindada) ===
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

        // === Edición de cliente (blindada) ===
        '/cliente/edit': (ctx) {
          final args = ModalRoute.of(ctx)!.settings.arguments;

          if (args is Map &&
              args['legajo'] is int &&
              args['data'] is Map<String, dynamic>) {
            return ClienteEditScreen(
              legajo: args['legajo'] as int,
              data: args['data'] as Map<String, dynamic>,
            );
          }

          // fallback si viene mal llamado
          return const Scaffold(
            body: Center(child: Text('Faltan datos para editar el cliente')),
          );
        },
      },

      // 👇 El Splash decide si te manda a /login o /app
      home: const SplashScreen(),
    );
  }
}

/// Helper para armar el AppShell con el nombre de usuario
AppShell _buildAppShell(String usuario) {
  return AppShell(
    initialIndex: kIndexInicio, // si kIndexInicio es 0, da lo mismo que 0
    pagesBuilder: (select) => [
      HomeScreen(
        nombreUsuario: usuario,
        onRequestTab: select, // 👈 Home puede pedir cambiar de tab
      ),
      TodosScreen(
        nombreUsuario: usuario,
        onRequestTab: select, // 👈 TodosScreen también
      ),
      const Placeholder(),
      const UsuariosListScreen(),
      const ClientesListScreen(),
      CalendarioScreen(
        nombreUsuario: usuario,
        // si algún día querés, también podés pasar onRequestTab acá
        // onRequestTab: select,
      ),
    ],
    titleBuilder: (index, dest) => index == kIndexInicio ? '' : dest.label,
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
  );
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
    // Si necesitás refrescar una lista, hacelo donde corresponda.
  }
}
