import 'dart:convert';
import 'package:http/http.dart' as http;

class RepartoDiaService {
  // Ajustá el prefijo si en el back el router tiene otro:
  // router = APIRouter(prefix="/repartos-dia", ...)
  final String baseUrl = 'http://localhost:8500/repartos-dia';

  Future<Map<String, dynamic>> obtenerPorFecha({
    required DateTime fecha,
    required int idEmpresa,
    int? idUsuario,
  }) async {
    // back espera date, no datetime → yyyy-MM-dd
    final fechaStr = fecha.toIso8601String().split('T').first;

    final uri = Uri.parse('$baseUrl/por-fecha').replace(
      queryParameters: {
        'fecha': fechaStr,
        'id_empresa': idEmpresa.toString(),
        if (idUsuario != null) 'id_usuario': idUsuario.toString(),
      },
    );

    final res = await http.get(uri);

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }

    if (res.statusCode == 404) {
      throw Exception('No hay reparto del día para $fechaStr');
    }

    throw Exception('Error obteniendo reparto del día: ${res.body}');
  }
}
