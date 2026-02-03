import 'package:dio/dio.dart';
import '../../core/net/api_client.dart';


class ClienteServicioPeriodoDto {
  final int idPeriodo;
  final int idClienteServicio;
  final DateTime periodo;
  final double monto;
  final String estado; // PENDIENTE / VENCIDO / PAGADO
  final DateTime fechaVencimiento;
  final DateTime? fechaPago;

  ClienteServicioPeriodoDto({
    required this.idPeriodo,
    required this.idClienteServicio,
    required this.periodo,
    required this.monto,
    required this.estado,
    required this.fechaVencimiento,
    this.fechaPago,
  });

  factory ClienteServicioPeriodoDto.fromJson(Map<String, dynamic> json) {
    return ClienteServicioPeriodoDto(
      idPeriodo: json['id_periodo'] as int,
      idClienteServicio: json['id_cliente_servicio'] as int,
      periodo: DateTime.parse(json['periodo']),
      monto: double.parse(json['monto'].toString()),
      estado: (json['estado'] ?? '').toString(),
      fechaVencimiento: DateTime.parse(json['fecha_vencimiento']),
      fechaPago:
          json['fecha_pago'] == null ? null : DateTime.parse(json['fecha_pago']),
    );
  }
}

class ServiciosService {
  final Dio _dio = ApiClient.dio;

  Future<List<ClienteServicioPeriodoDto>> getPendientes(int legajo) async {
    final res = await _dio.get('/servicios/clientes/$legajo/pendientes');
    final data = res.data;

    if (data is! List) {
      throw Exception('Respuesta inválida pendientes: ${res.data}');
    }

    return data
        .map((e) => ClienteServicioPeriodoDto.fromJson(
              Map<String, dynamic>.from(e),
            ))
        .toList();
  }

  Future<void> pagarPeriodo({
    required int idPeriodo,
    required int legajo,
    required int idMedioPago,
    String? observacion,
  }) async {
    await _dio.post(
      '/servicios/periodos/$idPeriodo/pagar',
      queryParameters: {
        'legajo': legajo,
        'id_medio_pago': idMedioPago,
        if (observacion != null && observacion.trim().isNotEmpty)
          'observacion': observacion.trim(),
      },
    );
  }
}

