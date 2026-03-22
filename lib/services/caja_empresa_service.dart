import 'package:dio/dio.dart';
import 'package:frontend_soderia/core/net/api_client.dart';
import 'package:frontend_soderia/models/caja_empresa_movimiento_out.dart';
import 'package:frontend_soderia/models/caja_empresa_total_out.dart';
import 'package:frontend_soderia/models/pago_egreso_create.dart';
import 'package:frontend_soderia/models/pago_ingreso_create.dart';
import 'package:frontend_soderia/models/pago_out.dart';

class CajaEmpresaService {
  final Dio _dio = ApiClient.dio;

  Future<CajaEmpresaTotalOut> getTotalPorRango({
    required DateTime desde,
    required DateTime hasta,
    int? idEmpresa,
  }) async {
    final desdeStr = desde.toIso8601String().split('T').first;
    final hastaStr = hasta.toIso8601String().split('T').first;

    try {
      final resp = await _dio.get(
        '/caja-empresa/total-por-rango',
        queryParameters: {
          'fecha_desde': desdeStr,
          'fecha_hasta': hastaStr,
          if (idEmpresa != null) 'id_empresa': idEmpresa,
        },
      );

      return CajaEmpresaTotalOut.fromJson(
        Map<String, dynamic>.from(resp.data as Map),
      );
    } on DioException catch (e) {
      throw Exception(
        'Error total por rango (${e.response?.statusCode}): ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<(List<CajaEmpresaMovimientoOut>, int)> getMovimientosPorRango({
    required DateTime desde,
    required DateTime hasta,
    int? idEmpresa,
    int limit = 200,
    int offset = 0,
  }) async {
    final desdeStr = desde.toIso8601String().split('T').first;
    final hastaStr = hasta.toIso8601String().split('T').first;

    try {
      final resp = await _dio.get(
        '/caja-empresa/movimientos',
        queryParameters: {
          'fecha_desde': desdeStr,
          'fecha_hasta': hastaStr,
          'limit': limit,
          'offset': offset,
          if (idEmpresa != null) 'id_empresa': idEmpresa,
        },
      );

      final data = Map<String, dynamic>.from(resp.data as Map);
      final total = (data['total'] as num).toInt();

      final items = (data['items'] as List)
          .map(
            (e) =>
                CajaEmpresaMovimientoOut.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();

      return (items, total);
    } on DioException catch (e) {
      throw Exception(
        'Error movimientos (${e.response?.statusCode}): ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<CajaEmpresaTotalOut> getTotalPorFecha({
    required DateTime fecha,
    int? idEmpresa,
  }) async {
    final fechaStr = fecha.toIso8601String().split('T').first;

    try {
      final resp = await _dio.get(
        '/caja-empresa/total-por-fecha',
        queryParameters: {
          'fecha': fechaStr,
          if (idEmpresa != null) 'id_empresa': idEmpresa,
        },
      );

      return CajaEmpresaTotalOut.fromJson(
        Map<String, dynamic>.from(resp.data as Map),
      );
    } on DioException catch (e) {
      throw Exception(
        'Error total por fecha (${e.response?.statusCode}): ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<PagoOut> crearIngreso(PagoIngresoCreate payload) async {
    try {
      final resp = await _dio.post('/pagos/ingreso', data: payload.toJson());

      return PagoOut.fromJson(Map<String, dynamic>.from(resp.data as Map));
    } on DioException catch (e) {
      throw Exception(
        'Error creando ingreso (${e.response?.statusCode}): ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<PagoOut> crearEgreso(PagoEgresoCreate payload) async {
    try {
      final resp = await _dio.post('/pagos/egreso', data: payload.toJson());

      return PagoOut.fromJson(Map<String, dynamic>.from(resp.data as Map));
    } on DioException catch (e) {
      throw Exception(
        'Error creando egreso (${e.response?.statusCode}): ${e.response?.data ?? e.message}',
      );
    }
  }
}
