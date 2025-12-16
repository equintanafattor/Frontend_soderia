import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/colors.dart';
import 'package:printing/printing.dart';

import '../utils/pdf_generator.dart';
import 'package:frontend_soderia/services/pedido_service.dart';
import 'package:frontend_soderia/services/reparto_dia_service.dart'; // 👈 NUEVO

class LineaVenta {
  final String nroPedido;
  final String producto;
  final int cantidad;
  final double precioUnitario;

  const LineaVenta({
    required this.nroPedido,
    required this.producto,
    required this.cantidad,
    required this.precioUnitario,
  });

  double get subtotal => cantidad * precioUnitario;
}

enum MedioPago { efectivo, transferencia, otro }

class PagoScreen extends StatefulWidget {
  final String nombreCliente;
  final String legajo;
  final DateTime fecha;
  final double deudaActual;
  final double saldoAFavorActual;
  final List<LineaVenta> items;
  final double total;

  const PagoScreen({
    super.key,
    required this.nombreCliente,
    required this.legajo,
    required this.fecha,
    required this.deudaActual,
    required this.saldoAFavorActual,
    required this.items,
    required this.total,
  });

  @override
  State<PagoScreen> createState() => _PagoScreenState();
}

class _PagoScreenState extends State<PagoScreen> {
  final _pedidoService = PedidoService();
  final _repartoDiaService =   RepartoDiaService(baseUrl: 'http://localhost:8500'); // 👈 HOST SOLITO

  // Chips de montos rápidos:
  // - total de la venta
  // - deuda (si existe)
  // - total + deuda (si ambos existen)
  List<num> get _montosRapidos {
    final montos = <num>[];

    final total = widget.total;
    final deuda = widget.deudaActual;

    if (total > 0) {
      montos.add(total);
    }
    if (deuda > 0) {
      montos.add(deuda);
    }
    final suma = total + deuda;
    if (total > 0 && deuda > 0 && suma > 0) {
      montos.add(suma);
    }

    return montos;
  }

  final TextEditingController _otroCtrl = TextEditingController();
  double? _montoElegido;
  MedioPago _medio = MedioPago.efectivo;
  bool _compartirComprobante = false;

  String _money(num v) => '\$${v.toStringAsFixed(0)}';

  /// Valida el monto elegido:
  /// - No puede ser null
  /// - No puede ser negativo
  /// - Puede ser 0 solo si el cliente tiene saldo a favor
  bool get _montoValido {
    final m = _montoElegido;

    if (m == null || m < 0) return false;

    if (m == 0) {
      return widget.saldoAFavorActual > 0;
    }

    return true;
  }

  int _mapMedioPagoToId(MedioPago medio) {
    switch (medio) {
      case MedioPago.efectivo:
        return 1;
      case MedioPago.transferencia:
        return 2;
      case MedioPago.otro:
        return 3;
    }
  }

  String _resolverEstadoPedido({
    required double totalVenta,
    required double deudaActual,
    required double saldoAFavor,
    required double montoAbonado,
  }) {
    const epsilon = 0.01;

    if (montoAbonado < 0) {
      return 'pendiente';
    }

    final deudaActualDec = deudaActual;
    final saldoActualDec = saldoAFavor;

    final A = montoAbonado;

    final saldoUsado = A < saldoActualDec ? A : saldoActualDec;

    final deudaTmp = deudaActualDec + totalVenta - A;

    double deudaNueva;
    double saldoGenerado;

    if (deudaTmp >= 0) {
      deudaNueva = deudaTmp;
      saldoGenerado = 0;
    } else {
      deudaNueva = 0;
      saldoGenerado = -deudaTmp;
    }

    final saldoNuevo = saldoActualDec - saldoUsado + saldoGenerado;

    final deudaCasiCero = deudaNueva.abs() < epsilon;
    final saldoCasiCero = saldoNuevo.abs() < epsilon;

    if (deudaCasiCero && saldoCasiCero) {
      return 'abonado';
    }

    if (!deudaCasiCero && montoAbonado <= 0) {
      return 'pendiente';
    }

    if (!deudaCasiCero && montoAbonado > 0) {
      return 'abonado parcialmente';
    }

    if (deudaCasiCero && saldoNuevo > epsilon) {
      return 'cliente pago de más';
    }

    return 'pendiente';
  }

