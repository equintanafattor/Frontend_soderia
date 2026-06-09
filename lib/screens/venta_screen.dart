// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/enums/visita_estado.dart';
import 'package:url_launcher/url_launcher.dart';

// Core
import 'package:frontend_soderia/core/colors.dart';
import 'package:frontend_soderia/core/navigation/app_shell_actions.dart';
import 'package:frontend_soderia/core/net/api_client.dart';

// Data local
import 'package:frontend_soderia/data/local/local_db.dart';
import 'package:frontend_soderia/data/local/daos/sync_queue_dao.dart';

// Remote
import 'package:frontend_soderia/data/remote/catalogo_api.dart';

// Models
import 'package:frontend_soderia/models/venta/venta_carrito_item.dart';

// Repositories
import 'package:frontend_soderia/repositories/catalogo_repository.dart';
import 'package:frontend_soderia/repositories/pedido_repository.dart';
import 'package:frontend_soderia/repositories/visita_repository.dart';

// Screens
import 'package:frontend_soderia/screens/clientes/cliente_edit_screen.dart';
import 'package:frontend_soderia/screens/pago_screen.dart';

// Services
import 'package:frontend_soderia/services/cliente_service.dart';
import 'package:frontend_soderia/services/lista_precio_service.dart';
import 'package:frontend_soderia/services/visita_service.dart';

// Widgets
import 'package:frontend_soderia/widgets/cliente/cliente_envases_widget.dart';
import 'package:frontend_soderia/widgets/venta/venta_cantidad_dialog.dart';
import 'package:frontend_soderia/widgets/venta/venta_confirm_action.dart';
import 'package:frontend_soderia/widgets/venta/venta_header_info.dart';
import 'package:frontend_soderia/widgets/venta/venta_title_cliente.dart';
import 'package:frontend_soderia/widgets/venta/venta_actual_tab.dart';
import 'package:frontend_soderia/widgets/venta/venta_historial_tab.dart';
import 'package:frontend_soderia/widgets/venta/venta_items_tab.dart';
import 'package:frontend_soderia/widgets/venta/venta_selector_cuenta.dart';
import 'package:frontend_soderia/widgets/venta/venta_selector_lista_precios.dart';
import 'package:frontend_soderia/widgets/venta/venta_selector_medio_pago.dart';

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

class _VentaScreenState extends State<VentaScreen> {
  List<Map<String, dynamic>> _cuentas = [];
  Map<String, dynamic>? _cuentaSeleccionada;

  int? get _idCuentaSeleccionada =>
      (_cuentaSeleccionada?['id_cuenta'] as num?)?.toInt();

