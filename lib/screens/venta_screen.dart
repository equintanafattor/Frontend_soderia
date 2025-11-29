import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/colors.dart';
import 'package:frontend_soderia/core/navigation/app_shell_actions.dart';
import 'package:frontend_soderia/screens/pago_screen.dart';
import 'package:frontend_soderia/services/cliente_service.dart';
import 'package:frontend_soderia/services/producto_service.dart';
import 'package:frontend_soderia/screens/clientes/cliente_edit_screen.dart';
import 'package:frontend_soderia/services/visita_service.dart';

class VentaScreen extends StatefulWidget {
  final int legajoCliente;
  final int idListaPrecios;

  const VentaScreen({
    super.key,
    required this.legajoCliente,
    this.idListaPrecios = 1,
  });

  @override
  State<VentaScreen> createState() => _VentaScreenState();
}

// ------------------- Modelo interno de carrito -------------------

class _CarritoItem {
  final int idProducto;
  final String nombre;
  final double precioUnitario;
  int cantidad;

  _CarritoItem({
    required this.idProducto,
    required this.nombre,
    required this.precioUnitario,
    required this.cantidad,
  });
}

class _VentaScreenState extends State<VentaScreen> {
  // Carrito actual (clave: nombre producto → item)
  final Map<int, _CarritoItem> _carrito = {};

  // Futuros para cliente (detalle) y productos
  late Future<Map<String, dynamic>> _futureClienteDetalle;
  late Future<List<dynamic>> _futureProductos;

  final _clienteService = ClienteService();
  final _productoService = ProductoService();
  final _visitaService = VisitaService();

  @override
  void initState() {
    super.initState();
    // Detalle del cliente (persona, direcciones, cuentas, historicos, etc.)
    _futureClienteDetalle = _clienteService.obtenerDetalleCliente(
      widget.legajoCliente,
    );

    // Productos de la lista seleccionada, con precio
    _futureProductos = _productoService.listarProductosDeLista(
      widget.idListaPrecios,
    );
  }

  // -------- Helpers --------

  Future<void> _registrarVisita(String estado) async {
    try {
      await _visitaService.crearVisita(
        legajo: widget.legajoCliente,
        estado: estado,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo registrar la visita: $e')),
      );
    }
  }

  double get _total {
    double t = 0;
    for (final item in _carrito.values) {
      t += item.precioUnitario * item.cantidad;
    }
    return t;
  }

  bool get _ventaValida => _carrito.isNotEmpty;

  void _agregarProducto(int idProducto, String nombre, double precioUnitario) {
    setState(() {
      final existente = _carrito[idProducto];
      if (existente != null) {
        existente.cantidad++;
      } else {
        _carrito[idProducto] = _CarritoItem(
          idProducto: idProducto,
          nombre: nombre,
          precioUnitario: precioUnitario,
          cantidad: 1,
        );
      }
    });
  }

  void _eliminarProducto(int idProducto) {
    setState(() {
      _carrito.remove(idProducto);
    });
  }

  Future<void> _editarCantidad(int idProducto) async {
    final item = _carrito[idProducto];
    if (item == null) return;

    final nueva = await showDialog<int>(
      context: context,
      builder: (_) => _CantidadDialog(cantidadInicial: item.cantidad),
    );
    if (nueva == null) return;

    setState(() {
      if (nueva <= 0) {
        _carrito.remove(idProducto);
      } else {
        item.cantidad = nueva;
      }
    });
  }

  Future<void> _confirmarVenta(
    String nombreCliente,
    String legajo,
    double deuda,
  ) async {
    // Si por alguna razón se llegó acá sin ítems, no sigo
    if (_carrito.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay productos en la venta')),
      );
      return;
    }

    // 1) Mapear el carrito → List<LineaVenta>
    final List<LineaVenta> items = [];
    int i = 1;

    _carrito.forEach((nombreProd, item) {
      items.add(
        LineaVenta(
          nroPedido: item.idProducto.toString(),
          producto: item.nombre,
          cantidad: item.cantidad,
          precioUnitario: item.precioUnitario,
        ),
      );
      i++;
    });

    final total = _total;

