import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart as p';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class ClientesLocal extends Table {
  IntColumn get legajo => integer()();
  TextColumn get nombre => text()();
  TextColumn get direccion => text().nullable()();
  TextColumn get telefono => text().nullable()();
  RealColumn get saldo => real().withDefault(const Constant(0))();
  RealColumn get deuda => real().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {legajo};
}

class RepartoClientesLocal extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get idReparto => integer()();
  IntColumn get legajo => integer()();
  TextColumn get turno => text().nullable()();
  IntColumn get posicion => integer().nullable()();
  TextColumn get estadoVisita => text().nullable()();
  TextColumn get observacion => text().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}

class PagosLocales extends Table {
  TextColumn get localUuid => text()();
  IntColumn get serverId => integer().nullable()();
  IntColumn get legajo => integer()();
  IntColumn get idCuenta => integer()();
  IntColumn get idRepartoDia => integer()();
  IntColumn get idMedioPago => integer()();
  RealColumn get monto => real()();
  DateTimeColumn get fecha => dateTime()();
  TextColumn get observacion => text().nullable()();
  TextColumn get estadoSync => text().withDefault(const Constant('PENDING'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {localUuid};
}

class VisitasLocales extends Table {
  TextColumn get localUuid => text()();
  IntColumn get serverId => integer().nullable()();
  IntColumn get legajo => integer()();
  DateTimeColumn get fecha => dateTime()();
  TextColumn get estado => text()();
  TextColumn get estadoSync => text().withDefault(const Constant('PENDING'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {localUuid};
}

class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get localOperationId => text()();
  TextColumn get entityType => text()(); // pago, visita, agenda
  TextColumn get entityLocalId => text()(); // uuid local o string del registro
  TextColumn get action => text()(); // CREATE, UPDATE, DELETE
  TextColumn get payloadJson => text()();
  TextColumn get idempotencyKey => text()();
  TextColumn get deviceId => text().nullable()();
  IntColumn get userId => integer().nullable()();
  TextColumn get status => text().withDefault(const Constant('PENDING'))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}

@DriftDatabase(
  tables: [
    ClientesLocal,
    RepartoClientesLocal,
    PagosLocales,
    VisitasLocales,
    SyncQueue,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'reparto_offline.sqlite'));
    return NativeDatabase(file);
  });
}