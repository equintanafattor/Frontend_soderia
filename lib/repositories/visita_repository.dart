import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../data/local/app_database.dart';
import '../data/local/daos/sync_queue_dao.dart';
import 'package:drift/drift.dart' as drift;

class VisitaRepository {
  final AppDatabase db;
  final SyncQueueDao queueDao;
  final Uuid _uuid = const Uuid();

  VisitaRepository({
    required this.db,
    required this.queueDao,
  });

  Future<String> registrarVisitaOffline({
    required int legajo,
    required String estado,
    int? userId,
    String? deviceId,
  }) async {
    final localUuid = _uuid.v4();
    final now = DateTime.now();

    await db.transaction(() async {
      await db.into(db.visitasLocales).insert(
        VisitasLocalesCompanion.insert(
          localUuid: localUuid,
          legajo: legajo,
          fecha: now,
          estado: estado,
        ),
      );

      await queueDao.enqueue(
        localOperationId: _uuid.v4(),
        entityType: 'visita',
        entityLocalId: localUuid,
        action: 'CREATE',
        payloadJson: jsonEncode({
          'client_uuid': localUuid,
          'idempotency_key': localUuid,
          'legajo': legajo,
          'fecha': now.toIso8601String(),
          'estado': estado,
        }),
        idempotencyKey: localUuid,
        userId: userId,
        deviceId: deviceId,
      );
    });

    return localUuid;
  }

  Future<void> markVisitaSynced({
    required String localUuid,
    required int serverId,
  }) async {
    await (db.update(db.visitasLocales)
          ..where((t) => t.localUuid.equals(localUuid)))
        .write(
      VisitasLocalesCompanion(
        serverId: drift.Value(serverId),
        estadoSync: const drift.Value('SYNCED'),
      ),
    );
  }
}