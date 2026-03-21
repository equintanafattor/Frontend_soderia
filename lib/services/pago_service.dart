import 'package:dio/dio.dart';
import 'package:frontend_soderia/core/net/api_client.dart';

class PagoService {
  final Dio _dio = ApiClient.dio;

  Future<Map<String, dynamic>> crearPagoLibre({
    required int legajo,
    required int idEmpresa,
    required int idMedioPago,
    int? idCuenta,
    required double monto,
    String? observacion,
    int? idRepartoDia,
  }) async {
    try {
      final res = await _dio.post(
        '/pagos/libre',
        data: {
          'legajo': legajo,
          'id_empresa': idEmpresa,
          'id_medio_pago': idMedioPago,
          'monto': monto,
          if (idCuenta != null) 'id_cuenta': idCuenta,
          if (observacion != null) 'observacion': observacion,
          if (idRepartoDia != null) 'id_repartodia': idRepartoDia,
        },
      );

      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw Exception(
        'Error registrando pago: ${e.response?.data ?? e.message}',
      );
    }
  }
}
