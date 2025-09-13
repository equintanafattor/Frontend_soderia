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
      home: AppShell(
        initialIndex: 0,
        pagesBuilder: (select) => [
          HomeScreen(nombreUsuario: 'Gastón', onRequestTab: select),
          const TodosScreen(nombreUsuario: 'Gastón'),
          const Placeholder(), // Reportes
          const Placeholder(), // Usuarios
          const Placeholder(), // Clientes
        ],
        // 👇 Aquí controlamos qué título muestra el AppBar
        titleBuilder: (index, dest) {
          if (index == 0) return ''; // Home → sin título
          return dest.label; // resto → usa el label de kDestinations
        },
      ),
    );
  }
}
