
import 'package:dio/dio.dart';
import '../../core/net/api_client.dart';
import 'package:frontend_soderia/models/jornada.dart';

class JornadaService {
  final Dio _dio = ApiClient.dio;

  Future<List<Jornada>> obtenerJornadas(int year, int month) async {
    final resp = await _dio.get(
      '/jornadas',
      queryParameters: {
        'year': year,
        'month': month,
      },
    );

    final data = resp.data as List<dynamic>;
    return data.map((e) => Jornada.fromJson(e as Map<String, dynamic>)).toList();
  }
}


