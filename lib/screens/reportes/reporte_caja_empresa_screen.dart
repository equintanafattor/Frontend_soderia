// reporte_caja_empresa_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:frontend_soderia/models/caja_empresa_movimiento_in.dart';
import 'package:frontend_soderia/models/caja_empresa_movimiento_out.dart';
import 'package:frontend_soderia/models/caja_empresa_total_out.dart';
import 'package:frontend_soderia/services/caja_empresa_service.dart';
import 'package:intl/intl.dart';

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

  List<CajaEmpresaMovimientoOut> _movimientos = [];

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

      if (!mounted) return;
      setState(() {
        _totalRango = totalOut.total;
        _movimientos = movOut.$1;
      });
    } catch (e) {
      if (!mounted) return;
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

  Future<void> _abrirNuevoMovimiento() async {
    final created = await showModalBottomSheet<_MovimientoFormResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _MovimientoCajaForm(idEmpresa: _idEmpresa),
    );

    if (created == null) return;

    try {
      // ✅ mock por ahora, POST real después
      final out = await _cajaService.crearMovimientoMock(created.toIn());

      if (!mounted) return;

      setState(() {
        _movimientos = [out, ..._movimientos];

        final isEgreso = out.tipo.toUpperCase() == 'EGRESO';
        _totalRango += isEgreso ? -out.monto : out.monto;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Movimiento registrado')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error registrando movimiento: $e')),
      );
    }
  }

  String _fmt(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

  String _money(double v) => NumberFormat.currency(
        locale: 'es_AR',
        symbol: r'$',
        decimalDigits: 2,
      ).format(v);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirNuevoMovimiento,
        icon: const Icon(Icons.add),
        label: const Text('Movimiento'),
      ),
      body: RefreshIndicator(
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
                  height: 520,
                  child: _cargando
                      ? const Center(child: CircularProgressIndicator())
                      : _movimientos.isEmpty
                          ? const Center(
                              child: Text('No hay movimientos en este rango.'),
                            )
                          : ListView.separated(
                              itemCount: _movimientos.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final m = _movimientos[index];

                                final isEgreso =
                                    m.tipo.toUpperCase() == 'EGRESO';
                                final montoTxt = isEgreso
                                    ? '- ${_money(m.monto)}'
                                    : _money(m.monto);

                                return ListTile(
                                  leading: Icon(isEgreso
                                      ? Icons.call_made
                                      : Icons.call_received),
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
                                    montoTxt,
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

// ===================== Modal: Nuevo movimiento =====================

enum _TipoMov { ingreso, egreso }

class _MovimientoFormResult {
  final _TipoMov tipo;
  final double monto;
  final String? medioPago;
  final String? observacion;
  final DateTime fecha;
  final int? idEmpresa;

  _MovimientoFormResult({
    required this.tipo,
    required this.monto,
    required this.fecha,
    this.medioPago,
    this.observacion,
    this.idEmpresa,
  });

  CajaEmpresaMovimientoIn toIn() => CajaEmpresaMovimientoIn(
        idEmpresa: idEmpresa,
        tipo: tipo == _TipoMov.ingreso ? 'INGRESO' : 'EGRESO',
        monto: monto,
        medioPago: medioPago,
        observacion: observacion,
        fecha: fecha,
      );
}

class _MovimientoCajaForm extends StatefulWidget {
  final int? idEmpresa;
  const _MovimientoCajaForm({this.idEmpresa});

  @override
  State<_MovimientoCajaForm> createState() => _MovimientoCajaFormState();
}

class _MovimientoCajaFormState extends State<_MovimientoCajaForm> {
  final _formKey = GlobalKey<FormState>();

  _TipoMov _tipo = _TipoMov.ingreso;
  final _montoCtrl = TextEditingController();
  final _medioPagoCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();
  DateTime _fecha = DateTime.now();

  @override
  void dispose() {
    _montoCtrl.dispose();
    _medioPagoCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  double? _parseMonto() {
    final raw = _montoCtrl.text.trim().replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(raw);
  }

  Future<void> _pickFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;

    setState(() {
      _fecha = DateTime(picked.year, picked.month, picked.day, _fecha.hour,
          _fecha.minute);
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final monto = _parseMonto()!;
    final res = _MovimientoFormResult(
      tipo: _tipo,
      monto: monto,
      fecha: _fecha,
      medioPago: _medioPagoCtrl.text.trim().isEmpty
          ? null
          : _medioPagoCtrl.text.trim(),
      observacion: _obsCtrl.text.trim().isEmpty ? null : _obsCtrl.text.trim(),
      idEmpresa: widget.idEmpresa,
    );

    Navigator.pop(context, res);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding:
          EdgeInsets.only(left: 16, right: 16, top: 12, bottom: bottom + 16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Nuevo movimiento de caja',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SegmentedButton<_TipoMov>(
              segments: const [
                ButtonSegment(
                  value: _TipoMov.ingreso,
                  label: Text('Ingreso'),
                  icon: Icon(Icons.call_received),
                ),
                ButtonSegment(
                  value: _TipoMov.egreso,
                  label: Text('Egreso'),
                  icon: Icon(Icons.call_made),
                ),
              ],
              selected: {_tipo},
              onSelectionChanged: (s) => setState(() => _tipo = s.first),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _montoCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Monto',
                prefixText: r'$ ',
                border: OutlineInputBorder(),
              ),
              validator: (_) {
                final v = _parseMonto();
                if (v == null) return 'Ingresá un monto válido';
                if (v <= 0) return 'El monto debe ser mayor a 0';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _medioPagoCtrl,
              decoration: const InputDecoration(
                labelText: 'Medio de pago (opcional)',
                hintText: 'Efectivo / Transferencia / etc.',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _obsCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Observación (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickFecha,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(DateFormat('dd/MM/yyyy').format(_fecha)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.check),
                    label: const Text('Guardar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
