import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

import '../data/local/app_database.dart';
import '../data/local/daos/sync_queue_dao.dart';
import '../core/net/api_client.dart';

class SyncService {
  final AppDatabase db;
  final SyncQueueDao queueDao;
  final Dio _dio = ApiClient.dio;

  bool _isSyncing = false;

  SyncService({required this.db, required this.queueDao});

  Future<void> syncPendientes() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final pendientes = await queueDao.getPendientes();

      for (final op in pendientes) {
        await _procesarOperacion(op);
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _procesarOperacion(SyncQueueData op) async {
    try {
      await queueDao.markSyncing(op.id);

      final payload = jsonDecode(op.payloadJson);

      switch (op.entityType) {
        case 'pago':
          await _syncPago(op, payload);
          break;

        case 'visita':
          await _syncVisita(op, payload);
          break;

        case 'pedido':
          await _syncPedido(op, payload);
          break;

        default:
          throw Exception('Tipo no soportado: ${op.entityType}');
      }

      await queueDao.markSynced(op.id);
    } catch (e) {
      await queueDao.markError(op.id, e.toString());
    }
  }

  // -----------------------------
  // PAGO
  // -----------------------------
  Future<void> _syncPago(SyncQueueData op, Map<String, dynamic> payload) async {
    final resp = await _dio.post(
      '/pagos',
      data: payload,
      options: Options(
        headers: {'Idempotency-Key': payload['idempotency_key']},
      ),
    );

    final serverId = resp.data['id_pago'];

    await (db.update(
      db.pagosLocales,
    )..where((t) => t.localUuid.equals(op.entityLocalId))).write(
      PagosLocalesCompanion(
        serverId: Value(serverId),
        estadoSync: const Value('SYNCED'),
      ),
    );
  }

  // -----------------------------
  // VISITA
  // -----------------------------
  Future<void> _syncVisita(
    SyncQueueData op,
    Map<String, dynamic> payload,
  ) async {
    final resp = await _dio.post(
      '/visitas',
      data: payload,
      options: Options(
        headers: {'Idempotency-Key': payload['idempotency_key']},
      ),
    );

    final serverId = resp.data['id_visita'];

    await (db.update(
      db.visitasLocales,
    )..where((t) => t.localUuid.equals(op.entityLocalId))).write(
      VisitasLocalesCompanion(
        serverId: Value(serverId),
        estadoSync: const Value('SYNCED'),
      ),
    );
  }

  // -----------------------------
  // PEDIDO
  // -----------------------------
  Future<void> _syncPedido(
    SyncQueueData op,
    Map<String, dynamic> payload,
  ) async {
    final resp = await _dio.post(
      '/pedidos',
      data: payload,
      options: Options(
        headers: {'Idempotency-Key': payload['idempotency_key']},
      ),
    );

    final serverId = resp.data['id_pedido'];

    await (db.update(
      db.pedidosLocales,
    )..where((t) => t.localUuid.equals(op.entityLocalId))).write(
      PedidosLocalesCompanion(
        serverId: Value(serverId),
        estadoSync: const Value('SYNCED'),
      ),
    );
  }
}
