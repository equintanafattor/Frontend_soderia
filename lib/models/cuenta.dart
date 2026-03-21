class Cuenta {
  final int idCuenta;
  final String nombre;
  final double deuda;
  final double saldo;
  final int? numeroBidones;
  final String? estado;
  final String? tipoDeCuenta;

  Cuenta({
    required this.idCuenta,
    required this.nombre,
    required this.deuda,
    required this.saldo,
    this.numeroBidones,
    this.estado,
    this.tipoDeCuenta,
  });

  factory Cuenta.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v.replaceAll(',', '.')) ?? 0;
      return 0;
    }

    return Cuenta(
      idCuenta: (json['id_cuenta'] as num).toInt(),
      nombre: (json['nombre'] ?? json['tipo_de_cuenta'] ?? 'Cuenta').toString(),
      deuda: toDouble(json['deuda']),
      saldo: toDouble(json['saldo']),
      numeroBidones: (json['numero_bidones'] as num?)?.toInt(),
      estado: json['estado']?.toString(),
      tipoDeCuenta: json['tipo_de_cuenta']?.toString(),
    );
  }
}
