// reporte_repartos_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend_soderia/services/reparto_dia_service.dart';
import 'package:frontend_soderia/models/reparto_dia_out.dart';

class ReporteRepartosScreen extends StatefulWidget {
  const ReporteRepartosScreen({super.key});

  @override
  State<ReporteRepartosScreen> createState() => _ReporteRepartosScreenState();
}

class _ReporteRepartosScreenState extends State<ReporteRepartosScreen> {
  final _service = RepartoDiaService();

  DateTime _desde = DateTime.now().subtract(const Duration(days: 7));
  DateTime _hasta = DateTime.now();

  bool _cargando = false;
  String? _error;

  List<RepartoDiaOut> _repartos = [];

  int? _idEmpresa; // opcional
  int? _idUsuario; // opcional

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
      final data = await _service.getPorRango(
        desde: _desde,
        hasta: _hasta,
        idEmpresa: _idEmpresa,
        idUsuario: _idUsuario,
      );

      setState(() => _repartos = data);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _pickRango() async {
    final desde = await showDatePicker(
      context: context,
      initialDate: _desde,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (desde == null) return;

    final hasta = await showDatePicker(
      context: context,
      initialDate: _hasta.isBefore(desde) ? desde : _hasta,
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

  String _money(num v) => NumberFormat.currency(
    locale: 'es_AR',
    symbol: r'$',
    decimalDigits: 2,
  ).format(v);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: Column(
        children: [
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
          Expanded(child: _cuerpo()),
        ],
      ),
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

    return ListView.separated(
      itemCount: _repartos.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final r = _repartos[index];

        return ListTile(
          title: Text('Reparto #${r.idRepartoDia} — ${_fmt(r.fecha)}'),
          subtitle: Text('Empresa ${r.idEmpresa} · Usuario ${r.idUsuario}'),
          trailing: Text(
            _money(r.totalRecaudado),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          onTap: () {
            // próximo paso: ir a detalle (clientes, recorridos, etc.)
          },
        );
      },
    );
  }
}
