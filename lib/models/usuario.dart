// models/usuario.dart
class Usuario {
  final int id;
  final String nombre;
  final String email;
  final String rol;
  final bool activo;
  final DateTime createdAt;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.activo,
    required this.createdAt,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id_usuario'] as int, // adapta si tu campo se llama distinto
      nombre: (json['nombre_usuario'] ?? json['nombre'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      rol: (json['rol'] ?? '') as String,
      activo: (json['activo'] ?? true) as bool,
      createdAt: _parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_usuario': id,
      'nombre_usuario': nombre,
      'email': email,
      'rol': rol,
      'activo': activo,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }
}
