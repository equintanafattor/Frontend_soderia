import 'package:frontend_soderia/models/combo_producto_draft.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ComboService {
  static const String baseUrl = 'http://localhost:8500/combos';

  Future<List<dynamic>> listar() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode != 200) {
      throw Exception('Error listando combos');
    }
    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> obtener(int idCombo) async {
    final res = await http.get(Uri.parse('$baseUrl/$idCombo'));
    if (res.statusCode != 200) {
      throw Exception('Error obteniendo combo');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> crear({
    required String nombre,
    required bool estado,
  }) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'estado': estado,
        'id_empresa': 1,
      }),
    );

    if (res.statusCode != 201) {
      throw Exception('Error creando combo');
    }
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> actualizar({
    required int idCombo,
    required String nombre,
    required bool estado,
  }) async {
    final res = await http.put(
      Uri.parse('$baseUrl/$idCombo'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'estado': estado,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Error actualizando combo');
    }
    return jsonDecode(res.body);
  }
}
