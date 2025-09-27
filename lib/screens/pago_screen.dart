import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/colors.dart';

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
  final double deudaActual;          // para mostrar en rojo si > 0
  final List<LineaVenta> items;      // ítems de la venta (para el recibo)
  final double total;                // total de la venta

  const PagoScreen({
    super.key,
    required this.nombreCliente,
    required this.legajo,
    required this.fecha,
    required this.deudaActual,
    required this.items,
    required this.total,
  });

  @override
  State<PagoScreen> createState() => _PagoScreenState();
}

class _PagoScreenState extends State<PagoScreen> {
  // Chips de montos rápidos (pueden variar según tu lógica)
  late final List<num> _montosRapidos = [
    widget.total * 2, // ejemplo: total + deuda posible
    widget.total + widget.deudaActual,
    widget.total,
  ].map((v) => v.clamp(0, double.infinity)).toList();

  final TextEditingController _otroCtrl = TextEditingController();
  double? _montoElegido;
  MedioPago _medio = MedioPago.efectivo;
  bool _compartirComprobante = false;

  String _money(num v) {
    // si tenés intl, reemplazá por NumberFormat.currency(locale: 'es_AR', symbol: '\$').format(v)
    return '\$${v.toStringAsFixed(0)}';
  }

  bool get _montoValido {
    final m = _montoElegido;
    return m != null && m > 0;
  }

  @override
  void dispose() {
    _otroCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    // Validaciones mínimas
    if (!_montoValido) return;

    // Confirmación
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar pago'),
        content: Text(
          'Cliente: ${widget.nombreCliente}\n'
          'Medio: ${_medio.name}\n'
          'Importe: ${_money(_montoElegido!)}\n\n'
          '¿Registrar pago?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirmar')),
        ],
      ),
    );

    if (ok == true && mounted) {
      // TODO: llamar API para registrar pago, emitir recibo, etc.
      // Si _compartirComprobante == true → disparar share / WhatsApp / email.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pago registrado por ${_money(_montoElegido!)}')),
      );
      Navigator.pop(context, true); // volvés a la venta
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 720;

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
            // Encabezado
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _EncabezadoCliente(
                    nombre: widget.nombreCliente,
                    legajo: widget.legajo,
                    deuda: widget.deudaActual,
                  ),
                ),
                const SizedBox(width: 12),
                _FechaPill(fecha: widget.fecha),
              ],
            ),
            const SizedBox(height: 12),

            const Divider(thickness: 1.4),
            const SizedBox(height: 4),

            // Cabecera tabla
            _TablaHeader(),
            const SizedBox(height: 4),

            // Filas
            ...widget.items.map((it) => _TablaRow(
                  nro: it.nroPedido,
                  producto: it.producto,
                  cantidad: it.cantidad,
                  pu: it.precioUnitario,
                  pt: it.subtotal,
                )),
            const SizedBox(height: 8),
            const Divider(thickness: 1.4),

            // Total
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

            // Monto a abonar
            Text('El cliente abonará:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final m in _montosRapidos)
                  _MontoChip(
                    label: _money(m),
                    selected: _montoElegido == m,
                    onTap: () {
                      setState(() {
                        _montoElegido = m as double?;
                        _otroCtrl.clear();
                      });
                    },
                  ),
                _MontoChip(
                  label: 'Otro',
                  selected: _montoElegido != null &&
                      !_montosRapidos.contains(_montoElegido),
                  onTap: () {
                    setState(() {
                      _montoElegido = null;
                    });
                  },
                  filled: true,
                ),
                SizedBox(
                  width: 160,
                  child: TextField(
                    controller: _otroCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      isDense: true,
                      labelText: 'Importe',
                      prefixText: '\$ ',
                      border: OutlineInputBorder(),
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

            const SizedBox(height: 16),

            // Medio de pago
            Text('Medio de pago:', style: Theme.of(context).textTheme.titleMedium),
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

            // Compartir comprobante
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Compartir comprobante'),
                Switch(
                  value: _compartirComprobante,
                  // ignore: deprecated_member_use
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
  const _EncabezadoCliente({
    required this.nombre,
    required this.legajo,
    required this.deuda,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(nombre,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                )),
        const SizedBox(height: 4),
        Row(
          children: [
            Text('Legajo: ',
                style: TextStyle(color: cs.onSurfaceVariant)),
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
      ],
    );
  }
}

class _FechaPill extends StatelessWidget {
  final DateTime fecha;
  const _FechaPill({required this.fecha});

  @override
  Widget build(BuildContext context) {
    final f = '${fecha.day.toString().padLeft(2, '0')}/'
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
    final style = Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700);
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
        border: Border(
          top: BorderSide(color: cs.outlineVariant),
        ),
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
        child: Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w700)),
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
          labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87, fontWeight: FontWeight.w700),
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
