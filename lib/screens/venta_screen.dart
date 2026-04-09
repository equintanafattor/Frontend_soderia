// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/colors.dart';
import 'package:frontend_soderia/core/navigation/app_shell_actions.dart';
import 'package:frontend_soderia/screens/pago_screen.dart';
import 'package:frontend_soderia/services/cliente_service.dart';
import 'package:frontend_soderia/services/lista_precio_service.dart';
import 'package:frontend_soderia/screens/clientes/cliente_edit_screen.dart';
import 'package:frontend_soderia/services/visita_service.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:frontend_soderia/data/local/local_db.dart';
import 'package:frontend_soderia/data/local/daos/sync_queue_dao.dart';
import 'package:frontend_soderia/repositories/visita_repository.dart';
import 'package:frontend_soderia/repositories/catalogo_repository.dart';
import 'package:frontend_soderia/data/remote/catalogo_api.dart';
import 'package:frontend_soderia/core/net/api_client.dart';

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

enum TipoItemVenta { producto, combo }

class CarritoItem {
  final TipoItemVenta tipo;
  final int idItem;
  final String nombre;
  final double precioUnitario;
  int cantidad;

  CarritoItem({
    required this.tipo,
    required this.idItem,
    required this.nombre,
    required this.precioUnitario,
    required this.cantidad,
  });
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

  Widget _selectorCuentaWidget() {
    if (_cuentas.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Card(
          child: ListTile(
            leading: Icon(Icons.warning_amber),
            title: Text('Este cliente no tiene cuentas'),
            subtitle: Text('Creá una cuenta para poder vender.'),
          ),
        ),
      );
    }

