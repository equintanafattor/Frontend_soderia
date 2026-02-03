import 'package:dio/dio.dart';
import '../../core/net/api_client.dart';


class MedioPagoService {
  final Dio _dio = ApiClient.dio;

  Future<List<Map<String, dynamic>>> listar() async {
    final res = await _dio.get('/medios-pago/');
    final data = res.data;

    if (data is! List) {
      throw Exception('Respuesta inválida medios-pago: ${res.data}');
    }

    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}
