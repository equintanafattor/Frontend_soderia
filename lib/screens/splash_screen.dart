// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:frontend_soderia/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _authService = AuthService();

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
      final token = await _authService.getToken();
      final usuario = await _authService.getSavedUsuario();

      if (!mounted) return;

      if (token != null && token.isNotEmpty) {
        // ✅ Token presente → ir a la app principal (AppShell)
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/app',
          (route) => false,
          arguments: usuario ?? 'Usuario',
        );
      } else {
        // ❌ Sin token → ir al Login
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      // En caso de error leyendo prefs, enviar a Login
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
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
