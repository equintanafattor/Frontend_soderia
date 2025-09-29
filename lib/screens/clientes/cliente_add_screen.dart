// screens/clientes/cliente_add_screen.dart
import 'package:flutter/material.dart';
import 'package:frontend_soderia/widgets/common/weekdays_selector.dart';

class ClienteAddScreen extends StatefulWidget {
  const ClienteAddScreen({super.key});

  @override
  State<ClienteAddScreen> createState() => _ClienteAddScreenState();
}

class _ClienteAddScreenState extends State<ClienteAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _apellido = TextEditingController();
  final _dni = TextEditingController();
  final _direccion = TextEditingController();
  final _entre1 = TextEditingController();
  final _entre2 = TextEditingController();
  final _zona = TextEditingController();
  final _tel1 = TextEditingController();
  final _tel2 = TextEditingController();
  final _mail = TextEditingController();
  final _obs = TextEditingController();
  Set<int> _frecuencia = {};

  @override
  void dispose() {
    _nombre.dispose();
    _apellido.dispose();
    _dni.dispose();
    _direccion.dispose();
    _entre1.dispose();
    _entre2.dispose();
    _tel1.dispose();
    _tel2.dispose();
    _mail.dispose();
    _obs.dispose();
    _zona.dispose();          // 👈 importante
    super.dispose();
  }

  bool get _isValid =>
      _formKey.currentState?.validate() == true && _frecuencia.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo cliente'),
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
            _row3(
              _tf('Nombre', _nombre, validator: _req),
              _tf('Apellido', _apellido, validator: _req),
              _tf(
                'DNI',
                _dni,
                keyboard: TextInputType.number,
                validator: (v) => _req(v) ?? _dniOk(v),
              ),
            ),
            const Divider(),
            _row3(
              _tf('Dirección', _direccion, validator: _req),
              _tf('Entre calle', _entre1),
              _tf('y', _entre2),
            ),
            const SizedBox(height: 12),
            _tf('Zona / Barrio', _zona), 
            const Divider(),
            _row3(
              _tf(
                'Teléfono 1',
                _tel1,
                keyboard: TextInputType.phone,
                validator: _req,
              ),
              _tf('Teléfono 2', _tel2, keyboard: TextInputType.phone),
              _tf(
                'Mail',
                _mail,
                keyboard: TextInputType.emailAddress,
                validator: _mailOk,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Frecuencia de visita',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            WeekdaysSelector(
              initial: const {},
              onChanged: (s) => setState(() => _frecuencia = s),
            ),
            const Divider(height: 32),
            _ta('Observaciones', _obs),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed: _isValid ? _submit : null,
            icon: const Icon(Icons.save),
            label: const Text('Guardar'),
          ),
        ),
      ),
    );
  }

  //Helpers UI
  Widget _row3(Widget a, Widget b, Widget c) => LayoutBuilder(
    builder: (ctx, _) {
      final isWide = MediaQuery.sizeOf(ctx).width > 900;
      return isWide
          ? Row(
              children: [
                Expanded(child: a),
                const SizedBox(width: 16),
                Expanded(child: b),
                const SizedBox(width: 16),
                Expanded(child: c),
              ],
            )
          : Column(
              children: [
                a,
                const SizedBox(height: 12),
                b,
                const SizedBox(height: 12),
                c,
              ],
            );
    },
  );

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

  Widget _ta(String label, TextEditingController c) => TextFormField(
    controller: c,
    maxLines: 4,
    decoration: InputDecoration(labelText: label),
  );

  // Validators
  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Obligatorio' : null;
  String? _mailOk(String? v) {
    if (v == null || v.isEmpty) return null;
    final ok = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v);
    return ok ? null : 'Email inválido';
  }

  String? _dniOk(String? v) {
    if (v == null || v.isEmpty) return null;
    return RegExp(r'^\d{7,9}$').hasMatch(v) ? null : 'DNI inválido';
  }

  Future<void> _submit() async {
    if (!_isValid) return;
    // TODO: llamar a tu repositorio/servicio
    // await ClientesRepo.create(ClienteCreate(...));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cliente guardado')));
      Navigator.pop(context, true);
    }
  }
}
