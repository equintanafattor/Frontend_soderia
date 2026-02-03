/* import 'dart:async';
import 'package:frontend_soderia/models/jornada.dart';
// import 'package:dio/dio.dart'; // ← lo vas a usar cuando conectes backend

class JornadaService {
  // final Dio _dio = Dio(BaseOptions(baseUrl: "http://localhost:8000")); // real

  Future<List<Jornada>> obtenerJornadas(int year, int month) async {
    // 👇 MOCK: borrá esto cuando conectes el backend
    await Future.delayed(const Duration(milliseconds: 500));
    return <Jornada>[
      Jornada(
        fecha: DateTime(year, month, 1),
        clientes: [
          'Silva Tamara',
          'Kreitzer Bernardo',
          'Brondani Gaston',
          'Quintana Emmanuel',
          'Luna Tristan',
          'Abasto Facundo',
          'Cliente Extra 1',
          'Cliente Extra 2',
        ],
      ),
      Jornada(
        fecha: DateTime(year, month, 2),
        clientes: [
          'Emilio Fouces',
          'Ernesto Zapata',
          'Franco Colapinto',
          'Fernando Filipuzzi',
          'Francisco Rodriguez',
          'Facundo Fumaneri',
        ],
      ),
    ];

    // 👇 REAL: descomentá esto cuando el backend esté listo
    /*
    try {
      final resp = await _dio.get("/repartos/mes/$year/$month");
      if (resp.statusCode == 200) {
        final data = resp.data as List;
        return data.map((j) => Jornada.fromJson(j)).toList();
      }
      throw Exception("Error ${resp.statusCode}");
    } catch (e) {
      rethrow;
    }
    */
  }
} */

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


