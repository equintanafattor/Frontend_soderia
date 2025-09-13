import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/colors.dart';

class VentaScreen extends StatefulWidget {
  final String nombreCliente;
  final String direccion;
  final String legajo;
  final double deuda;

  const VentaScreen({
    super.key,
    required this.nombreCliente,
    required this.direccion,
    required this.legajo,
    required this.deuda,
  });

  @override
  State<VentaScreen> createState() => _VentaScreenState();
}

class _VentaScreenState extends State<VentaScreen> {
  // Catálogo de ejemplo (nombre → precio)
  final Map<String, double> _catalogo = const {
    'Agua Bidón 12L': 2500,
    'Agua Bidón 20L': 3200,
    'Soda 2L': 1200,
    'Dispenser frío/calor': 150000,
    'Alquiler dispenser (mensual)': 8000,
  };

  // Carrito actual (nombre → cantidad)
  final Map<String, int> _carrito = {
    'Agua Bidón 12L': 2,
    'Dispenser frío/calor': 1,
  };

  // Historial MOCK
  final List<String> _historial = const [
    '12/08 · 2 × Agua Bidón 12L',
    '04/07 · 1 × Soda 2L',
    '21/06 · 1 × Agua Bidón 20L',
  ];

  // -------- Helpers --------
  double get _total {
    double t = 0;
    _carrito.forEach((nombre, cant) {
      final precio = _catalogo[nombre] ?? 0;
      t += precio * cant;
    });
    return t;
  }

  bool get _ventaValida => _carrito.isNotEmpty;

  void _agregarProducto(String nombre) {
    setState(() {
      _carrito.update(nombre, (v) => v + 1, ifAbsent: () => 1);
    });
  }

  void _eliminarProducto(String nombre) {
    setState(() {
      _carrito.remove(nombre);
    });
  }

  Future<void> _editarCantidad(String nombre) async {
    final cantActual = _carrito[nombre] ?? 1;
    final nueva = await showDialog<int>(
      context: context,
      builder: (_) => _CantidadDialog(cantidadInicial: cantActual),
    );
    if (nueva == null) return;
    setState(() {
      if (nueva <= 0) {
        _carrito.remove(nombre);
      } else {
        _carrito[nombre] = nueva;
      }
    });
  }

