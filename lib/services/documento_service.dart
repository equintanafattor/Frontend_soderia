import 'package:dio/dio.dart';
import '../core/net/api_client.dart';

class DocumentoService {
  DocumentoService({this.enableLogs = true});

  final bool enableLogs;
  Dio get _dio => ApiClient.dio;

  void _log(String msg) {
    if (enableLogs) {
      // ignore: avoid_print
      print(msg);
    }
  }

  String _fullUrl(String path) => '${_dio.options.baseUrl}$path';

  /// Intenta extraer un mensaje útil de error desde el body del backend
  String _extractBackendMessage(dynamic data) {
    if (data == null) return 'Sin detalle';

    // FastAPI suele mandar: {"detail": "..."}
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final detail = map['detail'];
      if (detail != null) return detail.toString();

      final message = map['message'];
      if (message != null) return message.toString();

      // fallback: muestro el map entero
      return map.toString();
    }

    // si es string plano o lista
    return data.toString();
  }

  Exception _dioToException(String method, String url, DioException e) {
    final status = e.response?.statusCode;
    final backendMsg = _extractBackendMessage(e.response?.data);

    final msg = '[$method] $url -> HTTP ${status ?? '-'}: $backendMsg';
    return Exception(msg);
  }

  // ✅ LISTAR POR CLIENTE
  Future<List<Map<String, dynamic>>> listarPorCliente(int legajo) async {
    final path = '/documentos/cliente/$legajo';
    final url = _fullUrl(path);

    try {
      _log('[DocumentoService.listarPorCliente] GET $url');

      final res = await _dio.get(path);

      _log('[DocumentoService.listarPorCliente] status: ${res.statusCode}');
      _log('[DocumentoService.listarPorCliente] data: ${res.data}');

      final data = res.data;

      if (data is List) {
        return data
            .where((e) => e is Map)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }

      // a veces backend manda {"items": [...]} (no es tu caso hoy, pero por si cambia)
      if (data is Map && data['items'] is List) {
        final items = data['items'] as List;
        return items
            .where((e) => e is Map)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      _log('[DocumentoService.listarPorCliente] DIO ERROR: ${e.message}');
      throw _dioToException('GET', url, e);
    } catch (e) {
      _log('[DocumentoService.listarPorCliente] ERROR: $e');
      rethrow;
    }
  }

  // ✅ GENERAR COMPROBANTE DE PEDIDO
  Future<Map<String, dynamic>> generarComprobantePedido(int idPedido) async {
    final path = '/pedidos/$idPedido/comprobante';
    final url = _fullUrl(path);

    try {
      _log('[DocumentoService.generarComprobantePedido] POST $url');

      final res = await _dio.post(path);

      _log(
        '[DocumentoService.generarComprobantePedido] status: ${res.statusCode}',
      );
      _log('[DocumentoService.generarComprobantePedido] data: ${res.data}');

      final data = res.data;

      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }

      // si volviera algo raro, al menos no rompe silencioso
      throw Exception('Respuesta inesperada del servidor: ${data.runtimeType}');
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final backendMsg = _extractBackendMessage(e.response?.data);

      _log(
        '[DocumentoService.generarComprobantePedido] DIO ERROR status: $status',
      );
      _log(
        '[DocumentoService.generarComprobantePedido] DIO ERROR data: ${e.response?.data}',
      );

      // mensaje pro para que lo veas en SnackBar sin perder el detalle
      throw Exception(
        'Error generando comprobante (HTTP ${status ?? '-'}) — $backendMsg',
      );
    } catch (e) {
      _log('[DocumentoService.generarComprobantePedido] ERROR: $e');
      rethrow;
    }
  }
}
