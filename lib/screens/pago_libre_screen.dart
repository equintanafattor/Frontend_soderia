// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/net/api_client.dart';
import 'package:frontend_soderia/services/pago_service.dart';
import 'package:frontend_soderia/services/medio_pago_service.dart';
import 'package:frontend_soderia/utils/open_pdf.dart';

class PagoLibreScreen extends StatefulWidget {
  final int legajo;
  final int idEmpresa;
  final int? idRepartoDia;
  final double deuda;
  final double saldo;
  final int? idCuenta; // ✅
  final List<dynamic> cuentas;

  const PagoLibreScreen({
    super.key,
    required this.legajo,
    required this.idEmpresa,
    required this.deuda,
    required this.saldo,
    this.idCuenta, // ✅
    this.cuentas = const [],
    this.idRepartoDia,
  });

  @override
  State<PagoLibreScreen> createState() => _PagoLibreScreenState();
}

class _PagoLibreScreenState extends State<PagoLibreScreen> {
  final base = ApiClient.dio.options.baseUrl;

  final _formKey = GlobalKey<FormState>();
  final _pagoService = PagoService();
  final _medioPagoService = MedioPagoService();

  final _montoCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  bool _loading = false;
  int? _idMedioPago;
  int? _idCuentaSeleccionada;
  List<MedioPagoDto> _mediosPago = [];

  List<Map<String, dynamic>> _cuentas = [];
  double _deudaSel = 0;
  double _saldoSel = 0;

  double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.replaceAll(',', '.')) ?? 0.0;
    return 0.0;
  }

  void _syncCuentaSeleccionada(int? idCuenta) {
    if (idCuenta == null) {
      _deudaSel = widget.deuda;
      _saldoSel = widget.saldo;
      return;
    }

    final c = _cuentas.firstWhere(
      (x) => (x['id_cuenta'] as num?)?.toInt() == idCuenta,
      orElse: () => _cuentas.isNotEmpty ? _cuentas.first : {},
    );

    _deudaSel = _toDouble(c['deuda']);
    _saldoSel = _toDouble(c['saldo']);
  }

  @override
  void initState() {
    super.initState();
    _loadMediosPago();

    // Parseo cuentas una vez
    _cuentas = widget.cuentas
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    _idCuentaSeleccionada = widget.idCuenta;

    // si no vino, auto-selección
    if (_idCuentaSeleccionada == null && _cuentas.isNotEmpty) {
      _idCuentaSeleccionada = (_cuentas.first['id_cuenta'] as num?)?.toInt();
    }

    // Inicializa resumen con la cuenta seleccionada
    if (_cuentas.isNotEmpty) {
      final c = _cuentas.firstWhere(
        (x) => (x['id_cuenta'] as num?)?.toInt() == _idCuentaSeleccionada,
        orElse: () => _cuentas.first,
      );
      _deudaSel = _toDouble(c['deuda']);
      _saldoSel = _toDouble(c['saldo']);
    } else {
      _deudaSel = widget.deuda;
      _saldoSel = widget.saldo;
    }
  }

  Future<void> _loadMediosPago() async {
    final data = await _medioPagoService.listar();
    if (!mounted) return;

    setState(() {
      _mediosPago = data;

      // Seteá un valor inicial si no hay uno
      if (_idMedioPago == null && data.isNotEmpty) {
        _idMedioPago = data.first.id; // 👈 OJO: ahora es .id
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_idMedioPago == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccioná un medio de pago')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final result = await _pagoService.crearPagoLibre(
        legajo: widget.legajo,
        idEmpresa: widget.idEmpresa,
        idMedioPago: _idMedioPago!,
        idCuenta: _idCuentaSeleccionada, // ✅
        monto: double.parse(_montoCtrl.text.replaceAll(',', '.')),
        observacion: _obsCtrl.text.trim().isEmpty ? null : _obsCtrl.text.trim(),
        idRepartoDia: widget.idRepartoDia,
      );

      final comprobanteUrl = '$base${result['comprobante_url']}';

      if (!mounted) return;

      final abrir = await showDialog<bool>(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          title: const Text('Pago registrado'),
          content: const Text('¿Deseás abrir el comprobante?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              child: const Text('Después'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogCtx).pop(true),
              child: const Text('Ver comprobante'),
            ),
          ],
        ),
      );

      if (abrir == true) {
        await openPdf(comprobanteUrl);
      }

      if (!mounted) return;
      Navigator.of(context).pop(true); // 👈 ahora sí: cerramos la screen
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error registrando pago: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _montoCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar pago')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ===== RESUMEN =====
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Deuda actual',
                            style: TextStyle(fontSize: 12),
                          ),
                          Text(
                            '\$ ${_deudaSel.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _deudaSel > 0 ? Colors.red : Colors.green,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Saldo a favor',
                            style: TextStyle(fontSize: 12),
                          ),
                          Text(
                            '\$ ${_saldoSel.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ===== MONTO =====
              TextFormField(
                controller: _montoCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Ingresá un monto';
                  }
                  final n = double.tryParse(v.replaceAll(',', '.'));
                  if (n == null || n <= 0) {
                    return 'Monto inválido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              if (widget.cuentas.length > 1)
                DropdownButtonFormField<int>(
                  value: _idCuentaSeleccionada,
                  items: _cuentas
                      .map((c) {
                        final id = (c['id_cuenta'] as num?)?.toInt();
                        final tipo = (c['tipo_de_cuenta'] ?? 'Cuenta')
                            .toString();
                        return DropdownMenuItem<int>(
                          value: id,
                          child: Text('$tipo (id $id)'),
                        );
                      })
                      .where((e) => e.value != null)
                      .toList(),

                  onChanged: (v) {
                    setState(() {
                      _idCuentaSeleccionada = v;
                      _syncCuentaSeleccionada(v);
                    });
                  },

                  decoration: const InputDecoration(
                    labelText: 'Cuenta',
                    prefixIcon: Icon(Icons.account_balance_wallet),
                  ),
                ),

              // ===== MEDIO DE PAGO =====
              if (_mediosPago.isEmpty)
                const LinearProgressIndicator()
              else
                DropdownButtonFormField<int>(
                  value: _idMedioPago,
                  items: _mediosPago
                      .map(
                        (m) => DropdownMenuItem<int>(
                          value: m.id,
                          child: Text(m.nombre),
                        ),
                      )
                      .toList(),
                  onChanged: _loading
                      ? null
                      : (v) => setState(() => _idMedioPago = v),
                  decoration: const InputDecoration(
                    labelText: 'Medio de pago',
                    prefixIcon: Icon(Icons.payment),
                  ),
                ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _obsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Observación (opcional)',
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 2,
              ),

              const Spacer(),

              FilledButton.icon(
                onPressed: _loading ? null : _submit,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: const Text('Confirmar pago'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
