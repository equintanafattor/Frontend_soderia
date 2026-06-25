// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/enums/estado_visita.dart';
import 'package:frontend_soderia/core/navigation/destinations.dart';
import 'package:frontend_soderia/core/navigation/shell_state.dart';
import 'package:frontend_soderia/core/session/session_state.dart';
import 'package:frontend_soderia/core/state/todos_filter.dart';
import 'package:frontend_soderia/core/net/api_client.dart';
import 'package:frontend_soderia/data/remote/catalogo_api.dart';
import 'package:frontend_soderia/repositories/catalogo_repository.dart';

import 'package:frontend_soderia/widgets/day_filter_buttons.dart';
import 'package:frontend_soderia/widgets/visit_card.dart';

import 'package:frontend_soderia/data/local/local_db.dart';
import 'package:frontend_soderia/data/remote/reparto_api.dart';
import 'package:frontend_soderia/repositories/reparto_repository.dart';
import 'package:frontend_soderia/data/local/daos/sync_queue_dao.dart';
import 'package:frontend_soderia/sync/sync_service.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class HomeScreen extends StatefulWidget {
  final String nombreUsuario;
  final void Function(int index)? onRequestTab;

  const HomeScreen({super.key, required this.nombreUsuario, this.onRequestTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String filtroSeleccionado = 'Hoy';

  late DateTime _fechaObjetivo;
  late Future<List<RepartoClienteConDatos>> _futureAgenda;
  late final VoidCallback _homeDayFilterListener;
  late final VoidCallback _shellListener;
  /*final ScrollController _scrollController = ScrollController();*/
  final ItemScrollController _itemScrollController = ItemScrollController();
  int? _scrollTargetIndex;

  late final RepartoRepository _repartoRepository;
  late final CatalogoRepository _catalogoRepository;
  late final SyncQueueDao _syncQueueDao;
  late final SyncService _syncService;
  bool _cerrandoReparto = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final current = sessionState.value;
      if (current == null || current.nombre != widget.nombreUsuario) {
        sessionState.setUser(SessionUser(nombre: widget.nombreUsuario));
      }
    });

    _repartoRepository = RepartoRepository(
      db: appDb,
      api: RepartoApi(ApiClient.dio),
    );

    _syncQueueDao = SyncQueueDao(appDb);
    _syncService = SyncService(db: appDb, queueDao: _syncQueueDao);

    _fechaObjetivo = _soloFecha(DateTime.now());
    _futureAgenda = _inicializarPantalla();

    _homeDayFilterListener = () {
      final value = homeDayFilter.value;
      if (value == null) return;

      if (value == 'Todos') {
        setState(() => filtroSeleccionado = 'Todos');
        return;
      }

      final hoy = DateTime.now();
      final nuevaFecha = _fechaParaFiltro(hoy, value);

      setState(() {
        filtroSeleccionado = value;
        _fechaObjetivo = nuevaFecha;
        _futureAgenda = _inicializarPantalla();
      });
    };

    homeDayFilter.addListener(_homeDayFilterListener);

    _shellListener = () {
      if (shellState.value == kIndexInicio) {
        _recargarAgenda();
      }
    };

    shellState.addListener(_shellListener);

    _catalogoRepository = CatalogoRepository(
      db: appDb,
      api: CatalogoApi(ApiClient.dio),
    );
  }

  @override
  void dispose() {
    homeDayFilter.removeListener(_homeDayFilterListener);
    shellState.removeListener(_shellListener);    
    super.dispose();
  }

  Future<List<RepartoClienteConDatos>> _inicializarPantalla() async {
    // IMPORTANTE: sincronizamos primero los cambios offline pendientes
    // (visitas, pedidos, etc.) para que el backend ya los tenga antes de
    // que el bootstrap descargue la agenda fresca y sobreescriba
    // RepartoClientesLocal. Si el orden fuera al revés, el bootstrap
    // pisaría el estado_visita local con el valor viejo del servidor,
    // y recién se vería actualizado en la siguiente recarga.
    try {
      await _syncService.syncPendientes();
    } catch (_) {}

    try {
      await _repartoRepository.bootstrapDelDia(
        fecha: _fechaObjetivo,
        idEmpresa: 1,
      );
    } catch (_) {}

    try {
      await _catalogoRepository.bootstrapCatalogo();
    } catch (_) {}

    return _cargarAgendaLocal();
  }

  Future<List<RepartoClienteConDatos>> _cargarAgendaLocal() async {
    final idReparto = await _repartoRepository.obtenerIdRepartoActualLocal();
    if (idReparto == null) return [];

    return _repartoRepository.obtenerClientesDelDiaLocal(idReparto: idReparto);
  }

  void _recargarAgenda() {
    setState(() {
      _futureAgenda = _inicializarPantalla();
    });
  }

  DateTime _soloFecha(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  DateTime _fechaParaFiltro(DateTime base, String filtro) {
    base = _soloFecha(base);
    switch (filtro) {
      case 'Mañana':
        return base.add(const Duration(days: 1));
      case 'Ayer':
        return base.subtract(const Duration(days: 1));
      default:
        return base;
    }
  }

  void _onFilterChanged(String nuevoFiltro) {
    if (nuevoFiltro == 'Todos') {
      setState(() => filtroSeleccionado = nuevoFiltro);
      widget.onRequestTab?.call(1);
      return;
    }

    final hoy = DateTime.now();
    final nuevaFecha = _fechaParaFiltro(hoy, nuevoFiltro);

    setState(() {
      filtroSeleccionado = nuevoFiltro;
      _fechaObjetivo = nuevaFecha;
      _futureAgenda = _inicializarPantalla();
    });
  }

    /// Devuelve el índice del próximo cliente pendiente/postergado después
  /// del actual. Si no hay siguiente, devuelve el índice del actual
  /// (para que quede visible con su nuevo estado).
  int _indexSiguientePendiente(
    List<RepartoClienteConDatos> clientes,
    int legajoActual,
  ) {
    final actualIndex = clientes.indexWhere((c) => c.legajo == legajoActual);

    for (int i = actualIndex + 1; i < clientes.length; i++) {
      final estado = mapEstadoVisita(clientes[i].estadoVisita ?? 'pendiente');
      if (estado == EstadoVisita.pendiente ||
          estado == EstadoVisita.postergado) {
        return i;
      }
    }
    return actualIndex == -1 ? 0 : actualIndex;
  }

  Future<void> _recargarAgendaYMostrarSiguiente(int legajoActual) async {
    // 1) Datos locales primero (sin red): reaccionamos al instante.
    final clientesLocales = await _cargarAgendaLocal();
    if (!mounted) return;

    setState(() {
      _futureAgenda = Future.value(clientesLocales);
      _scrollTargetIndex =
          _indexSiguientePendiente(clientesLocales, legajoActual);
    });

    // 2) Refresco en background (sync + bootstrap). Al terminar,
    //    recalculamos el índice y reafirmamos la posición.
    _inicializarPantalla().then((clientesActualizados) {
      if (!mounted) return;
      setState(() {
        _futureAgenda = Future.value(clientesActualizados);
        _scrollTargetIndex =
            _indexSiguientePendiente(clientesActualizados, legajoActual);
      });
    });
  }

  Future<void> _cerrarReparto() async {
    final idReparto = await _repartoRepository.obtenerIdRepartoActualLocal();
    if (idReparto == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay un reparto activo para cerrar')),
      );
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar reparto del día'),
        content: const Text(
          '¿Confirmás el cierre del reparto? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cerrar reparto'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _cerrandoReparto = true);
    try {
      await _repartoRepository.api.cerrarReparto(idReparto);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reparto cerrado correctamente')),
      );
      _recargarAgenda();
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cerrar reparto: $e')));
    } finally {
      if (mounted) setState(() => _cerrandoReparto = false);
    }
  }

  Widget _syncBanner() {
    return StreamBuilder<int>(
      stream: _syncQueueDao.watchPendingCount(),
      builder: (context, snap) {
        final count = snap.data ?? 0;

        if (count == 0) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade300),
          ),
          child: Row(
            children: [
              const Icon(Icons.sync_problem_outlined),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Hay $count operaciones pendientes de sincronización',
                ),
              ),
              TextButton(
                onPressed: () async {
                  await _syncService.syncPendientes();
                  if (!mounted) return;
                  _recargarAgenda();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sincronización ejecutada')),
                  );
                },
                child: const Text('Sincronizar ahora'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      color: cs.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Hola, ${widget.nombreUsuario}!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: cs.onBackground,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cerrar reparto del día',
                    onPressed: _cerrandoReparto ? null : _cerrarReparto,
                    icon: _cerrandoReparto
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.lock_outline),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _syncBanner(),
              DayFilterButtons(
                selected: filtroSeleccionado,
                onFilterChanged: _onFilterChanged,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: FutureBuilder<List<RepartoClienteConDatos>>(
                  future: _futureAgenda,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error al cargar visitas\n${snapshot.error}',
                          style: TextStyle(color: cs.error),
                        ),
                      );
                    }

                    final clientes = snapshot.data ?? [];

                    if (clientes.isEmpty) {
                      return Center(
                        child: Text(
                          'No hay visitas para $filtroSeleccionado',
                          style: TextStyle(color: cs.onBackground),
                        ),
                      );
                    }

                    // Disparamos el scroll recién cuando la lista está montada con datos.
                      final targetIndex = _scrollTargetIndex;
                      if (targetIndex != null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted || _scrollTargetIndex != targetIndex) return;
                          if (!_itemScrollController.isAttached) return;
                          _itemScrollController.scrollTo(
                            index: targetIndex.clamp(0, clientes.length - 1),
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOut,
                            alignment: 0.0, // 0.0 = el ítem queda arriba de todo
                          );
                          _scrollTargetIndex = null;
                        });
                      }

                      return ScrollablePositionedList.builder(
                        itemScrollController: _itemScrollController,
                        itemCount: clientes.length,
                        itemBuilder: (context, index) {
                          final c = clientes[index];
                          final estado = mapEstadoVisita(c.estadoVisita ?? 'pendiente');

                          final bool puedeEntrar = estado == EstadoVisita.pendiente ||
                              estado == EstadoVisita.postergado ||
                              estado == EstadoVisita.visitado;

                          return VisitCard(
                            nombre: c.nombre,
                            direccion: c.direccion ?? 'Sin dirección',
                            estado: estado,
                            turnoVisita: c.turno,
                            onTap: puedeEntrar
                                ? () async {
                                    final res = await Navigator.of(
                                      context,
                                      rootNavigator: true,
                                    ).pushNamed('/venta', arguments: {'legajo': c.legajo});
                                    if (res == true) {
                                      await _recargarAgendaYMostrarSiguiente(c.legajo);
                                    }
                                  }
                                : null,
                          );
                        },
                      );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
