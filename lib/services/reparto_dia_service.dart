import 'dart:convert';
import 'package:frontend_soderia/models/reparto_dia_out.dart';
import 'package:http/http.dart' as http;

class RepartoDiaService {
  /// baseUrl SOLO hasta el host, sin el prefix del router.
  /// Ej: 'http://localhost:8500'
  final String baseUrl;

  RepartoDiaService({required this.baseUrl});

  Future<RepartoDiaOut?> getByFecha({
    required DateTime fecha,
    int? idEmpresa,
    int? idUsuario,
  }) async {
    // yyyy-MM-dd
    final fechaStr = fecha.toIso8601String().split('T').first;

    // El router en el back tiene prefix="/repartos-dia"
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

    if (resp.statusCode == 404) {
      // No hay reparto ese día → devolvemos null
      return null;
    }

    throw Exception(
      'Error al obtener reparto del día (${resp.statusCode}): ${resp.body}',
    );
  }

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
}

