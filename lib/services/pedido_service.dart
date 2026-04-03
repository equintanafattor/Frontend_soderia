import 'package:dio/dio.dart';
import 'package:frontend_soderia/core/net/api_client.dart';

class PedidoService {
  final Dio _dio = ApiClient.dio;

  Future<Map<String, dynamic>> crearPedido({
    required int legajo,
    required int idMedioPago,
    required DateTime fecha,
    required double montoTotal,
    required double montoAbonado,
    required int idEmpresa,
    required List<Map<String, dynamic>> items,
    int? idRepartoDia,
    String? observacion,
    int? idCuenta,
  }) async {
    final body = <String, dynamic>{
      'legajo': legajo,
      'id_medio_pago': idMedioPago,
      'id_empresa': idEmpresa,
      'fecha': fecha.toIso8601String(),
      'monto_total': montoTotal,
      'monto_abonado': montoAbonado,
      'items': items,
      if (idCuenta != null) 'id_cuenta': idCuenta,
      if (observacion != null && observacion.trim().isNotEmpty)
        'observacion': observacion.trim(),
    };

    try {
      final res = await _dio.post('/pedidos/', data: body);
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw Exception(
        'Error al crear pedido: ${e.response?.statusCode} ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<Map<String, dynamic>> confirmarPedido({
    required int idPedido,
    required int idRepartoDia,
  }) async {
    try {
      final res = await _dio.post(
        '/pedidos/$idPedido/confirmar',
        data: {'id_repartodia': idRepartoDia},
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw Exception(
        'Error confirmando pedido: ${e.response?.statusCode} ${e.response?.data ?? e.message}',
      );
    }
  }
}