  @override
  void dispose() {
    _otroCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    if (!_montoValido) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar pago'),
        content: Text(
          'Cliente: ${widget.nombreCliente}\n'
          'Medio: ${_medio.name}\n'
          'Importe: ${_money(_montoElegido!)}\n\n'
          '¿Registrar pago y crear pedido?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    try {
      final legajoInt = int.tryParse(widget.legajo);
      if (legajoInt == null) {
        throw Exception('Legajo inválido: ${widget.legajo}');
      }

      final idMedio = _mapMedioPagoToId(_medio);

      // Estado según pago + saldo a favor
      final estado = _resolverEstadoPedido(
        totalVenta: widget.total,
        deudaActual: widget.deudaActual,
        saldoAFavor: widget.saldoAFavorActual,
        montoAbonado: _montoElegido!,
      );

      // 👇 AHORA OBTENEMOS EL REPARTO REAL DESDE EL BACK
      final reparto = await _repartoDiaService.obtenerPorFecha(
        fecha: widget.fecha,
        idEmpresa: 1,
        // si más adelante manejás usuario logueado, pasás idUsuario acá
        // idUsuario: ...
      );
      final int idRepartoDia = reparto['id_repartodia'] as int;

      // Crear pedido
      final pedido = await _pedidoService.crearPedido(
        legajo: legajoInt,
        idMedioPago: idMedio,
        fecha: widget.fecha,
        montoTotal: widget.total,
        montoAbonado: _montoElegido!,
        idEmpresa: 1,
        estado: estado,
        idRepartoDia: idRepartoDia,
      );

      final idPedido = pedido['id_pedido'] as int;

      // Confirmar pedido
      await _pedidoService.confirmarPedido(
        idPedido: idPedido,
        idRepartoDia: idRepartoDia,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pedido #$idPedido creado y confirmado.\n'
            'Estado: $estado · Pago ${_money(_montoElegido!)}',
          ),
        ),
      );

