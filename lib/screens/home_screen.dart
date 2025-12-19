// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/enums/estado_visita.dart';
import 'package:frontend_soderia/core/navigation/destinations.dart';
import 'package:frontend_soderia/core/navigation/shell_state.dart';
import 'package:frontend_soderia/core/state/todos_filter.dart';

import 'package:frontend_soderia/widgets/day_filter_buttons.dart';
import 'package:frontend_soderia/widgets/visit_card.dart';

import 'package:frontend_soderia/services/agenda_visitas_service.dart';
import 'package:frontend_soderia/models/clientes_por_dia.dart';
import 'package:frontend_soderia/services/direccion_cliente_service.dart';
import 'package:frontend_soderia/models/direccion_cliente.dart';

class HomeScreen extends StatefulWidget {
  final String nombreUsuario;
  final void Function(int index)? onRequestTab;

  const HomeScreen({super.key, required this.nombreUsuario, this.onRequestTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String filtroSeleccionado = 'Hoy';

  final AgendaVisitasService _agendaService = AgendaVisitasService();
  final DireccionClienteService _direccionService = DireccionClienteService();

  late DateTime _fechaObjetivo;
  late Future<ClientesPorDia> _futureAgenda;
  late final VoidCallback _homeDayFilterListener;
  late final VoidCallback _shellListener;

  void _recargarAgenda() {
    setState(() {
      _futureAgenda = _agendaService.obtenerClientesPorFecha(
        _soloFecha(_fechaObjetivo),
      );
    });
  }

  @override
  void initState() {
    super.initState();

    _fechaObjetivo = DateTime.now();
    _futureAgenda = _agendaService.obtenerClientesPorFecha(
      _soloFecha(_fechaObjetivo),
    );

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
        _futureAgenda = _agendaService.obtenerClientesPorFecha(
          _soloFecha(_fechaObjetivo),
        );
      });
    };

    homeDayFilter.addListener(_homeDayFilterListener);

    _shellListener = () {
      // Si el tab activo es Home (index 0)
      if (shellState.value == kIndexInicio) {
        _recargarAgenda();
      }
    };

    shellState.addListener(_shellListener);
  }

  @override
  void dispose() {
    homeDayFilter.removeListener(_homeDayFilterListener);
    shellState.removeListener(_shellListener);
    super.dispose();
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
      _futureAgenda = _agendaService.obtenerClientesPorFecha(
        _soloFecha(_fechaObjetivo),
      );
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
                child: FutureBuilder<ClientesPorDia>(
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

                    final agenda = snapshot.data;

                    if (agenda == null || agenda.clientes.isEmpty) {
                      return Center(
                        child: Text(
                          'No hay visitas para $filtroSeleccionado',
                          style: TextStyle(color: cs.onBackground),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: agenda.clientes.length,
                      itemBuilder: (context, index) {
                        final c = agenda.clientes[index];

                        // 🔴 MAPEO REAL DEL ESTADO
                        final estado = mapEstadoVisita(c.estadoVisita);

                        return FutureBuilder<DireccionCliente?>(
                          future: _direccionService.obtenerDireccionPrincipal(
                            c.legajo,
                          ),
                          builder: (context, dirSnapshot) {
                            String direccionTexto = 'Sin dirección';

                            if (dirSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              direccionTexto = 'Cargando dirección...';
                            } else if (dirSnapshot.hasData &&
                                dirSnapshot.data != null) {
                              direccionTexto =
                                  dirSnapshot.data!.descripcionCorta;
                            }

                            return VisitCard(
                              nombre: c.nombreCompleto,
                              direccion: direccionTexto,
                              estado: estado,
                              turnoVisita: c.turnoVisita,
                              onTap: () async {
                                final result =
                                    await Navigator.of(
                                      context,
                                      rootNavigator: true,
                                    ).pushNamed(
                                      '/venta',
                                      arguments: {'legajo': c.legajo},
                                    );

                                if (result == true) {
                                  _recargarAgenda();
                                }
                              },
                            );
                          },
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
