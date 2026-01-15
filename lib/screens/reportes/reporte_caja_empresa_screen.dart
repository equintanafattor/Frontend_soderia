// reporte_caja_empresa_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:frontend_soderia/models/caja_empresa_movimiento_out.dart';
import 'package:frontend_soderia/models/caja_empresa_total_out.dart';
import 'package:intl/intl.dart';
import 'package:frontend_soderia/services/caja_empresa_service.dart';

class ReporteCajaEmpresaScreen extends StatefulWidget {
  const ReporteCajaEmpresaScreen({super.key});

  @override
  State<ReporteCajaEmpresaScreen> createState() =>
      _ReporteCajaEmpresaScreenState();
}

class _ReporteCajaEmpresaScreenState extends State<ReporteCajaEmpresaScreen> {
  final _cajaService = CajaEmpresaService();

  DateTime _desde = DateTime.now().subtract(const Duration(days: 7));
  DateTime _hasta = DateTime.now();

  bool _cargando = false;
  String? _error;

  double _totalRango = 0;

  // cuando exista endpoint, tipamos y cargamos
  List<CajaEmpresaMovimientoOut> _movimientos = [];

  // Si manejás empresa: setear desde selector.
  int? _idEmpresa;

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
      final totalFuture = _cajaService.getTotalPorRango(
        desde: _desde,
        hasta: _hasta,
        idEmpresa: _idEmpresa,
      );

      final movFuture = _cajaService.getMovimientosPorRango(
        desde: _desde,
        hasta: _hasta,
        idEmpresa: _idEmpresa,
        limit: 200,
        offset: 0,
      );

      final results = await Future.wait([totalFuture, movFuture]);

      final totalOut = results[0] as CajaEmpresaTotalOut;
      final movOut = results[1] as (List<CajaEmpresaMovimientoOut>, int);

      setState(() {
        _totalRango = totalOut.total;
        _movimientos = movOut.$1;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
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

  String _money(double v) => NumberFormat.currency(
    locale: 'es_AR',
    symbol: r'$',
    decimalDigits: 2,
  ).format(v);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                trailing: _cargando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _money(_totalRango),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _ErrorBox(text: _error!),
            ),

          const SizedBox(height: 8),

          // movimientos
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: SizedBox(
                height: 520, // 👈 ajustá si querés más/menos alto
                child: _cargando
                    ? const Center(child: CircularProgressIndicator())
                    : _movimientos.isEmpty
                    ? const Center(
                        child: Text('No hay movimientos en este rango.'),
                      )
                    : ListView.separated(
                        itemCount: _movimientos.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final m = _movimientos[index];

                          return ListTile(
                            leading: const Icon(Icons.compare_arrows),
                            title: Text(
                              m.tipoMovimiento ?? m.tipo,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${DateFormat('dd/MM/yyyy HH:mm').format(m.fecha)} · '
                              '${m.medioPago ?? '-'}'
                              '${(m.observacion != null && m.observacion!.isNotEmpty) ? '\n${m.observacion}' : ''}',
                            ),
                            trailing: Text(
                              _money(m.monto),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String text;
  const _ErrorBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
