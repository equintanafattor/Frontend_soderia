// lib/repositories/visita_repository.dart

import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../data/local/app_database.dart';
import '../data/local/daos/sync_queue_dao.dart';

class VisitaRepository {
  final AppDatabase db;
  final SyncQueueDao queueDao;

  VisitaRepository({required this.db, required this.queueDao});

  Future<void> registrarVisitaOffline({
    required int legajo,
    required String estado,
  }) async {
    final localUuid = const Uuid().v4();
    final ahora = DateTime.now();

    // 1. Guardar en tabla local
    await db
        .into(db.visitasLocales)
        .insert(
          VisitasLocalesCompanion.insert(
            localUuid: localUuid,
            legajo: legajo,
            fecha: ahora,
            estado: estado,
            estadoSync: const Value('PENDING'),
          ),
        );

    // 2. Encolar en SyncQueue para sincronizar con el backend
    await queueDao.enqueue(
      localOperationId: localUuid,
      entityType: 'visita',
      entityLocalId: localUuid,
      action: 'CREATE',
      payloadJson: jsonEncode({
        'legajo': legajo,
        'estado': estado,
        'fecha': ahora.toIso8601String(),
        'idempotency_key': localUuid,
        'client_uuid': localUuid,
      }),
      idempotencyKey: localUuid,
    );
  }
}
