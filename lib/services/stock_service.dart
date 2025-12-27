// lib/services/stock_service.dart
import 'dart:convert';
import 'package:frontend_soderia/models/stock_detalle.dart';
import 'package:http/http.dart' as http;

import 'package:frontend_soderia/models/stock.dart';
import 'package:frontend_soderia/models/movimiento_stock.dart';

class StockService {
  // mismo host/puerto que el resto del back
  final String baseUrl = 'http://localhost:8500';

  // ---------------------------
  // GET /stock/detalle
  // ---------------------------

  Future<List<StockDetalle>> getStockDetalle({required int idEmpresa}) async {
    final uri = Uri.parse('$baseUrl/stock/detalle?id_empresa=$idEmpresa');

    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Error cargando stock');
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => StockDetalle.fromJson(e)).toList();
  }

  // ---------------------------
  // POST /movimientos-stock
  // ---------------------------
  Future<void> ajustarStock({
    required int idProducto,
    required String tipoMovimiento, // ingreso | egreso | ajuste
    required int cantidad,
    String? observacion,
  }) async {
    final uri = Uri.parse('$baseUrl/movimientos-stock');

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_producto': idProducto,
        'tipo_movimiento': tipoMovimiento,
        'cantidad': cantidad,
        'observacion': observacion,
      }),
    );

    if (res.statusCode != 201) {
      throw Exception('Error ajustando stock (${res.statusCode}): ${res.body}');
    }
  }

  // ---------------------------
  // GET /movimientos-stock
  // ---------------------------
  Future<List<MovimientoStock>> getMovimientos({
    required int idProducto,
    int limit = 50,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/movimientos-stock'
      '?id_producto=$idProducto&limit=$limit',
    );

    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final List<dynamic> json = jsonDecode(res.body);
      return json.map((e) => MovimientoStock.fromJson(e)).toList();
    } else {
      throw Exception(
        'Error cargando movimientos (${res.statusCode}): ${res.body}',
      );
    }
  }
}
