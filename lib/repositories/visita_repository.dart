import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../data/local/app_database.dart';
import '../data/local/daos/sync_queue_dao.dart';
import 'package:drift/drift.dart' as drift;

/// Movimiento de envase asociado a una visita (entrega/devolucion sin compra).
class EnvaseMovimientoVisita {
  final int idProducto;
  final int entregados;
  final int devueltos;
  final String? observacion;

  const EnvaseMovimientoVisita({
    required this.idProducto,
    this.entregados = 0,
    this.devueltos = 0,
    this.observacion,
  });

  Map<String, dynamic> toJson() => {
    'id_producto': idProducto,
    'entregados': entregados,
    'devueltos': devueltos,
    if (observacion != null) 'observacion': observacion,
  };
}

class VisitaRepository {
  final AppDatabase db;
  final SyncQueueDao queueDao;
  final Uuid _uuid = const Uuid();

  VisitaRepository({required this.db, required this.queueDao});

  Future<String> registrarVisitaOffline({
    required int legajo,
    required String estado,
    int? userId,
    String? deviceId,
    int? idRepartoDia,
    List<EnvaseMovimientoVisita> envases = const [],
  }) async {
    final localUuid = _uuid.v4();
    final now = DateTime.now();

    await db.transaction(() async {
      await db
          .into(db.visitasLocales)
          .insert(
            VisitasLocalesCompanion.insert(
              localUuid: localUuid,
              legajo: legajo,
              fecha: now,
              estado: estado,
            ),
          );

      // Reflejar el nuevo estado en RepartoClientesLocal para que la
      // agenda (HomeScreen) lo muestre sin necesitar un bootstrap completo.
      final idRepartoActual = await db
          .select(db.repartoActualLocal)
          .getSingleOrNull();
      if (idRepartoActual != null) {
        await (db.update(db.repartoClientesLocal)..where(
              (t) =>
                  t.idReparto.equals(idRepartoActual.idReparto) &
                  t.legajo.equals(legajo),
            ))
            .write(
              RepartoClientesLocalCompanion(
                estadoVisita: drift.Value(estado),
                updatedAt: drift.Value(now),
              ),
            );
      }

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
          if (idRepartoDia != null) 'id_repartodia': idRepartoDia,
          if (envases.isNotEmpty)
            'envases': envases.map((e) => e.toJson()).toList(),
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
    await (db.update(
      db.visitasLocales,
    )..where((t) => t.localUuid.equals(localUuid))).write(
      VisitasLocalesCompanion(
        serverId: drift.Value(serverId),
        estadoSync: const drift.Value('SYNCED'),
      ),
    );
  }
}
