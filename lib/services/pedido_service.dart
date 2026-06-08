import 'package:dio/dio.dart';
import 'package:frontend_soderia/core/net/api_client.dart';

class EnvaseMovimiento {
  final int idProducto;
  final int entregados;
  final int devueltos;
  final String? observacion;

  const EnvaseMovimiento({
    required this.idProducto,
    this.entregados = 0,
    this.devueltos = 0,
    this.observacion,
  });

  Map<String, dynamic> toJson() => {
    'id_producto': idProducto,
    'entregados': entregados,
    'devueltos': devueltos,
    if (observacion != null) 'observacion': observacion,
  };
}

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
      if (idRepartoDia != null) 'id_repartodia': idRepartoDia,
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
    List<EnvaseMovimiento> envases = const [],
  }) async {
    try {
      final res = await _dio.post(
        '/pedidos/$idPedido/confirmar',
        data: {
          'id_repartodia': idRepartoDia,
          if (envases.isNotEmpty)
            'envases': envases.map((e) => e.toJson()).toList(),
        },
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw Exception(
        'Error confirmando pedido: ${e.response?.statusCode} ${e.response?.data ?? e.message}',
      );
    }
  }
}
