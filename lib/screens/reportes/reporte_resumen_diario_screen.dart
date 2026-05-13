// reporte_resumen_diario_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:frontend_soderia/services/reparto_dia_service.dart';
import 'package:frontend_soderia/services/caja_empresa_service.dart';
import 'package:frontend_soderia/models/reparto_dia_out.dart';
import 'package:frontend_soderia/models/caja_empresa_total_out.dart';

// import 'package:frontend_soderia/core/colors.dart';

class ReporteResumenDiarioScreen extends StatefulWidget {
  const ReporteResumenDiarioScreen({super.key});

  @override
  State<ReporteResumenDiarioScreen> createState() =>
      _ReporteResumenDiarioScreenState();
}

class _ReporteResumenDiarioScreenState
    extends State<ReporteResumenDiarioScreen> {
  final _repartoService = RepartoDiaService();

  final _cajaService = CajaEmpresaService();

  DateTime _fecha = DateTime.now();
  bool _cargando = false;
  String? _error;

  RepartoDiaOut? _reparto;
  CajaEmpresaTotalOut? _totalCaja;

  // Si manejás múltiples empresas, acá podrías tener dropdown:
  int? _idEmpresa; // por ahora null = todas

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final repartoFuture = _repartoService.getByFecha(
        fecha: _fecha,
        idEmpresa: _idEmpresa,
      );

      final cajaFuture = _cajaService.getTotalPorFecha(
        fecha: _fecha,
        idEmpresa: _idEmpresa,
      );

      final results = await Future.wait([repartoFuture, cajaFuture]);

      if (!mounted) return;

      final reparto = results[0] as RepartoDiaOut?;
      final totalCaja = results[1] as CajaEmpresaTotalOut;

      setState(() {
        _reparto = reparto;
        _totalCaja = totalCaja;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _fecha) {
      setState(() => _fecha = picked);
      _load();
    }
  }

  String _formatFecha(DateTime d) {
    return DateFormat('dd/MM/yyyy').format(d);
  }

  String _formatMoney(double v) {
    final f = NumberFormat.currency(
      locale: 'es_AR',
      symbol: r'$',
      decimalDigits: 2,
    );
    return f.format(v);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFiltros(),
            const SizedBox(height: 16),
            if (_cargando) ...[
              const Center(child: CircularProgressIndicator()),
            ] else if (_error != null) ...[
              _buildError(),
            ] else ...[
              _buildKpis(),
              const SizedBox(height: 24),
              _buildDetalleReparto(),
              const SizedBox(height: 24),
              _buildDetalleCaja(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFiltros() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _seleccionarFecha,
            icon: const Icon(Icons.calendar_today),
            label: Text(_formatFecha(_fecha)),
          ),
        ),
        // Si después querés empresa:
        // const SizedBox(width: 8),
        // Expanded(
        //   child: DropdownButtonFormField<int>(
        //     decoration: const InputDecoration(
        //       labelText: 'Empresa',
        //     ),
        //     value: _idEmpresa,
        //     items: [
        //       const DropdownMenuItem(
        //         value: null,
        //         child: Text('Todas'),
        //       ),
        //       // ...
        //     ],
        //     onChanged: (value) {
        //       setState(() => _idEmpresa = value);
        //       _load();
        //     },
        //   ),
        // ),
      ],
    );
  }

  Widget _buildError() {
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
            child: Text(
              _error ?? 'Error desconocido',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpis() {
    final totalRecaudado = _reparto?.totalRecaudado ?? 0;
    final totalEfectivo = _reparto?.totalEfectivo ?? 0;
    final totalVirtual = _reparto?.totalVirtual ?? 0;
    final totalCaja = _totalCaja?.total ?? 0;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _KpiCard(
          titulo: 'Total Recaudado (Reparto)',
          valor: _formatMoney(totalRecaudado),
          icon: Icons.attach_money,
        ),
        _KpiCard(
          titulo: 'Total Efectivo',
          valor: _formatMoney(totalEfectivo),
          icon: Icons.money,
        ),
        _KpiCard(
          titulo: 'Total Virtual',
          valor: _formatMoney(totalVirtual),
          icon: Icons.credit_card,
        ),
        _KpiCard(
          titulo: 'Total Caja Empresa',
          valor: _formatMoney(totalCaja),
          icon: Icons.account_balance_wallet,
        ),
      ],
    );
  }

  Widget _buildDetalleReparto() {
    if (_reparto == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: const [
              Icon(Icons.info_outline),
              SizedBox(width: 8),
              Expanded(
                child: Text('No hay reparto registrado para esta fecha.'),
              ),
            ],
          ),
        ),
      );
    }

    final r = _reparto!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detalle del Reparto del Día',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDetalleRow('ID Reparto', r.idRepartoDia.toString()),
            _buildDetalleRow('Empresa', r.idEmpresa.toString()),
            _buildDetalleRow('Usuario', r.idUsuario.toString()),
            _buildDetalleRow('Fecha', _formatFecha(r.fecha)),
            if (r.observacion != null && r.observacion!.isNotEmpty)
              _buildDetalleRow('Observación', r.observacion!),
          ],
        ),
      ),
    );
  }

  Widget _buildDetalleCaja() {
    if (_totalCaja == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Caja Empresa (Día)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDetalleRow('Total del día', _formatMoney(_totalCaja!.total)),
            const SizedBox(height: 8),
            const Text(
              'Incluye cierres automáticos por reparto y otros movimientos de caja de la empresa.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetalleRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icon;

  const _KpiCard({
    required this.titulo,
    required this.valor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Podés reemplazar Colors.* por tus AppColors
    return SizedBox(
      width: 220,
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20),
              const SizedBox(height: 8),
              Text(
                titulo,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
