enum TipoItemVenta { producto, combo }

class CarritoItem {
  final TipoItemVenta tipo;
  final int idItem;
  final String nombre;
  final double precioUnitario;
  int cantidad;

  CarritoItem({
    required this.tipo,
    required this.idItem,
    required this.nombre,
    required this.precioUnitario,
    required this.cantidad,
  });
}