import 'package:dio/dio.dart';
import 'package:frontend_soderia/core/net/api_client.dart';

class VisitaService {
  final Dio _dio = ApiClient.dio;

  Future<Map<String, dynamic>> crearVisita({
    required int legajo,
    required String estado,
    DateTime? fecha,
  }) async {
    try {
      final res = await _dio.post(
        '/visitas/$legajo',
        data: {
          'estado': estado,
          if (fecha != null) 'fecha': fecha.toIso8601String(),
        },
      );

      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw Exception(
        'Error ${e.response?.statusCode} al crear visita: ${e.response?.data ?? e.message}',
      );
    }
  }
}

class VisitaEstado {
  static const compra = 'cliente_compra';
  static const noCompra = 'cliente_no_compra';
  static const postergada = 'postergacion_cliente';
}
