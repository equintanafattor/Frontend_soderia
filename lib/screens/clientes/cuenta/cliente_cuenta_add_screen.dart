// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:frontend_soderia/services/cliente_service.dart';

class ClienteCuentaAddScreen extends StatefulWidget {
  final int legajo;

  const ClienteCuentaAddScreen({
    super.key,
    required this.legajo,
  });

  @override
  State<ClienteCuentaAddScreen> createState() =>
      _ClienteCuentaAddScreenState();
}

class _ClienteCuentaAddScreenState extends State<ClienteCuentaAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ClienteService();

  final _tipoController = TextEditingController();
  final _bidonesController = TextEditingController(text: '0');

  String _estado = 'ACTIVA';
  bool _loading = false;

  @override
  void dispose() {
    _tipoController.dispose();
    _bidonesController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await _service.crearCuenta(
        legajo: widget.legajo,
        payload: {
          'tipo_de_cuenta': _tipoController.text.trim(),
          'estado': _estado,
          'numero_bidones': int.tryParse(_bidonesController.text) ?? 0,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cuenta creada correctamente')),
        );
        Navigator.of(context).pop(true); // 🔁 refresca detail
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva cuenta'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // TIPO DE CUENTA
            TextFormField(
              controller: _tipoController,
              decoration: const InputDecoration(
                labelText: 'Tipo de cuenta',
                hintText: 'Ej: Cuenta corriente, Dispenser, Empresa',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty
                      ? 'Ingresá el tipo de cuenta'
                      : null,
            ),

            const SizedBox(height: 16),

            // ESTADO
            DropdownButtonFormField<String>(
              value: _estado,
              items: const [
                DropdownMenuItem(
                  value: 'ACTIVA',
                  child: Text('ACTIVA'),
                ),
                DropdownMenuItem(
                  value: 'INACTIVA',
                  child: Text('INACTIVA'),
                ),
              ],
              onChanged: (v) => setState(() => _estado = v ?? 'ACTIVA'),
              decoration: const InputDecoration(labelText: 'Estado'),
            ),

            const SizedBox(height: 16),

            // BIDONES
            TextFormField(
              controller: _bidonesController,
              decoration: const InputDecoration(
                labelText: 'Número de bidones',
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 24),

            // INFO
            Card(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceVariant
                  .withOpacity(0.3),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'El saldo y la deuda se calcularán automáticamente a partir '
                  'de los pedidos y pagos del cliente.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton(
            onPressed: _loading ? null : _guardar,
            child: _loading
                ? const CircularProgressIndicator()
                : const Text('Crear cuenta'),
          ),
        ),
      ),
    );
  }
}
