class PagoIngresoCreate {
  final int idMedioPago;
  final double monto;
  final String? observacion;
  final DateTime? fecha;

  PagoIngresoCreate({
    required this.idMedioPago,
    required this.monto,
    this.observacion,
    this.fecha,
  });

  Map<String, dynamic> toJson() => {
    'id_medio_pago': idMedioPago,
    'monto': monto,
    if (observacion != null && observacion!.trim().isNotEmpty)
      'observacion': observacion,
    if (fecha != null) 'fecha': fecha!.toIso8601String(),
  };
}
