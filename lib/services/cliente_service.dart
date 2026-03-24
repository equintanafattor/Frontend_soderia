// lib/services/cliente_service.dart
import 'package:dio/dio.dart';
import 'package:frontend_soderia/core/net/api_client.dart';

class ClienteService {
  final Dio _dio = ApiClient.dio;

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

    try {
      final resp = await _dio.post('/clientes/', data: body);
      // tu back devuelve 201
      return Map<String, dynamic>.from(resp.data as Map);
    } on DioException catch (e) {
      throw Exception(
        'Error creando cliente: ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<Map<String, dynamic>> crearClienteCompleto(
    Map<String, dynamic> body,
  ) async {
    try {
      final resp = await _dio.post('/clientes/', data: body);
      return Map<String, dynamic>.from(resp.data as Map);
    } on DioException catch (e) {
      throw Exception(
        'Error creando cliente: ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<List<dynamic>> listarClientesPorIdDia(int idDia) async {
    try {
      final resp = await _dio.get('/clientes/agenda/visitas/dia/$idDia');
      final json = Map<String, dynamic>.from(resp.data as Map);
      return (json['clientes'] as List<dynamic>);
    } on DioException catch (e) {
      throw Exception(
        'Error listando clientes del día: ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<List<dynamic>> listarClientes() async {
    try {
      final resp = await _dio.get('/clientes/');
      return (resp.data as List).cast<dynamic>();
    } on DioException catch (e) {
      throw Exception(
        'Error listando clientes: ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<Map<String, dynamic>> obtenerCliente(int legajo) async {
    try {
      final resp = await _dio.get('/clientes/$legajo/detalle');
      return Map<String, dynamic>.from(resp.data as Map);
    } on DioException catch (e) {
      throw Exception(
        'Error obteniendo cliente $legajo: ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<Map<String, dynamic>> actualizarCliente(
    int legajo,
    Map<String, dynamic> payload,
  ) async {
    try {
      final resp = await _dio.put('/clientes/$legajo', data: payload);
      return Map<String, dynamic>.from(resp.data as Map);
    } on DioException catch (e) {
      throw Exception(
        'Error actualizando cliente: ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<Map<String, dynamic>> actualizarContacto(
    int legajo,
    Map<String, dynamic> payload,
  ) async {
    try {
      final resp = await _dio.put('/clientes/$legajo/contacto', data: payload);
      return Map<String, dynamic>.from(resp.data as Map);
    } on DioException catch (e) {
      throw Exception(
        'Error actualizando contacto: ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<void> borrarCliente(int legajo) async {
    try {
      await _dio.delete('/clientes/$legajo');
    } on DioException catch (e) {
      throw Exception('No se pudo borrar: ${e.response?.data ?? e.message}');
    }
  }

  Future<Map<String, dynamic>> obtenerDetalleCliente(int legajo) async {
    try {
      final resp = await _dio.get('/clientes/$legajo/detalle');
      return Map<String, dynamic>.from(resp.data as Map);
    } on DioException catch (e) {
      throw Exception(
        'Error obteniendo detalle de cliente: ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<List<dynamic>> listarPedidosCliente(
    int legajo, {
    int limit = 10,
  }) async {
    try {
      final resp = await _dio.get(
        '/clientes/$legajo/pedidos',
        queryParameters: {'limit': limit},
      );
      return (resp.data as List).cast<dynamic>();
    } on DioException catch (e) {
      throw Exception(
        'Error listando pedidos del cliente: ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<List<dynamic>> listarHistoricoCliente(
    int legajo, {
    int limit = 10,
  }) async {
    try {
      final resp = await _dio.get(
        '/clientes/$legajo/historicos',
        queryParameters: {'limit': limit},
      );
      return (resp.data as List).cast<dynamic>();
    } on DioException catch (e) {
      throw Exception(
        'Error listando histórico del cliente: ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<Map<String, dynamic>> actualizarClienteDetalle(
    int legajo,
    Map<String, dynamic> payload,
  ) async {
    try {
      final resp = await _dio.put('/clientes/$legajo/detalle', data: payload);
      return Map<String, dynamic>.from(resp.data as Map);
    } on DioException catch (e) {
      throw Exception(
        'Error: ${e.response?.statusCode} ${e.response?.data ?? e.message}',
      );
    }
  }

  Future<void> crearCuenta({
    required int legajo,
    required Map<String, dynamic> payload,
  }) async {
    try {
      await _dio.post('/clientes/$legajo/cuentas', data: payload);
    } on DioException catch (e) {
      throw Exception('Error creando cuenta: ${e.response?.data ?? e.message}');
    }
  }

  Future<void> moverClienteAgenda({
    required int idCliente,
    required int idDia,
    required String turno,
    required String posicion,
    int? despuesDeLegajo,
  }) async {
    try {
      await _dio.post(
        '/agenda/mover',
        data: {
          'id_cliente': idCliente,
          'id_dia': idDia,
          'turno': turno,
          'posicion': posicion,
          if (despuesDeLegajo != null) 'despues_de_legajo': despuesDeLegajo,
        },
      );
    } on DioException catch (e) {
      throw Exception(
        'Error moviendo cliente: ${e.response?.data ?? e.message}',
      );
    }
  }
}
