// lib/models/producto.dart
class Producto {
  final int idProducto;
  final String nombre;
  final bool? estado;
  final double? litros;
  final String? tipoDispenser;
  final String? observacion;

  // ✅ NUEVO
  final bool descuentaStock;

  Producto({
    required this.idProducto,
    required this.nombre,
    this.estado,
    this.litros,
    this.tipoDispenser,
    this.observacion,
    this.descuentaStock = true, // default
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      idProducto: json['id_producto'] as int,
      nombre: json['nombre'] ?? '',
      estado: json['estado'] as bool?,
      litros: json['litros'] == null
          ? null
          : double.tryParse(json['litros'].toString()),
      tipoDispenser: json['tipo_dispenser'] as String?,
      observacion: json['observacion'] as String?,

      // ✅ NUEVO (si no viene, true)
      descuentaStock: (json['descuenta_stock'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_producto': idProducto,
      'nombre': nombre,
      'estado': estado,
      'litros': litros,
      'tipo_dispenser': tipoDispenser,
      'observacion': observacion,

      // ✅ NUEVO
      'descuenta_stock': descuentaStock,
    };
  }

  // Para crear sin id (POST)
  Map<String, dynamic> toCreateJson() {
    return {
      'nombre': nombre,
      'estado': estado,
      'litros': litros,
      'tipo_dispenser': tipoDispenser,
      'observacion': observacion,

      // ✅ NUEVO
      'descuenta_stock': descuentaStock,
    };
  }

  Producto copyWith({
    int? idProducto,
    String? nombre,
    bool? estado,
    double? litros,
    String? tipoDispenser,
    String? observacion,

    // ✅ NUEVO
    bool? descuentaStock,
  }) {
    return Producto(
      idProducto: idProducto ?? this.idProducto,
      nombre: nombre ?? this.nombre,
      estado: estado ?? this.estado,
      litros: litros ?? this.litros,
      tipoDispenser: tipoDispenser ?? this.tipoDispenser,
      observacion: observacion ?? this.observacion,

      // ✅ NUEVO
      descuentaStock: descuentaStock ?? this.descuentaStock,
    );
  }
}
