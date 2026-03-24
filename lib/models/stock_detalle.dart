class StockDetalle {
  final int idProducto;
  final String nombreProducto;
  final int cantidad;
  final int? litros;
  final String? tipoDispenser;

  StockDetalle({
    required this.idProducto,
    required this.nombreProducto,
    required this.cantidad,
    this.litros,
    this.tipoDispenser,
  });

  factory StockDetalle.fromJson(Map<String, dynamic> json) {
    return StockDetalle(
      idProducto: json['id_producto'],
      nombreProducto: json['nombre_producto'],
      cantidad: json['cantidad'],
      litros: json['litros'],
      tipoDispenser: json['tipo_dispenser'],
    );
  }
}
