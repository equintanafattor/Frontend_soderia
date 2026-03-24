import 'package:dio/dio.dart';
import 'package:frontend_soderia/core/net/api_client.dart';

class ComboService {
  final Dio _dio = ApiClient.dio;

  Future<List<dynamic>> listar() async {
    try {
      final res = await _dio.get('/combos');
      return (res.data as List).cast<dynamic>();
    } on DioException catch (e) {
      throw Exception(
        'Error listando combos: ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<Map<String, dynamic>> obtener(int idCombo) async {
    try {
      final res = await _dio.get('/combos/$idCombo');
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw Exception(
        'Error obteniendo combo: ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<Map<String, dynamic>> crear({
    required String nombre,
    required bool estado,
  }) async {
    try {
      final res = await _dio.post(
        '/combos',
        data: {'nombre': nombre, 'estado': estado, 'id_empresa': 1},
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw Exception('Error creando combo: ${e.response?.data ?? e.message}');
    }
  }

  Future<Map<String, dynamic>> actualizar({
    required int idCombo,
    String? nombre,
    bool? estado,
    List<Map<String, dynamic>>? productos,
  }) async {
    final body = <String, dynamic>{};
    if (nombre != null) body['nombre'] = nombre;
    if (estado != null) body['estado'] = estado;
    if (productos != null) body['productos'] = productos;

    try {
      final res = await _dio.put('/combos/$idCombo', data: body);
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw Exception(
        'Error actualizando combo: ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<void> agregarProducto({
    required int idCombo,
    required int idProducto,
    required int cantidad,
  }) async {
    try {
      // ✅ ruta correcta (sin duplicar /combos)
      await _dio.post(
        '/combos/$idCombo/productos',
        data: {'id_producto': idProducto, 'cantidad': cantidad},
      );
    } on DioException catch (e) {
      throw Exception(
        'Error al agregar producto al combo: ${e.response?.data ?? e.message}',
      );
    }
  }
}
