// lib/models/producto_cliente.dart

class ProductoCliente {
  final int idProducto;
  final String nombre;
  final int cantidad;
  final String? estado;
  final DateTime? fechaEntrega;

  const ProductoCliente({
    required this.idProducto,
    required this.nombre,
    required this.cantidad,
    this.estado,
    this.fechaEntrega,
  });

  factory ProductoCliente.fromJson(Map<String, dynamic> json) {
    return ProductoCliente(
      idProducto: (json['id_producto'] as num).toInt(),
      nombre: (json['nombre'] ?? '').toString(),
      cantidad: (json['cantidad'] as num).toInt(),
      estado: json['estado']?.toString(),
      fechaEntrega: json['fecha_entrega'] != null
          ? DateTime.tryParse(json['fecha_entrega'].toString())
          : null,
    );
  }
}
