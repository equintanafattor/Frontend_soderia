// lib/data/usuarios_repo.dart
class UsuariosRepo {
  Future<List<Map<String, dynamic>>> fetch() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {'nombre':'Ana','email':'ana@soderia.com','rol':'Ventas','activo':true,'created':DateTime(2025,9,1)},
      {'nombre':'Bruno','email':'bruno@soderia.com','rol':'Repartidor','activo':true,'created':DateTime(2025,9,5)},
      {'nombre':'Carla','email':'carla@soderia.com','rol':'Admin','activo':false,'created':DateTime(2025,8,20)},
    ];
  }
}
