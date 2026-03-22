// models/pago_ingreso_create.dart
class PagoEgresoCreate {
  final int idMedioPago;
  final double monto;
  final String motivo; // COMBUSTIBLE | SUELDOS | INSUMOS | OTRO
  final String? observacion;
  final DateTime? fecha;

  PagoEgresoCreate({
    required this.idMedioPago,
    required this.monto,
    required this.motivo,
    this.observacion,
    this.fecha,
  });

  Map<String, dynamic> toJson() => {
    'id_medio_pago': idMedioPago,
    'monto': monto,
    'motivo': motivo,
    if (observacion != null && observacion!.trim().isNotEmpty)
      'observacion': observacion,
    if (fecha != null) 'fecha': fecha!.toIso8601String(),
  };
}
