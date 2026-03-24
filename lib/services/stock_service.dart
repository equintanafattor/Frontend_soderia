// lib/services/stock_service.dart
import 'package:dio/dio.dart';
import 'package:frontend_soderia/core/net/api_client.dart';
import 'package:frontend_soderia/models/stock_detalle.dart';
import 'package:frontend_soderia/models/movimiento_stock.dart';

class StockService {
  final Dio _dio = ApiClient.dio;

  // ---------------------------
  // GET /stock/detalle
  // ---------------------------
  Future<List<StockDetalle>> getStockDetalle({required int idEmpresa}) async {
    try {
      final res = await _dio.get(
        '/stock/detalle',
        queryParameters: {'id_empresa': idEmpresa},
      );

      final list = (res.data as List)
          .map(
            (e) => StockDetalle.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();

      return list;
    } on DioException catch (e) {
      throw Exception(
        'Error cargando stock: ${e.response?.statusCode} ${e.response?.data ?? e.message}',
      );
    }
  }

  // ---------------------------
  // POST /movimientos-stock
  // ---------------------------
  Future<void> ajustarStock({
    required int idProducto,
    required String tipoMovimiento, // ingreso | egreso | ajuste
    required int cantidad,
    String? observacion,
  }) async {
    try {
      await _dio.post(
        '/movimientos-stock',
        data: {
          'id_producto': idProducto,
          'tipo_movimiento': tipoMovimiento,
          'cantidad': cantidad,
          if (observacion != null) 'observacion': observacion,
        },
      );
    } on DioException catch (e) {
      throw Exception(
        'Error ajustando stock (${e.response?.statusCode}): ${e.response?.data ?? e.message}',
      );
    }
  }

  // ---------------------------
  // GET /movimientos-stock
  // ---------------------------
  Future<List<MovimientoStock>> getMovimientos({
    required int idProducto,
    int limit = 50,
  }) async {
    try {
      final res = await _dio.get(
        '/movimientos-stock',
        queryParameters: {'id_producto': idProducto, 'limit': limit},
      );

      final list = (res.data as List)
          .map(
            (e) =>
                MovimientoStock.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();

      return list;
    } on DioException catch (e) {
      throw Exception(
        'Error cargando movimientos (${e.response?.statusCode}): ${e.response?.data ?? e.message}',
      );
    }
  }
}
