class CajaEmpresaMovimientoOut {
  final int idMovimiento;
  final int idEmpresa;
  final DateTime fecha;
  final String tipo;
  final double monto;
  final String? observacion;
  final String? medioPago;
  final String? tipoMovimiento;

  CajaEmpresaMovimientoOut({
    required this.idMovimiento,
    required this.idEmpresa,
    required this.fecha,
    required this.tipo,
    required this.monto,
    this.observacion,
    this.medioPago,
    this.tipoMovimiento,
  });

  static double _parseNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }

  factory CajaEmpresaMovimientoOut.fromJson(Map<String, dynamic> json) {
    return CajaEmpresaMovimientoOut(
      idMovimiento: json['id_movimiento'] as int,
      idEmpresa: json['id_empresa'] as int,
      fecha: DateTime.parse(json['fecha'] as String),
      tipo: (json['tipo'] as String?) ?? '',
      monto: _parseNum(json['monto']),
      observacion: json['observacion'] as String?,
      medioPago: json['medio_pago'] as String?,
      tipoMovimiento: json['tipo_movimiento'] as String?,
    );
  }
}
