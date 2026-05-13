import 'package:dio/dio.dart';

class RepartoApi {
  final Dio dio;

  RepartoApi(this.dio);

  Future<Response> obtenerRepartoPorFecha({
    required String fechaIso,
    int? idEmpresa,
    int? idUsuario,
  }) {
    return dio.get(
      '/repartos-dia/por-fecha',
      queryParameters: {
        'fecha': fechaIso,
        if (idEmpresa != null) 'id_empresa': idEmpresa,
        if (idUsuario != null) 'id_usuario': idUsuario,
      },
    );
  }

  Future<Response> obtenerAgendaPorFecha({
    required String fechaIso,
    String? turno,
  }) {
    return dio.get(
      '/clientes/agenda/visitas',
      queryParameters: {
        'fecha': fechaIso,
        if (turno != null && turno.isNotEmpty) 'turno': turno,
      },
    );
  }

  Future<Response> obtenerDetalleCliente(int legajo) {
    return dio.get('/clientes/$legajo/detalle');
  }
}