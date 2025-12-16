// reporte_repartos_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReporteRepartosScreen extends StatefulWidget {
  const ReporteRepartosScreen({super.key});

  @override
  State<ReporteRepartosScreen> createState() => _ReporteRepartosScreenState();
}

class _ReporteRepartosScreenState extends State<ReporteRepartosScreen> {
  DateTime _desde = DateTime.now().subtract(const Duration(days: 7));
  DateTime _hasta = DateTime.now();

  bool _cargando = false;
  String? _error;
  List<dynamic> _repartos = []; // después tipamos

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      // TODO: llamar a tu servicio GET /repartos-dia?fecha_desde=&fecha_hasta=
      // _repartos = await _service.getPorRango(...);
      await Future.delayed(const Duration(milliseconds: 500)); // dummy
      setState(() {
        _repartos = []; // asignar lista real
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _cargando = false);
    }
  }

  Future<void> _pickRango() async {
    // Podés usar un date range picker custom, por simplicidad 2 pickers:
    final desde = await showDatePicker(
      context: context,
      initialDate: _desde,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (desde == null) return;
    final hasta = await showDatePicker(
      context: context,
      initialDate: _hasta,
      firstDate: desde,
      lastDate: DateTime(2100),
    );
    if (hasta == null) return;

    setState(() {
      _desde = desde;
      _hasta = hasta;
    });
    _load();
  }

  String _fmt(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // filtros
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickRango,
                  icon: const Icon(Icons.date_range),
                  label: Text('${_fmt(_desde)} - ${_fmt(_hasta)}'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _cuerpo(),
        ),
      ],
    );
  }

  Widget _cuerpo() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    if (_repartos.isEmpty) {
      return const Center(child: Text('No hay repartos para el rango.'));
    }

    // TODO: reemplazar por DataTable o ListView tipado
    return ListView.separated(
      itemCount: _repartos.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final r = _repartos[index];
        return ListTile(
          title: const Text('Reparto X'),
          subtitle: const Text('fecha / usuario / empresa'),
          trailing: const Text('\$ 0,00'),
          onTap: () {
            // TODO: navegar a detalle
          },
        );
      },
    );
  }
}
