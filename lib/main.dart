import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_soderia/screens/combos/combo_form_screen.dart';
import 'package:frontend_soderia/screens/combos/combo_precio_screen.dart';
import 'package:frontend_soderia/screens/combos/combo_productos_screen.dart';
import 'package:frontend_soderia/screens/combos/combos_list_screen.dart';
import 'package:frontend_soderia/screens/listas_precios/lista_precio_detail_screen.dart';
import 'package:frontend_soderia/screens/pago_libre_screen.dart';
import 'package:frontend_soderia/screens/reportes/reporte_screen.dart';
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
import 'package:frontend_soderia/screens/stock/stock_list_screen.dart';

// Altas
import 'package:frontend_soderia/screens/clientes/cliente_add_screen.dart';
import 'package:frontend_soderia/screens/productos/producto_add_screen.dart';
import 'package:frontend_soderia/screens/usuarios/usuario_add_screen.dart';
import 'package:frontend_soderia/screens/clientes/cuenta/cliente_cuenta_add_screen.dart';

// Listar / detalle / edición
import 'package:frontend_soderia/screens/usuarios/usuarios_list_screen.dart';
import 'package:frontend_soderia/screens/clientes/clientes_list_screen.dart';
import 'package:frontend_soderia/screens/clientes/cliente_detail_screen.dart';
import 'package:frontend_soderia/screens/clientes/cliente_edit_screen.dart';
import 'package:frontend_soderia/screens/listas_precios/listas_precios_list_screen.dart';
import 'package:frontend_soderia/screens/listas_precios/lista_precio_form_screen.dart';

// 👇 NUEVO: listado de productos
import 'package:frontend_soderia/screens/productos/productos_list_screen.dart';

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
        '/cliente/cuenta/new': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;

          return ClienteCuentaAddScreen(legajo: args['legajo'] as int);
        },

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

        // === Listas de precios ===
        '/listas-precios': (_) => const ListasPreciosListScreen(),

        '/listas-precios/new': (_) => const ListaPrecioFormScreen(),

        '/listas-precios/detail': (ctx) {
          final args = ModalRoute.of(ctx)!.settings.arguments;

          if (args is Map && args['id'] is int && args['nombre'] is String) {
            return ListaPrecioDetailScreen(
              idLista: args['id'] as int,
              nombreLista: args['nombre'] as String,
            );
          }

          return const Scaffold(
            body: Center(child: Text('Faltan datos de la lista')),
          );
        },

        '/listas-precios/combos-precios': (ctx) {
          final args = ModalRoute.of(ctx)!.settings.arguments;

          if (args is Map &&
              args['idLista'] is int &&
              args['nombreLista'] is String) {
            return ComboPrecioScreen(
              idLista: args['idLista'] as int,
              nombreLista: args['nombreLista'] as String,
            );
          }

          return const Scaffold(
            body: Center(child: Text('Faltan datos de la lista de precios')),
          );
        },

        // === Combos ===
        '/combos': (_) => const CombosListScreen(),

        '/combos/new': (_) => const ComboFormScreen(),

        '/combos/edit': (ctx) {
          final args = ModalRoute.of(ctx)!.settings.arguments;
          if (args is int) {
            return ComboFormScreen(idCombo: args);
          }
          return const Scaffold(
            body: Center(child: Text('Falta id del combo')),
          );
        },

        '/combos/productos': (ctx) {
          final args = ModalRoute.of(ctx)!.settings.arguments;
          if (args is Map &&
              args['idCombo'] is int &&
              args['nombre'] is String) {
            return ComboProductosScreen(
              idCombo: args['idCombo'],
              nombreCombo: args['nombre'],
            );
          }
          return const Scaffold(
            body: Center(child: Text('Faltan datos del combo')),
          );
        },

        // === PagoLibre ===
        '/pago': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;

          final int? idCuenta = (args['id_cuenta'] as num?)?.toInt();
          final int? idRepartoDia = (args['id_repartodia'] as num?)?.toInt();
          final List<dynamic> cuentas =
              (args['cuentas'] as List?)?.cast<dynamic>() ?? const [];

          return PagoLibreScreen(
            legajo: args['legajo'] as int,
            idEmpresa: args['id_empresa'] as int,
            deuda: (args['deuda'] as num).toDouble(),
            saldo: (args['saldo'] as num).toDouble(),
            idRepartoDia: idRepartoDia,
            idCuenta: idCuenta,
            cuentas: cuentas, // 👈 si agregaste este parámetro
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
    initialIndex: kIndexInicio,

    /// Importante: el orden de estas páginas debe matchear EXACTO
    /// con el orden de `kDestinations`:
    /// 0 Inicio
    /// 1 Tareas
    /// 2 Reportes
    /// 3 Usuarios
    /// 4 Clientes
    /// 5 Productos
    /// 6 Calendario
    pagesBuilder: (select) => [
      HomeScreen(nombreUsuario: usuario, onRequestTab: select), // 0
      TodosScreen(nombreUsuario: usuario, onRequestTab: select), // 1
      const ReportesScreen(), // 2
      const UsuariosListScreen(), // 3
      const ClientesListScreen(), // 4
      const ProductosListScreen(), // 5
      const StockListScreen(), // 6
      CalendarioScreen(nombreUsuario: usuario), // 7
    ],

    titleBuilder: (index, dest) => index == kIndexInicio ? ' ' : dest.label,

    fabBuilder: (ctx, index) {
      // FAB de Inicio: bottom sheet con altas (usa AppShellActions)
      if (index == kIndexInicio) {
        return FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text('Agregar'),
          onPressed: () => AppShellActions.showAddSheet(ctx),
        );
      }

      // FAB Usuarios
      if (index == kIndexUsuarios) {
        return FloatingActionButton(
          onPressed: () => AppShellActions.push(ctx, '/usuario/new'),
          child: const Icon(Icons.person_add),
        );
      }

      // FAB Clientes
      if (index == kIndexClientes) {
        return FloatingActionButton(
          onPressed: () => AppShellActions.push(ctx, '/cliente/new'),
          child: const Icon(Icons.person_add_alt_1),
        );
      }

      // FAB Productos
      if (index == kIndexProductos) {
        return FloatingActionButton(
          onPressed: () => AppShellActions.push(ctx, '/producto/new'),
          child: const Icon(Icons.inventory_2),
        );
      }

      // FAB Stock → ninguno
      if (index == kIndexStock) {
        return null;
      }

      return null;
    },
  );
}

// ===== Helpers privados ANTES definidos =====
// Estos dos helpers NO se usan en este archivo:
// - _showAddSheet
// - _pushAndRefresh
//
// Podés borrarlos tranquilamente si ya estás usando
// AppShellActions.showAddSheet y AppShellActions.push en todos lados.
