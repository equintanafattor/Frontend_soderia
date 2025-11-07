import 'package:flutter/material.dart';
import 'package:frontend_soderia/services/cliente_service.dart';

class FrecuenciaModal extends StatefulWidget {
  final int idDia;
  final Function(String modo, String turno, int? refCliente) onConfirm;

  const FrecuenciaModal({
    super.key,
    required this.idDia,
    required this.onConfirm,
  });

  @override
  State<FrecuenciaModal> createState() => _FrecuenciaModalState();
}

class _FrecuenciaModalState extends State<FrecuenciaModal> {
  String _modo = 'final';
  String _turno = 'mañana';
  int? _refCliente;
  List<dynamic> _clientesExistentes = [];

  @override
  void initState() {
    super.initState();
    _loadClientes();
  }

  Future<void> _loadClientes() async {
    final service = ClienteService();
    try {
      final list = await service.listarClientesPorDia(widget.idDia);
      setState(() => _clientesExistentes = list);
    } catch (_) {
      // si falla, lo dejamos vacío
    }
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
                  value: 'despues_de',
                  child: Text('Después de...'),
                ),
              ],
              onChanged: (v) => setState(() => _modo = v!),
            ),

            const SizedBox(height: 12),

            if (_modo == 'despues_de')
              DropdownButtonFormField<int>(
                value: _refCliente,
                decoration: const InputDecoration(
                  labelText: 'Cliente de referencia',
                ),
                items: _clientesExistentes.map<DropdownMenuItem<int>>((c) {
                  // intentamos distintos nombres según lo que devuelva el back
                  final int idCliente =
                      c['id_cliente'] ?? c['legajo'] ?? c['id'] as int;
                  // nombre “bonito” si viene con join
                  final String label;
                  if (c['cliente'] != null && c['cliente']['persona'] != null) {
                    label =
                        '${c['cliente']['persona']['nombre']} ${c['cliente']['persona']['apellido']}';
                  } else {
                    label = 'Cliente $idCliente';
                  }
                  return DropdownMenuItem<int>(
                    value: idCliente,
                    child: Text(label),
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
                  Navigator.pop(context);
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
