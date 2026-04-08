import 'package:dio/dio.dart';

class PagoApi {
  final Dio dio;

  PagoApi(this.dio);

  Future<Response> crearPago(Map<String, dynamic> payload) {
    return dio.post('/pago', data: payload);
  }
}