import 'package:flutter/material.dart';
import 'package:frontend_soderia/services/cliente_service.dart';

class ClienteEditScreen extends StatefulWidget {
  const ClienteEditScreen({super.key});

  @override
  State<ClienteEditScreen> createState() => _ClienteEditScreenState();
}

class _ClienteEditScreenState extends State<ClienteEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ClienteService();

  late int _legajo;
  late Map<String, dynamic> _data;

  late TextEditingController _nombreCtrl;
  late TextEditingController _apellidoCtrl;
  late TextEditingController _dniCtrl;
  late TextEditingController _obsPersonaCtrl;
  late TextEditingController _obsClienteCtrl;

  bool _loading = false;
  bool _inited = false;

  void _initFromArgs() {
    if (_inited) return;
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _legajo = args['legajo'] as int;
    _data = (args['data'] as Map).cast<String, dynamic>();

    final persona = _data['persona'] ?? {};
    _nombreCtrl = TextEditingController(text: persona['nombre']?.toString() ?? '');
    _apellidoCtrl = TextEditingController(text: persona['apellido']?.toString() ?? '');
    _dniCtrl = TextEditingController(
      text: (persona['dni'] ?? _data['dni'] ?? '').toString(),
    );
    _obsPersonaCtrl = TextEditingController(
      text: persona['observacion']?.toString() ?? '',
    );
    _obsClienteCtrl = TextEditingController(
      text: _data['observacion']?.toString() ?? '',
    );

    _inited = true;
  }

  @override
  void dispose() {
    if (_inited) {
      _nombreCtrl.dispose();
      _apellidoCtrl.dispose();
      _dniCtrl.dispose();
      _obsPersonaCtrl.dispose();
      _obsClienteCtrl.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final body = {
        "observacion": _obsClienteCtrl.text.trim().isEmpty
            ? null
            : _obsClienteCtrl.text.trim(),
        "persona": {
          "nombre": _nombreCtrl.text.trim().isEmpty
              ? null
              : _nombreCtrl.text.trim(),
          "apellido": _apellidoCtrl.text.trim().isEmpty
              ? null
              : _apellidoCtrl.text.trim(),
          "dni": _dniCtrl.text.trim().isEmpty
              ? null
              : int.parse(_dniCtrl.text.trim()),
          "observacion": _obsPersonaCtrl.text.trim().isEmpty
              ? null
              : _obsPersonaCtrl.text.trim(),
        }
      };

      // sacamos los nulls de persona
      (body["persona"] as Map<String, dynamic>).removeWhere((k, v) => v == null);

      final actualizado =
          await _service.actualizarCliente(_legajo, body);

      if (mounted) {
        Navigator.of(context).pop(actualizado);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error guardando: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _initFromArgs();

    return Scaffold(
      appBar: AppBar(
        title: Text('Editar cliente $_legajo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Datos de la persona',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextFormField(
                controller: _apellidoCtrl,
                decoration: const InputDecoration(labelText: 'Apellido'),
              ),
              TextFormField(
                controller: _dniCtrl,
                decoration: const InputDecoration(labelText: 'DNI'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _obsPersonaCtrl,
                decoration:
                    const InputDecoration(labelText: 'Observaciones de la persona'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Text('Datos del cliente',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _obsClienteCtrl,
                decoration:
                    const InputDecoration(labelText: 'Observaciones del cliente'),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _loading ? null : _guardar,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

