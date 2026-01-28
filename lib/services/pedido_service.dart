import 'dart:convert';
import 'package:http/http.dart' as http;

class PedidoService {
  final String baseUrl = 'http://localhost:8500/pedidos';

  Future<Map<String, dynamic>> crearPedido({
    required int legajo,
    required int idMedioPago,
    required DateTime fecha,
    required double montoTotal,
    required double montoAbonado,
    required int idEmpresa,
    required List<Map<String, dynamic>> items,
    int? idRepartoDia,
    String? observacion,

    // ✅ NUEVO
    int? idCuenta,
  }) async {
    final uri = Uri.parse(baseUrl);

    final body = <String, dynamic>{
      'legajo': legajo,
      'id_medio_pago': idMedioPago,
      'id_empresa': idEmpresa,
      'fecha': fecha.toIso8601String(),
      'monto_total': montoTotal,
      'monto_abonado': montoAbonado,
      'items': items,
      if (idRepartoDia != null) 'id_repartodia': idRepartoDia,
      if (idCuenta != null) 'id_cuenta': idCuenta, // ✅
      if (observacion != null && observacion.trim().isNotEmpty)
        'observacion': observacion.trim(),
    };

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }

    throw Exception('Error al crear pedido: ${res.statusCode} ${res.body}');
  }

  Future<Map<String, dynamic>> confirmarPedido({
    required int idPedido,
    required int idRepartoDia,
  }) async {
    final uri = Uri.parse('$baseUrl/$idPedido/confirmar');

    final body = jsonEncode({'id_repartodia': idRepartoDia});

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }

    throw Exception('Error confirmando pedido: ${res.statusCode} ${res.body}');
  }
}
