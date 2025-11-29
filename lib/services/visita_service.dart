import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class VisitaService {
  final String _baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:8500';

  Future<Map<String, dynamic>> crearVisita({
    required int legajo,
    required String estado,
    DateTime? fecha,
  }) async {
    final uri = Uri.parse('$_baseUrl/visitas/$legajo');

    final body = <String, dynamic>{
      'estado': estado,
      if (fecha != null) 'fecha': fecha.toIso8601String(),
    };

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (res.statusCode != 201) {
      throw Exception('Error ${res.statusCode} al crear visita: ${res.body}');
    }

    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}

class VisitaEstado {
  static const compra = 'cliente_compra';
  static const noCompra = 'cliente_no_compra';
  static const postergada = 'postergacion_cliente';
}
