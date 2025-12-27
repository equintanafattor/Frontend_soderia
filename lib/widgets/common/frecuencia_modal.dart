// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class FrecuenciaModal extends StatefulWidget {
  final int idDia;
  final List<Map<String, dynamic>> clientesDelDia;

  /// posicion: inicio | final | despues
  /// turno: manana | tarde
  /// despuesDeLegajo: int?
  final void Function(
    String posicion,
    String turno,
    int? despuesDeLegajo,
  ) onConfirm;

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
  String _posicion = 'final';
  String _turno = 'manana';
  int? _despuesDeLegajo;

  late final List<Map<String, dynamic>> _clientesExistentes;

  @override
  void initState() {
    super.initState();
    _clientesExistentes = widget.clientesDelDia;
  }

  bool get _puedeConfirmar {
    if (_posicion == 'despues') {
      return _despuesDeLegajo != null;
    }
    return true;
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

            // 📍 Posición
            DropdownButtonFormField<String>(
              value: _posicion,
              decoration: const InputDecoration(labelText: 'Posición'),
              items: const [
                DropdownMenuItem(value: 'inicio', child: Text('Al inicio')),
                DropdownMenuItem(value: 'final', child: Text('Al final')),
                DropdownMenuItem(
                  value: 'despues',
                  child: Text('Después de…'),
                ),
              ],
              onChanged: (v) {
                setState(() {
                  _posicion = v!;
                  if (_posicion != 'despues') {
                    _despuesDeLegajo = null;
                  }
                });
              },
            ),

            const SizedBox(height: 12),

            // 👤 Cliente de referencia
            if (_posicion == 'despues')
              _clientesExistentes.isEmpty
                  ? const Text(
                      'No hay clientes en ese día para usar como referencia.',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    )
                  : DropdownButtonFormField<int>(
                      value: _despuesDeLegajo,
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
                      onChanged: (v) =>
                          setState(() => _despuesDeLegajo = v),
                    ),

            const SizedBox(height: 12),

            // 🕒 Turno
            DropdownButtonFormField<String>(
              value: _turno,
              decoration: const InputDecoration(labelText: 'Turno'),
              items: const [
                DropdownMenuItem(value: 'manana', child: Text('Mañana')),
                DropdownMenuItem(value: 'tarde', child: Text('Tarde')),
              ],
              onChanged: (v) => setState(() => _turno = v!),
            ),

            const SizedBox(height: 24),

            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: _puedeConfirmar
                    ? () {
                        widget.onConfirm(
                          _posicion,
                          _turno,
                          _despuesDeLegajo,
                        );
                        Navigator.pop(context, true);
                      }
                    : null,
                child: const Text('Confirmar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
