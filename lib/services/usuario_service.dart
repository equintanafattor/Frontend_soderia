// services/usuario_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend_soderia/models/usuario.dart';

// Si tenés una clase Env o similar, reemplazá por eso
class UsuarioService {
  static const String _baseUrl = 'http://localhost:8500'; // adapta

  Future<List<Usuario>> obtenerUsuarios() async {
    final uri = Uri.parse('$_baseUrl/usuarios');
    final resp = await http.get(uri);

    if (resp.statusCode != 200) {
      throw Exception('Error al cargar usuarios (${resp.statusCode})');
    }

    final List<dynamic> jsonList = jsonDecode(resp.body) as List<dynamic>;
    return jsonList
        .map((e) => Usuario.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Usuario> obtenerUsuarioPorId(int id) async {
    final uri = Uri.parse('$_baseUrl/usuarios/$id');
    final resp = await http.get(uri);

    if (resp.statusCode != 200) {
      throw Exception('Error al cargar usuario (${resp.statusCode})');
    }

    final Map<String, dynamic> json = jsonDecode(resp.body);
    return Usuario.fromJson(json);
  }

  Future<Usuario> actualizarUsuario(Usuario u) async {
    final uri = Uri.parse('$_baseUrl/usuarios/${u.id}');
    final resp = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(u.toJson()),
    );

    if (resp.statusCode != 200) {
      throw Exception('Error al actualizar usuario (${resp.statusCode})');
    }

    final Map<String, dynamic> json = jsonDecode(resp.body);
    return Usuario.fromJson(json);
  }

  // Si más adelante querés usarlo desde UsuarioAddScreen:
  Future<void> crearUsuario({
    required String nombreUsuario,
    required String contrasena,
    int? legajoEmpleado,
    int? legajoCliente,
  }) async {
    final url = Uri.parse('$_baseUrl/usuarios');

    final body = {
      'nombre_usuario': nombreUsuario,
      'contrasena': contrasena,
      'legajo_empleado': legajoEmpleado,
      'legajo_cliente': legajoCliente,
    };

    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (resp.statusCode != 201) {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
  }
}
