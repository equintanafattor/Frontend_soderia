import 'dart:convert';
import 'package:http/http.dart' as http;

class DocumentoService {
  static const String baseUrl = 'http://localhost:8500/documentos';

  Future<List<Map<String, dynamic>>> listarPorCliente(int legajo) async {
    final res = await http.get(
      Uri.parse('$baseUrl/cliente/$legajo'),
    );

    if (res.statusCode == 200) {
      return List<Map<String, dynamic>>.from(
        jsonDecode(res.body),
      );
    }

    throw Exception('Error cargando documentos');
  }
}
