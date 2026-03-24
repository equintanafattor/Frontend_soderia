class DireccionCliente {
  final int idDireccion;
  final int legajo;
  final String localidad;
  final String direccion;
  final String? zona;
  final String? entreCalle1;
  final String? entreCalle2;
  final String? observacion;
  final String? tipo;
  final String? latitudLongitud;

  DireccionCliente({
    required this.idDireccion,
    required this.legajo,
    required this.localidad,
    required this.direccion,
    this.zona,
    this.entreCalle1,
    this.entreCalle2,
    this.observacion,
    this.tipo,
    this.latitudLongitud,
  });

  /// Texto corto para mostrar en la card (podés tunearlo después)
  String get descripcionCorta {
    // Ej: "Av. Siempre Viva 742, Villa Dolores"
    if (localidad.isEmpty) return direccion;
    return '$direccion, $localidad';
  }

  factory DireccionCliente.fromJson(Map<String, dynamic> json) {
    return DireccionCliente(
      idDireccion: json['id_direccion'] as int,
      legajo: json['legajo'] as int,
      localidad: json['localidad'] as String? ?? '',
      direccion: json['direccion'] as String? ?? '',
      zona: json['zona'] as String?,
      entreCalle1: json['entre_calle1'] as String?,
      entreCalle2: json['entre_calle2'] as String?,
      observacion: json['observacion'] as String?,
      tipo: json['tipo'] as String?,
      latitudLongitud: json['latitud_longitud'] as String?,
    );
  }
}
