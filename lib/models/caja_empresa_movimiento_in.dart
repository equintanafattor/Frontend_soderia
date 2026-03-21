class CajaEmpresaMovimientoIn {
  final int? idEmpresa;
  final String tipo; // 'INGRESO' | 'EGRESO'
  final double monto;
  final String? medioPago;
  final String? observacion;
  final DateTime fecha;

  CajaEmpresaMovimientoIn({
    this.idEmpresa,
    required this.tipo,
    required this.monto,
    this.medioPago,
    this.observacion,
    required this.fecha,
  });

  Map<String, dynamic> toJson() => {
    if (idEmpresa != null) 'id_empresa': idEmpresa,
    'tipo': tipo,
    'monto': monto,
    'medio_pago': medioPago,
    'observacion': observacion,
    'fecha': fecha.toIso8601String(),
  };
}
