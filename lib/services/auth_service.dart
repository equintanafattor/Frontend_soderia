import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/net/api_client.dart';

const bool kFakeAuth = false;

class AuthService {
  final Dio _dio = ApiClient.dio;

  Future<bool> login(String usuario, String password) async {
    if (kFakeAuth) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', 'FAKE_TOKEN_DEV');
      await prefs.setString(
        'username',
        usuario.isNotEmpty ? usuario : 'DevUser',
      );
      await prefs.setInt('user_id', 0);
      return true;
    }

    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'nombre_usuario': usuario, 'contrasena': password},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode != 200) return false;

      dynamic body = response.data;
      if (body is String) body = jsonDecode(body);

      if (body is! Map<String, dynamic>) {
        print('Login: respuesta inesperada: ${response.data}');
        return false;
      }

      final token = body['access_token'] as String?;
      final nombreBackend = body['nombre_usuario'] as String?;
      final idUsuario = body['id_usuario'];

      if (token == null || token.isEmpty) {
        print('Login: access_token ausente o vacío.');
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('username', nombreBackend ?? usuario);

      if (idUsuario is int) {
        await prefs.setInt('user_id', idUsuario);
      } else {
        await prefs.remove('user_id');
      }

      print('Login OK. Token guardado (len=${token.length}).');
      return true;
    } on DioException catch (e) {
      print('Login DioException: ${e.response?.statusCode}');
      print('REQ: ${e.requestOptions.method} ${e.requestOptions.uri}');
      print('SENT: ${e.requestOptions.data}');
      print('DATA: ${e.response?.data}');
      return false;
    } catch (e) {
      print('Error en login: $e');
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('username');
    await prefs.remove('user_id');
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
}
