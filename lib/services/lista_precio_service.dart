import 'package:dio/dio.dart';
import 'package:frontend_soderia/core/net/api_client.dart';

class ListaPrecioService {
  final Dio _dio = ApiClient.dio;

  Future<Map<String, dynamic>> obtenerLista(int idLista) async {
    try {
      final res = await _dio.get('/listas-precios/$idLista');
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw Exception(
        'Error obteniendo lista: ${e.response?.statusCode} ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<Map<String, dynamic>> actualizarLista({
    required int idLista,
    required String nombre,
    required String estado, // "activo" | "inactivo"
  }) async {
    try {
      final res = await _dio.put(
        '/listas-precios/$idLista',
        data: {'nombre': nombre, 'estado': estado},
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw Exception(
        'Error actualizando lista: ${e.response?.statusCode} ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<void> eliminarLista(int idLista) async {
    try {
      await _dio.delete('/listas-precios/$idLista');
    } on DioException catch (e) {
      throw Exception(
        'Error eliminando lista: ${e.response?.statusCode} ${e.response?.data ?? e.message}',
      );
    }
  }

  // =========================
  // Listas
  // =========================

  Future<List<dynamic>> listarListas({int limit = 50, int offset = 0}) async {
    try {
      final res = await _dio.get(
        '/listas-precios',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      return (res.data as List).cast<dynamic>();
    } on DioException catch (e) {
      throw Exception(
        'Error al listar listas: ${e.response?.statusCode} ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<Map<String, dynamic>> crearLista({
    required String nombre,
    required String estado,
  }) async {
    try {
      final res = await _dio.post(
        '/listas-precios/',
        data: {'nombre': nombre, 'estado': estado},
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw Exception(
        'Error al crear lista: ${e.response?.statusCode} ${e.response?.data ?? e.message}',
      );
    }
  }

  // =========================
  // Productos con precio
  // =========================

  Future<List<dynamic>> listarProductosConPrecio(int idLista) async {
    try {
      final res = await _dio.get('/listas-precios/$idLista/productos');
      return (res.data as List).cast<dynamic>();
    } on DioException catch (e) {
      throw Exception(
        'Error al listar productos de la lista: ${e.response?.statusCode} ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<void> upsertPrecio({
    required int idLista,
    required int idProducto,
    required double precio,
  }) async {
    try {
      await _dio.put(
        '/listas-precios/$idLista/precios/$idProducto',
        data: {
          'id_lista': idLista,
          'id_producto': idProducto,
          'precio': precio,
        },
      );
    } on DioException catch (e) {
      throw Exception(
        'Error al guardar precio: ${e.response?.statusCode} ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<List<dynamic>> listarPreciosDeLista(int idLista) async {
    try {
      final res = await _dio.get('/listas-precios/$idLista/precios');
      return (res.data as List).cast<dynamic>();
    } on DioException catch (e) {
      throw Exception(
        'Error al listar precios de lista: ${e.response?.statusCode} ${e.response?.data ?? e.message}',
      );
    }
  }

  // =========================
  // Ítems con precio (productos + combos)
  // =========================

  Future<List<dynamic>> listarItemsDeLista(int idLista) async {
    try {
      final res = await _dio.get('/listas-precios/$idLista/items');
      return (res.data as List).cast<dynamic>();
    } on DioException catch (e) {
      throw Exception(
        'Error al listar ítems de la lista: ${e.response?.statusCode} ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<List<dynamic>> listarCombosConPrecio(int idLista) async {
    try {
      final res = await _dio.get('/listas-precios/$idLista/combos');
      return (res.data as List).cast<dynamic>();
    } on DioException catch (e) {
      throw Exception(
        'Error al listar combos de la lista: ${e.response?.statusCode} ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<void> upsertPrecioCombo({
    required int idLista,
    required int idCombo,
    required double precio,
  }) async {
    try {
      await _dio.put(
        '/listas-precios/$idLista/precios-combos/$idCombo',
        data: {'precio': precio},
      );
    } on DioException catch (e) {
      throw Exception(
        'Error al guardar precio de combo: ${e.response?.statusCode} ${e.response?.data ?? e.message}',
      );
    }
  }

  // =========================
  // Servicios
  // =========================

  Future<List<dynamic>> listarServiciosConPrecio(int idLista) async {
    try {
      final res = await _dio.get(
        '/listas-precios/$idLista/precios-servicios',
        queryParameters: {'include_tipo': true},
      );
      return (res.data as List).cast<dynamic>();
    } on DioException catch (e) {
      throw Exception(
        'Error al listar servicios de la lista: ${e.response?.statusCode} ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<void> upsertPrecioServicio({
    required int idLista,
    required int idClienteServicio,
    required double precio,
  }) async {
    try {
      await _dio.put(
        '/listas-precios/$idLista/precios-servicios/$idClienteServicio',
        data: {'precio': precio},
      );
    } on DioException catch (e) {
      throw Exception(
        'Error al guardar precio de servicio: ${e.response?.statusCode} ${e.response?.data ?? e.message}',
      );
    }
  }
}
