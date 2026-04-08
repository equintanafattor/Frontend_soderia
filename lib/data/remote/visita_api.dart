import 'package:dio/dio.dart';

class VisitaApi {
  final Dio dio;

  VisitaApi(this.dio);

  Future<Response> crearVisita(Map<String, dynamic> payload) {
    return dio.post('/visita', data: payload);
  }
}