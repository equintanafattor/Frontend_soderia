import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/colors.dart';
import 'package:frontend_soderia/screens/pago_screen.dart';
import 'package:frontend_soderia/services/cliente_service.dart';

class VentaScreen extends StatefulWidget {
  final int legajoCliente;

  const VentaScreen({
    super.key,
    required this.legajoCliente,
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

  late Future<Map<String, dynamic>> _futureCliente;
  final _service = ClienteService();

  @override
  void initState() {
    super.initState();
    _futureCliente = _service.obtenerCliente(widget.legajoCliente);
  }

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

  Future<void> _confirmarVenta(
    String nombreCliente,
    String legajo,
    double deuda,
  ) async {
    // acá después pegás al endpoint real
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PagoScreen(
          nombreCliente: nombreCliente,
          legajo: legajo,
          fecha: DateTime.now(),
          deudaActual: deuda,
          items: const [
            LineaVenta(
              nroPedido: '015',
              producto: 'Agua de 20 Lts',
              cantidad: 2,
              precioUnitario: 3500,
            ),
            LineaVenta(
              nroPedido: '015',
              producto: 'Dispenser Frio Calor',
              cantidad: 1,
              precioUnitario: 20000,
            ),
          ],
          total: 27000,
        ),
      ),
    );

    if (ok == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Venta confirmada')),
        );
        Navigator.pop(context);
      }
    }
  }

  void _noCompra(String nombreCliente) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Marcar como "No compra"'),
        content: Text(
          '¿Estás seguro de marcar a $nombreCliente como "No compra"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      // TODO: pegar al endpoint de no compra
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Visita marcada como "No compra"')),
        );
        Navigator.pop(context);
      }
    }
  }

  void _postergar() {
    // TODO: endpoint de postergar
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Visita postergada (demo)')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _futureCliente,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Venta')),
            body: Center(child: Text('Error: ${snap.error}')),
          );
        }

        final cli = snap.data!;
        final persona = cli['persona'] ?? {};
        final nombre =
            '${persona['nombre'] ?? ''} ${persona['apellido'] ?? ''}'.trim();
        final legajoStr = cli['legajo'].toString();
        final direccion = ''; // cuando tu GET de cliente lo traiga, lo usás acá
        final deuda = 0.0; // lo mismo, cuando tengas cuenta corriente

        return _buildScaffold(nombre, direccion, legajoStr, deuda);
      },
    );
  }

  Widget _buildScaffold(
    String nombreCliente,
    String direccion,
    String legajo,
    double deuda,
  ) {
    final cs = Theme.of(context).colorScheme;
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 600;

    final confirm = ConfirmAction(
      enabled: _ventaValida,
      total: _total,
      onConfirm: () => _confirmarVenta(nombreCliente, legajo, deuda),
    );

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.azul,
          foregroundColor: Colors.white,
          title: _TitleCliente(
            nombre: nombreCliente,
            direccion: direccion,
          ),
          actions: [
            IconButton(
              tooltip: 'Editar cliente',
              icon: const Icon(Icons.edit),
              onPressed: () {
                // TODO: editar cliente
              },
            ),
            IconButton(
              tooltip: 'Ver ubicación',
              icon: const Icon(Icons.location_on),
              onPressed: () {
                // TODO: mapa
              },
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Venta actual'),
              Tab(text: 'Productos'),
              Tab(text: 'Historial'),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: isMobile ? null : confirm,
        bottomNavigationBar: isMobile ? confirm : null,
        body: Padding(
          padding: EdgeInsets.only(bottom: isMobile ? 84 : 0),
          child: TabBarView(
            children: [
              _tabVentaActual(context, cs, legajo, deuda, nombreCliente),
              _tabProductos(context, cs),
              _tabHistorial(context, cs),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Tabs ----------

  Widget _tabVentaActual(
    BuildContext context,
    ColorScheme cs,
    String legajo,
    double deuda,
    String nombreCliente,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _HeaderInfo(legajo: legajo, deuda: deuda),
        const SizedBox(height: 12),

        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => _noCompra(nombreCliente),
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
                const Expanded(
                  child: Text('No hay productos en la venta actual.'),
                ),
              ],
            ),
          ),

        for (final entry in _carrito.entries) ...[
          Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.local_drink),
              title: Text(entry.key),
              subtitle: Text(
                'Cantidad: ${entry.value} · \$${(_catalogo[entry.key] ?? 0).toStringAsFixed(0)} c/u',
              ),
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
        Text(
          nombre,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (direccion.isNotEmpty)
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
        Text(
          value,
          style: valueStyle ?? const TextStyle(fontWeight: FontWeight.w600),
        ),
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
          Text(
            '$_cant',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          IconButton(
            tooltip: 'Más',
            onPressed: () => setState(() => _cant = (_cant + 1).clamp(0, 999)),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop<int>(context, _cant),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

// ---------- Botón Confirmar (responsive) ----------

class ConfirmAction extends StatelessWidget {
  final bool enabled;
  final double total;
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
                total > 0
                    ? 'Confirmar · \$${total.toStringAsFixed(0)}'
                    : 'Confirmar',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: enabled ? Colors.green : null,
                foregroundColor: enabled ? Colors.white : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      );
    }

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