  double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.replaceAll(',', '.')) ?? 0.0;
    return 0.0;
  }

  double get _deudaSel => _toDouble(_cuentaSeleccionada?['deuda']);
  double get _saldoSel => _toDouble(_cuentaSeleccionada?['saldo']);

  bool get _tieneCuentaSeleccionada => _cuentaSeleccionada != null;

  final Map<String, CarritoItem> _carrito = {};

  late Future<Map<String, dynamic>> _futureClienteDetalle;
  int? _idListaSeleccionada;
  Future<List<dynamic>> _futureItems = Future.value(const []);
  late Future<List<dynamic>> _futureListasPrecios;
  String _key(TipoItemVenta tipo, int id) => '${tipo.name}-$id';

  final _clienteService = ClienteService();
  final _listaPrecioService = ListaPrecioService();

  late final VisitaRepository _visitaRepository;
  List<dynamic> _mediosPago = [];
  int? _idMedioPagoSeleccionado;
  late Future<List<dynamic>> _futureMediosPago;

  Future<List<dynamic>> _cargarMediosPagoHibrido() async {
    try {
      final medios = await _catalogoRepository.obtenerMediosPagoLocales();

      if (medios.isNotEmpty) {
        return medios;
      }

      return [];
    } catch (_) {
      return [];
    }
  }

  Future<int?> _obtenerIdRepartoDiaActual() async {
    final reparto = await appDb
        .select(appDb.repartoActualLocal)
        .getSingleOrNull();
    return reparto?.idReparto;
  }

  bool _modoLocalCliente = false;

  double _parsePrecio(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  Future<void> _abrirEnMapsPorDireccion(String direccion) async {
    final dir = direccion.trim();
    if (dir.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este cliente no tiene dirección cargada'),
        ),
      );
      return;
    }

    final query = Uri.encodeComponent(dir);
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No se pudo abrir Maps')));
    }
  }

  late final CatalogoRepository _catalogoRepository;
  bool _modoLocalCatalogo = false;

  Future<List<dynamic>> _cargarListasHibrido() async {
    try {
      final listas = await _listaPrecioService.listarListas();
      _modoLocalCatalogo = false;
      return listas;
    } catch (_) {
      _modoLocalCatalogo = true;
      return await _catalogoRepository.obtenerListasLocales();
    }
  }

  Future<List<dynamic>> _cargarItemsHibrido(int idLista) async {
    try {
      final items = await _listaPrecioService.listarItemsDeLista(idLista);
      _modoLocalCatalogo = false;
      return items;
    } catch (_) {
      _modoLocalCatalogo = true;

      final itemsLocales = await _catalogoRepository.obtenerItemsDeListaLocal();

      return itemsLocales
          .map(
            (i) => {
              'tipo': i.tipo,
              'id_item': i.idItem,
              'nombre': i.nombre,
              'precio': i.precio,
              'estado': i.estado,
            },
          )
          .toList();
    }
  }

  @override
  void initState() {
    super.initState();

    final queueDao = SyncQueueDao(appDb);
    _visitaRepository = VisitaRepository(db: appDb, queueDao: queueDao);

    _catalogoRepository = CatalogoRepository(
      db: appDb,
      api: CatalogoApi(ApiClient.dio),
    );

    _futureClienteDetalle = _cargarClienteHibrido();

    _idListaSeleccionada = widget.idListaPrecios;
    _futureListasPrecios = _cargarListasHibrido();
    _futureItems = _cargarItemsHibrido(widget.idListaPrecios);
    _futureMediosPago = _cargarMediosPagoHibrido();
  }

  Future<Map<String, dynamic>> _cargarClienteHibrido() async {
    final local = await (appDb.select(
      appDb.clientesLocal,
    )..where((t) => t.legajo.equals(widget.legajoCliente))).getSingleOrNull();

    try {
      final remoto = await _clienteService.obtenerDetalleCliente(
        widget.legajoCliente,
      );
      _modoLocalCliente = false;
      return remoto;
    } catch (_) {
      _modoLocalCliente = true;
      return _buildClienteDetalleDesdeLocal(local);
    }
  }

  Map<String, dynamic> _buildClienteDetalleDesdeLocal(dynamic local) {
    final persona = _personaDesdeNombreLocal(local?.nombre?.toString() ?? '');

    return {
      'legajo': widget.legajoCliente,
      'observacion': null,
      'persona': persona,
      'direcciones': [
        if ((local?.direccion as String?) != null &&
            (local!.direccion as String).trim().isNotEmpty)
          {'direccion': local.direccion, 'zona': null},
      ],
      'telefonos': [
        if ((local?.telefono as String?) != null &&
            (local!.telefono as String).trim().isNotEmpty)
          {'nro_telefono': local.telefono},
      ],
      'cuentas': [
        {
          'id_cuenta': local?.idCuenta,
          'deuda': local?.deuda ?? 0.0,
          'saldo': local?.saldo ?? 0.0,
          'tipo_de_cuenta': 'Cuenta',
          'estado': 'local',
        },
      ],
      'historicos': const [],
    };
  }

  Map<String, dynamic> _personaDesdeNombreLocal(String nombreLocal) {
    final nombre = nombreLocal.trim();

    if (nombre.contains(',')) {
      final parts = nombre.split(',');
      final apellido = parts.isNotEmpty ? parts.first.trim() : '';
      final nombrePersona = parts.length > 1
          ? parts.sublist(1).join(',').trim()
          : '';
      return {'nombre': nombrePersona, 'apellido': apellido};
    }

    final parts = nombre.split(' ').where((e) => e.trim().isNotEmpty).toList();
    if (parts.length >= 2) {
      return {
        'nombre': parts.sublist(0, parts.length - 1).join(' '),
        'apellido': parts.last,
      };
    }

    return {'nombre': nombre, 'apellido': ''};
  }

  Future<void> _pickCuenta() async {
    final selected = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: ListView.separated(
            itemCount: _cuentas.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final c = _cuentas[i];
              final id = (c['id_cuenta'] as num?)?.toInt();
              final tipo = (c['tipo_de_cuenta'] ?? 'Cuenta').toString();
              final deuda = _toDouble(c['deuda']);
              final saldo = _toDouble(c['saldo']);
              final sel = _idCuentaSeleccionada == id;

              return ListTile(
                leading: Icon(sel ? Icons.check_circle : Icons.circle_outlined),
                title: Text(tipo),
                subtitle: Text(
                  'Deuda: \$ ${deuda.toStringAsFixed(0)} · '
                  'Saldo: \$ ${saldo.toStringAsFixed(0)}',
                ),
                onTap: () => Navigator.pop(context, c),
              );
            },
          ),
        );
      },
    );

    if (selected != null && mounted) {
      setState(() {
        _cuentaSeleccionada = selected;
      });
    }
  }

  bool _comboTienePrecio(Map<String, dynamic> item) {
    if (item['tipo'] != 'combo') return true;
    final precio = item['precio'];
    return precio != null && precio > 0;
  }

  Future<void> _registrarVisita(String estado) async {
    try {
      await _visitaRepository.registrarVisitaOffline(
        legajo: widget.legajoCliente,
        estado: estado,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Visita guardada en el dispositivo')),
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

  void _agregarItem(TipoItemVenta tipo, int id, String nombre, double precio) {
    final key = _key(tipo, id);

    if (tipo == TipoItemVenta.combo && precio <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este combo no tiene precio asignado')),
      );
      return;
    }

    setState(() {
      final existente = _carrito[key];
      if (existente != null) {
        existente.cantidad++;
      } else {
        _carrito[key] = CarritoItem(
          tipo: tipo,
          idItem: id,
          nombre: nombre,
          precioUnitario: precio,
          cantidad: 1,
        );
      }
    });
  }

  void _eliminarItem(String key) {
    setState(() {
      _carrito.remove(key);
    });
  }

  void _seleccionarLista(int idLista) {
    setState(() {
      _idListaSeleccionada = idLista;
      _carrito.clear();
      _futureItems = _cargarItemsHibrido(idLista);
    });
  }

  Future<void> _editarCantidad(String key) async {
    final item = _carrito[key];
    if (item == null) return;

    final nueva = await showDialog<int>(
      context: context,
      builder: (_) => VentaCantidadDialog(cantidadInicial: item.cantidad),
    );
    if (nueva == null) return;

    setState(() {
      if (nueva <= 0) {
        _carrito.remove(key);
      } else {
        item.cantidad = nueva;
      }
    });
  }

  Future<void> _confirmarVenta(
    String nombreCliente,
    String legajo,
    double deuda,
    double saldoAFavor,
    int? idCuenta,
  ) async {
    if (idCuenta == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No hay cuenta local válida. Para venta offline falta guardar idCuenta en SQLite.',
          ),
        ),
      );
      return;
    }

    if (_carrito.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay productos en la venta')),
      );
      return;
    }

    final List<LineaVenta> items = [];

    _carrito.forEach((_, item) {
      items.add(
        LineaVenta(
          nroPedido: '${item.tipo.name}-${item.idItem}',
          producto: item.nombre,
          cantidad: item.cantidad,
          precioUnitario: item.precioUnitario,
        ),
      );
    });

    final idMedioPago = _idMedioPagoSeleccionado;

    if (idMedioPago == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccioná un medio de pago')),
      );
      return;
    }

    final total = _total;

    final pedidoRepo = PedidoRepository(
      db: appDb,
      queueDao: SyncQueueDao(appDb),
    );

    final itemsPayload = _carrito.values.map((item) {
      return {
        'id_producto': item.tipo == TipoItemVenta.producto ? item.idItem : null,
        'id_combo': item.tipo == TipoItemVenta.combo ? item.idItem : null,
        'cantidad': item.cantidad.toDouble(),
        'precio_unitario': item.precioUnitario,
      };
    }).toList();

    final idRepartoDia = await _obtenerIdRepartoDiaActual();

    if (idRepartoDia == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay reparto actual cargado en el dispositivo'),
        ),
      );
      return;
    }

    await pedidoRepo.crearPedidoOffline(
      legajo: int.parse(legajo),
      idCuenta: idCuenta,
      idRepartoDia: idRepartoDia,
      idMedioPago: idMedioPago,
      montoTotal: total,
      items: itemsPayload,
    );

    if (!mounted) return;

    final result = await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => PagoScreen(
          nombreCliente: nombreCliente,
          legajo: legajo,
          fecha: DateTime.now(),
          deudaActual: deuda,
          saldoAFavorActual: saldoAFavor,
          items: items,
          total: total,
          idCuenta: idCuenta,
        ),
      ),
    );

    if (!mounted) return;
    Navigator.of(context).pop(result ?? true);
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
      await _registrarVisita(VisitaEstado.noCompra);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Visita marcada como "No compra"')),
      );
      Navigator.of(context).pop(true);
    }
  }

  void _postergar() async {
    await _registrarVisita(VisitaEstado.postergada);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Visita postergada')));

    Navigator.of(context).pop(true);
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

        final cli = snap.data!;
        final persona = cli['persona'] ?? {};
        final nombre = '${persona['nombre'] ?? ''} ${persona['apellido'] ?? ''}'
            .trim();
        final legajoStr = cli['legajo'].toString();

        String direccion = '';
        String direccionBase = '';

        final direcciones = (cli['direcciones'] as List?) ?? [];
        if (direcciones.isNotEmpty) {
          final d0 = direcciones.first as Map<String, dynamic>;
          final partes = <String>[];

          direccionBase = (d0['direccion'] ?? '').toString().trim();
          if (direccionBase.isNotEmpty) partes.add(direccionBase);

          final zona = (d0['zona'] ?? '').toString().trim();
          if (zona.isNotEmpty) partes.add('Zona $zona');

          direccion = partes.join(' · ');
        }

        final cuentasRaw = (cli['cuentas'] as List?) ?? [];
        _cuentas = cuentasRaw
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();

        if (_cuentas.length == 1 && _cuentaSeleccionada == null) {
          _cuentaSeleccionada = _cuentas.first;
        }

        if (_cuentaSeleccionada != null) {
          final selId = _idCuentaSeleccionada;
          final sigue = _cuentas.any(
            (c) => (c['id_cuenta'] as num?)?.toInt() == selId,
          );
          if (!sigue) {
            _cuentaSeleccionada = _cuentas.length == 1 ? _cuentas.first : null;
          }
        }

        final deuda = _deudaSel;
        final saldoAFavor = _saldoSel;
        final idCuenta = _idCuentaSeleccionada;

        final historicos = (cli['historicos'] as List?) ?? [];

        return _buildScaffold(
          nombreCliente: nombre,
          direccion: direccion,
          legajo: legajoStr,
          deuda: deuda,
          saldoAFavor: saldoAFavor,
          historicos: historicos,
          dataCliente: cli,
          idCuenta: idCuenta,
          direccionBase: direccionBase,
        );
      },
    );
  }

  Widget _buildScaffold({
    required String nombreCliente,
    required String direccion,
    required String direccionBase,
    required String legajo,
    required double deuda,
    required double saldoAFavor,
    required List<dynamic> historicos,
    required Map<String, dynamic> dataCliente,
    required int? idCuenta,
  }) {
    final cs = Theme.of(context).colorScheme;
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 600;

    final confirm = VentaConfirmAction(
      enabled: _ventaValida && _tieneCuentaSeleccionada,
      total: _total,
      onConfirm: () =>
          _confirmarVenta(nombreCliente, legajo, deuda, saldoAFavor, idCuenta),
    );

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.azul,
          foregroundColor: Colors.white,
          title: VentaTitleCliente(nombre: nombreCliente, direccion: direccion),
          actions: [
            IconButton(
              tooltip: 'Ver detalle',
              icon: const Icon(Icons.person_search),
              onPressed: () async {
                final res = await AppShellActions.push(
                  context,
                  '/cliente/detail',
                  arguments: {'legajo': widget.legajoCliente},
                );

                if (res == true && mounted) {
                  setState(() {
                    _futureClienteDetalle = _cargarClienteHibrido();
                  });
                }
              },
            ),
            IconButton(
              tooltip: 'Editar cliente',
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final res = await AppShellActions.push(
                  context,
                  '/cliente/edit',
                  arguments: {
                    'legajo': widget.legajoCliente,
                    'data': dataCliente,
                  },
                );

                if (res == true && mounted) {
                  setState(() {
                    _futureClienteDetalle = _cargarClienteHibrido();
                  });
                }
              },
            ),
            IconButton(
              tooltip: 'Ver ubicación',
              icon: const Icon(Icons.location_on),
              onPressed: () {
                final toOpen = (direccionBase.isNotEmpty)
                    ? direccionBase
                    : direccion;
                _abrirEnMapsPorDireccion(toOpen);
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
        body: Column(
          children: [
            if (_modoLocalCliente)
              Container(
                width: double.infinity,
                color: Colors.orange.shade100,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: const Text(
                  'Mostrando datos locales del cliente. El catálogo todavía requiere conexión.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            if (_modoLocalCatalogo)
              Container(
                width: double.infinity,
                color: Colors.orange.shade100,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: const Text(
                  'Mostrando catálogo local',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            VentaSelectorCuenta(
              cuentas: _cuentas,
              cuentaSeleccionada: _cuentaSeleccionada,
              modoLocalCliente: _modoLocalCliente,
              onPickCuenta: _pickCuenta,
            ),

            VentaSelectorListaPrecios(
              futureListasPrecios: _futureListasPrecios,
              idListaSeleccionada: _idListaSeleccionada,
              onChanged: _seleccionarLista,
              onDefaultSelected: (id) {
                if (!mounted) return;
                setState(() {
                  _idListaSeleccionada = id;
                  _futureItems = _cargarItemsHibrido(id);
                });
              },
            ),

            EnvasesCompacto(legajo: widget.legajoCliente),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isMobile ? 84 : 0),
                child: TabBarView(
                  children: [
                    VentaActualTab(
                      cs: cs,
                      legajo: legajo,
                      deuda: deuda,
                      saldoAFavor: saldoAFavor,
                      nombreCliente: nombreCliente,
                      carrito: _carrito,
                      onPostergar: _postergar,
                      onNoCompra: () => _noCompra(nombreCliente),
                      onEditarCantidad: _editarCantidad,
                      onEliminarItem: _eliminarItem,
                      selectorMedioPago: VentaSelectorMedioPago(
                        futureMediosPago: _futureMediosPago,
                        idMedioPagoSeleccionado: _idMedioPagoSeleccionado,
                        onChanged: (id) {
                          setState(() => _idMedioPagoSeleccionado = id);
                        },
                        onDefaultSelected: (id) {
                          if (!mounted) return;
                          setState(() => _idMedioPagoSeleccionado = id);
                        },
                      ),
                    ),

                    VentaItemsTab(
                      idListaSeleccionada: _idListaSeleccionada,
                      futureItems: _futureItems,
                      comboTienePrecio: _comboTienePrecio,
                      parsePrecio: _parsePrecio,
                      onAgregarItem: _agregarItem,
                    ),

                    VentaHistorialTab(cs: cs, historicos: historicos),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
