// lib/services/producto_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend_soderia/models/producto.dart';

class ProductoService {
  // Ajustá baseUrl si lo tenés centralizado.
  static const String baseUrl = 'http://localhost:8500';

  Future<List<Producto>> listar({int limit = 50, int offset = 0}) async {
    final uri = Uri.parse('$baseUrl/productos?limit=$limit&offset=$offset');
    final resp = await http.get(uri);

    if (resp.statusCode != 200) {
      throw Exception('Error al listar productos: ${resp.statusCode}');
    }

    final List<dynamic> data = jsonDecode(resp.body);
    return data
        .map((e) => Producto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Producto> crear({
    required String nombre,
    bool? estado,
    double? litros,
    String? tipoDispenser,
    String? observacion,
    bool descuentaStock = true,
  }) async {
    final uri = Uri.parse('$baseUrl/productos/');
    final body = jsonEncode({
      'nombre': nombre,
      'estado': estado,
      'litros': litros,
      'tipo_dispenser': tipoDispenser,
      'observacion': observacion,
      'descuenta_stock': descuentaStock,
    });

    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (resp.statusCode != 201) {
      throw Exception('Error al crear producto: ${resp.statusCode}');
    }

    return Producto.fromJson(jsonDecode(resp.body));
  }

  Future<Producto> actualizar(
    int idProducto, {
    String? nombre,
    bool? estado,
    double? litros,
    String? tipoDispenser,
    String? observacion,
    bool? descuentaStock,
  }) async {
    final uri = Uri.parse('$baseUrl/productos/$idProducto');
    final body = <String, dynamic>{};

    if (nombre != null) body['nombre'] = nombre;
    if (estado != null) body['estado'] = estado;
    if (litros != null) body['litros'] = litros;
    if (tipoDispenser != null) body['tipo_dispenser'] = tipoDispenser;
    if (observacion != null) body['observacion'] = observacion;
    if (descuentaStock != null) body['descuenta_stock'] = descuentaStock;

    final resp = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (resp.statusCode != 200) {
      throw Exception('Error al actualizar producto: ${resp.statusCode}');
    }

    return Producto.fromJson(jsonDecode(resp.body));
  }

  Future<void> borrar(int idProducto) async {
    final uri = Uri.parse('$baseUrl/productos/$idProducto');
    final resp = await http.delete(uri);

    if (resp.statusCode != 204) {
      throw Exception('Error al borrar producto: ${resp.statusCode}');
    }
  }

  Future<List<dynamic>> listarProductosDeLista(int idLista) async {
    final res = await http.get(
      Uri.parse('$baseUrl/listas-precios/$idLista/productos'),
    );
    if (res.statusCode != 200) {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
    return jsonDecode(res.body) as List<dynamic>;
  }
}
