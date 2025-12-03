import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 🔧 mientras uses el backend real, poné esto en false
const bool kFakeAuth = false;

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8500', // mismo host/puerto que el back
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  Future<bool> login(String usuario, String password) async {
    // === MODO FAKE (si querés seguir sin backend) ===
    if (kFakeAuth) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', 'FAKE_TOKEN_DEV');
      await prefs.setString('username', usuario.isNotEmpty ? usuario : 'DevUser');
      await prefs.setInt('user_id', 0);
      return true;
    }

    // === MODO REAL: usa tu endpoint /auth/login de FastAPI ===
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          // OJO: estos nombres deben coincidir con LoginRequest
          'nombre_usuario': usuario,
          'contrasena': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // nombres que devuelve tu LoginResponse de FastAPI
        final token = data['access_token'] as String?;
        final nombreBackend = data['nombre_usuario'] as String?;
        final idUsuario = data['id_usuario'];

        if (token == null) return false;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('username', nombreBackend ?? usuario);
        if (idUsuario is int) {
          await prefs.setInt('user_id', idUsuario);
        }

        return true;
      }

      return false;
    } catch (e) {
      // Podés loguear esto en consola
      print('Error en login: $e');
      return false;
    }
  }

  Future<String?> getToken() async {
    if (kFakeAuth) return 'FAKE_TOKEN_DEV';

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<String?> getSavedUsuario() async {
    if (kFakeAuth) return 'DevUser';

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('username');
    await prefs.remove('user_id');
  }
}
