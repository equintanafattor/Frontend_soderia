// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/state/todos_filter.dart';

import 'package:frontend_soderia/widgets/day_filter_buttons.dart';
import 'package:frontend_soderia/widgets/visit_card.dart';

// Nuevo service + modelos reales
import 'package:frontend_soderia/services/agenda_visitas_service.dart';
import 'package:frontend_soderia/models/clientes_por_dia.dart';
import 'package:frontend_soderia/services/direccion_cliente_service.dart';
import 'package:frontend_soderia/models/direccion_cliente.dart';

class HomeScreen extends StatefulWidget {
  final String nombreUsuario;
  final void Function(int index)? onRequestTab; // callback al shell

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
  late final VoidCallback _homeDayFilterListener; // 👈 nuevo

  @override
  void initState() {
    super.initState();

    _fechaObjetivo = DateTime.now();
    _futureAgenda = _agendaService.obtenerClientesPorFecha(
      _soloFecha(_fechaObjetivo),
    );

    // Listener para cambios que vengan de otros lados (TodosScreen)
    _homeDayFilterListener = () {
      final value = homeDayFilter.value;
      if (value == null) return;

      // Opcional: si quisieras limpiar el valor después de usarlo:
      // homeDayFilter.value = null;

      if (value == 'Todos') {
        // Si algún día querés que "Todos" signifique algo en Home
        setState(() {
          filtroSeleccionado = 'Todos';
        });
        return;
      }

      // 'Hoy' | 'Mañana' | 'Ayer'
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
  }

  @override
  void dispose() {
    homeDayFilter.removeListener(_homeDayFilterListener);
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
      case 'Hoy':
      default:
        return base;
    }
  }

  void _onFilterChanged(String nuevoFiltro) {
    if (nuevoFiltro == 'Todos') {
      setState(() {
        filtroSeleccionado = nuevoFiltro;
      });
      widget.onRequestTab?.call(1); // ir a TodosScreen
      return;
    }

    final hoy = DateTime.now();
    final nuevaFecha = _fechaParaFiltro(hoy, nuevoFiltro);

    setState(() {
      filtroSeleccionado = nuevoFiltro;
      _fechaObjetivo = nuevaFecha;
      _futureAgenda = _agendaService.obtenerClientesPorFecha(
        _soloFecha(_fechaObjetivo),
        // si querés filtrar por turno: turno: 'Mañana'
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
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
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
                          'Error al cargar las visitas:\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: cs.error),
                        ),
                      );
                    }

                    final agenda = snapshot.data;

                    if (agenda == null || agenda.clientes.isEmpty) {
                      return Center(
                        child: Text(
                          'No hay visitas para $filtroSeleccionado.',
                          style: TextStyle(color: cs.onBackground),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: agenda.clientes.length,
                      itemBuilder: (context, index) {
                        final c = agenda.clientes[index];

                        // Por cada cliente pedimos su dirección principal
                        return FutureBuilder<DireccionCliente?>(
                          future: _direccionService.obtenerDireccionPrincipal(
                            c.legajo,
                          ),
                          builder: (context, dirSnapshot) {
                            String direccionTexto = '';

                            if (dirSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              direccionTexto = 'Cargando dirección...';
                            } else if (dirSnapshot.hasError) {
                              direccionTexto = 'Error al cargar dirección';
                            } else {
                              final dir = dirSnapshot.data;
                              if (dir != null) {
                                direccionTexto = dir.descripcionCorta;
                              } else {
                                direccionTexto = 'Sin dirección cargada';
                              }
                            }

                            return VisitCard(
                              nombre: c.nombreCompleto,
                              direccion: direccionTexto,
                              visitado:
                                  false, // todavía no tenemos estado de visita en este endpoint
                              turnoVisita:
                                  c.turnoVisita, // esto lo agregamos antes
                              onTap: () {
                                final legajo = c.legajo;
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pushNamed(
                                  '/venta',
                                  arguments: {'legajo': legajo},
                                );
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
