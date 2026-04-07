// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ClientesLocalTable extends ClientesLocal
    with TableInfo<$ClientesLocalTable, ClientesLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientesLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _legajoMeta = const VerificationMeta('legajo');
  @override
  late final GeneratedColumn<int> legajo = GeneratedColumn<int>(
    'legajo',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _direccionMeta = const VerificationMeta(
    'direccion',
  );
  @override
  late final GeneratedColumn<String> direccion = GeneratedColumn<String>(
    'direccion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _telefonoMeta = const VerificationMeta(
    'telefono',
  );
  @override
  late final GeneratedColumn<String> telefono = GeneratedColumn<String>(
    'telefono',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _saldoMeta = const VerificationMeta('saldo');
  @override
  late final GeneratedColumn<double> saldo = GeneratedColumn<double>(
    'saldo',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _deudaMeta = const VerificationMeta('deuda');
  @override
  late final GeneratedColumn<double> deuda = GeneratedColumn<double>(
    'deuda',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    legajo,
    nombre,
    direccion,
    telefono,
    saldo,
    deuda,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clientes_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClientesLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('legajo')) {
      context.handle(
        _legajoMeta,
        legajo.isAcceptableOrUnknown(data['legajo']!, _legajoMeta),
      );
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('direccion')) {
      context.handle(
        _direccionMeta,
        direccion.isAcceptableOrUnknown(data['direccion']!, _direccionMeta),
      );
    }
    if (data.containsKey('telefono')) {
      context.handle(
        _telefonoMeta,
        telefono.isAcceptableOrUnknown(data['telefono']!, _telefonoMeta),
      );
    }
    if (data.containsKey('saldo')) {
      context.handle(
        _saldoMeta,
        saldo.isAcceptableOrUnknown(data['saldo']!, _saldoMeta),
      );
    }
    if (data.containsKey('deuda')) {
      context.handle(
        _deudaMeta,
        deuda.isAcceptableOrUnknown(data['deuda']!, _deudaMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {legajo};
  @override
  ClientesLocalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClientesLocalData(
      legajo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}legajo'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      direccion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direccion'],
      ),
      telefono: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}telefono'],
      ),
      saldo: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}saldo'],
      )!,
      deuda: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}deuda'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $ClientesLocalTable createAlias(String alias) {
    return $ClientesLocalTable(attachedDatabase, alias);
  }
}

