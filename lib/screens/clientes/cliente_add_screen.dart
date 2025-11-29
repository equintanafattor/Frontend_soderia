// screens/clientes/cliente_add_screen.dart
import 'package:flutter/material.dart';
import 'package:frontend_soderia/widgets/common/weekdays_selector.dart';
import 'package:frontend_soderia/core/constants/dias_semana.dart';
import 'package:frontend_soderia/services/cliente_service.dart';
import 'package:frontend_soderia/widgets/common/frecuencia_modal.dart';

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

  // días seleccionados (id_dia)
  Set<int> _frecuencia = {};
  // config por día: { 1: {modo: 'final', turno: 'mañana', ref: 123}, ... }
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
    _zona.dispose();
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
              onChanged: (newSet) async {
                // días destildados → limpiar
                final quitados = _frecuencia.difference(newSet);
                for (final dia in quitados) {
                  _frecuenciasConfig.remove(dia);
                }

                // días tildados → si no tienen config, abrir modal
                for (final dia in newSet) {
                  if (!_frecuenciasConfig.containsKey(dia)) {
                    final confirmed = await showModalBottomSheet<bool>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => FrecuenciaModal(
                        idDia: dia,
                        onConfirm: (modo, turno, refCliente) {
                          _frecuenciasConfig[dia] = {
                            'modo': modo,
                            'turno': turno,
                            'ref': refCliente,
                          };
                        },
                      ),
                    );

                    if (confirmed != true) {
                      // no confirmó → no guardamos y queda sin config
                      _frecuenciasConfig.remove(dia);
                    }
                  }
                }

                setState(() => _frecuencia = newSet);
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
      // 1) persona
      final persona = {
        "nombre": _nombre.text.trim(),
        "apellido": _apellido.text.trim(),
        "dni": int.parse(_dni.text.trim()),
      };

      // 2) direcciones (array aunque haya una sola)
      final direcciones = <Map<String, dynamic>>[];
      if (_direccion.text.trim().isNotEmpty) {
        direcciones.add({
          "direccion": _direccion.text.trim(),
          "entre_calle1": _entre1.text.trim().isEmpty
              ? null
              : _entre1.text.trim(),
          "entre_calle2": _entre2.text.trim().isEmpty
              ? null
              : _entre2.text.trim(),
          "zona": _zona.text.trim().isEmpty ? null : _zona.text.trim(),
        });
      }

      // 3) teléfonos
      final telefonos = <Map<String, dynamic>>[];
      if (_tel1.text.trim().isNotEmpty) {
        telefonos.add({"nro_telefono": _tel1.text.trim()});
      }
      if (_tel2.text.trim().isNotEmpty) {
        telefonos.add({"nro_telefono": _tel2.text.trim()});
      }

      // 4) emails
      final emails = <Map<String, dynamic>>[];
      if (_mail.text.trim().isNotEmpty) {
        emails.add({"mail": _mail.text.trim()});
      }

      // 5) dias_visita (el back quiere códigos: "lun", "mar", ...)
      final diasVisita = _frecuencia.map((idDia) {
        final dia = diasSemana.firstWhere((d) => d['id'] == idDia);
        return dia['codigo'] as String;
      }).toList();

      // 6) frecuencias (usa la info del modal)
      final frecuencias = _frecuencia.map((idDia) {
        final dia = diasSemana.firstWhere((d) => d['id'] == idDia);
        final cfg = _frecuenciasConfig[idDia];

        // turno
        String turnoBack = 'manana';
        if (cfg?['turno'] == 'tarde') turnoBack = 'tarde';

        // posicion lógica
        final modo = cfg?['modo'];

        final String posicionBack = (modo == 'despues')
            ? 'despues'
            : (modo ?? 'final');

        final int? ref = (modo == 'despues' && cfg?['ref'] != null)
            ? cfg!['ref']
            : null;

        return {
          "dia": dia['codigo'],
          "turno": turnoBack,
          "posicion": posicionBack,
          if (ref != null) "despues_de_legajo": ref,
        };
      }).toList();

      // 7) turno_visita general (el back lo tiene a nivel raíz)
      // podemos tomar el primero o dejar "manana" por defecto
      String turnoVisitaRoot = 'manana';
      if (_frecuencia.isNotEmpty) {
        final firstCfg = _frecuenciasConfig[_frecuencia.first];
        if (firstCfg != null && firstCfg['turno'] == 'tarde') {
          turnoVisitaRoot = 'tarde';
        }
      }

      // 8) armar body final EXACTO al back
      final body = {
        "observacion": _obs.text.trim().isEmpty ? null : _obs.text.trim(),
        "dni": int.parse(_dni.text.trim()),
        "persona": persona,
        "direcciones": direcciones,
        "telefonos": telefonos,
        "emails": emails,
        "dias_visita": diasVisita,
        "turno_visita": turnoVisitaRoot,
        "frecuencias": frecuencias,
      };

      final res = await service.crearClienteCompleto(body);

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
