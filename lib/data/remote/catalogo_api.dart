import 'package:dio/dio.dart';

class CatalogoApi {
  final Dio dio;

  CatalogoApi(this.dio);

  Future<Response> listarListas() {
    return dio.get('/listas-precios');
  }

  Future<Response> listarItemsDeLista(int idLista) {
    return dio.get('/listas-precios/$idLista/items');
  }

  Future<Response> listarMediosPago() {
    return dio.get('/medios-pago');
  }
}