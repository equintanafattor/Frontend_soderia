// lib/models/clientes_por_dia.dart

class ClientePorDiaItem {
  final int legajo;
  final int? dni;
  final String? nombre;
  final String? apellido;
  final String? turnoVisita;
  final String estadoVisita; // 👈 NUEVO

  ClientePorDiaItem({
    required this.legajo,
    this.dni,
    this.nombre,
    this.apellido,
    this.turnoVisita,
    required this.estadoVisita,
  });

  String get nombreCompleto {
    final n = nombre ?? '';
    final a = apellido ?? '';
    if (n.isEmpty && a.isEmpty) return 'Sin nombre';
    if (a.isEmpty) return n;
    if (n.isEmpty) return a;
    return '$apellido, $nombre';
  }

  factory ClientePorDiaItem.fromJson(Map<String, dynamic> json) {
    return ClientePorDiaItem(
      legajo: json['legajo'] as int,
      dni: json['dni'] as int?,
      nombre: json['nombre'] as String?,
      apellido: json['apellido'] as String?,
      turnoVisita: json['turno_visita'] as String?,
      estadoVisita:
          (json['estado_visita'] as String?) ?? 'pendiente',
    );
  }
}

class ClientesPorDia {
  final DateTime fecha;
  final int idDia;
  final String nombreDia;
  final List<ClientePorDiaItem> clientes;

  ClientesPorDia({
    required this.fecha,
    required this.idDia,
    required this.nombreDia,
    required this.clientes,
  });

  factory ClientesPorDia.fromJson(Map<String, dynamic> json) {
    return ClientesPorDia(
      fecha: DateTime.parse(json['fecha'] as String),
      idDia: json['id_dia'] as int,
      nombreDia: json['nombre_dia'] as String,
      clientes: (json['clientes'] as List<dynamic>)
          .map((e) => ClientePorDiaItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
