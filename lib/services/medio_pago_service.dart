import 'dart:convert';
import 'package:http/http.dart' as http;

class MedioPagoService {
  final String baseUrl = 'http://localhost:8500/medios-pago';

  Future<List<Map<String, dynamic>>> listar() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode != 200) {
      throw Exception('Error cargando medios de pago');
    }
    return List<Map<String, dynamic>>.from(jsonDecode(res.body));
  }
}