    // 2) Navegar a PagoScreen con los datos reales
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PagoScreen(
          nombreCliente: nombreCliente,
          legajo: legajo,
          fecha: DateTime.now(),
          deudaActual: deuda,
          items: items, // 👈 carrito real
          total: total, // 👈 total real
        ),
      ),
    );

    // 3) Si pago OK, cierro la venta (y acá después podés registrar la visita/venta en el back)
    if (ok == true && mounted) {
      // Si ya implementaste lo de Visita:
      // await _registrarVisita(VisitaEstado.compra);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Venta confirmada')));

      // Podés limpiar el carrito si querés:
      // setState(() => _carrito.clear());

      Navigator.pop(context);
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
    if (ok == true && mounted) {
      // Registrar visita como NO_COMPRA
      await _registrarVisita(VisitaEstado.noCompra);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Visita marcada como "No compra"')),
      );
      Navigator.pop(context);
    }
  }

  void _postergar() async {
    // Registrar visita como POSTERGADA
    await _registrarVisita(VisitaEstado.postergada);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Visita postergada')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _futureClienteDetalle,
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

        final cli = snap.data!; // este es el detalle del cliente
        final persona = cli['persona'] ?? {};
        final nombre = '${persona['nombre'] ?? ''} ${persona['apellido'] ?? ''}'
            .trim();
        final legajoStr = cli['legajo'].toString();

        // ---- Dirección: tomamos la primera de "direcciones" ----
        String direccion = '';
        final direcciones = (cli['direcciones'] as List?) ?? [];
        if (direcciones.isNotEmpty) {
          final d0 = direcciones.first as Map<String, dynamic>;
          final partes = <String>[];

          final dirBase = (d0['direccion'] ?? '').toString().trim();
          if (dirBase.isNotEmpty) partes.add(dirBase);

          final zona = (d0['zona'] ?? '').toString().trim();
          if (zona.isNotEmpty) partes.add('Zona $zona');

          direccion = partes.join(' · ');
        }

        // ---- Deuda: primera cuenta de "cuentas" ----
        double deuda = 0.0;
        final cuentas = (cli['cuentas'] as List?) ?? [];
        if (cuentas.isNotEmpty) {
          final c0 = cuentas.first as Map<String, dynamic>;
          final rawDeuda = c0['deuda'] ?? 0;
          if (rawDeuda is num) {
            deuda = rawDeuda.toDouble();
          } else if (rawDeuda is String) {
            deuda = double.tryParse(rawDeuda) ?? 0.0;
          }
        }

        // ---- Historial: viene dentro de "historicos" ----
        final historicos = (cli['historicos'] as List?) ?? [];

        return _buildScaffold(
          nombreCliente: nombre,
          direccion: direccion,
          legajo: legajoStr,
          deuda: deuda,
          historicos: historicos,
          dataCliente: cli, // 👈 acá pasamos el detalle completo
        );
      },
    );
  }

  Widget _buildScaffold({
    required String nombreCliente,
    required String direccion,
    required String legajo,
    required double deuda,
    required List<dynamic> historicos,
    required Map<String, dynamic> dataCliente, // 👈 NUEVO
  }) {
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
          title: _TitleCliente(nombre: nombreCliente, direccion: direccion),
          actions: [
            IconButton(
              tooltip: 'Editar cliente',
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final res = await AppShellActions.push(
                  context,
                  '/cliente/edit', // ajustá al nombre real de tu ruta
                  arguments: {
                    'legajo': widget.legajoCliente,
                    'data': dataCliente, // 👈 ahora usamos el parámetro
                  },
                );

                // Si se guardó y el edit hace `Navigator.pop(true)`
                if (res == true && mounted) {
                  setState(() {
                    // recargo los datos del cliente para refrescar dirección, deuda, etc.
                    _futureClienteDetalle = _clienteService
                        .obtenerDetalleCliente(widget.legajoCliente);
                  });
                }
              },
            ),
            IconButton(
              tooltip: 'Ver ubicación',
              icon: const Icon(Icons.location_on),
              onPressed: () {
                // TODO: abrir mapa con dirección del cliente
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
              _tabHistorial(context, cs, historicos),
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

        // 👇 ACA VA LA PARTE CORREGIDA
        ..._carrito.entries.map((entry) {
          final int idProducto = entry.key;
          final item = entry.value; // _CarritoItem

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.local_drink),
              title: Text(item.nombre),
              subtitle: Text(
                'ID: $idProducto · Cantidad: ${item.cantidad} · '
                '\$${item.precioUnitario.toStringAsFixed(0)} c/u',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Editar cantidad',
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editarCantidad(idProducto),
                  ),
                  IconButton(
                    tooltip: 'Quitar',
                    icon: const Icon(Icons.close),
                    onPressed: () => _eliminarProducto(idProducto),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _tabProductos(BuildContext context, ColorScheme cs) {
    return FutureBuilder<List<dynamic>>(
      future: _futureProductos,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Error cargando productos: ${snap.error}'));
        }

        final productos = snap.data ?? [];
        if (productos.isEmpty) {
          return Center(
            child: Text(
              'No hay productos cargados para esta lista de precios',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: productos.length,
          itemBuilder: (context, i) {
            final p = productos[i] as Map<String, dynamic>;
            final idProducto = p['id_producto'] as int;
            final nombre = (p['nombre'] ?? '').toString();
            double precio = 0;

            final rawPrecio = p['precio'];
            if (rawPrecio is num) {
              precio = rawPrecio.toDouble();
            } else if (rawPrecio is String) {
              precio = double.tryParse(rawPrecio) ?? 0.0;
            }

            return Card(
              child: ListTile(
                leading: const Icon(Icons.add_shopping_cart),
                title: Text(nombre),
                subtitle: Text(
                  precio > 0
                      ? '\$${precio.toStringAsFixed(0)}'
                      : 'Sin precio definido',
                ),
                trailing: FilledButton(
                  onPressed: () => _agregarProducto(idProducto, nombre, precio),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.azul,
                  ),
                  child: const Text('Agregar'),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _tabHistorial(
    BuildContext context,
    ColorScheme cs,
    List<dynamic> historicos,
  ) {
    if (historicos.isEmpty) {
      return Center(
        child: Text(
          'Sin historial',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: historicos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final h = historicos[i] as Map<String, dynamic>;
        final fechaStr = (h['fecha'] ?? '').toString();
        final obs = (h['observacion'] ?? '').toString();
        final evento = (h['evento'] as Map<String, dynamic>?) ?? {};
        final nombreEvento = (evento['nombre'] ?? evento['descripcion'] ?? '')
            .toString();

        return Card(
          child: ListTile(
            leading: const Icon(Icons.history),
            title: Text(nombreEvento.isNotEmpty ? nombreEvento : 'Evento'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (fechaStr.isNotEmpty) Text(fechaStr),
                if (obs.isNotEmpty) Text(obs),
              ],
            ),
          ),
        );
      },
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
