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
      fechaPago: json['fecha_pago'] == null
          ? null
          : DateTime.parse(json['fecha_pago']),
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
        .map(
          (e) =>
              ClienteServicioPeriodoDto.fromJson(Map<String, dynamic>.from(e)),
        )
        .toList();
  }

  Future<void> pagarPeriodo({
    required int idPeriodo,
    required int legajo,
    required int idMedioPago,
    int? idCuenta, // ✅ nuevo
    String? observacion,
  }) async {
    await _dio.post(
      '/servicios/periodos/$idPeriodo/pagar',
      queryParameters: {
        'legajo': legajo,
        'id_medio_pago': idMedioPago,
        if (idCuenta != null) 'id_cuenta': idCuenta, // ✅ nuevo
        if (observacion != null && observacion.trim().isNotEmpty)
          'observacion': observacion.trim(),
      },
    );
  }

  Future<void> crearAlquilerDispenser({
    required int legajo,
    required double montoMensual,
  }) async {
    await _dio.post(
      '/servicios/clientes/$legajo/alquiler-dispenser',
      queryParameters: {'monto_mensual': montoMensual.toStringAsFixed(2)},
    );
  }

  Future<List<ClienteServicioDto>> listarServiciosCliente(int legajo) async {
    final res = await _dio.get('/servicios/clientes/$legajo');
    final data = res.data;

    if (data is! List) {
      throw Exception('Respuesta inválida servicios: ${res.data}');
    }

    return data
        .map((e) => ClienteServicioDto.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> actualizarMontoServicio({
    required int idClienteServicio,
    required double montoMensual,
    DateTime? aplicarDesde,
    bool actualizarPeriodosNoPagados = true,
  }) async {
    await _dio.patch(
      '/servicios/$idClienteServicio/monto',
      data: {
        'monto_mensual': montoMensual.toStringAsFixed(2),
        'aplicar_desde': aplicarDesde?.toIso8601String().split('T').first,
        'actualizar_periodos_no_pagados': actualizarPeriodosNoPagados,
      },
    );
  }
}

class ClienteServicioDto {
  final int idClienteServicio;
  final int legajo;
  final String tipoServicio;
  final double montoMensual;
  final DateTime fechaInicio;
  final bool activo;

  ClienteServicioDto({
    required this.idClienteServicio,
    required this.legajo,
    required this.tipoServicio,
    required this.montoMensual,
    required this.fechaInicio,
    required this.activo,
  });

  factory ClienteServicioDto.fromJson(Map<String, dynamic> json) {
    return ClienteServicioDto(
      idClienteServicio: json['id_cliente_servicio'] as int,
      legajo: json['legajo'] as int,
      tipoServicio: (json['tipo_servicio'] ?? '').toString(),
      montoMensual: double.parse(json['monto_mensual'].toString()),
      fechaInicio: DateTime.parse(json['fecha_inicio']),
      activo: json['activo'] == true,
    );
  }
}
