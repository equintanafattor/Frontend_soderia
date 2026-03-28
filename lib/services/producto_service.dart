// lib/services/producto_service.dart
import 'package:dio/dio.dart';
import 'package:frontend_soderia/core/net/api_client.dart';
import 'package:frontend_soderia/models/producto.dart';

class ProductoService {
  final Dio _dio = ApiClient.dio;

  Future<List<Producto>> listar({int limit = 50, int offset = 0}) async {
    try {
      final resp = await _dio.get(
        '/productos/',
        queryParameters: {'limit': limit, 'offset': offset},
      );

      final list = (resp.data as List)
          .map((e) => Producto.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      return list;
    } on DioException catch (e) {
      throw Exception(
        'Error al listar productos: ${e.response?.statusCode} ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<Producto> crear({
    required String nombre,
    bool? estado,
    double? litros,
    String? tipoDispenser,
    String? observacion,
    bool descuentaStock = true,
  }) async {
    try {
      final resp = await _dio.post(
        '/productos/',
        data: {
          'nombre': nombre,
          'estado': estado,
          'litros': litros,
          'tipo_dispenser': tipoDispenser,
          'observacion': observacion,
          'descuenta_stock': descuentaStock,
        },
      );

      return Producto.fromJson(Map<String, dynamic>.from(resp.data as Map));
    } on DioException catch (e) {
      throw Exception(
        'Error al crear producto: ${e.response?.statusCode} ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<Producto> actualizar(
    int idProducto, {
    String? nombre,
    bool? estado,
    double? litros,
    String? tipoDispenser,
    String? observacion,
    bool? descuentaStock,
  }) async {
    final body = <String, dynamic>{};
    if (nombre != null) body['nombre'] = nombre;
    if (estado != null) body['estado'] = estado;
    if (litros != null) body['litros'] = litros;
    if (tipoDispenser != null) body['tipo_dispenser'] = tipoDispenser;
    if (observacion != null) body['observacion'] = observacion;
    if (descuentaStock != null) body['descuenta_stock'] = descuentaStock;

    try {
      final resp = await _dio.put('/productos/$idProducto', data: body);
      return Producto.fromJson(Map<String, dynamic>.from(resp.data as Map));
    } on DioException catch (e) {
      throw Exception(
        'Error al actualizar producto: ${e.response?.statusCode} ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<void> borrar(int idProducto) async {
    try {
      await _dio.delete('/productos/$idProducto');
    } on DioException catch (e) {
      throw Exception(
        'Error al borrar producto: ${e.response?.statusCode} ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<List<dynamic>> listarProductosDeLista(int idLista) async {
    try {
      final resp = await _dio.get('/listas-precios/$idLista/productos');
      return (resp.data as List).cast<dynamic>();
    } on DioException catch (e) {
      throw Exception(
        'Error listando productos de lista: ${e.response?.statusCode} ${e.response?.data ?? e.message}',
      );
    }
  }
}
