// reporte_caja_empresa_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReporteCajaEmpresaScreen extends StatefulWidget {
  const ReporteCajaEmpresaScreen({super.key});

  @override
  State<ReporteCajaEmpresaScreen> createState() =>
      _ReporteCajaEmpresaScreenState();
}

class _ReporteCajaEmpresaScreenState extends State<ReporteCajaEmpresaScreen> {
  DateTime _desde = DateTime.now().subtract(const Duration(days: 7));
  DateTime _hasta = DateTime.now();

  bool _cargando = false;
  String? _error;
  double _totalRango = 0;
  List<dynamic> _movimientos = []; // después tipamos

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
      // TODO:
      // 1) llamar a /caja-empresa/total-por-rango
      // 2) llamar a /caja-empresa/movimientos (cuando lo tengas)
      await Future.delayed(const Duration(milliseconds: 500)); // dummy
      setState(() {
        _totalRango = 0; // valor real
        _movimientos = []; // lista real
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _cargando = false);
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

  String _money(double v) => NumberFormat.currency(
    locale: 'es_AR',
    symbol: r'$',
    decimalDigits: 2,
  ).format(v);

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
        // KPI
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            child: ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Total caja en el rango'),
              subtitle: Text('${_fmt(_desde)} - ${_fmt(_hasta)}'),
              trailing: Text(
                _money(_totalRango),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(child: _cuerpo()),
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
    if (_movimientos.isEmpty) {
      return const Center(child: Text('No hay movimientos en este rango.'));
    }

    // TODO: DataTable / ListView bien tipado
    return ListView.separated(
      itemCount: _movimientos.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final m = _movimientos[index];
        return ListTile(
          leading: const Icon(Icons.compare_arrows),
          title: const Text('Tipo movimiento'),
          subtitle: const Text('Fecha / Medio de pago / Observación'),
          trailing: Text(_money(0)),
        );
      },
    );
  }
}
