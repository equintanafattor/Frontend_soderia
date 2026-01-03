import 'dart:convert';
import 'package:http/http.dart' as http;

class ComboProductoService {
  static const String baseUrl = 'http://localhost:8500/combos';

  Future<List<dynamic>> listar(int idCombo) async {
    final res = await http.get(Uri.parse('$baseUrl/$idCombo'));

    if (res.statusCode != 200) {
      throw Exception('Error cargando productos del combo');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return (data['productos'] ?? []) as List<dynamic>;
  }

  Future<void> agregar({
    required int idCombo,
    required int idProducto,
    required int cantidad,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/$idCombo/productos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_producto': idProducto, 'cantidad': cantidad}),
    );

    if (res.statusCode != 201) {
      throw Exception('Error agregando producto al combo');
    }
  }

  Future<void> actualizar({
    required int idCombo,
    required int idProducto,
    required int cantidad,
  }) async {
    final res = await http.put(
      Uri.parse('$baseUrl/$idCombo/productos/$idProducto'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'cantidad': cantidad}),
    );

    if (res.statusCode != 200) {
      throw Exception('Error actualizando cantidad');
    }
  }

  Future<void> eliminar({required int idCombo, required int idProducto}) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/$idCombo/productos/$idProducto'),
    );

    if (res.statusCode != 204) {
      throw Exception('Error eliminando producto del combo');
    }
  }

  Future<Map<String, dynamic>> obtener(int idCombo) async {
    final res = await http.get(Uri.parse('$baseUrl/$idCombo'));
    if (res.statusCode != 200) {
      throw Exception('Error obteniendo combo');
    }
    return jsonDecode(res.body);
  }

  Future<void> actualizarProductos({
    required int idCombo,
    required List<Map<String, dynamic>> productos,
  }) async {
    final res = await http.put(
      Uri.parse('$baseUrl/$idCombo/productos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(productos),
    );

    if (res.statusCode != 200) {
      throw Exception('Error actualizando productos del combo');
    }
  }
}
