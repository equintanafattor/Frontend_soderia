import 'dart:convert';
import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import '../data/local/app_database.dart';
import '../data/local/daos/sync_queue_dao.dart';

class PagoRepository {
  final AppDatabase db;
  final SyncQueueDao queueDao;
  final Uuid _uuid = const Uuid();

  PagoRepository({required this.db, required this.queueDao});

  Future<String> registrarPagoOffline({
    required int legajo,
    required int idCuenta,
    required int idRepartoDia,
    required int idMedioPago,
    required double monto,
    String? observacion,
    int? userId,
    String? deviceId,
  }) async {
    final localUuid = _uuid.v4();
    final now = DateTime.now();

    await db.transaction(() async {
      await db
          .into(db.pagosLocales)
          .insert(
            PagosLocalesCompanion.insert(
              localUuid: localUuid,
              legajo: legajo,
              idCuenta: idCuenta,
              idRepartoDia: idRepartoDia,
              idMedioPago: idMedioPago,
              monto: monto,
              fecha: now,
              observacion: Value(observacion),
            ),
          );

      await queueDao.enqueue(
        localOperationId: _uuid.v4(),
        entityType: 'pago',
        entityLocalId: localUuid,
        action: 'CREATE',
        payloadJson: jsonEncode({
          'client_uuid': localUuid,
          'idempotency_key': localUuid,
          'legajo': legajo,
          'id_cuenta': idCuenta,
          'id_repartodia': idRepartoDia,
          'id_medio_pago': idMedioPago,
          'fecha': now.toIso8601String(),
          'monto': monto,
          'tipo_pago': 'cobro_reparto',
          'observacion': observacion,
        }),
        idempotencyKey: localUuid,
        userId: userId,
        deviceId: deviceId,
      );

      final cuenta = await (db.select(
        db.clientesLocal,
      )..where((t) => t.legajo.equals(legajo))).getSingleOrNull();

      if (cuenta != null) {
        final nuevaDeuda = (cuenta.deuda - monto)
            .clamp(0.0, double.infinity)
            .toDouble();
        final nuevoSaldo = (cuenta.saldo + monto).toDouble();

        await (db.update(
          db.clientesLocal,
        )..where((t) => t.legajo.equals(legajo))).write(
          ClientesLocalCompanion(
            saldo: Value(nuevoSaldo),
            deuda: Value(nuevaDeuda),
            updatedAt: Value(now),
          ),
        );
      }
    });

    return localUuid;
  }

  Future<void> markPagoSynced({
    required String localUuid,
    required int serverId,
  }) async {
    await (db.update(
      db.pagosLocales,
    )..where((t) => t.localUuid.equals(localUuid))).write(
      PagosLocalesCompanion(
        serverId: Value(serverId),
        estadoSync: const Value('SYNCED'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> markPagoError(String localUuid) async {
    await (db.update(
      db.pagosLocales,
    )..where((t) => t.localUuid.equals(localUuid))).write(
      PagosLocalesCompanion(
        estadoSync: const Value('ERROR'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
