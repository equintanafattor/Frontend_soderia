import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_soderia/services/usuario_service.dart';

enum Rol { admin, ventas, repartidor, caja }

extension RolX on Rol {
  String get label => switch (this) {
    Rol.admin => 'Admin',
    Rol.ventas => 'Ventas',
    Rol.repartidor => 'Repartidor',
    Rol.caja => 'Caja',
  };
}

class UsuarioAddScreen extends StatefulWidget {
  const UsuarioAddScreen({super.key});
  @override
  State<UsuarioAddScreen> createState() => _UsuarioAddScreenState();
}

class _UsuarioAddScreenState extends State<UsuarioAddScreen> {
  final _formKey = GlobalKey<FormState>();

  // Nuevo: nombre de usuario
  final _username = TextEditingController();

  final _nombre = TextEditingController();
  final _mail = TextEditingController();
  final _tel = TextEditingController();
  Rol? _rol;
  bool _activo = true;

  final _service = UsuarioService();

  // Guardamos la contraseña generada para usar la MISMA en el POST
  String? _tempPass;

  bool get _isValid =>
      _formKey.currentState?.validate() == true && _rol != null;

  @override
  void dispose() {
    _username.dispose();
    _nombre.dispose();
    _mail.dispose();
    _tel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar usuario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isValid ? _submit : null,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 👇 NUEVO campo: nombre de usuario (login)
            _tf(
              'Nombre de usuario',
              _username,
              validator: _req,
              keyboard: TextInputType.text,
            ),

            _tf('Nombre y apellido', _nombre, validator: _req),
            _tf(
              'Email',
              _mail,
              keyboard: TextInputType.emailAddress,
              validator: _mailOk,
            ),
            _tf('Teléfono', _tel, keyboard: TextInputType.phone),
            const SizedBox(height: 8),
            Text('Rol', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Wrap(
              spacing: 10,
              children: Rol.values
                  .map(
                    (r) => ChoiceChip(
                      label: Text(r.label),
                      selected: _rol == r,
                      onSelected: (_) => setState(() => _rol = r),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Switch.adaptive(
                  value: _activo,
                  onChanged: (v) => setState(() => _activo = v),
                ),
                const Text('Activo'),
                const Spacer(),
                OutlinedButton.icon(
                  icon: const Icon(Icons.key),
                  label: const Text('Contraseña temporal'),
                  onPressed: _genPass,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tf(
    String label,
    TextEditingController c, {
    String? Function(String?)? validator,
    TextInputType? keyboard,
  }) => TextFormField(
    controller: c,
    decoration: InputDecoration(labelText: label),
    validator: validator,
    keyboardType: keyboard,
  );

  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Obligatorio' : null;

  String? _mailOk(String? v) {
    if (_req(v) != null) return 'Obligatorio';
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v!)
        ? null
        : 'Email inválido';
  }

  Future<void> _genPass() async {
    final pass = _randomPass();
    _tempPass = pass; // guardamos para usarla en el submit

    await Clipboard.setData(ClipboardData(text: pass));
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Contraseña temporal'),
        content: SelectableText(pass),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _randomPass() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789*@#';
    final rnd = Random.secure();
    return List.generate(10, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  Future<void> _submit() async {
    if (!_isValid) return;

    // Asegurarnos de tener contraseña generada
    if (_tempPass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Primero generá una contraseña temporal para el usuario.',
          ),
        ),
      );
      return;
    }

    final username = _username.text.trim();

    try {
      await _service.crearUsuario(
        nombreUsuario: username,
        contrasena: _tempPass!,
        // Por ahora null hasta que lo ates a empleado/cliente
        legajoEmpleado: null,
        legajoCliente: null,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Usuario guardado')));
      Navigator.pop(context, true); // para que la lista recargue
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar usuario: $e')));
    }
  }
}
