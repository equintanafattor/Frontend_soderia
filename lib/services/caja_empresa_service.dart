// services/caja_empresa_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/caja_empresa_total_out.dart';

class CajaEmpresaService {
  final String baseUrl;

  CajaEmpresaService({required this.baseUrl});

  Future<CajaEmpresaTotalOut> getTotalPorFecha({
    required DateTime fecha,
    int? idEmpresa,
  }) async {
    final uri = Uri.parse('$baseUrl/caja-empresa/total-por-fecha').replace(
      queryParameters: {
        'fecha': fecha.toIso8601String().substring(0, 10),
        if (idEmpresa != null) 'id_empresa': idEmpresa.toString(),
      },
    );

    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return CajaEmpresaTotalOut.fromJson(data);
    }
    throw Exception('Error al obtener total de caja (${resp.statusCode})');
  }
}
