// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:frontend_soderia/models/cuenta.dart';
import 'package:frontend_soderia/services/medio_pago_service.dart';
import 'package:frontend_soderia/services/servicios_service.dart';

class ClienteServiciosPendientes extends StatefulWidget {
  final int legajo;
  final ServiciosService serviciosService;
  final MedioPagoService medioPagoService;
  final List<Cuenta> cuentas;
  final VoidCallback onChanged;

  const ClienteServiciosPendientes({
    super.key,
    required this.legajo,
    required this.serviciosService,
    required this.medioPagoService,
    required this.cuentas,
    required this.onChanged,
  });

  @override
  State<ClienteServiciosPendientes> createState() =>
      _ClienteServiciosPendientesState();
}

class _ClienteServiciosPendientesState
    extends State<ClienteServiciosPendientes> {
  late Future<List<ClienteServicioPeriodoDto>> _pendientesFuture;
  late Future<List<MedioPagoDto>> _mediosPagoFuture;

  @override
  void initState() {
    super.initState();
    _pendientesFuture = widget.serviciosService.getPendientes(widget.legajo);
    _mediosPagoFuture = widget.medioPagoService.listar();
  }

  void _refreshPendientes() {
    setState(() {
      _pendientesFuture = widget.serviciosService.getPendientes(widget.legajo);
    });
  }

  Widget _bannerServicios(List<ClienteServicioPeriodoDto> periodos) {
    if (periodos.isEmpty) return const SizedBox.shrink();

    final total = periodos.fold<double>(0, (a, p) => a + p.monto);
    final vencidos = periodos.where((p) => p.estado == 'VENCIDO').length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: vencidos > 0 ? const Color(0xFFFFE5E5) : const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: vencidos > 0
              ? const Color(0xFFEE7777)
              : const Color(0xFFE6C200),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.water_drop_outlined,
            color: vencidos > 0 ? const Color(0xFFCC0000) : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alquiler dispenser: ${periodos.length} pendiente(s)',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total a cobrar: \$${total.toStringAsFixed(2)}'
                  '${vencidos > 0 ? ' • $vencidos vencido(s)' : ''}',
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _openServiciosSheet(periodos),
            child: const Text('Ver / Cobrar'),
          ),
        ],
      ),
    );
  }

  void _openServiciosSheet(List<ClienteServicioPeriodoDto> periodos) {
    final items = [...periodos];

    items.sort((a, b) {
      final av = a.estado == 'VENCIDO' ? 0 : 1;
      final bv = b.estado == 'VENCIDO' ? 0 : 1;
      if (av != bv) return av.compareTo(bv);
      return b.periodo.compareTo(a.periodo);
    });

    final total = items.fold<double>(0, (a, p) => a + p.monto);
    final vencidos = items.where((p) => p.estado == 'VENCIDO').length;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        final cs = Theme.of(sheetCtx).colorScheme;

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          minChildSize: 0.35,
          maxChildSize: 0.92,
          builder: (ctx, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      Icon(Icons.water_drop_outlined, color: cs.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Servicios pendientes',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${items.length} período(s) • $vencidos vencido(s)',
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Cerrar',
                        onPressed: () => Navigator.pop(sheetCtx),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final p = items[i];
                      final y = p.periodo.year;
                      final m = p.periodo.month.toString().padLeft(2, '0');
                      final vence = p.fechaVencimiento
                          .toIso8601String()
                          .split('T')
                          .first;

                      final isVencido = p.estado == 'VENCIDO';

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isVencido
                                ? const Color(0xFFEE7777)
                                : cs.outlineVariant,
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                              color: Colors.black.withOpacity(0.06),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isVencido ? Icons.error_outline : Icons.schedule,
                              color: isVencido ? const Color(0xFFCC0000) : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Período $y-$m',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Vence: $vence',
                                    style: TextStyle(
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: _EstadoChip(estado: p.estado),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${p.monto.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 34,
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        _cobrarPeriodo(p, sheetCtx),
                                    child: const Text('Cobrar'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const Divider(height: 1),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total a cobrar',
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '\$${total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pop(sheetCtx),
                        icon: const Icon(Icons.close),
                        label: const Text('Cerrar'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _cobrarPeriodo(
    ClienteServicioPeriodoDto p,
    BuildContext sheetCtx,
  ) async {
    int? medioPagoId;
    String obs = '';
    bool loading = false;

    int? cuentaSeleccionada = widget.cuentas.length == 1
        ? widget.cuentas.first.idCuenta
        : null;

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (dialogCtx, setStateDialog) {
            final cs = Theme.of(dialogCtx).colorScheme;
            final sinCuentas = widget.cuentas.isEmpty;
            final requiereSeleccionCuenta = widget.cuentas.length > 1;

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              title: Row(
                children: [
                  Icon(Icons.payments_outlined, color: cs.primary),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Cobrar alquiler dispenser',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.surfaceVariant.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: cs.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Importe a cobrar',
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${p.monto.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    FutureBuilder<List<MedioPagoDto>>(
                      future: _mediosPagoFuture,
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const LinearProgressIndicator();
                        }
                        if (snap.hasError) {
                          return const Text('Error cargando medios de pago');
                        }

                        final medios = snap.data ?? const [];
                        if (medios.isEmpty) {
                          return const Text('No hay medios de pago cargados');
                        }

                        return DropdownButtonFormField<int>(
                          decoration: const InputDecoration(
                            labelText: 'Medio de pago',
                            border: OutlineInputBorder(),
                          ),
                          value: medioPagoId,
                          items: medios
                              .map(
                                (m) => DropdownMenuItem<int>(
                                  value: m.id,
                                  child: Text(m.nombre),
                                ),
                              )
                              .toList(),
                          onChanged: loading
                              ? null
                              : (v) => setStateDialog(() => medioPagoId = v),
                        );
                      },
                    ),

                    if (requiereSeleccionCuenta) ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: 'Cuenta',
                          border: OutlineInputBorder(),
                        ),
                        value: cuentaSeleccionada,
                        items: widget.cuentas
                            .map(
                              (c) => DropdownMenuItem<int>(
                                value: c.idCuenta,
                                child: Text(c.nombre),
                              ),
                            )
                            .toList(),
                        onChanged: loading
                            ? null
                            : (v) =>
                                  setStateDialog(() => cuentaSeleccionada = v),
                      ),
                    ],

                    if (!sinCuentas && widget.cuentas.length == 1) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Cuenta: ${widget.cuentas.first.nombre}',
                          style: TextStyle(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],

                    if (sinCuentas)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                          'El cliente no tiene cuentas disponibles para imputar el cobro.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),

                    const SizedBox(height: 12),

                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Observación (opcional)',
                        border: OutlineInputBorder(),
                      ),
                      minLines: 1,
                      maxLines: 3,
                      onChanged: (v) => obs = v,
                      enabled: !loading,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: loading
                      ? null
                      : () => Navigator.pop(dialogCtx, false),
                  child: const Text('Cancelar'),
                ),
                FilledButton.icon(
                  onPressed: loading || sinCuentas
                      ? null
                      : () async {
                          if (medioPagoId == null ||
                              cuentaSeleccionada == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Seleccioná medio de pago y cuenta.',
                                ),
                              ),
                            );
                            return;
                          }

                          setStateDialog(() => loading = true);

                          try {
                            await widget.serviciosService.pagarPeriodo(
                              idPeriodo: p.idPeriodo,
                              legajo: widget.legajo,
                              idMedioPago: medioPagoId!,
                              idCuenta: cuentaSeleccionada,
                              observacion: obs.trim().isEmpty
                                  ? null
                                  : obs.trim(),
                            );

                            if (!mounted) return;

                            _refreshPendientes();
                            widget.onChanged();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Servicio cobrado ✅'),
                              ),
                            );

                            Navigator.pop(dialogCtx, true);
                            Navigator.pop(sheetCtx);
                          } catch (e) {
                            setStateDialog(() => loading = false);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error cobrando servicio: $e'),
                              ),
                            );
                          }
                        },
                  icon: loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: const Text('Confirmar cobro'),
                ),
              ],
            );
          },
        );
      },
    );

    if (ok != true) return;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ClienteServicioPeriodoDto>>(
      future: _pendientesFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        if (snap.hasError) {
          return const SizedBox.shrink();
        }
        return _bannerServicios(snap.data ?? const []);
      },
    );
  }
}

class _EstadoChip extends StatelessWidget {
  final String estado;
  const _EstadoChip({required this.estado});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Color bg;
    Color fg;

    switch (estado) {
      case 'VENCIDO':
        bg = const Color(0xFFFFE5E5);
        fg = const Color(0xFFB00020);
        break;
      case 'PENDIENTE':
        bg = const Color(0xFFFFF3CD);
        fg = const Color(0xFF7A5A00);
        break;
      case 'PAGADO':
        bg = const Color(0xFFE7F7EE);
        fg = const Color(0xFF1B7F3A);
        break;
      default:
        bg = cs.surfaceVariant;
        fg = cs.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withOpacity(0.25)),
      ),
      child: Text(
        estado,
        style: TextStyle(fontWeight: FontWeight.w700, color: fg, fontSize: 12),
      ),
    );
  }
}
