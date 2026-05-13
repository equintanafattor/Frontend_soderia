import 'package:drift/drift.dart';
import '../app_database.dart';

class SyncQueueDao {
  final AppDatabase db;

  SyncQueueDao(this.db);

  Future<void> enqueue({
    required String localOperationId,
    required String entityType,
    required String entityLocalId,
    required String action,
    required String payloadJson,
    required String idempotencyKey,
    String? deviceId,
    int? userId,
  }) async {
    await db
        .into(db.syncQueue)
        .insert(
          SyncQueueCompanion.insert(
            localOperationId: localOperationId,
            entityType: entityType,
            entityLocalId: entityLocalId,
            action: action,
            payloadJson: payloadJson,
            idempotencyKey: idempotencyKey,
            deviceId: Value(deviceId),
            userId: Value(userId),
          ),
        );
  }

  Future<List<SyncQueueData>> getPending() {
    return (db.select(db.syncQueue)
          ..where((t) => t.status.isIn(['PENDING', 'ERROR']))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Future<List<SyncQueueData>> getPendientes() {
    return (db.select(db.syncQueue)
          ..where((t) => t.status.equals('PENDING'))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Future<void> markSyncing(int id) async {
    await (db.update(db.syncQueue)..where((t) => t.id.equals(id))).write(
      SyncQueueCompanion(
        status: const Value('SYNCING'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> markSynced(int id) async {
    await (db.update(db.syncQueue)..where((t) => t.id.equals(id))).write(
      SyncQueueCompanion(
        status: const Value('SYNCED'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> markPendingAgain(int id, String error) async {
    await (db.update(db.syncQueue)..where((t) => t.id.equals(id))).write(
      SyncQueueCompanion(
        status: const Value('PENDING'),
        lastError: Value(error),
        updatedAt: Value(DateTime.now()),
      ),
    );

    await db.customStatement(
      'UPDATE sync_queue SET retry_count = retry_count + 1 WHERE id = ?',
      [id],
    );
  }

  Future<void> markConflict(int id, String error) async {
    await (db.update(db.syncQueue)..where((t) => t.id.equals(id))).write(
      SyncQueueCompanion(
        status: const Value('CONFLICT'),
        lastError: Value(error),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> markError(int id, String error) async {
    await (db.update(db.syncQueue)..where((t) => t.id.equals(id))).write(
      SyncQueueCompanion(
        status: const Value('ERROR'),
        lastError: Value(error),
        updatedAt: Value(DateTime.now()),
      ),
    );

    await db.customStatement(
      'UPDATE sync_queue SET retry_count = retry_count + 1 WHERE id = ?',
      [id],
    );
  }

  Stream<int> watchPendingCount() {
    final countExpression = db.syncQueue.id.count();

    final query = db.selectOnly(db.syncQueue)
      ..addColumns([countExpression])
      ..where(db.syncQueue.status.isIn(['PENDING', 'ERROR', 'CONFLICT']));

    return query.watchSingle().map((row) => row.read(countExpression) ?? 0);
  }
}
