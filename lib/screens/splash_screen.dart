import 'package:flutter/material.dart';
import 'package:frontend_soderia/screens/home_screen.dart';
import 'package:frontend_soderia/screens/login_screen.dart';
import 'package:frontend_soderia/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Pequeño delay para que el splash no parpadee
    Future<void>(() async {
      await Future.delayed(const Duration(milliseconds: 450));
      await _checkToken();
    });
  }

  Future<void> _checkToken() async {
    try {
      final token = await AuthService().getToken();

      if (!mounted) return;

      if (token != null && token.isNotEmpty) {
        // ✅ Token presente → ir al Home
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const HomeScreen(nombreUsuario: 'Usuario'),
          ),
        );
      } else {
        // ❌ Sin token → ir al Login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      // En caso de error leyendo prefs, enviar a Login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo / nombre de la app
            Text(
              'Sodería',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: cs.onBackground,
              ),
            ),
            const SizedBox(height: 16),
            CircularProgressIndicator(color: cs.primary),
          ],
        ),
      ),
    );
  }
}