  Future<void> _confirmarVenta() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar venta'),
        content: Text('¿Confirmar venta por \$${_total.toStringAsFixed(0)}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirmar')),
        ],
      ),
    );

    if (ok == true) {
      // TODO: Llamar a API para registrar venta, mostrar éxito y volver
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Venta confirmada')),
        );
        Navigator.pop(context); // volver a la lista de Hoy (si aplica)
      }
    }
  }

  void _noCompra() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Marcar como "No compra"'),
        content: const Text('¿Estás seguro de marcar esta visita como "No compra"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      // TODO: Registrar "no compra"
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Visita marcada como "No compra"')),
        );
        Navigator.pop(context);
      }
    }
  }

  void _postergar() async {
    // TODO: Abrir date picker / motivo
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Visita postergada (demo)')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 600;

    final confirm = ConfirmAction(
      enabled: _ventaValida,
      total: _total,
      onConfirm: _confirmarVenta,
    );

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.azul,
          foregroundColor: Colors.white,
          title: _TitleCliente(
            nombre: widget.nombreCliente,
            direccion: widget.direccion,
          ),
          actions: [
            IconButton(
              tooltip: 'Editar cliente',
              icon: const Icon(Icons.edit),
              onPressed: () {
                // TODO: editar datos del cliente
              },
            ),
            IconButton(
              tooltip: 'Ver ubicación',
              icon: const Icon(Icons.location_on),
              onPressed: () {
                // TODO: abrir mapa/geo
              },
            ),
          ],
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: 'Venta actual'),
              Tab(text: 'Productos'),
              Tab(text: 'Historial'),
            ],
          ),
        ),

        // Botón Confirmar (responsive)
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: isMobile ? null : confirm,
        bottomNavigationBar: isMobile ? confirm : null,

        body: Padding(
          padding: EdgeInsets.only(bottom: isMobile ? 84 : 0), // espacio para que no tape el botón
          child: TabBarView(
            children: [
              _tabVentaActual(context, cs),
              _tabProductos(context, cs),
              _tabHistorial(context, cs),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Tabs ----------

  Widget _tabVentaActual(BuildContext context, ColorScheme cs) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _HeaderInfo(
          legajo: widget.legajo,
          deuda: widget.deuda,
        ),
        const SizedBox(height: 12),

        // Acciones rápidas
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: _noCompra,
              icon: const Icon(Icons.close),
              label: const Text('No compra'),
            ),
            OutlinedButton.icon(
              onPressed: _postergar,
              icon: const Icon(Icons.refresh),
              label: const Text('Postergar visita'),
            ),
          ],
        ),

        const SizedBox(height: 16),
        Text('Ítems', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),

        if (_carrito.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: cs.primary),
                const SizedBox(width: 8),
                const Expanded(child: Text('No hay productos en la venta actual.')),
              ],
            ),
          ),

        for (final entry in _carrito.entries) ...[
          Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.local_drink),
              title: Text(entry.key),
              subtitle: Text('Cantidad: ${entry.value} · \$${(_catalogo[entry.key] ?? 0).toStringAsFixed(0)} c/u'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Editar cantidad',
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editarCantidad(entry.key),
                  ),
                  IconButton(
                    tooltip: 'Quitar',
                    icon: const Icon(Icons.close),
                    onPressed: () => _eliminarProducto(entry.key),
                  ),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Total: \$${_total.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ],
    );
  }

  Widget _tabProductos(BuildContext context, ColorScheme cs) {
    final nombres = _catalogo.keys.toList();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: nombres.length,
      itemBuilder: (context, i) {
        final nombre = nombres[i];
        final precio = _catalogo[nombre]!;
        return Card(
          child: ListTile(
            leading: const Icon(Icons.add_shopping_cart),
            title: Text(nombre),
            subtitle: Text('\$${precio.toStringAsFixed(0)}'),
            trailing: FilledButton(
              onPressed: () => _agregarProducto(nombre),
              style: FilledButton.styleFrom(backgroundColor: AppColors.azul),
              child: const Text('Agregar'),
            ),
          ),
        );
      },
    );
  }

  Widget _tabHistorial(BuildContext context, ColorScheme cs) {
    if (_historial.isEmpty) {
      return Center(
        child: Text(
          'Sin historial',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _historial.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => Card(
        child: ListTile(
          leading: const Icon(Icons.history),
          title: Text(_historial[i]),
        ),
      ),
    );
    }

}

// ---------- Widgets auxiliares ----------

class _TitleCliente extends StatelessWidget {
  final String nombre;
  final String direccion;
  const _TitleCliente({required this.nombre, required this.direccion});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(nombre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(direccion, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}

class _HeaderInfo extends StatelessWidget {
  final String legajo;
  final double deuda;
  const _HeaderInfo({required this.legajo, required this.deuda});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _InfoItem(label: 'Legajo', value: legajo),
                _InfoItem(
                  label: 'Deuda',
                  value: '\$ ${deuda.toStringAsFixed(0)}',
                  valueStyle: TextStyle(
                    color: deuda > 0 ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;
  const _InfoItem({required this.label, required this.value, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ', style: TextStyle(color: cs.onSurfaceVariant)),
        Text(value, style: valueStyle ?? const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _CantidadDialog extends StatefulWidget {
  final int cantidadInicial;
  const _CantidadDialog({required this.cantidadInicial});

  @override
  State<_CantidadDialog> createState() => _CantidadDialogState();
}

class _CantidadDialogState extends State<_CantidadDialog> {
  late int _cant;

  @override
  void initState() {
    super.initState();
    _cant = widget.cantidadInicial;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar cantidad'),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            tooltip: 'Menos',
            onPressed: () => setState(() => _cant = (_cant - 1).clamp(0, 999)),
            icon: const Icon(Icons.remove),
          ),
          Text('$_cant', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          IconButton(
            tooltip: 'Más',
            onPressed: () => setState(() => _cant = (_cant + 1).clamp(0, 999)),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop<int>(context, _cant), child: const Text('Guardar')),
      ],
    );
  }
}

// ---------- Botón Confirmar (responsive) ----------

class ConfirmAction extends StatelessWidget {
  final bool enabled;
  final double total; // total de la venta
  final VoidCallback onConfirm;

  const ConfirmAction({
    super.key,
    required this.enabled,
    required this.total,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 600;

    if (isMobile) {
      // Botón ancho al pie (sticky)
      return SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black12)],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: enabled ? onConfirm : null,
              icon: const Icon(Icons.check),
              label: Text(
                total > 0 ? 'Confirmar · \$${total.toStringAsFixed(0)}' : 'Confirmar',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: enabled ? Colors.green : null,
                foregroundColor: enabled ? Colors.white : null,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
      );
    }

    // FAB extendido centrado (tablet/desktop)
    return SafeArea(
      child: FloatingActionButton.extended(
        onPressed: enabled ? onConfirm : null,
        icon: const Icon(Icons.check),
        label: Text(
          total > 0 ? 'Confirmar · \$${total.toStringAsFixed(0)}' : 'Confirmar',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: enabled ? Colors.green : Colors.grey.shade400,
        foregroundColor: Colors.white,
      ),
    );
  }
}