    final tipo = (_cuentaSeleccionada?['tipo_de_cuenta'] ?? 'Cuenta')
        .toString();
    final estado = (_cuentaSeleccionada?['estado'] ?? '').toString();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Card(
        child: ListTile(
          leading: const Icon(Icons.account_balance_wallet_outlined),
          title: Text('Cuenta: $tipo'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Deuda: \$ ${_deudaSel.toStringAsFixed(0)}  ·  '
                'Saldo: \$ ${_saldoSel.toStringAsFixed(0)}',
              ),
              if (estado.isNotEmpty) Text('Estado: $estado'),
              if (_cuentas.length > 1 && !_tieneCuentaSeleccionada)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'Seleccioná una cuenta para continuar',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              if (_modoLocalCliente)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'Datos cargados localmente',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
            ],
          ),
          trailing: _cuentas.length <= 1
              ? null
              : OutlinedButton.icon(
                  onPressed: _pickCuenta,
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Cambiar'),
                ),
          onTap: _cuentas.length > 1 ? _pickCuenta : null,
        ),
      ),
    );
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
      builder: (_) => _CantidadDialog(cantidadInicial: item.cantidad),
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

    final total = _total;

    final ok = await Navigator.of(context).push<bool>(
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

    if (ok == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Venta confirmada')));

      Navigator.of(context).pop(true);
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

    final confirm = ConfirmAction(
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
          title: _TitleCliente(nombre: nombreCliente, direccion: direccion),
          actions: [
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
            _selectorCuentaWidget(),
            _selectorListaPrecios(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isMobile ? 84 : 0),
                child: TabBarView(
                  children: [
                    _tabVentaActual(
                      context,
                      cs,
                      legajo,
                      deuda,
                      saldoAFavor,
                      nombreCliente,
                    ),
                    _tabItems(context),
                    _tabHistorial(context, cs, historicos),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _selectorListaPrecios() {
    return FutureBuilder<List<dynamic>>(
      future: _futureListasPrecios,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: LinearProgressIndicator(),
          );
        }

        if (snap.hasError) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: Text('No se pudieron cargar listas de precios'),
          );
        }

        final listas = snap.data ?? const [];

        final activas = listas.where((l) {
          final estado = (l['estado'] ?? l.estado ?? '')
              .toString()
              .toLowerCase()
              .trim();
          return estado == 'activo';
        }).toList();

        if (activas.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: Text('No hay listas de precios activas'),
          );
        }

        final existeYActiva =
            _idListaSeleccionada != null &&
            activas.any((l) {
              final id = l is Map<String, dynamic> ? l['id_lista'] : l.idLista;
              return id == _idListaSeleccionada;
            });

        if (!existeYActiva) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              final primera = activas.first;
              _idListaSeleccionada = primera is Map<String, dynamic>
                  ? (primera['id_lista'] as num).toInt()
                  : primera.idLista as int;
              _futureItems = _cargarItemsHibrido(_idListaSeleccionada!);
            });
          });
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: DropdownButtonFormField<int>(
            value: _idListaSeleccionada,
            decoration: const InputDecoration(
              labelText: 'Lista de precios',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: activas.map((l) {
              final id = l is Map<String, dynamic>
                  ? (l['id_lista'] as num).toInt()
                  : l.idLista as int;
              final nombre = l is Map<String, dynamic>
                  ? (l['nombre'] ?? '').toString()
                  : l.nombre as String;

              return DropdownMenuItem<int>(value: id, child: Text(nombre));
            }).toList(),
            onChanged: (v) {
              if (v != null && v != _idListaSeleccionada) {
                _seleccionarLista(v);
              }
            },
          ),
        );
      },
    );
  }

  Widget _tabVentaActual(
    BuildContext context,
    ColorScheme cs,
    String legajo,
    double deuda,
    double saldoAFavor,
    String nombreCliente,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _HeaderInfo(legajo: legajo, deuda: deuda, saldoAFavor: saldoAFavor),
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
        ..._carrito.entries.map((entry) {
          final key = entry.key;
          final item = entry.value;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: Icon(
                item.tipo == TipoItemVenta.combo
                    ? Icons.inventory_2
                    : Icons.local_drink,
              ),
              title: Text(item.nombre),
              subtitle: Text(
                '${item.tipo == TipoItemVenta.combo ? "Combo" : "Producto"} · '
                'Cantidad: ${item.cantidad} · '
                '\$${item.precioUnitario.toStringAsFixed(0)} c/u',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Editar cantidad',
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editarCantidad(key),
                  ),
                  IconButton(
                    tooltip: 'Quitar',
                    icon: const Icon(Icons.close),
                    onPressed: () => _eliminarItem(key),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _tabItems(BuildContext context) {
    if (_idListaSeleccionada == null) {
      return const Center(child: Text('Seleccioná una lista de precios'));
    }

    return FutureBuilder<List<dynamic>>(
      future: _futureItems,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snap.hasError) {
          return const Center(child: Text('No se pudieron cargar los ítems'));
        }

        final items = snap.data ?? const [];

        if (items.isEmpty) {
          return const Center(
            child: Text('Esta lista no tiene ítems con precio'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final raw = items[i];

            final Map<String, dynamic> it = raw is Map<String, dynamic>
                ? raw
                : {
                    'tipo': raw.tipo,
                    'id_item': raw.idItem,
                    'nombre': raw.nombre,
                    'precio': raw.precio,
                    'estado': raw.estado,
                  };

            final tipo = it['tipo'] == 'combo'
                ? TipoItemVenta.combo
                : TipoItemVenta.producto;

            final bool esCombo = tipo == TipoItemVenta.combo;
            final bool tienePrecio = _comboTienePrecio(it);

            final double precio = _parsePrecio(it['precio']);

            final bool activo = esCombo
                ? (it['estado'] == true ||
                      it['estado'] == 'true' ||
                      it['estado'] == 1 ||
                      (it['estado']?.toString().toLowerCase() == 'activo'))
                : true;

            final bool puedeVender = activo && (!esCombo || tienePrecio);

            final icon = esCombo ? Icons.inventory_2 : Icons.local_drink;

            return Card(
              child: ListTile(
                enabled: puedeVender,
                leading: Icon(icon, color: puedeVender ? null : Colors.grey),
                title: Text(
                  (it['nombre'] ?? '').toString(),
                  style: TextStyle(
                    color: puedeVender ? null : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: !activo && esCombo
                    ? const Text(
                        'Combo inactivo',
                        style: TextStyle(color: Colors.red),
                      )
                    : (esCombo && !tienePrecio)
                    ? const Text(
                        'Combo sin precio en esta lista',
                        style: TextStyle(color: Colors.redAccent),
                      )
                    : Text('\$${precio.toStringAsFixed(0)}'),
                trailing: FilledButton(
                  onPressed: puedeVender
                      ? () => _agregarItem(
                          tipo,
                          (it['id_item'] as num).toInt(),
                          (it['nombre'] ?? '').toString(),
                          precio,
                        )
                      : null,
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
  final double saldoAFavor;

  const _HeaderInfo({
    required this.legajo,
    required this.deuda,
    required this.saldoAFavor,
  });

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
                _InfoItem(
                  label: 'Saldo a favor',
                  value: '\$ ${saldoAFavor.toStringAsFixed(0)}',
                  valueStyle: const TextStyle(
                    color: Colors.teal,
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
