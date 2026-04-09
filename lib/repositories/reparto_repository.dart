import 'package:drift/drift.dart' show Value, Variable;

import '../data/local/app_database.dart';
import '../data/remote/reparto_api.dart';

class RepartoRepository {
  final AppDatabase db;
  final RepartoApi api;

  RepartoRepository({required this.db, required this.api});

  Future<void> bootstrapDelDia({
    required DateTime fecha,
    int? idEmpresa,
    int? idUsuario,
    String? turno,
  }) async {
    final fechaIso = _soloFecha(fecha);

    final repartoResp = await api.obtenerRepartoPorFecha(
      fechaIso: fechaIso,
      idEmpresa: idEmpresa,
      idUsuario: idUsuario,
    );

    final agendaResp = await api.obtenerAgendaPorFecha(
      fechaIso: fechaIso,
      turno: turno,
    );

    final reparto = Map<String, dynamic>.from(repartoResp.data);
    final agenda = Map<String, dynamic>.from(agendaResp.data);
    final clientesAgenda = List<Map<String, dynamic>>.from(
      agenda['clientes'] ?? const [],
    );

    await db.transaction(() async {
      await db.delete(db.repartoActualLocal).go();
      await db.delete(db.repartoClientesLocal).go();

      await db
          .into(db.repartoActualLocal)
          .insert(
            RepartoActualLocalCompanion(
              idReparto: Value(reparto['id_repartodia'] as int),
              fecha: Value(DateTime.parse(reparto['fecha'] as String)),
              idUsuario: Value(reparto['id_usuario'] as int?),
              idEmpresa: Value(reparto['id_empresa'] as int?),
              observacion: Value(reparto['observacion'] as String?),
              updatedAt: Value(DateTime.now()),
            ),
          );

      final legajos = clientesAgenda
          .map((c) => c['legajo'])
          .whereType<int>()
          .toSet()
          .toList();

      if (legajos.isNotEmpty) {
        await (db.delete(
          db.clientesLocal,
        )..where((t) => t.legajo.isIn(legajos))).go();
      }

      for (final item in clientesAgenda) {
        final legajo = item['legajo'] as int;

        final detalleResp = await api.obtenerDetalleCliente(legajo);
        final detalle = Map<String, dynamic>.from(detalleResp.data);

        final persona = detalle['persona'] as Map<String, dynamic>?;
        final direcciones = List<Map<String, dynamic>>.from(
          detalle['direcciones'] ?? const [],
        );
        final telefonos = List<Map<String, dynamic>>.from(
          detalle['telefonos'] ?? const [],
        );
        final cuentas = List<Map<String, dynamic>>.from(
          detalle['cuentas'] ?? const [],
        );

        final direccion = direcciones.isNotEmpty
            ? direcciones.first['direccion'] as String?
            : null;

        final telefono = telefonos.isNotEmpty
            ? telefonos.first['nro_telefono'] as String?
            : null;

        final cuenta = cuentas.isNotEmpty ? cuentas.first : null;
        final idCuenta = (cuenta?['id_cuenta'] as num?)?.toInt();
        final saldo = _toDouble(cuenta?['saldo']);
        final deuda = _toDouble(cuenta?['deuda']);

        final nombre = [
          persona?['apellido']?.toString().trim(),
          persona?['nombre']?.toString().trim(),
        ].where((e) => e != null && e!.isNotEmpty).join(', ');

        await db
            .into(db.clientesLocal)
            .insert(
              ClientesLocalCompanion(
                legajo: Value(legajo),
                nombre: Value(nombre.isEmpty ? 'Cliente $legajo' : nombre),
                direccion: Value(direccion),
                telefono: Value(telefono),
                idCuenta: Value(idCuenta),
                saldo: Value(saldo),
                deuda: Value(deuda),
                updatedAt: Value(DateTime.now()),
              ),
            );

        await db
            .into(db.repartoClientesLocal)
            .insert(
              RepartoClientesLocalCompanion(
                idReparto: Value(reparto['id_repartodia'] as int),
                legajo: Value(legajo),
                turno: Value(item['turno_visita'] as String?),
                posicion: const Value.absent(),
                estadoVisita: Value(item['estado_visita'] as String?),
                observacion: Value(detalle['observacion'] as String?),
                dirty: const Value(false),
                updatedAt: Value(DateTime.now()),
              ),
            );
      }
    });
  }

  Future<int?> obtenerIdRepartoActualLocal() async {
    final row = await db.select(db.repartoActualLocal).getSingleOrNull();
    return row?.idReparto;
  }

  Future<RepartoActualLocalData?> obtenerRepartoActualLocal() {
    return db.select(db.repartoActualLocal).getSingleOrNull();
  }

  Future<List<RepartoClienteConDatos>> obtenerClientesDelDiaLocal({
    required int idReparto,
  }) async {
    final rows = await db
        .customSelect(
          '''
      SELECT
        r.id,
        r.id_reparto,
        r.legajo,
        r.turno,
        r.posicion,
        r.estado_visita,
        r.observacion,
        c.nombre,
        c.direccion,
        c.telefono,
        c.saldo,
        c.deuda
      FROM reparto_clientes_local r
      INNER JOIN clientes_local c ON c.legajo = r.legajo
      WHERE r.id_reparto = ?
      ORDER BY
        CASE WHEN r.turno IS NULL THEN 1 ELSE 0 END,
        r.turno,
        CASE WHEN r.posicion IS NULL THEN 999999 ELSE r.posicion END,
        c.nombre
      ''',
          variables: [Variable.withInt(idReparto)],
          readsFrom: {db.repartoClientesLocal, db.clientesLocal},
        )
        .get();

    return rows
        .map(
          (r) => RepartoClienteConDatos(
            id: r.read<int>('id') ?? 0,
            idReparto: r.read<int>('id_reparto') ?? 0,
            legajo: r.read<int>('legajo') ?? 0,
            turno: r.read<String>('turno'),
            posicion: r.read<int>('posicion'),
            estadoVisita: r.read<String>('estado_visita'),
            observacion: r.read<String>('observacion'),
            nombre: r.read<String>('nombre') ?? '',
            direccion: r.read<String>('direccion'),
            telefono: r.read<String>('telefono'),
            saldo: r.read<double>('saldo') ?? 0,
            deuda: r.read<double>('deuda') ?? 0,
          ),
        )
        .toList();
  }

  String _soloFecha(DateTime fecha) {
    final y = fecha.year.toString().padLeft(4, '0');
    final m = fecha.month.toString().padLeft(2, '0');
    final d = fecha.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}

class RepartoClienteConDatos {
  final int id;
  final int idReparto;
  final int legajo;
  final String? turno;
  final int? posicion;
  final String? estadoVisita;
  final String? observacion;
  final String nombre;
  final String? direccion;
  final String? telefono;
  final double saldo;
  final double deuda;

  RepartoClienteConDatos({
    required this.id,
    required this.idReparto,
    required this.legajo,
    required this.turno,
    required this.posicion,
    required this.estadoVisita,
    required this.observacion,
    required this.nombre,
    required this.direccion,
    required this.telefono,
    required this.saldo,
    required this.deuda,
  });
}
