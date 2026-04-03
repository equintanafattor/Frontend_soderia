import 'package:dio/dio.dart';

import '../../core/net/api_client.dart';
import 'package:frontend_soderia/models/direccion_cliente.dart';

class DireccionClienteService {
  final Dio _dio = ApiClient.dio;

  Future<List<DireccionCliente>> obtenerDirecciones(int legajo) async {
    final resp = await _dio.get('/clientes/$legajo/direcciones/');
    final data = resp.data as List<dynamic>;
    return data
        .map((e) => DireccionCliente.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Devuelve la dirección "principal" si existe, o la primera.
  Future<DireccionCliente?> obtenerDireccionPrincipal(int legajo) async {
    final direcciones = await obtenerDirecciones(legajo);
    if (direcciones.isEmpty) return null;

    // Si tenés un tipo 'Principal', lo priorizamos
    final principal = direcciones.where((d) {
      final t = d.tipo?.toLowerCase().trim();
      return t == 'principal' || t == 'p';
    });

    if (principal.isNotEmpty) {
      return principal.first;
    }

    return direcciones.first;
  }
}
