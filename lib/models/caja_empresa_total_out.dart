class CajaEmpresaTotalOut {
  final double total;

  CajaEmpresaTotalOut({required this.total});

  static double _parseNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }

  factory CajaEmpresaTotalOut.fromJson(Map<String, dynamic> json) {
    return CajaEmpresaTotalOut(total: _parseNum(json['total']));
  }
}
