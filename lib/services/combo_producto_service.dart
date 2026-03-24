import 'package:dio/dio.dart';
import 'package:frontend_soderia/core/net/api_client.dart';

class ComboProductoService {
  final Dio _dio = ApiClient.dio;

  Future<List<dynamic>> listar(int idCombo) async {
    try {
      final res = await _dio.get('/combos/$idCombo');

      final data = Map<String, dynamic>.from(res.data as Map);
      return (data['productos'] ?? []) as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(
        'Error cargando productos del combo: ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<void> agregar({
    required int idCombo,
    required int idProducto,
    required int cantidad,
  }) async {
    try {
      await _dio.post(
        '/combos/$idCombo/productos',
        data: {'id_producto': idProducto, 'cantidad': cantidad},
      );
      // si el back devuelve 201, Dio igual lo toma como success
    } on DioException catch (e) {
      throw Exception(
        'Error agregando producto al combo: ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<void> actualizar({
    required int idCombo,
    required int idProducto,
    required int cantidad,
  }) async {
    try {
      await _dio.put(
        '/combos/$idCombo/productos/$idProducto',
        data: {'cantidad': cantidad},
      );
    } on DioException catch (e) {
      throw Exception(
        'Error actualizando cantidad: ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<void> eliminar({required int idCombo, required int idProducto}) async {
    try {
      await _dio.delete('/combos/$idCombo/productos/$idProducto');
      // 204 también cuenta como success
    } on DioException catch (e) {
      throw Exception(
        'Error eliminando producto del combo: ${e.response?.data ?? e.message}',
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

  Future<void> actualizarProductos({
    required int idCombo,
    required List<Map<String, dynamic>> productos,
  }) async {
    try {
      await _dio.put('/combos/$idCombo/productos', data: productos);
    } on DioException catch (e) {
      throw Exception(
        'Error actualizando productos del combo: ${e.response?.data ?? e.message}',
      );
    }
  }
}
