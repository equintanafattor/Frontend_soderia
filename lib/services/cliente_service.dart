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

  Future<void> agregarDireccion(int legajo, Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$baseUrl/$legajo/direcciones'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (res.statusCode != 201) {
      throw Exception('Error agregando dirección: ${res.body}');
    }
  }

  Future<void> agregarTelefono(int legajo, String numero) async {
    final res = await http.post(
      Uri.parse('$baseUrl/$legajo/telefonos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"numero": numero}),
    );
    if (res.statusCode != 201) {
      throw Exception('Error agregando teléfono: ${res.body}');
    }
  }

  Future<void> agregarMail(int legajo, String mail) async {
    final res = await http.post(
      Uri.parse('$baseUrl/$legajo/emails'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"mail": mail}),
    );
    if (res.statusCode != 201) {
      throw Exception('Error agregando mail: ${res.body}');
    }
  }

  Future<void> agregarFrecuencia(
    int legajo, {
    required int idDia,
    required String modo,
    required String turnoVisita,
    int? idClienteReferencia,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/$legajo/frecuencia'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "id_dia": idDia,
        "modo": modo,
        "turno_visita": turnoVisita,
        "id_cliente_referencia": idClienteReferencia,
      }),
    );
    if (res.statusCode != 201) {
      throw Exception('Error agregando frecuencia: ${res.body}');
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
}
