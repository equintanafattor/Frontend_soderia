import 'package:frontend_soderia/core/net/api_client.dart';
import 'package:frontend_soderia/models/usuario.dart';

class UsuarioService {
  Future<List<Usuario>> obtenerUsuarios() async {
    final resp = await ApiClient.dio.get('/usuarios/');

    final List data = resp.data as List;
    return data
        .map((e) => Usuario.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Usuario> obtenerUsuarioPorId(int id) async {
    final resp = await ApiClient.dio.get('/usuarios/$id');

    return Usuario.fromJson(resp.data);
  }

  Future<Usuario> actualizarUsuario(Usuario u) async {
    final resp = await ApiClient.dio.put('/usuarios/${u.id}', data: u.toJson());

    return Usuario.fromJson(resp.data);
  }

  Future<void> crearUsuario({
    required String nombreUsuario,
    required String contrasena,
    int? legajoEmpleado,
    int? legajoCliente,
  }) async {
    await ApiClient.dio.post(
      '/usuarios/',
      data: {
        'nombre_usuario': nombreUsuario,
        'contrasena': contrasena,
        'legajo_empleado': legajoEmpleado,
        'legajo_cliente': legajoCliente,
      },
    );
  }
}
