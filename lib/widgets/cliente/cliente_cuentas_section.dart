// lib/widgets/cliente/cliente_cuentas_section.dart

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:frontend_soderia/models/cuenta.dart';
import 'package:frontend_soderia/core/navigation/app_shell_actions.dart';
import 'package:frontend_soderia/utils/estado_cuenta_pdf.dart';
import 'package:frontend_soderia/services/cliente_service.dart';

class ClienteCuentasSection extends StatelessWidget {
  final int legajo;
  final String nombreCliente;
  final List<Cuenta> cuentas;
  final List<dynamic> pedidos;
  final VoidCallback onChanged;

  final _clienteService = ClienteService();

  ClienteCuentasSection({
    super.key,
    required this.legajo,
    required this.nombreCliente,
    required this.cuentas,
    required this.pedidos,
    required this.onChanged,
  });

  Future<void> _aplicarInteres(BuildContext context, Cuenta cuenta) async {
    final porcentajeCtrl = TextEditingController(text: '10');
    final observacionCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Aplicar interés'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cuenta: ${cuenta.tipoDeCuenta ?? cuenta.nombre}\n'
                'Deuda actual: \$${cuenta.deuda.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: porcentajeCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Porcentaje',
                  suffixText: '%',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: observacionCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Observación opcional',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(ctx, true),
              icon: const Icon(Icons.percent),
              label: const Text('Aplicar'),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    final porcentaje = double.tryParse(
      porcentajeCtrl.text.trim().replaceAll(',', '.'),
    );

    if (porcentaje == null || porcentaje <= 0) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresá un porcentaje válido')),
      );
      return;
    }

    try {
      await _clienteService.aplicarInteresCuenta(
        legajo: legajo,
        idCuenta: cuenta.idCuenta,
        porcentaje: porcentaje,
        observacion: observacionCtrl.text.trim().isEmpty
            ? null
            : observacionCtrl.text.trim(),
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Interés aplicado correctamente')),
      );

      onChanged();
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Cuentas',
      trailing: IconButton(
        icon: const Icon(Icons.add),
        tooltip: 'Crear nueva cuenta',
        onPressed: () async {
          final ok = await AppShellActions.push(
            context,
            '/cliente/cuenta/new',
            arguments: {'legajo': legajo},
          );

          if (ok == true && context.mounted) {
            onChanged();
          }
        },
      ),
      child: cuentas.isEmpty
          ? const Text('Sin cuentas')
          : Wrap(
              spacing: 12,
              runSpacing: 12,
              children: cuentas.map((c) {
                final tipo =
                    (c.tipoDeCuenta != null &&
                        c.tipoDeCuenta!.trim().isNotEmpty)
                    ? c.tipoDeCuenta!
                    : c.nombre;

                return _CuentaMiniCard(
                  tipo: tipo,
                  saldo: c.saldo,
                  deuda: c.deuda,
                  bidones: c.numeroBidones,
                  estado: c.estado,
                  onPdf: () async {
                    final ultimos = pedidos.map<Map<String, dynamic>>((p0) {
                      final p = Map<String, dynamic>.from(p0 as Map);
                      return {
                        'fecha': p['fecha'],
                        'id_pedido': p['id_pedido'],
                        'total': _toDouble(p['total']),
                      };
                    }).toList();

                    final pdfBytes = await generarEstadoCuentaPDF(
                      nombreCliente: nombreCliente,
                      legajo: legajo.toString(),
                      fecha: DateTime.now(),
                      deuda: c.deuda,
                      saldoAFavor: c.saldo,
                      ultimosPedidos: ultimos,
                    );

                    await Printing.layoutPdf(onLayout: (_) async => pdfBytes);
                  },
                  onAplicarInteres: () => _aplicarInteres(context, c),
                );
              }).toList(),
            ),
    );
  }
}

class _CuentaMiniCard extends StatelessWidget {
  final String tipo;
  final double saldo;
  final double deuda;
  final int? bidones;
  final String? estado;
  final VoidCallback onPdf;
  final VoidCallback onAplicarInteres;

  const _CuentaMiniCard({
    required this.tipo,
    required this.saldo,
    required this.deuda,
    required this.bidones,
    required this.estado,
    required this.onPdf,
    required this.onAplicarInteres,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: 240,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        color: cs.surface,
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tipo,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text('Deuda: ${deuda.toStringAsFixed(2)}'),
              Text('Saldo: ${saldo.toStringAsFixed(2)}'),
              Text('Bidones: ${bidones ?? 0}'),
              if (estado != null && estado!.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Estado: $estado',
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.percent),
                    tooltip: 'Aplicar interés',
                    onPressed: deuda > 0 ? onAplicarInteres : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.picture_as_pdf),
                    tooltip: 'Estado de cuenta',
                    onPressed: onPdf,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

double _toDouble(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  if (v is String) {
    return double.tryParse(v.replaceAll(',', '.')) ?? 0;
  }
  return 0;
}
