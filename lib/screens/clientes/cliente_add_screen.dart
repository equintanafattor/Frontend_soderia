// screens/clientes/cliente_add_screen.dart
import 'package:flutter/material.dart';
import 'package:frontend_soderia/widgets/common/frecuencia_modal.dart';
import 'package:frontend_soderia/widgets/common/weekdays_selector.dart';
import 'package:frontend_soderia/core/constants/dias_semana.dart';
import 'package:frontend_soderia/services/cliente_service.dart';

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
  final Map<int, Map<String, dynamic>> _frecuenciasConfig = {};

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
    _zona.dispose(); // 👈 importante
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
              onChanged: (s) async {
                for (final idDia in s.difference(_frecuencia)) {
                  // se agregó un nuevo día → abrir modal
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => FrecuenciaModal(
                      idDia: idDia,
                      onConfirm: (modo, turno, refCliente) {
                        // acá podés guardar esta info para usar en _submit()
                        // ejemplo:
                        _frecuenciasConfig[idDia] = {
                          'modo': modo,
                          'turno': turno,
                          'ref': refCliente,
                        };
                      },
                    ),
                  );
                }
                setState(() => _frecuencia = s);
              },
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

    final service = ClienteService();

    try {
      // 1) crear cliente base
      final res = await service.crearCliente(
        nombre: _nombre.text.trim(),
        apellido: _apellido.text.trim(),
        dni: _dni.text.trim(),
        observacion: _obs.text.trim().isEmpty ? null : _obs.text.trim(),
      );

      // el back te devuelve el legajo
      final int legajo = res['legajo'];

      // 2) dirección si hay
      if (_direccion.text.trim().isNotEmpty) {
        await service.agregarDireccion(legajo, {
          "direccion": _direccion.text.trim(),
          "entre_calle": _entre1.text.trim().isEmpty
              ? null
              : _entre1.text.trim(),
          "y_calle": _entre2.text.trim().isEmpty ? null : _entre2.text.trim(),
          "zona_barrio": _zona.text.trim().isEmpty ? null : _zona.text.trim(),
        });
      }

      // 3) teléfonos
      if (_tel1.text.trim().isNotEmpty) {
        await service.agregarTelefono(legajo, _tel1.text.trim());
      }
      if (_tel2.text.trim().isNotEmpty) {
        await service.agregarTelefono(legajo, _tel2.text.trim());
      }

      // 4) mail
      if (_mail.text.trim().isNotEmpty) {
        await service.agregarMail(legajo, _mail.text.trim());
      }

      // 5) frecuencia (acá hoy solo tenés los días marcados,
      // después le agregamos el modal para "inicio/final/después de")
      for (final idDia in _frecuencia) {
        final f = _frecuenciasConfig[idDia];
        await service.agregarFrecuencia(
          legajo,
          idDia: idDia,
          modo: f?['modo'] ?? 'final',
          turnoVisita: f?['turno'] ?? 'mañana',
          idClienteReferencia: f?['ref'],
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cliente guardado')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
