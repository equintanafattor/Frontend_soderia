import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' show Value;

import '../data/local/app_database.dart';
import '../data/local/daos/sync_queue_dao.dart';

class PedidoRepository {
  final AppDatabase db;
  final SyncQueueDao queueDao;
  final Uuid _uuid = const Uuid();

  PedidoRepository({required this.db, required this.queueDao});

  Future<String> crearPedidoOffline({
    required int legajo,
    required int idCuenta,
    required int idRepartoDia,
    required int idMedioPago,
    required double montoTotal,
    required List<Map<String, dynamic>> items,
    String? observacion,
    int? userId,
    String? deviceId,
  }) async {
    final localUuid = _uuid.v4();
    final now = DateTime.now();

    await db.transaction(() async {
      // 1. Guardar pedido
      await db
          .into(db.pedidosLocales)
          .insert(
            PedidosLocalesCompanion.insert(
              localUuid: localUuid,
              legajo: legajo,
              idCuenta: idCuenta,
              idRepartoDia: idRepartoDia,
              idMedioPago: idMedioPago,
              montoTotal: montoTotal,
              estado: 'pendiente',
              fecha: now,
              observacion: Value(observacion),
            ),
          );

      // 2. Guardar items
      for (final item in items) {
        await db
            .into(db.pedidoItemsLocales)
            .insert(
              PedidoItemsLocalesCompanion.insert(
                pedidoLocalUuid: localUuid,
                idProducto: Value(item['id_producto']),
                idCombo: Value(item['id_combo']),
                cantidad: item['cantidad'],
                precioUnitario: item['precio_unitario'],
              ),
            );
      }

      // 3. Actualizar deuda local
      final cliente = await (db.select(
        db.clientesLocal,
      )..where((t) => t.legajo.equals(legajo))).getSingleOrNull();

      if (cliente != null) {
        final nuevaDeuda = cliente.deuda + montoTotal;

        await (db.update(
          db.clientesLocal,
        )..where((t) => t.legajo.equals(legajo))).write(
          ClientesLocalCompanion(
            deuda: Value(nuevaDeuda),
            updatedAt: Value(now),
          ),
        );
      }

      // 4. Encolar sync
      await queueDao.enqueue(
        localOperationId: _uuid.v4(),
        entityType: 'pedido',
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
          'monto_total': montoTotal,
          'observacion': observacion,
          'items': items,
        }),
        idempotencyKey: localUuid,
        userId: userId,
        deviceId: deviceId,
      );
    });

    return localUuid;
  }
}
