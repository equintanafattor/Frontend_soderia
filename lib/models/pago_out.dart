class PagoOut {
  final int idPago;
  final int idEmpresa;
  final int idMedioPago;
  final DateTime fecha;
  final double monto;
  final String tipoPago;
  final String? observacion;
  final int? legajo;
  final int? idPedido;
  final int? idRepartodia;

  PagoOut({
    required this.idPago,
    required this.idEmpresa,
    required this.idMedioPago,
    required this.fecha,
    required this.monto,
    required this.tipoPago,
    this.observacion,
    this.legajo,
    this.idPedido,
    this.idRepartodia,
  });

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.parse(value);
    throw Exception('Valor inválido para double: $value');
  }

  factory PagoOut.fromJson(Map<String, dynamic> json) {
    return PagoOut(
      idPago: (json['id_pago'] as num).toInt(),
      idEmpresa: (json['id_empresa'] as num).toInt(),
      idMedioPago: (json['id_medio_pago'] as num).toInt(),
      fecha: DateTime.parse(json['fecha'] as String),
      monto: _toDouble(json['monto']),
      tipoPago: json['tipo_pago'] as String,
      observacion: json['observacion'] as String?,
      legajo: (json['legajo'] as num?)?.toInt(),
      idPedido: (json['id_pedido'] as num?)?.toInt(),
      idRepartodia: (json['id_repartodia'] as num?)?.toInt(),
    );
  }
}
