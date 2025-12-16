class CajaEmpresaTotalOut {
  final double total;

  CajaEmpresaTotalOut({required this.total});

  factory CajaEmpresaTotalOut.fromJson(Map<String, dynamic> json) {
    return CajaEmpresaTotalOut(
      total: (json['total'] as num).toDouble(),
    );
  }
}
