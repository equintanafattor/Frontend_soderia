/* class Jornada {
  final DateTime fecha; 
  final List<String> clientes; 

  Jornada({required this.fecha, required this.clientes});
  
  factory Jornada.fromJson(Map<String, dynamic> json) {
    return Jornada(
      fecha: DateTime.parse(json['fecha']), 
      clientes: List<String>.from(json['clientes']),
    );
  }
} */

class Jornada {
  final DateTime fecha;
  final List<String> clientes;

  Jornada({required this.fecha, required this.clientes});

  factory Jornada.fromJson(Map<String, dynamic> json) {
    return Jornada(
      fecha: DateTime.parse(json['fecha'] as String),
      clientes: (json['clientes'] as List<dynamic>).map((e) => e.toString()).toList(),
    );
  }
}
