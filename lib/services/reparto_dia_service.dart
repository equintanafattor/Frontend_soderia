import 'package:dio/dio.dart';
import 'package:frontend_soderia/core/net/api_client.dart';
import 'package:frontend_soderia/models/reparto_dia_out.dart';

class RepartoDiaService {
  final Dio _dio = ApiClient.dio;

  /// Si todavía lo necesitás “crudo”
  Future<Map<String, dynamic>> obtenerPorFecha({
    required DateTime fecha,
    required int idEmpresa,
    int? idUsuario,
  }) async {
    final fechaStr = fecha.toIso8601String().split('T').first;

    try {
      final resp = await _dio.get(
        '/repartos-dia/por-fecha',
        queryParameters: {
          'fecha': fechaStr,
          'id_empresa': idEmpresa,
          if (idUsuario != null) 'id_usuario': idUsuario,
        },
      );

      return Map<String, dynamic>.from(resp.data as Map);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('No hay reparto del día para $fechaStr');
      }
      throw Exception(
        'Error obteniendo reparto del día: ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<RepartoDiaOut?> getByFecha({
    required DateTime fecha,
    int? idEmpresa,
    int? idUsuario,
  }) async {
    final fechaStr = fecha.toIso8601String().split('T').first;

    try {
      final resp = await _dio.get(
        '/repartos-dia/por-fecha',
        queryParameters: {
          'fecha': fechaStr,
          if (idEmpresa != null) 'id_empresa': idEmpresa,
          if (idUsuario != null) 'id_usuario': idUsuario,
        },
      );

      final data = Map<String, dynamic>.from(resp.data as Map);
      return RepartoDiaOut.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw Exception(
        'Error al obtener reparto (${e.response?.statusCode}): ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<List<RepartoDiaOut>> getPorRango({
    required DateTime desde,
    required DateTime hasta,
    int? idEmpresa,
    int? idUsuario,
  }) async {
    final desdeStr = desde.toIso8601String().split('T').first;
    final hastaStr = hasta.toIso8601String().split('T').first;

    try {
      final resp = await _dio.get(
        '/repartos-dia/por-rango',
        queryParameters: {
          'fecha_desde': desdeStr,
          'fecha_hasta': hastaStr,
          if (idEmpresa != null) 'id_empresa': idEmpresa,
          if (idUsuario != null) 'id_usuario': idUsuario,
        },
      );

      final list = (resp.data as List)
          .map((e) => RepartoDiaOut.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      return list;
    } on DioException catch (e) {
      throw Exception(
        'Error listando repartos (${e.response?.statusCode}): ${e.response?.data ?? e.message}',
      );
    }
  }
}