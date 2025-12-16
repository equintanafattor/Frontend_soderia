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

  factory RepartoDiaOut.fromJson(Map<String, dynamic> json) {
    return RepartoDiaOut(
      idRepartoDia: json['id_repartodia'] as int,
      idUsuario: json['id_usuario'] as int,
      idEmpresa: json['id_empresa'] as int,
      fecha: DateTime.parse(json['fecha'] as String),
      totalRecaudado: (json['total_recaudado'] as num).toDouble(),
      totalEfectivo: (json['total_efectivo'] as num).toDouble(),
      totalVirtual: (json['total_virtual'] as num).toDouble(),
      observacion: json['observacion'] as String?,
    );
  }
}
