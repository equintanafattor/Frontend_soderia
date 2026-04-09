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

  late final RepartoRepository _repartoRepository;
  late final CatalogoRepository _catalogoRepository;

  @override
  void initState() {
    super.initState();

    final current = sessionState.value;
    if (current == null || current.nombre != widget.nombreUsuario) {
      sessionState.setUser(SessionUser(nombre: widget.nombreUsuario));
    }

    _repartoRepository = RepartoRepository(
      db: appDb,
      api: RepartoApi(ApiClient.dio),
    );

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
    try {
      // 👇 1. Trae reparto (clientes)
      await _repartoRepository.bootstrapDelDia(
        fecha: _fechaObjetivo,
        idEmpresa: 1,
      );

      // 👇 2. Trae catálogo (productos, listas, medios de pago)
      await _catalogoRepository.bootstrapCatalogo(
        idListaInicial: 1, // podés hacerlo dinámico después
      );
    } catch (_) {
      // si falla, seguimos con lo local (offline mode)
    }

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
              Text(
                'Hola, ${widget.nombreUsuario}!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: cs.onBackground,
                ),
              ),
              const SizedBox(height: 16),
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

                    return ListView.builder(
                      itemCount: clientes.length,
                      itemBuilder: (context, index) {
                        final c = clientes[index];
                        final estado = mapEstadoVisita(
                          c.estadoVisita ?? 'pendiente',
                        );

                        final bool puedeEntrar =
                            estado == EstadoVisita.pendiente ||
                            estado == EstadoVisita.postergado;

                        return VisitCard(
                          nombre: c.nombre,
                          direccion: c.direccion ?? 'Sin dirección',
                          estado: estado,
                          turnoVisita: c.turno,
                          onTap: puedeEntrar
                              ? () async {
                                  final res =
                                      await Navigator.of(
                                        context,
                                        rootNavigator: true,
                                      ).pushNamed(
                                        '/venta',
                                        arguments: {'legajo': c.legajo},
                                      );
                                  if (res == true) _recargarAgenda();
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
