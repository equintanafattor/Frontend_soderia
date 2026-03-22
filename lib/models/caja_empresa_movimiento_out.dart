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

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.parse(value);
    throw Exception('Valor inválido para double: $value');
  }

  factory CajaEmpresaMovimientoOut.fromJson(Map<String, dynamic> json) {
    return CajaEmpresaMovimientoOut(
      idMovimiento: (json['id_movimiento'] as num).toInt(),
      idEmpresa: (json['id_empresa'] as num).toInt(),
      fecha: DateTime.parse(json['fecha'] as String),
      tipo: json['tipo'] as String,
      monto: _toDouble(json['monto']),
      observacion: json['observacion'] as String?,
      medioPago: json['medio_pago'] as String?,
      tipoMovimiento: json['tipo_movimiento'] as String?,
    );
  }
}
