class Stock {
  final int idStock;
  final int idProducto;
  final int idEmpresa;
  final int cantidad;

  final String nombreProducto;
  final String? litros;
  final String? tipoDispenser;

  Stock({
    required this.idStock,
    required this.idProducto,
    required this.idEmpresa,
    required this.cantidad,
    required this.nombreProducto,
    this.litros,
    this.tipoDispenser,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      idStock: json['id_stock'],
      idProducto: json['id_producto'],
      idEmpresa: json['id_empresa'],
      cantidad: json['cantidad'],
      nombreProducto: json['nombre_producto'],
      litros: json['litros'],
      tipoDispenser: json['tipo_dispenser'],
    );
  }
}



