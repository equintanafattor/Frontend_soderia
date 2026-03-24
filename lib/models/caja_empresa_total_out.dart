class CajaEmpresaTotalOut {
  final double total;

  CajaEmpresaTotalOut({required this.total});

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.parse(value);
    throw Exception('Valor inválido para double: $value');
  }

  factory CajaEmpresaTotalOut.fromJson(Map<String, dynamic> json) {
    return CajaEmpresaTotalOut(total: _toDouble(json['total']));
  }
}
