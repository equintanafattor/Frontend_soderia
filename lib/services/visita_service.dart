// lib/services/visita_service.dart
//
// Servicio HTTP para visitas. Actualmente el flujo pasa por
// VisitaRepository (offline-first), pero este archivo existe
// para uso directo online si se necesita en el futuro.

import 'package:dio/dio.dart';
import 'package:frontend_soderia/core/net/api_client.dart';

class VisitaService {
  final Dio _dio = ApiClient.dio;

  Future<Map<String, dynamic>> registrarVisita({
    required int legajo,
    required String estado,
    required DateTime fecha,
    String? idempotencyKey,
    String? clientUuid,
  }) async {
    try {
      final resp = await _dio.post(
        '/visitas',
        data: {
          'legajo': legajo,
          'estado': estado,
          'fecha': fecha.toIso8601String(),
          if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
          if (clientUuid != null) 'client_uuid': clientUuid,
        },
      );
      return Map<String, dynamic>.from(resp.data as Map);
    } on DioException catch (e) {
      throw Exception(
        'Error registrando visita: ${e.response?.data ?? e.message}',
      );
    }
  }
}
