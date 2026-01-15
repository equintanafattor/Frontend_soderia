// services/caja_empresa_service.dart
import 'dart:convert';
import 'package:frontend_soderia/models/caja_empresa_movimiento_out.dart';
import 'package:http/http.dart' as http;
import '../models/caja_empresa_total_out.dart';

class CajaEmpresaService {
  final String baseUrl = 'http://localhost:8500/caja-empresa';

  Future<CajaEmpresaTotalOut> getTotalPorRango({
    required DateTime desde,
    required DateTime hasta,
    int? idEmpresa,
  }) async {
    final desdeStr = desde.toIso8601String().split('T').first;
    final hastaStr = hasta.toIso8601String().split('T').first;

    final uri = Uri.parse('$baseUrl/total-por-rango').replace(
      queryParameters: {
        'fecha_desde': desdeStr,
        'fecha_hasta': hastaStr,
        if (idEmpresa != null) 'id_empresa': idEmpresa.toString(),
      },
    );

    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return CajaEmpresaTotalOut.fromJson(data);
    }
    throw Exception('Error total por rango (${resp.statusCode}): ${resp.body}');
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

    final uri = Uri.parse('$baseUrl/movimientos').replace(
      queryParameters: {
        'fecha_desde': desdeStr,
        'fecha_hasta': hastaStr,
        'limit': limit.toString(),
        'offset': offset.toString(),
        if (idEmpresa != null) 'id_empresa': idEmpresa.toString(),
      },
    );

    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final total = (data['total'] as num).toInt();
      final items = (data['items'] as List)
          .map(
            (e) => CajaEmpresaMovimientoOut.fromJson(e as Map<String, dynamic>),
          )
          .toList();
      return (items, total);
    }
    throw Exception('Error movimientos (${resp.statusCode}): ${resp.body}');
  }

  Future<CajaEmpresaTotalOut> getTotalPorFecha({
    required DateTime fecha,
    int? idEmpresa,
  }) async {
    final fechaStr = fecha.toIso8601String().split('T').first; // yyyy-MM-dd

    final uri = Uri.parse('$baseUrl/total-por-fecha').replace(
      queryParameters: {
        'fecha': fechaStr,
        if (idEmpresa != null) 'id_empresa': idEmpresa.toString(),
      },
    );

    final resp = await http.get(uri);

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return CajaEmpresaTotalOut.fromJson(data);
    }

    throw Exception(
      'Error al obtener total de caja por fecha (${resp.statusCode}): ${resp.body}',
    );
  }
}
