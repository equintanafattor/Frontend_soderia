import 'package:flutter/material.dart';
import 'package:frontend_soderia/models/usuario.dart';
import 'package:frontend_soderia/services/usuario_service.dart';

class UsuarioEditScreen extends StatefulWidget {
  const UsuarioEditScreen({super.key, required this.usuario});

  final Usuario usuario;

  @override
  State<UsuarioEditScreen> createState() => _UsuarioEditScreenState();
}

class _UsuarioEditScreenState extends State<UsuarioEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _mail;
  late final TextEditingController _tel; // por si después lo agregás al modelo
  late bool _activo;
  String _rol = '';

  final _service = UsuarioService();

  bool get _isValid => _formKey.currentState?.validate() == true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nombre = TextEditingController(text: widget.usuario.nombre);
    _mail = TextEditingController(text: widget.usuario.email);
    _tel = TextEditingController(); // placeholder
    _activo = widget.usuario.activo;
    _rol = widget.usuario.rol;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _mail.dispose();
    _tel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar usuario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: (_isValid && !_saving) ? _guardar : null,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nombre,
              decoration: const InputDecoration(labelText: 'Nombre y apellido'),
              validator: _req,
            ),
            TextFormField(
              controller: _mail,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: _mailOk,
            ),
            TextFormField(
              controller: _tel,
              decoration: const InputDecoration(labelText: 'Teléfono'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            Text('Rol', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                for (final r in ['Admin', 'Ventas', 'Repartidor', 'Caja'])
                  ChoiceChip(
                    label: Text(r),
                    selected: _rol == r,
                    onSelected: (_) => setState(() => _rol = r),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              value: _activo,
              onChanged: (v) => setState(() => _activo = v),
              title: const Text('Activo'),
            ),
          ],
        ),
      ),
    );
  }

  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Obligatorio' : null;

  String? _mailOk(String? v) {
    if (_req(v) != null) return 'Obligatorio';
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(v!) ? null : 'Email inválido';
  }

  Future<void> _guardar() async {
    if (_saving) return;
    setState(() => _saving = true);
    final u = widget.usuario;
    final actualizado = Usuario(
      id: u.id,
      nombre: _nombre.text.trim(),
      email: _mail.text.trim(),
      rol: _rol.isEmpty ? u.rol : _rol,
      activo: _activo,
      createdAt: u.createdAt,
    );

    try {
      await _service.actualizarUsuario(actualizado);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al actualizar: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
