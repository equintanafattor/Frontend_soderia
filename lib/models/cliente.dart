class ClienteOut {
  final int legajo;
  final int dni;
  final String? observacion;

  ClienteOut({
    required this.legajo,
    required this.dni,
    this.observacion,
  });

  factory ClienteOut.fromJson(Map<String, dynamic> json) => ClienteOut(
        legajo: json['legajo'],
        dni: json['dni'],
        observacion: json['observacion'],
      );
}
