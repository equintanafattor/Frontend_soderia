// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:frontend_soderia/services/pago_service.dart';
import 'package:frontend_soderia/services/medio_pago_service.dart';
import 'package:frontend_soderia/utils/open_pdf.dart';

class PagoLibreScreen extends StatefulWidget {
  final int legajo;
  final int idEmpresa;
  final int? idRepartoDia;
  final double deuda;
  final double saldo;

  const PagoLibreScreen({
    super.key,
    required this.legajo,
    required this.idEmpresa,
    required this.deuda,
    required this.saldo,
    this.idRepartoDia,
  });

  @override
  State<PagoLibreScreen> createState() => _PagoLibreScreenState();
}

class _PagoLibreScreenState extends State<PagoLibreScreen> {
  static const String baseUrl = 'http://localhost:8500';

  final _formKey = GlobalKey<FormState>();
  final _pagoService = PagoService();
  final _medioPagoService = MedioPagoService();

  final _montoCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  bool _loading = false;
  int? _idMedioPago;
  List<Map<String, dynamic>> _mediosPago = [];

  @override
  void initState() {
    super.initState();
    _loadMediosPago();
  }

  Future<void> _loadMediosPago() async {
    final data = await _medioPagoService.listar();
    if (!mounted) return;

    setState(() {
      _mediosPago = data;
      if (data.isNotEmpty) {
        _idMedioPago = data.first['id_medio_pago'];
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      // 🔹 1. Crear pago
      final result = await _pagoService.crearPagoLibre(
        legajo: widget.legajo,
        idEmpresa: widget.idEmpresa,
        idMedioPago: _idMedioPago!,
        monto: double.parse(_montoCtrl.text.replaceAll(',', '.')),
        observacion: _obsCtrl.text.trim().isEmpty ? null : _obsCtrl.text.trim(),
        idRepartoDia: widget.idRepartoDia,
      );

      final comprobanteUrl =
          'http://localhost:8500${result['comprobante_url']}';

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Pago registrado'),
          content: const Text('¿Deseás abrir el comprobante?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Después'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);
                await openPdf(comprobanteUrl);
              },
              child: const Text('Ver comprobante'),
            ),
          ],
        ),
      );

      Navigator.of(context).pop(true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pago registrado correctamente')),
      );
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
                            '\$ ${widget.deuda.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: widget.deuda > 0
                                  ? Colors.red
                                  : Colors.green,
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
                            '\$ ${widget.saldo.toStringAsFixed(2)}',
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

              // ===== MEDIO DE PAGO =====
              if (_mediosPago.isEmpty)
                const LinearProgressIndicator()
              else
                DropdownButtonFormField<int>(
                  value: _idMedioPago,
                  items: _mediosPago
                      .map(
                        (m) => DropdownMenuItem<int>(
                          value: m['id_medio_pago'],
                          child: Text(m['nombre']),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _idMedioPago = v),
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
