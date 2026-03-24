class MovimientoStock {
  final int idMovimiento;
  final int idProducto;
  final String tipo;
  final int cantidad;
  final DateTime fecha;
  final String? observacion;
  final int? idPedido;
  final int? idRecorrido;

  MovimientoStock({
    required this.idMovimiento,
    required this.idProducto,
    required this.tipo,
    required this.cantidad,
    required this.fecha,
    this.observacion,
    this.idPedido,
    this.idRecorrido,
  });

  factory MovimientoStock.fromJson(Map<String, dynamic> json) {
    return MovimientoStock(
      idMovimiento: json['id_movimiento'],
      idProducto: json['id_producto'],
      tipo: json['tipo_movimiento'],
      cantidad: json['cantidad'],
      fecha: DateTime.parse(json['fecha']),
      observacion: json['observacion'],
      idPedido: json['id_pedido'],
      idRecorrido: json['id_recorrido'],
    );
  }
}