      if (_compartirComprobante) {
        await _shareComprobante();
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al registrar pedido: $e')));
    }
  }

  bool get _saldoAlDia {
    if (!_montoValido) return false;

    const epsilon = 0.01;

    final netoAnterior = widget.deudaActual - widget.saldoAFavorActual;
    final netoNuevo = netoAnterior + widget.total - (_montoElegido ?? 0);

    return netoNuevo <= epsilon;
  }

  Future<void> _showShareSheet() {
    return showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text('Compartir comprobante'),
                subtitle: Text('Elegí un canal'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.chat),
                title: const Text('WhatsApp'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Email'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.print_outlined),
                title: const Text('Imprimir'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _shareComprobante() async {
    final data = await generarComprobantePDF(
      nombreCliente: widget.nombreCliente,
      legajo: widget.legajo,
      fecha: widget.fecha,
      deudaAnterior: widget.deudaActual,
      saldoAFavorAnterior: widget.saldoAFavorActual,
      totalVenta: widget.total,
      montoPagado: _montoElegido!,
      medioPago: _medio.name,
      items: widget.items.map((it) {
        return {
          'producto': it.producto,
          'cantidad': it.cantidad,
          'precioUnitario': it.precioUnitario,
        };
      }).toList(),
    );

    await Printing.sharePdf(
      bytes: data,
      filename: 'comprobante_${widget.legajo}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 720;

    final bool _otroActivo =
        _montoElegido == null || !_montosRapidos.contains(_montoElegido);

    final confirmButton = _ConfirmarButton(
      enabled: _montoValido,
      label: 'Confirmar pago',
      onPressed: _confirmar,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.azul,
        foregroundColor: Colors.white,
        title: Text('Pago — ${widget.nombreCliente}'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: isMobile ? null : confirmButton,
      bottomNavigationBar: isMobile ? confirmButton : null,
      body: Padding(
        padding: EdgeInsets.only(bottom: isMobile ? 84 : 0),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _EncabezadoCliente(
                    nombre: widget.nombreCliente,
                    legajo: widget.legajo,
                    deuda: widget.deudaActual,
                    saldoAFavor: widget.saldoAFavorActual,
                  ),
                ),
                const SizedBox(width: 12),
                _FechaPill(fecha: widget.fecha),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(thickness: 1.4),
            const SizedBox(height: 4),
            _TablaHeader(),
            const SizedBox(height: 4),
            ...widget.items.map(
              (it) => _TablaRow(
                nro: it.nroPedido,
                producto: it.producto,
                cantidad: it.cantidad,
                pu: it.precioUnitario,
                pt: it.subtotal,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(thickness: 1.4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total: ${_money(widget.total)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'El cliente abonará:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (widget.saldoAFavorActual > 0)
                  _MontoChip(
                    label: 'Usar saldo a favor',
                    selected: _montoElegido == 0,
                    onTap: () {
                      setState(() {
                        _montoElegido = 0;
                        _otroCtrl.clear();
                      });
                    },
                  ),
                for (final m in _montosRapidos)
                  _MontoChip(
                    label: _money(m),
                    selected: _montoElegido == m,
                    onTap: () {
                      setState(() {
                        _montoElegido = m.toDouble();
                        _otroCtrl.clear();
                      });
                    },
                  ),
                _MontoChip(
                  label: 'Otro',
                  selected: _otroActivo,
                  onTap: () {
                    setState(() {
                      _montoElegido = null;
                      _otroCtrl.text = '';
                    });
                  },
                  filled: _otroActivo,
                ),
                if (_otroActivo)
                  SizedBox(
                    width: 160,
                    child: TextField(
                      controller: _otroCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        isDense: true,
                        labelText: widget.saldoAFavorActual > 0
                            ? 'Importe (puede ser 0)'
                            : 'Importe',
                        prefixText: '\$ ',
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (txt) {
                        final cleaned = txt.replaceAll(RegExp(r'[^0-9.]'), '');
                        final val = double.tryParse(cleaned);
                        setState(() {
                          _montoElegido = val;
                        });
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (_saldoAlDia)
              Row(
                children: const [
                  Icon(Icons.verified, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    'Saldo al día ✅',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Text(
              'Medio de pago:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _Segmented<MedioPago>(
              value: _medio,
              items: const [
                (MedioPago.efectivo, 'Efectivo'),
                (MedioPago.transferencia, 'Transferencia'),
                (MedioPago.otro, 'Otro'),
              ],
              onChanged: (v) => setState(() => _medio = v),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Compartir comprobante'),
                Switch(
                  value: _compartirComprobante,
                  activeColor: AppColors.azul,
                  onChanged: (v) => setState(() => _compartirComprobante = v),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Auxiliares UI ----------------

class _EncabezadoCliente extends StatelessWidget {
  final String nombre;
  final String legajo;
  final double deuda;
  final double saldoAFavor;

  const _EncabezadoCliente({
    required this.nombre,
    required this.legajo,
    required this.deuda,
    required this.saldoAFavor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          nombre,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text('Legajo: ', style: TextStyle(color: cs.onSurfaceVariant)),
            Text(legajo, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Text('Deuda: ', style: TextStyle(color: cs.onSurfaceVariant)),
            Text(
              '\$ ${deuda.toStringAsFixed(0)}',
              style: TextStyle(
                color: deuda > 0 ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Text(
              'Saldo a favor: ',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            Text(
              '\$ ${saldoAFavor.toStringAsFixed(0)}',
              style: const TextStyle(
                color: Colors.teal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FechaPill extends StatelessWidget {
  final DateTime fecha;
  const _FechaPill({required this.fecha});

  @override
  Widget build(BuildContext context) {
    final f =
        '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.celeste.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.celeste),
      ),
      child: Text('Fecha: $f'),
    );
  }
}

class _TablaHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = Theme.of(
      context,
    ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          _cell('Nro.', flex: 1, style: style),
          _cell('Producto', flex: 3, style: style),
          _cell('Cant.', flex: 1, style: style, align: TextAlign.center),
          _cell('P. unitario', flex: 2, style: style, align: TextAlign.right),
          _cell('P. total', flex: 2, style: style, align: TextAlign.right),
        ],
      ),
    );
  }
}

class _TablaRow extends StatelessWidget {
  final String nro;
  final String producto;
  final int cantidad;
  final double pu;
  final double pt;

  const _TablaRow({
    required this.nro,
    required this.producto,
    required this.cantidad,
    required this.pu,
    required this.pt,
  });

  String _m(num v) => '\$${v.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: Row(
        children: [
          _cell(nro, flex: 1),
          _cell(producto, flex: 3),
          _cell('$cantidad', flex: 1, align: TextAlign.center),
          _cell(_m(pu), flex: 2, align: TextAlign.right),
          _cell(_m(pt), flex: 2, align: TextAlign.right),
        ],
      ),
    );
  }
}

Widget _cell(String text, {int flex = 1, TextStyle? style, TextAlign? align}) {
  return Expanded(
    flex: flex,
    child: Text(text, textAlign: align, style: style),
  );
}

class _MontoChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool filled;

  const _MontoChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final sel = selected;
    final bg = sel || filled ? Colors.black : Colors.transparent;
    final fg = sel || filled ? Colors.white : Colors.black87;
    final border = BorderSide(color: Colors.black87, width: 1.6);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: border.color, width: border.width),
        ),
        child: Text(
          label,
          style: TextStyle(color: fg, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _Segmented<T> extends StatelessWidget {
  final T value;
  final List<(T, String)> items;
  final ValueChanged<T> onChanged;

  const _Segmented({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((e) {
        final selected = e.$1 == value;
        return ChoiceChip(
          label: Text(e.$2),
          selected: selected,
          onSelected: (_) => onChanged(e.$1),
          selectedColor: AppColors.azul,
          labelStyle: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w700,
          ),
          backgroundColor: Colors.transparent,
          side: const BorderSide(color: Colors.black87, width: 1.2),
        );
      }).toList(),
    );
  }
}

class _ConfirmarButton extends StatelessWidget {
  final bool enabled;
  final String label;
  final VoidCallback onPressed;

  const _ConfirmarButton({
    required this.enabled,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 720;

    final child = ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled ? Colors.green : Colors.grey.shade400,
        foregroundColor: Colors.white,
        minimumSize: Size(isMobile ? double.infinity : 240, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );

    if (isMobile) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: child,
        ),
      );
    }
    return FloatingActionButton.extended(
      onPressed: enabled ? onPressed : null,
      icon: const Icon(Icons.check),
      label: Text(label),
      backgroundColor: enabled ? Colors.green : Colors.grey.shade400,
      foregroundColor: Colors.white,
    );
  }
}
