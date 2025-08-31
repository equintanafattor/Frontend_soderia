import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AuthService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://tu-api-gaston.api', //Reemplazar con la api real
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5)
  ));

  Future<bool> login(String usuario, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'usuario' : usuario,
          'password' : password,
        },
      );

      // Suponiendo que la API responde con un token
      if (response.statusCode == 200 && response.data['token'] != null) {
        // TODO: guardar token con shared_preferencies
        final token = response.data['token'];

        //Guardar token en local
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        return true;
      }

      return false;
    } catch (e) {
      // Podes loguearlo o mostrar un mensaje de error
      print('Error en login: $e');
      return false; 
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}