import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 👇 cambiar a false cuando el backend de auth esté listo
const bool kFakeAuth = true;

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8500', // Reemplazar con la API real si cambia
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  Future<bool> login(String usuario, String password) async {
    // 👇 MODO FAKE: no pegamos al backend, dejamos pasar siempre
    if (kFakeAuth) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', 'FAKE_TOKEN_DEV');
      await prefs.setString(
        'username',
        (usuario.isNotEmpty ? usuario : 'DevUser'),
      );
      return true;
    }

    // 👇 MODO REAL (cuando tengas el endpoint listo)
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'usuario': usuario, 'password': password},
      );

      if (response.statusCode == 200 && response.data['token'] != null) {
        final token = response.data['token'] as String;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('username', usuario);

        return true;
      }

      return false;
    } catch (e) {
      print('Error en login: $e');
      return false;
    }
  }

  Future<String?> getToken() async {
    if (kFakeAuth) {
      // Podrías hasta devolver null al principio si querés obligar a pasar por Login.
      return 'FAKE_TOKEN_DEV';
    }

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<String?> getSavedUsuario() async {
    if (kFakeAuth) {
      return 'DevUser';
    }

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

    Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('username');
  }

}
