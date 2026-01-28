import 'dart:convert';
import 'package:http/http.dart' as http;

class PagoService {
  static const String baseUrl = 'http://localhost:8500/pagos';

  Future<Map<String, dynamic>> crearPagoLibre({
    required int legajo,
    required int idEmpresa,
    required int idMedioPago,
    int? idCuenta, // 👈 CAMBIAR
    required double monto,
    String? observacion,
    int? idRepartoDia,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/libre'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'legajo': legajo,
        'id_empresa': idEmpresa,
        'id_medio_pago': idMedioPago,
        'monto': monto,
        if (idCuenta != null) 'id_cuenta': idCuenta, // 👈 SOLO SI VIENE
        if (observacion != null) 'observacion': observacion,
        if (idRepartoDia != null) 'id_repartodia': idRepartoDia,
      }),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body);
    }

    throw Exception('Error registrando pago: ${res.body}');
  }
}
