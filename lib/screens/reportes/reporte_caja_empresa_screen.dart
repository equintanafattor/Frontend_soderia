// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:frontend_soderia/models/caja_empresa_movimiento_out.dart';
import 'package:frontend_soderia/models/caja_empresa_total_out.dart';
import 'package:frontend_soderia/models/pago_egreso_create.dart';
import 'package:frontend_soderia/models/pago_ingreso_create.dart';
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
  List<CajaEmpresaMovimientoOut> _movimientos = [];
  int _totalMovimientos = 0;

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

      final movimientosFuture = _cajaService.getMovimientosPorRango(
        desde: _desde,
        hasta: _hasta,
        idEmpresa: _idEmpresa,
        limit: 200,
        offset: 0,
      );

      final results = await Future.wait([totalFuture, movimientosFuture]);

      final totalOut = results[0] as CajaEmpresaTotalOut;
      final movimientosOut =
          results[1] as (List<CajaEmpresaMovimientoOut>, int);

      if (!mounted) return;

      setState(() {
        _totalRango = totalOut.total;
        _movimientos = movimientosOut.$1;
        _totalMovimientos = movimientosOut.$2;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _cargando = false;
      });
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
      _desde = DateTime(desde.year, desde.month, desde.day, 0, 0, 0);
      _hasta = DateTime(hasta.year, hasta.month, hasta.day, 23, 59, 59);
    });

    await _load();
  }

  Future<void> _abrirNuevoMovimiento() async {
    final result = await showModalBottomSheet<_MovimientoFormResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _MovimientoCajaForm(),
    );

    if (result == null) return;

    try {
      if (result.tipo == _TipoMov.ingreso) {
        await _cajaService.crearIngreso(
          PagoIngresoCreate(
            idMedioPago: result.idMedioPago,
            monto: result.monto,
            observacion: result.observacion,
            fecha: result.fecha,
          ),
        );
      } else {
        await _cajaService.crearEgreso(
          PagoEgresoCreate(
            idMedioPago: result.idMedioPago,
            monto: result.monto,
            motivo: result.motivo!,
            observacion: result.observacion,
            fecha: result.fecha,
          ),
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Movimiento registrado correctamente')),
      );

      await _load();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar movimiento: $e')),
      );
    }
  }

  String _fmtFecha(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

  String _fmtFechaHora(DateTime d) => DateFormat('dd/MM/yyyy HH:mm').format(d);

  String _fmtMoney(num value) {
    return NumberFormat.currency(
      locale: 'es_AR',
      symbol: '\$',
      decimalDigits: 2,
    ).format(value);
  }

  bool _esEgreso(CajaEmpresaMovimientoOut m) {
    final tipo = (m.tipo).toUpperCase();
    final tipoMov = (m.tipoMovimiento ?? '').toUpperCase();
    return tipo.contains('EGRESO') || tipoMov.contains('EGRESO');
  }

  IconData _iconoMovimiento(CajaEmpresaMovimientoOut m) {
    return _esEgreso(m) ? Icons.arrow_upward : Icons.arrow_downward;
  }

  Color _colorMovimiento(CajaEmpresaMovimientoOut m, BuildContext context) {
    return _esEgreso(m) ? Colors.red : Colors.green;
  }

  String _tituloMovimiento(CajaEmpresaMovimientoOut m) {
    if ((m.tipoMovimiento ?? '').trim().isNotEmpty) {
      return m.tipoMovimiento!;
    }
    return m.tipo;
  }

  String _montoMovimiento(CajaEmpresaMovimientoOut m) {
    final monto = _fmtMoney(m.monto);
    return _esEgreso(m) ? '- $monto' : monto;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Caja empresa')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirNuevoMovimiento,
        icon: const Icon(Icons.add),
        label: const Text('Movimiento'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.date_range),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${_fmtFecha(_desde)} - ${_fmtFecha(_hasta)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: _pickRango,
                      child: const Text('Cambiar'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _cargando
                    ? const SizedBox(
                        height: 72,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total en el rango',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _fmtMoney(_totalRango),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Movimientos: $_totalMovimientos',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 12),
            if (_error != null) ...[
              _ErrorBox(text: _error!),
              const SizedBox(height: 12),
            ],
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _cargando
                    ? const SizedBox(
                        height: 260,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : _movimientos.isEmpty
                    ? const SizedBox(
                        height: 180,
                        child: Center(
                          child: Text('No hay movimientos en este rango'),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _movimientos.length,
                        separatorBuilder: (_, __) => const Divider(height: 16),
                        itemBuilder: (context, index) {
                          final m = _movimientos[index];
                          final color = _colorMovimiento(m, context);

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(_iconoMovimiento(m), color: color),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _tituloMovimiento(m),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _fmtFechaHora(m.fecha),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    if ((m.medioPago ?? '').trim().isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          'Medio de pago: ${m.medioPago}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                    if ((m.observacion ?? '').trim().isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(
                                          m.observacion!,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _montoMovimiento(m),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: color,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ),
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
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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

enum _TipoMov { ingreso, egreso }

class _MovimientoFormResult {
  final _TipoMov tipo;
  final double monto;
  final int idMedioPago;
  final String? motivo;
  final String? observacion;
  final DateTime fecha;

  _MovimientoFormResult({
    required this.tipo,
    required this.monto,
    required this.idMedioPago,
    required this.fecha,
    this.motivo,
    this.observacion,
  });
}

class _MovimientoCajaForm extends StatefulWidget {
  const _MovimientoCajaForm();

  @override
  State<_MovimientoCajaForm> createState() => _MovimientoCajaFormState();
}

class _MovimientoCajaFormState extends State<_MovimientoCajaForm> {
  final _formKey = GlobalKey<FormState>();

  _TipoMov _tipo = _TipoMov.ingreso;

  final _montoCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  DateTime _fecha = DateTime.now();
  int? _idMedioPago;
  String? _motivo;

  final List<(int, String)> _mediosPago = const [
    (1, 'Efectivo'),
    (2, 'Virtual'),
  ];

  final List<(String, String)> _motivosEgreso = const [
    ('INSUMOS', 'Insumos'),
    ('SUELDOS', 'Sueldos'),
    ('OTRO', 'Otro'),
  ];

  @override
  void dispose() {
    _montoCtrl.dispose();
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
      _fecha = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _fecha.hour,
        _fecha.minute,
      );
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final monto = _parseMonto()!;
    final observacion = _obsCtrl.text.trim().isEmpty
        ? null
        : _obsCtrl.text.trim();

    Navigator.of(context).pop(
      _MovimientoFormResult(
        tipo: _tipo,
        monto: monto,
        idMedioPago: _idMedioPago!,
        fecha: _fecha,
        motivo: _tipo == _TipoMov.egreso ? _motivo : null,
        observacion: observacion,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final insetsBottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, insetsBottom + 16),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Nuevo movimiento de caja',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              SegmentedButton<_TipoMov>(
                segments: const [
                  ButtonSegment<_TipoMov>(
                    value: _TipoMov.ingreso,
                    label: Text('Ingreso'),
                    icon: Icon(Icons.arrow_downward),
                  ),
                  ButtonSegment<_TipoMov>(
                    value: _TipoMov.egreso,
                    label: Text('Egreso'),
                    icon: Icon(Icons.arrow_upward),
                  ),
                ],
                selected: {_tipo},
                onSelectionChanged: (value) {
                  setState(() {
                    _tipo = value.first;
                    if (_tipo == _TipoMov.ingreso) {
                      _motivo = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _montoCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                validator: (_) {
                  final monto = _parseMonto();
                  if (monto == null) return 'Ingresá un monto válido';
                  if (monto <= 0) return 'El monto debe ser mayor a 0';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _idMedioPago,
                decoration: const InputDecoration(
                  labelText: 'Medio de pago',
                  border: OutlineInputBorder(),
                ),
                items: _mediosPago
                    .map(
                      (e) =>
                          DropdownMenuItem<int>(value: e.$1, child: Text(e.$2)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _idMedioPago = value;
                  });
                },
                validator: (value) {
                  if (value == null) return 'Seleccioná un medio de pago';
                  return null;
                },
              ),
              if (_tipo == _TipoMov.egreso) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _motivo,
                  decoration: const InputDecoration(
                    labelText: 'Motivo',
                    border: OutlineInputBorder(),
                  ),
                  items: _motivosEgreso
                      .map(
                        (e) => DropdownMenuItem<String>(
                          value: e.$1,
                          child: Text(e.$2),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _motivo = value;
                    });
                  },
                  validator: (value) {
                    if (_tipo == _TipoMov.egreso && value == null) {
                      return 'Seleccioná un motivo';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _obsCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Observación',
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
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
