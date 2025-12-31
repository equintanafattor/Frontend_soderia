class ComboPrecioItem {
  final int idCombo;
  final String nombre;
  final double? precio;

  ComboPrecioItem({
    required this.idCombo,
    required this.nombre,
    this.precio,
  });

  factory ComboPrecioItem.fromJson(Map<String, dynamic> json) {
    return ComboPrecioItem(
      idCombo: json['id_combo'],
      nombre: json['nombre'],
      precio: json['precio'] == null
          ? null
          : double.tryParse(json['precio'].toString()),
    );
  }
}
