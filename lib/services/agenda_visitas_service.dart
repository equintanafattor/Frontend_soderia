// lib/services/agenda_visitas_service.dart

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../core/net/api_client.dart';
import 'package:frontend_soderia/models/clientes_por_dia.dart';

class AgendaVisitasService {
  final Dio _dio = ApiClient.dio;

  Future<ClientesPorDia> obtenerClientesPorFecha(DateTime fecha,
      {String? turno}) async {
    final formatter = DateFormat('yyyy-MM-dd');
    final resp = await _dio.get(
      '/clientes/agenda/visitas',
      queryParameters: {
        'fecha': formatter.format(fecha),
        if (turno != null && turno.isNotEmpty) 'turno': turno,
      },
    );

    return ClientesPorDia.fromJson(resp.data as Map<String, dynamic>);
  }
}