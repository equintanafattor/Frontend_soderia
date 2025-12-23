class RepartoDiaOut {
  final int idRepartoDia;
  final int idUsuario;
  final int idEmpresa;
  final DateTime fecha;
  final double totalRecaudado;
  final double totalEfectivo;
  final double totalVirtual;
  final String? observacion;

  RepartoDiaOut({
    required this.idRepartoDia,
    required this.idUsuario,
    required this.idEmpresa,
    required this.fecha,
    required this.totalRecaudado,
    required this.totalEfectivo,
    required this.totalVirtual,
    this.observacion,
  });

  /// 👇 helper estático (NO depende de instancia)
  static double _parseNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    throw Exception('Valor numérico inválido: $v');
  }

  factory RepartoDiaOut.fromJson(Map<String, dynamic> json) {
    return RepartoDiaOut(
      idRepartoDia: json['id_repartodia'] as int,
      idUsuario: json['id_usuario'] as int,
      idEmpresa: json['id_empresa'] as int,
      fecha: DateTime.parse(json['fecha']),
      totalRecaudado: _parseNum(json['total_recaudado']),
      totalEfectivo: _parseNum(json['total_efectivo']),
      totalVirtual: _parseNum(json['total_virtual']),
      observacion: json['observacion'],
    );
  }
}

