import 'dart:convert';
import 'package:http/http.dart' as http;

class ListaPrecioService {
  static const String baseUrl = 'http://localhost:8500';

  // =========================
  // Listas
  // =========================

  Future<List<dynamic>> listarListas({int limit = 50, int offset = 0}) async {
    final uri = Uri.parse(
      '$baseUrl/listas-precios?limit=$limit&offset=$offset',
    );
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Error al listar listas: ${res.statusCode}');
    }

    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> crearLista({
    required String nombre,
    required String estado,
  }) async {
    final uri = Uri.parse('$baseUrl/listas-precios/');
    final body = jsonEncode({'nombre': nombre, 'estado': estado});

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (res.statusCode != 201) {
      throw Exception('Error al crear lista: ${res.statusCode}');
    }

    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // =========================
  // Productos con precio
  // =========================

  /// Devuelve productos con precio para una lista
  Future<List<dynamic>> listarProductosConPrecio(int idLista) async {
    final uri = Uri.parse('$baseUrl/listas-precios/$idLista/productos');
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception(
        'Error al listar productos de la lista: ${res.statusCode}',
      );
    }

    return jsonDecode(res.body) as List<dynamic>;
  }

  /// Upsert de precio (crear o actualizar)
  Future<void> upsertPrecio({
    required int idLista,
    required int idProducto,
    required double precio,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/listas-precios/$idLista/precios/$idProducto',
    );

    final body = jsonEncode({
      'id_lista': idLista,
      'id_producto': idProducto,
      'precio': precio,
    });

    final res = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (res.statusCode != 200) {
      throw Exception('Error al guardar precio: ${res.statusCode} ${res.body}');
    }
  }

  /// Lista_precio_producto “crudo” (si lo necesitás después)
  Future<List<dynamic>> listarPreciosDeLista(int idLista) async {
    final uri = Uri.parse('$baseUrl/listas-precios/$idLista/precios');
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Error al listar precios de lista: ${res.statusCode}');
    }

    return jsonDecode(res.body) as List<dynamic>;
  }

  // =========================
  // Ítems con precio (productos + combos)
  // =========================

  /// Devuelve productos y combos con precio para una lista
  Future<List<dynamic>> listarItemsDeLista(int idLista) async {
    final uri = Uri.parse('$baseUrl/listas-precios/$idLista/items');
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception(
        'Error al listar ítems de la lista: ${res.statusCode} ${res.body}',
      );
    }

    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<List<dynamic>> listarCombosConPrecio(int idLista) async {
    final uri = Uri.parse('$baseUrl/listas-precios/$idLista/combos');
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Error al listar combos de la lista: ${res.statusCode}');
    }

    return jsonDecode(res.body) as List<dynamic>;
  }

  /// Upsert de precio de combo en lista
  Future<void> upsertPrecioCombo({
    required int idLista,
    required int idCombo,
    required double precio,
  }) async {
    final uri = Uri.parse('$baseUrl/listas-precios/$idLista/combos/$idCombo');

    final body = jsonEncode({
      'id_lista': idLista,
      'id_combo': idCombo,
      'precio': precio,
    });

    final res = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (res.statusCode != 200) {
      throw Exception(
        'Error al guardar precio de combo: ${res.statusCode} ${res.body}',
      );
    }
  }
}
