import 'package:dio/dio.dart';
import '../../core/net/api_client.dart';

class MedioPagoDto {
  final int id;
  final String nombre;

  MedioPagoDto({required this.id, required this.nombre});

  factory MedioPagoDto.fromJson(Map<String, dynamic> json) {
    return MedioPagoDto(
      id: (json['id_medio_pago'] as num).toInt(),
      nombre: (json['nombre'] ?? '').toString(),
    );
  }
}

class MedioPagoService {
  final Dio _dio = ApiClient.dio;

  List<MedioPagoDto>? _cache;

  Future<List<MedioPagoDto>> listar({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache != null) return _cache!;

    final res = await _dio.get('/medios-pago'); // 👈 sin slash final
    final data = res.data;

    if (data is! List) {
      throw Exception('Respuesta inválida medios-pago: ${res.data}');
    }

    _cache = data
        .map((e) => MedioPagoDto.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return _cache!;
  }
}
