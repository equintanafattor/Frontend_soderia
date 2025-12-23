// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:frontend_soderia/services/cliente_service.dart';

class FrecuenciaModal extends StatefulWidget {
  final int idDia;
  final List<Map<String, dynamic>> clientesDelDia;
  final void Function(String modo, String turno, int? refCliente) onConfirm;

  const FrecuenciaModal({
    super.key,
    required this.idDia,
    required this.clientesDelDia,
    required this.onConfirm,
  });

  @override
  State<FrecuenciaModal> createState() => _FrecuenciaModalState();
}

class _FrecuenciaModalState extends State<FrecuenciaModal> {
  String _modo = 'final';
  String _turno = 'mañana';
  int? _refCliente;
  late final List<Map<String, dynamic>> _clientesExistentes;

  @override
  void initState() {
    super.initState();
    _clientesExistentes = widget.clientesDelDia;
    debugPrint(
      '🧪 Modal día ${widget.idDia} → clientes: ${_clientesExistentes.length}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configurá la frecuencia',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // modo
            DropdownButtonFormField<String>(
              value: _modo,
              decoration: const InputDecoration(labelText: 'Posición'),
              items: const [
                DropdownMenuItem(value: 'inicio', child: Text('Al inicio')),
                DropdownMenuItem(value: 'final', child: Text('Al final')),
                DropdownMenuItem(
                  value: 'despues',
                  child: Text('Después de...'),
                ),
              ],
              onChanged: (v) => setState(() => _modo = v!),
            ),

            const SizedBox(height: 12),

            if (_modo == 'despues')
              _clientesExistentes.isEmpty
                  ? const Text(
                      'No hay clientes en ese día para poner “después de”.',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    )
                  : DropdownButtonFormField<int>(
                      value: _refCliente,
                      decoration: const InputDecoration(
                        labelText: 'Cliente de referencia',
                      ),
                      items: _clientesExistentes.map((c) {
                        final int legajo = c['legajo'];
                        final nombre = c['nombre'] ?? '';
                        final apellido = c['apellido'] ?? '';
                        return DropdownMenuItem<int>(
                          value: legajo,
                          child: Text('$nombre $apellido'.trim()),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _refCliente = v),
                    ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _turno,
              decoration: const InputDecoration(labelText: 'Turno'),
              items: const [
                DropdownMenuItem(value: 'mañana', child: Text('Mañana')),
                DropdownMenuItem(value: 'tarde', child: Text('Tarde')),
              ],
              onChanged: (v) => setState(() => _turno = v!),
            ),

            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () {
                  widget.onConfirm(_modo, _turno, _refCliente);
                  Navigator.pop(context, true);
                },
                child: const Text('Confirmar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
