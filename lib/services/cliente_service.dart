// lib/services/cliente_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ClienteService {
  // poné tu puerto real
  final String baseUrl = 'http://localhost:8500/clientes';

  Future<Map<String, dynamic>> crearCliente({
    required String nombre,
    required String apellido,
    required String dni,
    String? observacion,
  }) async {
    final body = {
      "persona": {
        "dni": int.parse(dni),
        "nombre": nombre,
        "apellido": apellido,
      },
      "observacion": observacion,
    };

    final res = await http.post(
      Uri.parse('$baseUrl/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (res.statusCode == 201) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Error creando cliente: ${res.body}');
    }
  }

  Future<Map<String, dynamic>> crearClienteCompleto(
    Map<String, dynamic> body,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode == 201) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Error creando cliente: ${res.body}');
    }
  }

  Future<List<dynamic>> listarClientesPorIdDia(int idDia) async {
    final res = await http.get(Uri.parse('$baseUrl/agenda/visitas/dia/$idDia'));
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      // el endpoint devuelve { id_dia, nombre_dia, clientes: [...] }
      return (json['clientes'] as List<dynamic>);
    } else {
      throw Exception('Error listando clientes del día: ${res.body}');
    }
  }

  // traer todos los clientes
  Future<List<dynamic>> listarClientes() async {
    final res = await http.get(Uri.parse('$baseUrl/'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List;
    } else {
      throw Exception('Error listando clientes: ${res.body}');
    }
  }

  // traer un cliente puntual por legajo
  Future<Map<String, dynamic>> obtenerCliente(int legajo) async {
    final res = await http.get(
      Uri.parse('$baseUrl/$legajo/detalle'),
      // headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Error obteniendo cliente $legajo: ${res.body}');
    }
  }

  // PUT /clientes/{legajo}
  Future<Map<String, dynamic>> actualizarCliente(
    int legajo,
    Map<String, dynamic> payload,
  ) async {
    final resp = await http.put(
      Uri.parse('$baseUrl/$legajo'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (resp.statusCode != 200) {
      throw Exception('Error actualizando cliente: ${resp.body}');
    }
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  // PUT /clientes/{legajo}/contacto
  // payload:
  // {
  //   "direcciones": [ { ... } ],
  //   "telefonos":   [ { ... } ],
  //   "emails":      [ { ... } ]
  // }
  Future<Map<String, dynamic>> actualizarContacto(
    int legajo,
    Map<String, dynamic> payload,
  ) async {
    final resp = await http.put(
      Uri.parse('$baseUrl/$legajo/contacto'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (resp.statusCode != 200) {
      throw Exception('Error actualizando contacto: ${resp.body}');
    }
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  // PUT /clientes/{legajo}/dias-visita
  // payload que proponemos al back:
  // {
  //   "dias": [
  //     { "dia": "lun", "turno_visita": "manana" },
  //     { "dia": "mie", "turno_visita": "manana" }
  //   ]
  // }

  Future<void> borrarCliente(int legajo) async {
    final resp = await http.delete(Uri.parse('$baseUrl/$legajo'));
    // tu back devuelve 204 si OK
    if (resp.statusCode != 204) {
      // puede ser 404 o 409, lo mostramos
      throw Exception('No se pudo borrar: ${resp.body}');
    }
  }

  Future<Map<String, dynamic>> obtenerDetalleCliente(int legajo) async {
    final resp = await http.get(Uri.parse('$baseUrl/$legajo/detalle'));
    if (resp.statusCode != 200) {
      throw Exception('Error obteniendo detalle de cliente');
    }
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> listarPedidosCliente(
    int legajo, {
    int limit = 10,
  }) async {
    final resp = await http.get(
      Uri.parse('$baseUrl/$legajo/pedidos?limit=$limit'),
    );
    if (resp.statusCode != 200) {
      throw Exception('Error listando pedidos del cliente');
    }
    return jsonDecode(resp.body) as List<dynamic>;
  }

  Future<List<dynamic>> listarHistoricoCliente(
    int legajo, {
    int limit = 10,
  }) async {
    final resp = await http.get(
      Uri.parse('$baseUrl/$legajo/historicos?limit=$limit'),
    );
    if (resp.statusCode != 200) {
      throw Exception('Error listando histórico del cliente');
    }
    return jsonDecode(resp.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> actualizarClienteDetalle(
    int legajo,
    Map<String, dynamic> payload,
  ) async {
    final url = Uri.parse('$baseUrl/$legajo/detalle');
    final res = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }

  Future<void> crearCuenta({
    required int legajo,
    required Map<String, dynamic> payload,
  }) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/$legajo/cuentas'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (resp.statusCode != 201) {
      throw Exception('Error creando cuenta: ${resp.body}');
    }
  }

  Future<void> moverClienteAgenda({
    required int idCliente,
    required int idDia,
    required String turno,
    required String posicion,
    int? despuesDeLegajo,
  }) async {
    final res = await http.post(
      Uri.parse('http://localhost:8500/agenda/mover'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_cliente': idCliente,
        'id_dia': idDia,
        'turno': turno,
        'posicion': posicion,
        if (despuesDeLegajo != null) 'despues_de_legajo': despuesDeLegajo,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Error moviendo cliente: ${res.body}');
    }
  }
}
