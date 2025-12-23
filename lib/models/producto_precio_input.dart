// models/producto_precio_input.dart
class ProductoPrecioInput {
  final int idListaPrecio;
  double? precio;
  bool activo;

  ProductoPrecioInput({
    required this.idListaPrecio,
    this.precio,
    this.activo = true,
  });

  Map<String, dynamic> toJson() => {
        'id_lista_precio': idListaPrecio,
        'precio': precio,
        'activo': activo,
      };
}
