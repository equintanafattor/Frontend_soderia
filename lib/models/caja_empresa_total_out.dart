class CajaEmpresaTotalOut {
  final double total;

  CajaEmpresaTotalOut({required this.total});

  factory CajaEmpresaTotalOut.fromJson(Map<String, dynamic> json) {
    final v = json['total'];
    return CajaEmpresaTotalOut(
      total: v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0,
    );
  }
}
