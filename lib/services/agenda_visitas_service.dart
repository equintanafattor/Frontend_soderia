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

    /// UNA sola llamada para todo un rango (reemplaza N llamadas por día).
  /// Devuelve el mapa fecha -> clientes, ya armado para la UI.
  Future<Map<DateTime, List<ClientePorDiaItem>>> obtenerAgendaPorRango(
    DateTime desde,
    DateTime hasta, {
    String? turno,
  }) async {
    final formatter = DateFormat('yyyy-MM-dd');
    final resp = await _dio.get(
      '/clientes/agenda/visitas/rango',
      queryParameters: {
        'desde': formatter.format(desde),
        'hasta': formatter.format(hasta),
        if (turno != null && turno.isNotEmpty) 'turno': turno,
      },
    );

    final rango = AgendaRango.fromJson(resp.data as Map<String, dynamic>);

    // Aplanamos a Map<DateTime, List<...>> que es justo lo que espera TodosScreen.
    final map = <DateTime, List<ClientePorDiaItem>>{};
    for (final dia in rango.dias) {
      final key = DateTime(dia.fecha.year, dia.fecha.month, dia.fecha.day);
      map[key] = dia.clientes;
    }
    return map;
  }
}