class ClientesLocalData extends DataClass
    implements Insertable<ClientesLocalData> {
  final int legajo;
  final String nombre;
  final String? direccion;
  final String? telefono;
  final double saldo;
  final double deuda;
  final DateTime? updatedAt;
  const ClientesLocalData({
    required this.legajo,
    required this.nombre,
    this.direccion,
    this.telefono,
    required this.saldo,
    required this.deuda,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['legajo'] = Variable<int>(legajo);
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || direccion != null) {
      map['direccion'] = Variable<String>(direccion);
    }
    if (!nullToAbsent || telefono != null) {
      map['telefono'] = Variable<String>(telefono);
    }
    map['saldo'] = Variable<double>(saldo);
    map['deuda'] = Variable<double>(deuda);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  ClientesLocalCompanion toCompanion(bool nullToAbsent) {
    return ClientesLocalCompanion(
      legajo: Value(legajo),
      nombre: Value(nombre),
      direccion: direccion == null && nullToAbsent
          ? const Value.absent()
          : Value(direccion),
      telefono: telefono == null && nullToAbsent
          ? const Value.absent()
          : Value(telefono),
      saldo: Value(saldo),
      deuda: Value(deuda),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory ClientesLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClientesLocalData(
      legajo: serializer.fromJson<int>(json['legajo']),
      nombre: serializer.fromJson<String>(json['nombre']),
      direccion: serializer.fromJson<String?>(json['direccion']),
      telefono: serializer.fromJson<String?>(json['telefono']),
      saldo: serializer.fromJson<double>(json['saldo']),
      deuda: serializer.fromJson<double>(json['deuda']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'legajo': serializer.toJson<int>(legajo),
      'nombre': serializer.toJson<String>(nombre),
      'direccion': serializer.toJson<String?>(direccion),
      'telefono': serializer.toJson<String?>(telefono),
      'saldo': serializer.toJson<double>(saldo),
      'deuda': serializer.toJson<double>(deuda),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  ClientesLocalData copyWith({
    int? legajo,
    String? nombre,
    Value<String?> direccion = const Value.absent(),
    Value<String?> telefono = const Value.absent(),
    double? saldo,
    double? deuda,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => ClientesLocalData(
    legajo: legajo ?? this.legajo,
    nombre: nombre ?? this.nombre,
    direccion: direccion.present ? direccion.value : this.direccion,
    telefono: telefono.present ? telefono.value : this.telefono,
    saldo: saldo ?? this.saldo,
    deuda: deuda ?? this.deuda,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  ClientesLocalData copyWithCompanion(ClientesLocalCompanion data) {
    return ClientesLocalData(
      legajo: data.legajo.present ? data.legajo.value : this.legajo,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      direccion: data.direccion.present ? data.direccion.value : this.direccion,
      telefono: data.telefono.present ? data.telefono.value : this.telefono,
      saldo: data.saldo.present ? data.saldo.value : this.saldo,
      deuda: data.deuda.present ? data.deuda.value : this.deuda,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClientesLocalData(')
          ..write('legajo: $legajo, ')
          ..write('nombre: $nombre, ')
          ..write('direccion: $direccion, ')
          ..write('telefono: $telefono, ')
          ..write('saldo: $saldo, ')
          ..write('deuda: $deuda, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(legajo, nombre, direccion, telefono, saldo, deuda, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClientesLocalData &&
          other.legajo == this.legajo &&
          other.nombre == this.nombre &&
          other.direccion == this.direccion &&
          other.telefono == this.telefono &&
          other.saldo == this.saldo &&
          other.deuda == this.deuda &&
          other.updatedAt == this.updatedAt);
}

class ClientesLocalCompanion extends UpdateCompanion<ClientesLocalData> {
  final Value<int> legajo;
  final Value<String> nombre;
  final Value<String?> direccion;
  final Value<String?> telefono;
  final Value<double> saldo;
  final Value<double> deuda;
  final Value<DateTime?> updatedAt;
  const ClientesLocalCompanion({
    this.legajo = const Value.absent(),
    this.nombre = const Value.absent(),
    this.direccion = const Value.absent(),
    this.telefono = const Value.absent(),
    this.saldo = const Value.absent(),
    this.deuda = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ClientesLocalCompanion.insert({
    this.legajo = const Value.absent(),
    required String nombre,
    this.direccion = const Value.absent(),
    this.telefono = const Value.absent(),
    this.saldo = const Value.absent(),
    this.deuda = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : nombre = Value(nombre);
  static Insertable<ClientesLocalData> custom({
    Expression<int>? legajo,
    Expression<String>? nombre,
    Expression<String>? direccion,
    Expression<String>? telefono,
    Expression<double>? saldo,
    Expression<double>? deuda,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (legajo != null) 'legajo': legajo,
      if (nombre != null) 'nombre': nombre,
      if (direccion != null) 'direccion': direccion,
      if (telefono != null) 'telefono': telefono,
      if (saldo != null) 'saldo': saldo,
      if (deuda != null) 'deuda': deuda,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ClientesLocalCompanion copyWith({
    Value<int>? legajo,
    Value<String>? nombre,
    Value<String?>? direccion,
    Value<String?>? telefono,
    Value<double>? saldo,
    Value<double>? deuda,
    Value<DateTime?>? updatedAt,
  }) {
    return ClientesLocalCompanion(
      legajo: legajo ?? this.legajo,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      saldo: saldo ?? this.saldo,
      deuda: deuda ?? this.deuda,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (legajo.present) {
      map['legajo'] = Variable<int>(legajo.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (direccion.present) {
      map['direccion'] = Variable<String>(direccion.value);
    }
    if (telefono.present) {
      map['telefono'] = Variable<String>(telefono.value);
    }
    if (saldo.present) {
      map['saldo'] = Variable<double>(saldo.value);
    }
    if (deuda.present) {
      map['deuda'] = Variable<double>(deuda.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientesLocalCompanion(')
          ..write('legajo: $legajo, ')
          ..write('nombre: $nombre, ')
          ..write('direccion: $direccion, ')
          ..write('telefono: $telefono, ')
          ..write('saldo: $saldo, ')
          ..write('deuda: $deuda, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $RepartoClientesLocalTable extends RepartoClientesLocal
    with TableInfo<$RepartoClientesLocalTable, RepartoClientesLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RepartoClientesLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _idRepartoMeta = const VerificationMeta(
    'idReparto',
  );
  @override
  late final GeneratedColumn<int> idReparto = GeneratedColumn<int>(
    'id_reparto',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _legajoMeta = const VerificationMeta('legajo');
  @override
  late final GeneratedColumn<int> legajo = GeneratedColumn<int>(
    'legajo',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _turnoMeta = const VerificationMeta('turno');
  @override
  late final GeneratedColumn<String> turno = GeneratedColumn<String>(
    'turno',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _posicionMeta = const VerificationMeta(
    'posicion',
  );
  @override
  late final GeneratedColumn<int> posicion = GeneratedColumn<int>(
    'posicion',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estadoVisitaMeta = const VerificationMeta(
    'estadoVisita',
  );
  @override
  late final GeneratedColumn<String> estadoVisita = GeneratedColumn<String>(
    'estado_visita',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _observacionMeta = const VerificationMeta(
    'observacion',
  );
  @override
  late final GeneratedColumn<String> observacion = GeneratedColumn<String>(
    'observacion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    idReparto,
    legajo,
    turno,
    posicion,
    estadoVisita,
    observacion,
    dirty,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reparto_clientes_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<RepartoClientesLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('id_reparto')) {
      context.handle(
        _idRepartoMeta,
        idReparto.isAcceptableOrUnknown(data['id_reparto']!, _idRepartoMeta),
      );
    } else if (isInserting) {
      context.missing(_idRepartoMeta);
    }
    if (data.containsKey('legajo')) {
      context.handle(
        _legajoMeta,
        legajo.isAcceptableOrUnknown(data['legajo']!, _legajoMeta),
      );
    } else if (isInserting) {
      context.missing(_legajoMeta);
    }
    if (data.containsKey('turno')) {
      context.handle(
        _turnoMeta,
        turno.isAcceptableOrUnknown(data['turno']!, _turnoMeta),
      );
    }
    if (data.containsKey('posicion')) {
      context.handle(
        _posicionMeta,
        posicion.isAcceptableOrUnknown(data['posicion']!, _posicionMeta),
      );
    }
    if (data.containsKey('estado_visita')) {
      context.handle(
        _estadoVisitaMeta,
        estadoVisita.isAcceptableOrUnknown(
          data['estado_visita']!,
          _estadoVisitaMeta,
        ),
      );
    }
    if (data.containsKey('observacion')) {
      context.handle(
        _observacionMeta,
        observacion.isAcceptableOrUnknown(
          data['observacion']!,
          _observacionMeta,
        ),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RepartoClientesLocalData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RepartoClientesLocalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      idReparto: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id_reparto'],
      )!,
      legajo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}legajo'],
      )!,
      turno: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}turno'],
      ),
      posicion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}posicion'],
      ),
      estadoVisita: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado_visita'],
      ),
      observacion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observacion'],
      ),
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $RepartoClientesLocalTable createAlias(String alias) {
    return $RepartoClientesLocalTable(attachedDatabase, alias);
  }
}

class RepartoClientesLocalData extends DataClass
    implements Insertable<RepartoClientesLocalData> {
  final int id;
  final int idReparto;
  final int legajo;
  final String? turno;
  final int? posicion;
  final String? estadoVisita;
  final String? observacion;
  final bool dirty;
  final DateTime? updatedAt;
  const RepartoClientesLocalData({
    required this.id,
    required this.idReparto,
    required this.legajo,
    this.turno,
    this.posicion,
    this.estadoVisita,
    this.observacion,
    required this.dirty,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['id_reparto'] = Variable<int>(idReparto);
    map['legajo'] = Variable<int>(legajo);
    if (!nullToAbsent || turno != null) {
      map['turno'] = Variable<String>(turno);
    }
    if (!nullToAbsent || posicion != null) {
      map['posicion'] = Variable<int>(posicion);
    }
    if (!nullToAbsent || estadoVisita != null) {
      map['estado_visita'] = Variable<String>(estadoVisita);
    }
    if (!nullToAbsent || observacion != null) {
      map['observacion'] = Variable<String>(observacion);
    }
    map['dirty'] = Variable<bool>(dirty);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  RepartoClientesLocalCompanion toCompanion(bool nullToAbsent) {
    return RepartoClientesLocalCompanion(
      id: Value(id),
      idReparto: Value(idReparto),
      legajo: Value(legajo),
      turno: turno == null && nullToAbsent
          ? const Value.absent()
          : Value(turno),
      posicion: posicion == null && nullToAbsent
          ? const Value.absent()
          : Value(posicion),
      estadoVisita: estadoVisita == null && nullToAbsent
          ? const Value.absent()
          : Value(estadoVisita),
      observacion: observacion == null && nullToAbsent
          ? const Value.absent()
          : Value(observacion),
      dirty: Value(dirty),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory RepartoClientesLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RepartoClientesLocalData(
      id: serializer.fromJson<int>(json['id']),
      idReparto: serializer.fromJson<int>(json['idReparto']),
      legajo: serializer.fromJson<int>(json['legajo']),
      turno: serializer.fromJson<String?>(json['turno']),
      posicion: serializer.fromJson<int?>(json['posicion']),
      estadoVisita: serializer.fromJson<String?>(json['estadoVisita']),
      observacion: serializer.fromJson<String?>(json['observacion']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'idReparto': serializer.toJson<int>(idReparto),
      'legajo': serializer.toJson<int>(legajo),
      'turno': serializer.toJson<String?>(turno),
      'posicion': serializer.toJson<int?>(posicion),
      'estadoVisita': serializer.toJson<String?>(estadoVisita),
      'observacion': serializer.toJson<String?>(observacion),
      'dirty': serializer.toJson<bool>(dirty),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  RepartoClientesLocalData copyWith({
    int? id,
    int? idReparto,
    int? legajo,
    Value<String?> turno = const Value.absent(),
    Value<int?> posicion = const Value.absent(),
    Value<String?> estadoVisita = const Value.absent(),
    Value<String?> observacion = const Value.absent(),
    bool? dirty,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => RepartoClientesLocalData(
    id: id ?? this.id,
    idReparto: idReparto ?? this.idReparto,
    legajo: legajo ?? this.legajo,
    turno: turno.present ? turno.value : this.turno,
    posicion: posicion.present ? posicion.value : this.posicion,
    estadoVisita: estadoVisita.present ? estadoVisita.value : this.estadoVisita,
    observacion: observacion.present ? observacion.value : this.observacion,
    dirty: dirty ?? this.dirty,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  RepartoClientesLocalData copyWithCompanion(
    RepartoClientesLocalCompanion data,
  ) {
    return RepartoClientesLocalData(
      id: data.id.present ? data.id.value : this.id,
      idReparto: data.idReparto.present ? data.idReparto.value : this.idReparto,
      legajo: data.legajo.present ? data.legajo.value : this.legajo,
      turno: data.turno.present ? data.turno.value : this.turno,
      posicion: data.posicion.present ? data.posicion.value : this.posicion,
      estadoVisita: data.estadoVisita.present
          ? data.estadoVisita.value
          : this.estadoVisita,
      observacion: data.observacion.present
          ? data.observacion.value
          : this.observacion,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RepartoClientesLocalData(')
          ..write('id: $id, ')
          ..write('idReparto: $idReparto, ')
          ..write('legajo: $legajo, ')
          ..write('turno: $turno, ')
          ..write('posicion: $posicion, ')
          ..write('estadoVisita: $estadoVisita, ')
          ..write('observacion: $observacion, ')
          ..write('dirty: $dirty, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    idReparto,
    legajo,
    turno,
    posicion,
    estadoVisita,
    observacion,
    dirty,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RepartoClientesLocalData &&
          other.id == this.id &&
          other.idReparto == this.idReparto &&
          other.legajo == this.legajo &&
          other.turno == this.turno &&
          other.posicion == this.posicion &&
          other.estadoVisita == this.estadoVisita &&
          other.observacion == this.observacion &&
          other.dirty == this.dirty &&
          other.updatedAt == this.updatedAt);
}

class RepartoClientesLocalCompanion
    extends UpdateCompanion<RepartoClientesLocalData> {
  final Value<int> id;
  final Value<int> idReparto;
  final Value<int> legajo;
  final Value<String?> turno;
  final Value<int?> posicion;
  final Value<String?> estadoVisita;
  final Value<String?> observacion;
  final Value<bool> dirty;
  final Value<DateTime?> updatedAt;
  const RepartoClientesLocalCompanion({
    this.id = const Value.absent(),
    this.idReparto = const Value.absent(),
    this.legajo = const Value.absent(),
    this.turno = const Value.absent(),
    this.posicion = const Value.absent(),
    this.estadoVisita = const Value.absent(),
    this.observacion = const Value.absent(),
    this.dirty = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  RepartoClientesLocalCompanion.insert({
    this.id = const Value.absent(),
    required int idReparto,
    required int legajo,
    this.turno = const Value.absent(),
    this.posicion = const Value.absent(),
    this.estadoVisita = const Value.absent(),
    this.observacion = const Value.absent(),
    this.dirty = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : idReparto = Value(idReparto),
       legajo = Value(legajo);
  static Insertable<RepartoClientesLocalData> custom({
    Expression<int>? id,
    Expression<int>? idReparto,
    Expression<int>? legajo,
    Expression<String>? turno,
    Expression<int>? posicion,
    Expression<String>? estadoVisita,
    Expression<String>? observacion,
    Expression<bool>? dirty,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (idReparto != null) 'id_reparto': idReparto,
      if (legajo != null) 'legajo': legajo,
      if (turno != null) 'turno': turno,
      if (posicion != null) 'posicion': posicion,
      if (estadoVisita != null) 'estado_visita': estadoVisita,
      if (observacion != null) 'observacion': observacion,
      if (dirty != null) 'dirty': dirty,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  RepartoClientesLocalCompanion copyWith({
    Value<int>? id,
    Value<int>? idReparto,
    Value<int>? legajo,
    Value<String?>? turno,
    Value<int?>? posicion,
    Value<String?>? estadoVisita,
    Value<String?>? observacion,
    Value<bool>? dirty,
    Value<DateTime?>? updatedAt,
  }) {
    return RepartoClientesLocalCompanion(
      id: id ?? this.id,
      idReparto: idReparto ?? this.idReparto,
      legajo: legajo ?? this.legajo,
      turno: turno ?? this.turno,
      posicion: posicion ?? this.posicion,
      estadoVisita: estadoVisita ?? this.estadoVisita,
      observacion: observacion ?? this.observacion,
      dirty: dirty ?? this.dirty,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (idReparto.present) {
      map['id_reparto'] = Variable<int>(idReparto.value);
    }
    if (legajo.present) {
      map['legajo'] = Variable<int>(legajo.value);
    }
    if (turno.present) {
      map['turno'] = Variable<String>(turno.value);
    }
    if (posicion.present) {
      map['posicion'] = Variable<int>(posicion.value);
    }
    if (estadoVisita.present) {
      map['estado_visita'] = Variable<String>(estadoVisita.value);
    }
    if (observacion.present) {
      map['observacion'] = Variable<String>(observacion.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RepartoClientesLocalCompanion(')
          ..write('id: $id, ')
          ..write('idReparto: $idReparto, ')
          ..write('legajo: $legajo, ')
          ..write('turno: $turno, ')
          ..write('posicion: $posicion, ')
          ..write('estadoVisita: $estadoVisita, ')
          ..write('observacion: $observacion, ')
          ..write('dirty: $dirty, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PagosLocalesTable extends PagosLocales
    with TableInfo<$PagosLocalesTable, PagosLocale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PagosLocalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localUuidMeta = const VerificationMeta(
    'localUuid',
  );
  @override
  late final GeneratedColumn<String> localUuid = GeneratedColumn<String>(
    'local_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _legajoMeta = const VerificationMeta('legajo');
  @override
  late final GeneratedColumn<int> legajo = GeneratedColumn<int>(
    'legajo',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idCuentaMeta = const VerificationMeta(
    'idCuenta',
  );
  @override
  late final GeneratedColumn<int> idCuenta = GeneratedColumn<int>(
    'id_cuenta',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idRepartoDiaMeta = const VerificationMeta(
    'idRepartoDia',
  );
  @override
  late final GeneratedColumn<int> idRepartoDia = GeneratedColumn<int>(
    'id_reparto_dia',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMedioPagoMeta = const VerificationMeta(
    'idMedioPago',
  );
  @override
  late final GeneratedColumn<int> idMedioPago = GeneratedColumn<int>(
    'id_medio_pago',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _montoMeta = const VerificationMeta('monto');
  @override
  late final GeneratedColumn<double> monto = GeneratedColumn<double>(
    'monto',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _observacionMeta = const VerificationMeta(
    'observacion',
  );
  @override
  late final GeneratedColumn<String> observacion = GeneratedColumn<String>(
    'observacion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estadoSyncMeta = const VerificationMeta(
    'estadoSync',
  );
  @override
  late final GeneratedColumn<String> estadoSync = GeneratedColumn<String>(
    'estado_sync',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PENDING'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localUuid,
    serverId,
    legajo,
    idCuenta,
    idRepartoDia,
    idMedioPago,
    monto,
    fecha,
    observacion,
    estadoSync,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pagos_locales';
  @override
  VerificationContext validateIntegrity(
    Insertable<PagosLocale> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_uuid')) {
      context.handle(
        _localUuidMeta,
        localUuid.isAcceptableOrUnknown(data['local_uuid']!, _localUuidMeta),
      );
    } else if (isInserting) {
      context.missing(_localUuidMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('legajo')) {
      context.handle(
        _legajoMeta,
        legajo.isAcceptableOrUnknown(data['legajo']!, _legajoMeta),
      );
    } else if (isInserting) {
      context.missing(_legajoMeta);
    }
    if (data.containsKey('id_cuenta')) {
      context.handle(
        _idCuentaMeta,
        idCuenta.isAcceptableOrUnknown(data['id_cuenta']!, _idCuentaMeta),
      );
    } else if (isInserting) {
      context.missing(_idCuentaMeta);
    }
    if (data.containsKey('id_reparto_dia')) {
      context.handle(
        _idRepartoDiaMeta,
        idRepartoDia.isAcceptableOrUnknown(
          data['id_reparto_dia']!,
          _idRepartoDiaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idRepartoDiaMeta);
    }
    if (data.containsKey('id_medio_pago')) {
      context.handle(
        _idMedioPagoMeta,
        idMedioPago.isAcceptableOrUnknown(
          data['id_medio_pago']!,
          _idMedioPagoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idMedioPagoMeta);
    }
    if (data.containsKey('monto')) {
      context.handle(
        _montoMeta,
        monto.isAcceptableOrUnknown(data['monto']!, _montoMeta),
      );
    } else if (isInserting) {
      context.missing(_montoMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('observacion')) {
      context.handle(
        _observacionMeta,
        observacion.isAcceptableOrUnknown(
          data['observacion']!,
          _observacionMeta,
        ),
      );
    }
    if (data.containsKey('estado_sync')) {
      context.handle(
        _estadoSyncMeta,
        estadoSync.isAcceptableOrUnknown(data['estado_sync']!, _estadoSyncMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localUuid};
  @override
  PagosLocale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PagosLocale(
      localUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_uuid'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      legajo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}legajo'],
      )!,
      idCuenta: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id_cuenta'],
      )!,
      idRepartoDia: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id_reparto_dia'],
      )!,
      idMedioPago: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id_medio_pago'],
      )!,
      monto: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monto'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      observacion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observacion'],
      ),
      estadoSync: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado_sync'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $PagosLocalesTable createAlias(String alias) {
    return $PagosLocalesTable(attachedDatabase, alias);
  }
}

class PagosLocale extends DataClass implements Insertable<PagosLocale> {
  final String localUuid;
  final int? serverId;
  final int legajo;
  final int idCuenta;
  final int idRepartoDia;
  final int idMedioPago;
  final double monto;
  final DateTime fecha;
  final String? observacion;
  final String estadoSync;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const PagosLocale({
    required this.localUuid,
    this.serverId,
    required this.legajo,
    required this.idCuenta,
    required this.idRepartoDia,
    required this.idMedioPago,
    required this.monto,
    required this.fecha,
    this.observacion,
    required this.estadoSync,
    required this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_uuid'] = Variable<String>(localUuid);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['legajo'] = Variable<int>(legajo);
    map['id_cuenta'] = Variable<int>(idCuenta);
    map['id_reparto_dia'] = Variable<int>(idRepartoDia);
    map['id_medio_pago'] = Variable<int>(idMedioPago);
    map['monto'] = Variable<double>(monto);
    map['fecha'] = Variable<DateTime>(fecha);
    if (!nullToAbsent || observacion != null) {
      map['observacion'] = Variable<String>(observacion);
    }
    map['estado_sync'] = Variable<String>(estadoSync);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  PagosLocalesCompanion toCompanion(bool nullToAbsent) {
    return PagosLocalesCompanion(
      localUuid: Value(localUuid),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      legajo: Value(legajo),
      idCuenta: Value(idCuenta),
      idRepartoDia: Value(idRepartoDia),
      idMedioPago: Value(idMedioPago),
      monto: Value(monto),
      fecha: Value(fecha),
      observacion: observacion == null && nullToAbsent
          ? const Value.absent()
          : Value(observacion),
      estadoSync: Value(estadoSync),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory PagosLocale.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PagosLocale(
      localUuid: serializer.fromJson<String>(json['localUuid']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      legajo: serializer.fromJson<int>(json['legajo']),
      idCuenta: serializer.fromJson<int>(json['idCuenta']),
      idRepartoDia: serializer.fromJson<int>(json['idRepartoDia']),
      idMedioPago: serializer.fromJson<int>(json['idMedioPago']),
      monto: serializer.fromJson<double>(json['monto']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      observacion: serializer.fromJson<String?>(json['observacion']),
      estadoSync: serializer.fromJson<String>(json['estadoSync']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localUuid': serializer.toJson<String>(localUuid),
      'serverId': serializer.toJson<int?>(serverId),
      'legajo': serializer.toJson<int>(legajo),
      'idCuenta': serializer.toJson<int>(idCuenta),
      'idRepartoDia': serializer.toJson<int>(idRepartoDia),
      'idMedioPago': serializer.toJson<int>(idMedioPago),
      'monto': serializer.toJson<double>(monto),
      'fecha': serializer.toJson<DateTime>(fecha),
      'observacion': serializer.toJson<String?>(observacion),
      'estadoSync': serializer.toJson<String>(estadoSync),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  PagosLocale copyWith({
    String? localUuid,
    Value<int?> serverId = const Value.absent(),
    int? legajo,
    int? idCuenta,
    int? idRepartoDia,
    int? idMedioPago,
    double? monto,
    DateTime? fecha,
    Value<String?> observacion = const Value.absent(),
    String? estadoSync,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => PagosLocale(
    localUuid: localUuid ?? this.localUuid,
    serverId: serverId.present ? serverId.value : this.serverId,
    legajo: legajo ?? this.legajo,
    idCuenta: idCuenta ?? this.idCuenta,
    idRepartoDia: idRepartoDia ?? this.idRepartoDia,
    idMedioPago: idMedioPago ?? this.idMedioPago,
    monto: monto ?? this.monto,
    fecha: fecha ?? this.fecha,
    observacion: observacion.present ? observacion.value : this.observacion,
    estadoSync: estadoSync ?? this.estadoSync,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  PagosLocale copyWithCompanion(PagosLocalesCompanion data) {
    return PagosLocale(
      localUuid: data.localUuid.present ? data.localUuid.value : this.localUuid,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      legajo: data.legajo.present ? data.legajo.value : this.legajo,
      idCuenta: data.idCuenta.present ? data.idCuenta.value : this.idCuenta,
      idRepartoDia: data.idRepartoDia.present
          ? data.idRepartoDia.value
          : this.idRepartoDia,
      idMedioPago: data.idMedioPago.present
          ? data.idMedioPago.value
          : this.idMedioPago,
      monto: data.monto.present ? data.monto.value : this.monto,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      observacion: data.observacion.present
          ? data.observacion.value
          : this.observacion,
      estadoSync: data.estadoSync.present
          ? data.estadoSync.value
          : this.estadoSync,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PagosLocale(')
          ..write('localUuid: $localUuid, ')
          ..write('serverId: $serverId, ')
          ..write('legajo: $legajo, ')
          ..write('idCuenta: $idCuenta, ')
          ..write('idRepartoDia: $idRepartoDia, ')
          ..write('idMedioPago: $idMedioPago, ')
          ..write('monto: $monto, ')
          ..write('fecha: $fecha, ')
          ..write('observacion: $observacion, ')
          ..write('estadoSync: $estadoSync, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localUuid,
    serverId,
    legajo,
    idCuenta,
    idRepartoDia,
    idMedioPago,
    monto,
    fecha,
    observacion,
    estadoSync,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PagosLocale &&
          other.localUuid == this.localUuid &&
          other.serverId == this.serverId &&
          other.legajo == this.legajo &&
          other.idCuenta == this.idCuenta &&
          other.idRepartoDia == this.idRepartoDia &&
          other.idMedioPago == this.idMedioPago &&
          other.monto == this.monto &&
          other.fecha == this.fecha &&
          other.observacion == this.observacion &&
          other.estadoSync == this.estadoSync &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PagosLocalesCompanion extends UpdateCompanion<PagosLocale> {
  final Value<String> localUuid;
  final Value<int?> serverId;
  final Value<int> legajo;
  final Value<int> idCuenta;
  final Value<int> idRepartoDia;
  final Value<int> idMedioPago;
  final Value<double> monto;
  final Value<DateTime> fecha;
  final Value<String?> observacion;
  final Value<String> estadoSync;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const PagosLocalesCompanion({
    this.localUuid = const Value.absent(),
    this.serverId = const Value.absent(),
    this.legajo = const Value.absent(),
    this.idCuenta = const Value.absent(),
    this.idRepartoDia = const Value.absent(),
    this.idMedioPago = const Value.absent(),
    this.monto = const Value.absent(),
    this.fecha = const Value.absent(),
    this.observacion = const Value.absent(),
    this.estadoSync = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PagosLocalesCompanion.insert({
    required String localUuid,
    this.serverId = const Value.absent(),
    required int legajo,
    required int idCuenta,
    required int idRepartoDia,
    required int idMedioPago,
    required double monto,
    required DateTime fecha,
    this.observacion = const Value.absent(),
    this.estadoSync = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localUuid = Value(localUuid),
       legajo = Value(legajo),
       idCuenta = Value(idCuenta),
       idRepartoDia = Value(idRepartoDia),
       idMedioPago = Value(idMedioPago),
       monto = Value(monto),
       fecha = Value(fecha);
  static Insertable<PagosLocale> custom({
    Expression<String>? localUuid,
    Expression<int>? serverId,
    Expression<int>? legajo,
    Expression<int>? idCuenta,
    Expression<int>? idRepartoDia,
    Expression<int>? idMedioPago,
    Expression<double>? monto,
    Expression<DateTime>? fecha,
    Expression<String>? observacion,
    Expression<String>? estadoSync,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localUuid != null) 'local_uuid': localUuid,
      if (serverId != null) 'server_id': serverId,
      if (legajo != null) 'legajo': legajo,
      if (idCuenta != null) 'id_cuenta': idCuenta,
      if (idRepartoDia != null) 'id_reparto_dia': idRepartoDia,
      if (idMedioPago != null) 'id_medio_pago': idMedioPago,
      if (monto != null) 'monto': monto,
      if (fecha != null) 'fecha': fecha,
      if (observacion != null) 'observacion': observacion,
      if (estadoSync != null) 'estado_sync': estadoSync,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PagosLocalesCompanion copyWith({
    Value<String>? localUuid,
    Value<int?>? serverId,
    Value<int>? legajo,
    Value<int>? idCuenta,
    Value<int>? idRepartoDia,
    Value<int>? idMedioPago,
    Value<double>? monto,
    Value<DateTime>? fecha,
    Value<String?>? observacion,
    Value<String>? estadoSync,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return PagosLocalesCompanion(
      localUuid: localUuid ?? this.localUuid,
      serverId: serverId ?? this.serverId,
      legajo: legajo ?? this.legajo,
      idCuenta: idCuenta ?? this.idCuenta,
      idRepartoDia: idRepartoDia ?? this.idRepartoDia,
      idMedioPago: idMedioPago ?? this.idMedioPago,
      monto: monto ?? this.monto,
      fecha: fecha ?? this.fecha,
      observacion: observacion ?? this.observacion,
      estadoSync: estadoSync ?? this.estadoSync,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localUuid.present) {
      map['local_uuid'] = Variable<String>(localUuid.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (legajo.present) {
      map['legajo'] = Variable<int>(legajo.value);
    }
    if (idCuenta.present) {
      map['id_cuenta'] = Variable<int>(idCuenta.value);
    }
    if (idRepartoDia.present) {
      map['id_reparto_dia'] = Variable<int>(idRepartoDia.value);
    }
    if (idMedioPago.present) {
      map['id_medio_pago'] = Variable<int>(idMedioPago.value);
    }
    if (monto.present) {
      map['monto'] = Variable<double>(monto.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (observacion.present) {
      map['observacion'] = Variable<String>(observacion.value);
    }
    if (estadoSync.present) {
      map['estado_sync'] = Variable<String>(estadoSync.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PagosLocalesCompanion(')
          ..write('localUuid: $localUuid, ')
          ..write('serverId: $serverId, ')
          ..write('legajo: $legajo, ')
          ..write('idCuenta: $idCuenta, ')
          ..write('idRepartoDia: $idRepartoDia, ')
          ..write('idMedioPago: $idMedioPago, ')
          ..write('monto: $monto, ')
          ..write('fecha: $fecha, ')
          ..write('observacion: $observacion, ')
          ..write('estadoSync: $estadoSync, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VisitasLocalesTable extends VisitasLocales
    with TableInfo<$VisitasLocalesTable, VisitasLocale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VisitasLocalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localUuidMeta = const VerificationMeta(
    'localUuid',
  );
  @override
  late final GeneratedColumn<String> localUuid = GeneratedColumn<String>(
    'local_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _legajoMeta = const VerificationMeta('legajo');
  @override
  late final GeneratedColumn<int> legajo = GeneratedColumn<int>(
    'legajo',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estadoSyncMeta = const VerificationMeta(
    'estadoSync',
  );
  @override
  late final GeneratedColumn<String> estadoSync = GeneratedColumn<String>(
    'estado_sync',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PENDING'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localUuid,
    serverId,
    legajo,
    fecha,
    estado,
    estadoSync,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'visitas_locales';
  @override
  VerificationContext validateIntegrity(
    Insertable<VisitasLocale> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_uuid')) {
      context.handle(
        _localUuidMeta,
        localUuid.isAcceptableOrUnknown(data['local_uuid']!, _localUuidMeta),
      );
    } else if (isInserting) {
      context.missing(_localUuidMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('legajo')) {
      context.handle(
        _legajoMeta,
        legajo.isAcceptableOrUnknown(data['legajo']!, _legajoMeta),
      );
    } else if (isInserting) {
      context.missing(_legajoMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    } else if (isInserting) {
      context.missing(_estadoMeta);
    }
    if (data.containsKey('estado_sync')) {
      context.handle(
        _estadoSyncMeta,
        estadoSync.isAcceptableOrUnknown(data['estado_sync']!, _estadoSyncMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localUuid};
  @override
  VisitasLocale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VisitasLocale(
      localUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_uuid'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      legajo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}legajo'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      estadoSync: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado_sync'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $VisitasLocalesTable createAlias(String alias) {
    return $VisitasLocalesTable(attachedDatabase, alias);
  }
}

class VisitasLocale extends DataClass implements Insertable<VisitasLocale> {
  final String localUuid;
  final int? serverId;
  final int legajo;
  final DateTime fecha;
  final String estado;
  final String estadoSync;
  final DateTime createdAt;
  const VisitasLocale({
    required this.localUuid,
    this.serverId,
    required this.legajo,
    required this.fecha,
    required this.estado,
    required this.estadoSync,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_uuid'] = Variable<String>(localUuid);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['legajo'] = Variable<int>(legajo);
    map['fecha'] = Variable<DateTime>(fecha);
    map['estado'] = Variable<String>(estado);
    map['estado_sync'] = Variable<String>(estadoSync);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  VisitasLocalesCompanion toCompanion(bool nullToAbsent) {
    return VisitasLocalesCompanion(
      localUuid: Value(localUuid),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      legajo: Value(legajo),
      fecha: Value(fecha),
      estado: Value(estado),
      estadoSync: Value(estadoSync),
      createdAt: Value(createdAt),
    );
  }

  factory VisitasLocale.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VisitasLocale(
      localUuid: serializer.fromJson<String>(json['localUuid']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      legajo: serializer.fromJson<int>(json['legajo']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      estado: serializer.fromJson<String>(json['estado']),
      estadoSync: serializer.fromJson<String>(json['estadoSync']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localUuid': serializer.toJson<String>(localUuid),
      'serverId': serializer.toJson<int?>(serverId),
      'legajo': serializer.toJson<int>(legajo),
      'fecha': serializer.toJson<DateTime>(fecha),
      'estado': serializer.toJson<String>(estado),
      'estadoSync': serializer.toJson<String>(estadoSync),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  VisitasLocale copyWith({
    String? localUuid,
    Value<int?> serverId = const Value.absent(),
    int? legajo,
    DateTime? fecha,
    String? estado,
    String? estadoSync,
    DateTime? createdAt,
  }) => VisitasLocale(
    localUuid: localUuid ?? this.localUuid,
    serverId: serverId.present ? serverId.value : this.serverId,
    legajo: legajo ?? this.legajo,
    fecha: fecha ?? this.fecha,
    estado: estado ?? this.estado,
    estadoSync: estadoSync ?? this.estadoSync,
    createdAt: createdAt ?? this.createdAt,
  );
  VisitasLocale copyWithCompanion(VisitasLocalesCompanion data) {
    return VisitasLocale(
      localUuid: data.localUuid.present ? data.localUuid.value : this.localUuid,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      legajo: data.legajo.present ? data.legajo.value : this.legajo,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      estado: data.estado.present ? data.estado.value : this.estado,
      estadoSync: data.estadoSync.present
          ? data.estadoSync.value
          : this.estadoSync,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VisitasLocale(')
          ..write('localUuid: $localUuid, ')
          ..write('serverId: $serverId, ')
          ..write('legajo: $legajo, ')
          ..write('fecha: $fecha, ')
          ..write('estado: $estado, ')
          ..write('estadoSync: $estadoSync, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localUuid,
    serverId,
    legajo,
    fecha,
    estado,
    estadoSync,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VisitasLocale &&
          other.localUuid == this.localUuid &&
          other.serverId == this.serverId &&
          other.legajo == this.legajo &&
          other.fecha == this.fecha &&
          other.estado == this.estado &&
          other.estadoSync == this.estadoSync &&
          other.createdAt == this.createdAt);
}

class VisitasLocalesCompanion extends UpdateCompanion<VisitasLocale> {
  final Value<String> localUuid;
  final Value<int?> serverId;
  final Value<int> legajo;
  final Value<DateTime> fecha;
  final Value<String> estado;
  final Value<String> estadoSync;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const VisitasLocalesCompanion({
    this.localUuid = const Value.absent(),
    this.serverId = const Value.absent(),
    this.legajo = const Value.absent(),
    this.fecha = const Value.absent(),
    this.estado = const Value.absent(),
    this.estadoSync = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VisitasLocalesCompanion.insert({
    required String localUuid,
    this.serverId = const Value.absent(),
    required int legajo,
    required DateTime fecha,
    required String estado,
    this.estadoSync = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localUuid = Value(localUuid),
       legajo = Value(legajo),
       fecha = Value(fecha),
       estado = Value(estado);
  static Insertable<VisitasLocale> custom({
    Expression<String>? localUuid,
    Expression<int>? serverId,
    Expression<int>? legajo,
    Expression<DateTime>? fecha,
    Expression<String>? estado,
    Expression<String>? estadoSync,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localUuid != null) 'local_uuid': localUuid,
      if (serverId != null) 'server_id': serverId,
      if (legajo != null) 'legajo': legajo,
      if (fecha != null) 'fecha': fecha,
      if (estado != null) 'estado': estado,
      if (estadoSync != null) 'estado_sync': estadoSync,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VisitasLocalesCompanion copyWith({
    Value<String>? localUuid,
    Value<int?>? serverId,
    Value<int>? legajo,
    Value<DateTime>? fecha,
    Value<String>? estado,
    Value<String>? estadoSync,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return VisitasLocalesCompanion(
      localUuid: localUuid ?? this.localUuid,
      serverId: serverId ?? this.serverId,
      legajo: legajo ?? this.legajo,
      fecha: fecha ?? this.fecha,
      estado: estado ?? this.estado,
      estadoSync: estadoSync ?? this.estadoSync,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localUuid.present) {
      map['local_uuid'] = Variable<String>(localUuid.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (legajo.present) {
      map['legajo'] = Variable<int>(legajo.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (estadoSync.present) {
      map['estado_sync'] = Variable<String>(estadoSync.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VisitasLocalesCompanion(')
          ..write('localUuid: $localUuid, ')
          ..write('serverId: $serverId, ')
          ..write('legajo: $legajo, ')
          ..write('fecha: $fecha, ')
          ..write('estado: $estado, ')
          ..write('estadoSync: $estadoSync, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _localOperationIdMeta = const VerificationMeta(
    'localOperationId',
  );
  @override
  late final GeneratedColumn<String> localOperationId = GeneratedColumn<String>(
    'local_operation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityLocalIdMeta = const VerificationMeta(
    'entityLocalId',
  );
  @override
  late final GeneratedColumn<String> entityLocalId = GeneratedColumn<String>(
    'entity_local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PENDING'),
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    localOperationId,
    entityType,
    entityLocalId,
    action,
    payloadJson,
    idempotencyKey,
    deviceId,
    userId,
    status,
    retryCount,
    lastError,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('local_operation_id')) {
      context.handle(
        _localOperationIdMeta,
        localOperationId.isAcceptableOrUnknown(
          data['local_operation_id']!,
          _localOperationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localOperationIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_local_id')) {
      context.handle(
        _entityLocalIdMeta,
        entityLocalId.isAcceptableOrUnknown(
          data['entity_local_id']!,
          _entityLocalIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_entityLocalIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      localOperationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_operation_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityLocalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_local_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final int id;
  final String localOperationId;
  final String entityType;
  final String entityLocalId;
  final String action;
  final String payloadJson;
  final String idempotencyKey;
  final String? deviceId;
  final int? userId;
  final String status;
  final int retryCount;
  final String? lastError;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const SyncQueueData({
    required this.id,
    required this.localOperationId,
    required this.entityType,
    required this.entityLocalId,
    required this.action,
    required this.payloadJson,
    required this.idempotencyKey,
    this.deviceId,
    this.userId,
    required this.status,
    required this.retryCount,
    this.lastError,
    required this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['local_operation_id'] = Variable<String>(localOperationId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_local_id'] = Variable<String>(entityLocalId);
    map['action'] = Variable<String>(action);
    map['payload_json'] = Variable<String>(payloadJson);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<int>(userId);
    }
    map['status'] = Variable<String>(status);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      localOperationId: Value(localOperationId),
      entityType: Value(entityType),
      entityLocalId: Value(entityLocalId),
      action: Value(action),
      payloadJson: Value(payloadJson),
      idempotencyKey: Value(idempotencyKey),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      status: Value(status),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory SyncQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<int>(json['id']),
      localOperationId: serializer.fromJson<String>(json['localOperationId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityLocalId: serializer.fromJson<String>(json['entityLocalId']),
      action: serializer.fromJson<String>(json['action']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      userId: serializer.fromJson<int?>(json['userId']),
      status: serializer.fromJson<String>(json['status']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'localOperationId': serializer.toJson<String>(localOperationId),
      'entityType': serializer.toJson<String>(entityType),
      'entityLocalId': serializer.toJson<String>(entityLocalId),
      'action': serializer.toJson<String>(action),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'deviceId': serializer.toJson<String?>(deviceId),
      'userId': serializer.toJson<int?>(userId),
      'status': serializer.toJson<String>(status),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  SyncQueueData copyWith({
    int? id,
    String? localOperationId,
    String? entityType,
    String? entityLocalId,
    String? action,
    String? payloadJson,
    String? idempotencyKey,
    Value<String?> deviceId = const Value.absent(),
    Value<int?> userId = const Value.absent(),
    String? status,
    int? retryCount,
    Value<String?> lastError = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => SyncQueueData(
    id: id ?? this.id,
    localOperationId: localOperationId ?? this.localOperationId,
    entityType: entityType ?? this.entityType,
    entityLocalId: entityLocalId ?? this.entityLocalId,
    action: action ?? this.action,
    payloadJson: payloadJson ?? this.payloadJson,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    userId: userId.present ? userId.value : this.userId,
    status: status ?? this.status,
    retryCount: retryCount ?? this.retryCount,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      localOperationId: data.localOperationId.present
          ? data.localOperationId.value
          : this.localOperationId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityLocalId: data.entityLocalId.present
          ? data.entityLocalId.value
          : this.entityLocalId,
      action: data.action.present ? data.action.value : this.action,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      userId: data.userId.present ? data.userId.value : this.userId,
      status: data.status.present ? data.status.value : this.status,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('localOperationId: $localOperationId, ')
          ..write('entityType: $entityType, ')
          ..write('entityLocalId: $entityLocalId, ')
          ..write('action: $action, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('deviceId: $deviceId, ')
          ..write('userId: $userId, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    localOperationId,
    entityType,
    entityLocalId,
    action,
    payloadJson,
    idempotencyKey,
    deviceId,
    userId,
    status,
    retryCount,
    lastError,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.localOperationId == this.localOperationId &&
          other.entityType == this.entityType &&
          other.entityLocalId == this.entityLocalId &&
          other.action == this.action &&
          other.payloadJson == this.payloadJson &&
          other.idempotencyKey == this.idempotencyKey &&
          other.deviceId == this.deviceId &&
          other.userId == this.userId &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<int> id;
  final Value<String> localOperationId;
  final Value<String> entityType;
  final Value<String> entityLocalId;
  final Value<String> action;
  final Value<String> payloadJson;
  final Value<String> idempotencyKey;
  final Value<String?> deviceId;
  final Value<int?> userId;
  final Value<String> status;
  final Value<int> retryCount;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.localOperationId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityLocalId = const Value.absent(),
    this.action = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.userId = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String localOperationId,
    required String entityType,
    required String entityLocalId,
    required String action,
    required String payloadJson,
    required String idempotencyKey,
    this.deviceId = const Value.absent(),
    this.userId = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : localOperationId = Value(localOperationId),
       entityType = Value(entityType),
       entityLocalId = Value(entityLocalId),
       action = Value(action),
       payloadJson = Value(payloadJson),
       idempotencyKey = Value(idempotencyKey);
  static Insertable<SyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? localOperationId,
    Expression<String>? entityType,
    Expression<String>? entityLocalId,
    Expression<String>? action,
    Expression<String>? payloadJson,
    Expression<String>? idempotencyKey,
    Expression<String>? deviceId,
    Expression<int>? userId,
    Expression<String>? status,
    Expression<int>? retryCount,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localOperationId != null) 'local_operation_id': localOperationId,
      if (entityType != null) 'entity_type': entityType,
      if (entityLocalId != null) 'entity_local_id': entityLocalId,
      if (action != null) 'action': action,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (deviceId != null) 'device_id': deviceId,
      if (userId != null) 'user_id': userId,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SyncQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? localOperationId,
    Value<String>? entityType,
    Value<String>? entityLocalId,
    Value<String>? action,
    Value<String>? payloadJson,
    Value<String>? idempotencyKey,
    Value<String?>? deviceId,
    Value<int?>? userId,
    Value<String>? status,
    Value<int>? retryCount,
    Value<String?>? lastError,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      localOperationId: localOperationId ?? this.localOperationId,
      entityType: entityType ?? this.entityType,
      entityLocalId: entityLocalId ?? this.entityLocalId,
      action: action ?? this.action,
      payloadJson: payloadJson ?? this.payloadJson,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      deviceId: deviceId ?? this.deviceId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (localOperationId.present) {
      map['local_operation_id'] = Variable<String>(localOperationId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityLocalId.present) {
      map['entity_local_id'] = Variable<String>(entityLocalId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('localOperationId: $localOperationId, ')
          ..write('entityType: $entityType, ')
          ..write('entityLocalId: $entityLocalId, ')
          ..write('action: $action, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('deviceId: $deviceId, ')
          ..write('userId: $userId, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ClientesLocalTable clientesLocal = $ClientesLocalTable(this);
  late final $RepartoClientesLocalTable repartoClientesLocal =
      $RepartoClientesLocalTable(this);
  late final $PagosLocalesTable pagosLocales = $PagosLocalesTable(this);
  late final $VisitasLocalesTable visitasLocales = $VisitasLocalesTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    clientesLocal,
    repartoClientesLocal,
    pagosLocales,
    visitasLocales,
    syncQueue,
  ];
}

typedef $$ClientesLocalTableCreateCompanionBuilder =
    ClientesLocalCompanion Function({
      Value<int> legajo,
      required String nombre,
      Value<String?> direccion,
      Value<String?> telefono,
      Value<double> saldo,
      Value<double> deuda,
      Value<DateTime?> updatedAt,
    });
typedef $$ClientesLocalTableUpdateCompanionBuilder =
    ClientesLocalCompanion Function({
      Value<int> legajo,
      Value<String> nombre,
      Value<String?> direccion,
      Value<String?> telefono,
      Value<double> saldo,
      Value<double> deuda,
      Value<DateTime?> updatedAt,
    });

class $$ClientesLocalTableFilterComposer
    extends Composer<_$AppDatabase, $ClientesLocalTable> {
  $$ClientesLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get legajo => $composableBuilder(
    column: $table.legajo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direccion => $composableBuilder(
    column: $table.direccion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get telefono => $composableBuilder(
    column: $table.telefono,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get saldo => $composableBuilder(
    column: $table.saldo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get deuda => $composableBuilder(
    column: $table.deuda,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ClientesLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $ClientesLocalTable> {
  $$ClientesLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get legajo => $composableBuilder(
    column: $table.legajo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direccion => $composableBuilder(
    column: $table.direccion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get telefono => $composableBuilder(
    column: $table.telefono,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get saldo => $composableBuilder(
    column: $table.saldo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get deuda => $composableBuilder(
    column: $table.deuda,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClientesLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClientesLocalTable> {
  $$ClientesLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get legajo =>
      $composableBuilder(column: $table.legajo, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get direccion =>
      $composableBuilder(column: $table.direccion, builder: (column) => column);

  GeneratedColumn<String> get telefono =>
      $composableBuilder(column: $table.telefono, builder: (column) => column);

  GeneratedColumn<double> get saldo =>
      $composableBuilder(column: $table.saldo, builder: (column) => column);

  GeneratedColumn<double> get deuda =>
      $composableBuilder(column: $table.deuda, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ClientesLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClientesLocalTable,
          ClientesLocalData,
          $$ClientesLocalTableFilterComposer,
          $$ClientesLocalTableOrderingComposer,
          $$ClientesLocalTableAnnotationComposer,
          $$ClientesLocalTableCreateCompanionBuilder,
          $$ClientesLocalTableUpdateCompanionBuilder,
          (
            ClientesLocalData,
            BaseReferences<
              _$AppDatabase,
              $ClientesLocalTable,
              ClientesLocalData
            >,
          ),
          ClientesLocalData,
          PrefetchHooks Function()
        > {
  $$ClientesLocalTableTableManager(_$AppDatabase db, $ClientesLocalTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientesLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientesLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClientesLocalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> legajo = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String?> direccion = const Value.absent(),
                Value<String?> telefono = const Value.absent(),
                Value<double> saldo = const Value.absent(),
                Value<double> deuda = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => ClientesLocalCompanion(
                legajo: legajo,
                nombre: nombre,
                direccion: direccion,
                telefono: telefono,
                saldo: saldo,
                deuda: deuda,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> legajo = const Value.absent(),
                required String nombre,
                Value<String?> direccion = const Value.absent(),
                Value<String?> telefono = const Value.absent(),
                Value<double> saldo = const Value.absent(),
                Value<double> deuda = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => ClientesLocalCompanion.insert(
                legajo: legajo,
                nombre: nombre,
                direccion: direccion,
                telefono: telefono,
                saldo: saldo,
                deuda: deuda,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ClientesLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClientesLocalTable,
      ClientesLocalData,
      $$ClientesLocalTableFilterComposer,
      $$ClientesLocalTableOrderingComposer,
      $$ClientesLocalTableAnnotationComposer,
      $$ClientesLocalTableCreateCompanionBuilder,
      $$ClientesLocalTableUpdateCompanionBuilder,
      (
        ClientesLocalData,
        BaseReferences<_$AppDatabase, $ClientesLocalTable, ClientesLocalData>,
      ),
      ClientesLocalData,
      PrefetchHooks Function()
    >;
typedef $$RepartoClientesLocalTableCreateCompanionBuilder =
    RepartoClientesLocalCompanion Function({
      Value<int> id,
      required int idReparto,
      required int legajo,
      Value<String?> turno,
      Value<int?> posicion,
      Value<String?> estadoVisita,
      Value<String?> observacion,
      Value<bool> dirty,
      Value<DateTime?> updatedAt,
    });
typedef $$RepartoClientesLocalTableUpdateCompanionBuilder =
    RepartoClientesLocalCompanion Function({
      Value<int> id,
      Value<int> idReparto,
      Value<int> legajo,
      Value<String?> turno,
      Value<int?> posicion,
      Value<String?> estadoVisita,
      Value<String?> observacion,
      Value<bool> dirty,
      Value<DateTime?> updatedAt,
    });

class $$RepartoClientesLocalTableFilterComposer
    extends Composer<_$AppDatabase, $RepartoClientesLocalTable> {
  $$RepartoClientesLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get idReparto => $composableBuilder(
    column: $table.idReparto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get legajo => $composableBuilder(
    column: $table.legajo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get turno => $composableBuilder(
    column: $table.turno,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get posicion => $composableBuilder(
    column: $table.posicion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estadoVisita => $composableBuilder(
    column: $table.estadoVisita,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observacion => $composableBuilder(
    column: $table.observacion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RepartoClientesLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $RepartoClientesLocalTable> {
  $$RepartoClientesLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get idReparto => $composableBuilder(
    column: $table.idReparto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get legajo => $composableBuilder(
    column: $table.legajo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get turno => $composableBuilder(
    column: $table.turno,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get posicion => $composableBuilder(
    column: $table.posicion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estadoVisita => $composableBuilder(
    column: $table.estadoVisita,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observacion => $composableBuilder(
    column: $table.observacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RepartoClientesLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $RepartoClientesLocalTable> {
  $$RepartoClientesLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get idReparto =>
      $composableBuilder(column: $table.idReparto, builder: (column) => column);

  GeneratedColumn<int> get legajo =>
      $composableBuilder(column: $table.legajo, builder: (column) => column);

  GeneratedColumn<String> get turno =>
      $composableBuilder(column: $table.turno, builder: (column) => column);

  GeneratedColumn<int> get posicion =>
      $composableBuilder(column: $table.posicion, builder: (column) => column);

  GeneratedColumn<String> get estadoVisita => $composableBuilder(
    column: $table.estadoVisita,
    builder: (column) => column,
  );

  GeneratedColumn<String> get observacion => $composableBuilder(
    column: $table.observacion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RepartoClientesLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RepartoClientesLocalTable,
          RepartoClientesLocalData,
          $$RepartoClientesLocalTableFilterComposer,
          $$RepartoClientesLocalTableOrderingComposer,
          $$RepartoClientesLocalTableAnnotationComposer,
          $$RepartoClientesLocalTableCreateCompanionBuilder,
          $$RepartoClientesLocalTableUpdateCompanionBuilder,
          (
            RepartoClientesLocalData,
            BaseReferences<
              _$AppDatabase,
              $RepartoClientesLocalTable,
              RepartoClientesLocalData
            >,
          ),
          RepartoClientesLocalData,
          PrefetchHooks Function()
        > {
  $$RepartoClientesLocalTableTableManager(
    _$AppDatabase db,
    $RepartoClientesLocalTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RepartoClientesLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RepartoClientesLocalTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RepartoClientesLocalTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> idReparto = const Value.absent(),
                Value<int> legajo = const Value.absent(),
                Value<String?> turno = const Value.absent(),
                Value<int?> posicion = const Value.absent(),
                Value<String?> estadoVisita = const Value.absent(),
                Value<String?> observacion = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => RepartoClientesLocalCompanion(
                id: id,
                idReparto: idReparto,
                legajo: legajo,
                turno: turno,
                posicion: posicion,
                estadoVisita: estadoVisita,
                observacion: observacion,
                dirty: dirty,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int idReparto,
                required int legajo,
                Value<String?> turno = const Value.absent(),
                Value<int?> posicion = const Value.absent(),
                Value<String?> estadoVisita = const Value.absent(),
                Value<String?> observacion = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => RepartoClientesLocalCompanion.insert(
                id: id,
                idReparto: idReparto,
                legajo: legajo,
                turno: turno,
                posicion: posicion,
                estadoVisita: estadoVisita,
                observacion: observacion,
                dirty: dirty,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RepartoClientesLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RepartoClientesLocalTable,
      RepartoClientesLocalData,
      $$RepartoClientesLocalTableFilterComposer,
      $$RepartoClientesLocalTableOrderingComposer,
      $$RepartoClientesLocalTableAnnotationComposer,
      $$RepartoClientesLocalTableCreateCompanionBuilder,
      $$RepartoClientesLocalTableUpdateCompanionBuilder,
      (
        RepartoClientesLocalData,
        BaseReferences<
          _$AppDatabase,
          $RepartoClientesLocalTable,
          RepartoClientesLocalData
        >,
      ),
      RepartoClientesLocalData,
      PrefetchHooks Function()
    >;
typedef $$PagosLocalesTableCreateCompanionBuilder =
    PagosLocalesCompanion Function({
      required String localUuid,
      Value<int?> serverId,
      required int legajo,
      required int idCuenta,
      required int idRepartoDia,
      required int idMedioPago,
      required double monto,
      required DateTime fecha,
      Value<String?> observacion,
      Value<String> estadoSync,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$PagosLocalesTableUpdateCompanionBuilder =
    PagosLocalesCompanion Function({
      Value<String> localUuid,
      Value<int?> serverId,
      Value<int> legajo,
      Value<int> idCuenta,
      Value<int> idRepartoDia,
      Value<int> idMedioPago,
      Value<double> monto,
      Value<DateTime> fecha,
      Value<String?> observacion,
      Value<String> estadoSync,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$PagosLocalesTableFilterComposer
    extends Composer<_$AppDatabase, $PagosLocalesTable> {
  $$PagosLocalesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localUuid => $composableBuilder(
    column: $table.localUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get legajo => $composableBuilder(
    column: $table.legajo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get idCuenta => $composableBuilder(
    column: $table.idCuenta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get idRepartoDia => $composableBuilder(
    column: $table.idRepartoDia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get idMedioPago => $composableBuilder(
    column: $table.idMedioPago,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observacion => $composableBuilder(
    column: $table.observacion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estadoSync => $composableBuilder(
    column: $table.estadoSync,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PagosLocalesTableOrderingComposer
    extends Composer<_$AppDatabase, $PagosLocalesTable> {
  $$PagosLocalesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localUuid => $composableBuilder(
    column: $table.localUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get legajo => $composableBuilder(
    column: $table.legajo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get idCuenta => $composableBuilder(
    column: $table.idCuenta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get idRepartoDia => $composableBuilder(
    column: $table.idRepartoDia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get idMedioPago => $composableBuilder(
    column: $table.idMedioPago,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observacion => $composableBuilder(
    column: $table.observacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estadoSync => $composableBuilder(
    column: $table.estadoSync,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PagosLocalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PagosLocalesTable> {
  $$PagosLocalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localUuid =>
      $composableBuilder(column: $table.localUuid, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<int> get legajo =>
      $composableBuilder(column: $table.legajo, builder: (column) => column);

  GeneratedColumn<int> get idCuenta =>
      $composableBuilder(column: $table.idCuenta, builder: (column) => column);

  GeneratedColumn<int> get idRepartoDia => $composableBuilder(
    column: $table.idRepartoDia,
    builder: (column) => column,
  );

  GeneratedColumn<int> get idMedioPago => $composableBuilder(
    column: $table.idMedioPago,
    builder: (column) => column,
  );

  GeneratedColumn<double> get monto =>
      $composableBuilder(column: $table.monto, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get observacion => $composableBuilder(
    column: $table.observacion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estadoSync => $composableBuilder(
    column: $table.estadoSync,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PagosLocalesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PagosLocalesTable,
          PagosLocale,
          $$PagosLocalesTableFilterComposer,
          $$PagosLocalesTableOrderingComposer,
          $$PagosLocalesTableAnnotationComposer,
          $$PagosLocalesTableCreateCompanionBuilder,
          $$PagosLocalesTableUpdateCompanionBuilder,
          (
            PagosLocale,
            BaseReferences<_$AppDatabase, $PagosLocalesTable, PagosLocale>,
          ),
          PagosLocale,
          PrefetchHooks Function()
        > {
  $$PagosLocalesTableTableManager(_$AppDatabase db, $PagosLocalesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PagosLocalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PagosLocalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PagosLocalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> localUuid = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<int> legajo = const Value.absent(),
                Value<int> idCuenta = const Value.absent(),
                Value<int> idRepartoDia = const Value.absent(),
                Value<int> idMedioPago = const Value.absent(),
                Value<double> monto = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<String?> observacion = const Value.absent(),
                Value<String> estadoSync = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PagosLocalesCompanion(
                localUuid: localUuid,
                serverId: serverId,
                legajo: legajo,
                idCuenta: idCuenta,
                idRepartoDia: idRepartoDia,
                idMedioPago: idMedioPago,
                monto: monto,
                fecha: fecha,
                observacion: observacion,
                estadoSync: estadoSync,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localUuid,
                Value<int?> serverId = const Value.absent(),
                required int legajo,
                required int idCuenta,
                required int idRepartoDia,
                required int idMedioPago,
                required double monto,
                required DateTime fecha,
                Value<String?> observacion = const Value.absent(),
                Value<String> estadoSync = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PagosLocalesCompanion.insert(
                localUuid: localUuid,
                serverId: serverId,
                legajo: legajo,
                idCuenta: idCuenta,
                idRepartoDia: idRepartoDia,
                idMedioPago: idMedioPago,
                monto: monto,
                fecha: fecha,
                observacion: observacion,
                estadoSync: estadoSync,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PagosLocalesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PagosLocalesTable,
      PagosLocale,
      $$PagosLocalesTableFilterComposer,
      $$PagosLocalesTableOrderingComposer,
      $$PagosLocalesTableAnnotationComposer,
      $$PagosLocalesTableCreateCompanionBuilder,
      $$PagosLocalesTableUpdateCompanionBuilder,
      (
        PagosLocale,
        BaseReferences<_$AppDatabase, $PagosLocalesTable, PagosLocale>,
      ),
      PagosLocale,
      PrefetchHooks Function()
    >;
typedef $$VisitasLocalesTableCreateCompanionBuilder =
    VisitasLocalesCompanion Function({
      required String localUuid,
      Value<int?> serverId,
      required int legajo,
      required DateTime fecha,
      required String estado,
      Value<String> estadoSync,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$VisitasLocalesTableUpdateCompanionBuilder =
    VisitasLocalesCompanion Function({
      Value<String> localUuid,
      Value<int?> serverId,
      Value<int> legajo,
      Value<DateTime> fecha,
      Value<String> estado,
      Value<String> estadoSync,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$VisitasLocalesTableFilterComposer
    extends Composer<_$AppDatabase, $VisitasLocalesTable> {
  $$VisitasLocalesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localUuid => $composableBuilder(
    column: $table.localUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get legajo => $composableBuilder(
    column: $table.legajo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estadoSync => $composableBuilder(
    column: $table.estadoSync,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VisitasLocalesTableOrderingComposer
    extends Composer<_$AppDatabase, $VisitasLocalesTable> {
  $$VisitasLocalesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localUuid => $composableBuilder(
    column: $table.localUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get legajo => $composableBuilder(
    column: $table.legajo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estadoSync => $composableBuilder(
    column: $table.estadoSync,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VisitasLocalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VisitasLocalesTable> {
  $$VisitasLocalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localUuid =>
      $composableBuilder(column: $table.localUuid, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<int> get legajo =>
      $composableBuilder(column: $table.legajo, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<String> get estadoSync => $composableBuilder(
    column: $table.estadoSync,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$VisitasLocalesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VisitasLocalesTable,
          VisitasLocale,
          $$VisitasLocalesTableFilterComposer,
          $$VisitasLocalesTableOrderingComposer,
          $$VisitasLocalesTableAnnotationComposer,
          $$VisitasLocalesTableCreateCompanionBuilder,
          $$VisitasLocalesTableUpdateCompanionBuilder,
          (
            VisitasLocale,
            BaseReferences<_$AppDatabase, $VisitasLocalesTable, VisitasLocale>,
          ),
          VisitasLocale,
          PrefetchHooks Function()
        > {
  $$VisitasLocalesTableTableManager(
    _$AppDatabase db,
    $VisitasLocalesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VisitasLocalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VisitasLocalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VisitasLocalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> localUuid = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<int> legajo = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<String> estadoSync = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VisitasLocalesCompanion(
                localUuid: localUuid,
                serverId: serverId,
                legajo: legajo,
                fecha: fecha,
                estado: estado,
                estadoSync: estadoSync,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localUuid,
                Value<int?> serverId = const Value.absent(),
                required int legajo,
                required DateTime fecha,
                required String estado,
                Value<String> estadoSync = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VisitasLocalesCompanion.insert(
                localUuid: localUuid,
                serverId: serverId,
                legajo: legajo,
                fecha: fecha,
                estado: estado,
                estadoSync: estadoSync,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VisitasLocalesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VisitasLocalesTable,
      VisitasLocale,
      $$VisitasLocalesTableFilterComposer,
      $$VisitasLocalesTableOrderingComposer,
      $$VisitasLocalesTableAnnotationComposer,
      $$VisitasLocalesTableCreateCompanionBuilder,
      $$VisitasLocalesTableUpdateCompanionBuilder,
      (
        VisitasLocale,
        BaseReferences<_$AppDatabase, $VisitasLocalesTable, VisitasLocale>,
      ),
      VisitasLocale,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      required String localOperationId,
      required String entityType,
      required String entityLocalId,
      required String action,
      required String payloadJson,
      required String idempotencyKey,
      Value<String?> deviceId,
      Value<int?> userId,
      Value<String> status,
      Value<int> retryCount,
      Value<String?> lastError,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      Value<String> localOperationId,
      Value<String> entityType,
      Value<String> entityLocalId,
      Value<String> action,
      Value<String> payloadJson,
      Value<String> idempotencyKey,
      Value<String?> deviceId,
      Value<int?> userId,
      Value<String> status,
      Value<int> retryCount,
      Value<String?> lastError,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
    });

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localOperationId => $composableBuilder(
    column: $table.localOperationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityLocalId => $composableBuilder(
    column: $table.entityLocalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localOperationId => $composableBuilder(
    column: $table.localOperationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityLocalId => $composableBuilder(
    column: $table.entityLocalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localOperationId => $composableBuilder(
    column: $table.localOperationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityLocalId => $composableBuilder(
    column: $table.entityLocalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueData,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueData,
            BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
          ),
          SyncQueueData,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> localOperationId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityLocalId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<int?> userId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                localOperationId: localOperationId,
                entityType: entityType,
                entityLocalId: entityLocalId,
                action: action,
                payloadJson: payloadJson,
                idempotencyKey: idempotencyKey,
                deviceId: deviceId,
                userId: userId,
                status: status,
                retryCount: retryCount,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String localOperationId,
                required String entityType,
                required String entityLocalId,
                required String action,
                required String payloadJson,
                required String idempotencyKey,
                Value<String?> deviceId = const Value.absent(),
                Value<int?> userId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => SyncQueueCompanion.insert(
                id: id,
                localOperationId: localOperationId,
                entityType: entityType,
                entityLocalId: entityLocalId,
                action: action,
                payloadJson: payloadJson,
                idempotencyKey: idempotencyKey,
                deviceId: deviceId,
                userId: userId,
                status: status,
                retryCount: retryCount,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTable,
      SyncQueueData,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueData,
        BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
      ),
      SyncQueueData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ClientesLocalTableTableManager get clientesLocal =>
      $$ClientesLocalTableTableManager(_db, _db.clientesLocal);
  $$RepartoClientesLocalTableTableManager get repartoClientesLocal =>
      $$RepartoClientesLocalTableTableManager(_db, _db.repartoClientesLocal);
  $$PagosLocalesTableTableManager get pagosLocales =>
      $$PagosLocalesTableTableManager(_db, _db.pagosLocales);
  $$VisitasLocalesTableTableManager get visitasLocales =>
      $$VisitasLocalesTableTableManager(_db, _db.visitasLocales);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
}
