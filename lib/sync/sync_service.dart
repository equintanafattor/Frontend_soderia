import 'dart:convert';
import 'package:dio/dio.dart';

import '../data/local/app_database.dart';
import '../data/local/daos/sync_queue_dao.dart';
import '../data/remote/pago_api.dart';
import '../data/remote/visita_api.dart';
import '../repositories/pago_repository.dart';
import '../repositories/visita_repository.dart';

class SyncService {
  final SyncQueueDao queueDao;
  final PagoApi pagoApi;
  final VisitaApi visitaApi;
  final PagoRepository pagoRepository;
  final VisitaRepository visitaRepository;

  bool _running = false;

  SyncService({
    required this.queueDao,
    required this.pagoApi,
    required this.visitaApi,
    required this.pagoRepository,
    required this.visitaRepository,
  });

  Future<void> syncPending() async {
    if (_running) return;
    _running = true;

    try {
      final items = await queueDao.getPending();

      for (final item in items) {
        await queueDao.markSyncing(item.id);

        try {
          final payload = jsonDecode(item.payloadJson) as Map<String, dynamic>;

          switch (item.entityType) {
            case 'pago':
              final response = await pagoApi.crearPago(payload);
              final serverId = response.data['id_pago'] ?? response.data['id'];

              if (serverId == null) {
                throw Exception('Respuesta sin id_pago');
              }

              await pagoRepository.markPagoSynced(
                localUuid: item.entityLocalId,
                serverId: serverId,
              );

              await queueDao.markSynced(item.id);
              break;

            case 'visita':
              final response = await visitaApi.crearVisita(payload);
              final serverId = response.data['id_visita'] ?? response.data['id'];

              if (serverId == null) {
                throw Exception('Respuesta sin id_visita');
              }

              await visitaRepository.markVisitaSynced(
                localUuid: item.entityLocalId,
                serverId: serverId,
              );

              await queueDao.markSynced(item.id);
              break;

            default:
              await queueDao.markError(item.id, 'entity_type no soportado: ${item.entityType}');
              break;
          }
        } on DioException catch (e) {
          final code = e.response?.statusCode;

          if (code == null) {
            await queueDao.markPendingAgain(item.id, 'Error de red: ${e.message}');
            continue;
          }

          if (code == 409) {
            await queueDao.markConflict(item.id, 'Conflicto: ${e.response?.data}');
            continue;
          }

          if (code >= 400 && code < 500) {
            await queueDao.markError(item.id, 'Validación: ${e.response?.data}');
            continue;
          }

          await queueDao.markPendingAgain(item.id, 'Servidor/red: ${e.message}');
        } catch (e) {
          await queueDao.markError(item.id, e.toString());
        }
      }
    } finally {
      _running = false;
    }
  }
}