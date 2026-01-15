import 'dart:convert';
import 'package:frontend_soderia/models/reparto_dia_out.dart';
import 'package:http/http.dart' as http;

class RepartoDiaService {
  /// baseUrl SOLO hasta el host, sin el prefix del router.
  /// Ej: 'http://localhost:8500'
  final String baseUrl;

  RepartoDiaService({required this.baseUrl});

  /// Si querés mantener este método que devuelve el Map "crudo", podés
  /// dejarlo, pero en la práctica con `RepartoDiaOut` alcanza.
  Future<Map<String, dynamic>> obtenerPorFecha({
    required DateTime fecha,
    required int idEmpresa,
    int? idUsuario,
  }) async {
    final fechaStr = fecha.toIso8601String().split('T').first;

    final uri = Uri.parse('$baseUrl/repartos-dia/por-fecha').replace(
      queryParameters: {
        'fecha': fechaStr,
        'id_empresa': idEmpresa.toString(),
        if (idUsuario != null) 'id_usuario': idUsuario.toString(),
      },
    );

    final res = await http.get(uri);

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }

    if (res.statusCode == 404) {
      throw Exception('No hay reparto del día para $fechaStr');
    }

    throw Exception('Error obteniendo reparto del día: ${res.body}');
  }

  Future<RepartoDiaOut?> getByFecha({
    required DateTime fecha,
    int? idEmpresa,
    int? idUsuario,
  }) async {
    final fechaStr = fecha.toIso8601String().split('T').first;

    final uri = Uri.parse('$baseUrl/repartos-dia/por-fecha').replace(
      queryParameters: {
        'fecha': fechaStr,
        if (idEmpresa != null) 'id_empresa': idEmpresa.toString(),
        if (idUsuario != null) 'id_usuario': idUsuario.toString(),
      },
    );

    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return RepartoDiaOut.fromJson(data);
    }
    if (resp.statusCode == 404) return null;
    throw Exception(
      'Error al obtener reparto (${resp.statusCode}): ${resp.body}',
    );
  }

  Future<List<RepartoDiaOut>> getPorRango({
    required DateTime desde,
    required DateTime hasta,
    int? idEmpresa,
    int? idUsuario,
  }) async {
    final desdeStr = desde.toIso8601String().split('T').first;
    final hastaStr = hasta.toIso8601String().split('T').first;

    final uri = Uri.parse('$baseUrl/repartos-dia/por-rango').replace(
      queryParameters: {
        'fecha_desde': desdeStr,
        'fecha_hasta': hastaStr,
        if (idEmpresa != null) 'id_empresa': idEmpresa.toString(),
        if (idUsuario != null) 'id_usuario': idUsuario.toString(),
      },
    );

    final resp = await http.get(uri);

    if (resp.statusCode == 200) {
      final list = jsonDecode(resp.body) as List;
      return list
          .map((e) => RepartoDiaOut.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception(
      'Error listando repartos (${resp.statusCode}): ${resp.body}',
    );
  }
}
