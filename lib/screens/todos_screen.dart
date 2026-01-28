// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:frontend_soderia/core/colors.dart';
import 'package:frontend_soderia/widgets/day_filter_buttons.dart';
import 'package:frontend_soderia/widgets/jornada_card.dart';
import 'package:frontend_soderia/core/state/todos_filter.dart';

// 👇 nuevos imports (ajustá paths si hace falta)
import 'package:frontend_soderia/services/agenda_visitas_service.dart';
import 'package:frontend_soderia/models/clientes_por_dia.dart';

import 'package:frontend_soderia/core/navigation/shell_state.dart';
import 'package:frontend_soderia/core/navigation/destinations.dart'; // para kIndexTodos

class TodosScreen extends StatefulWidget {
  const TodosScreen({
    super.key,
    this.nombreUsuario = 'Usuario',
    this.onRequestTab,
  });

  final String nombreUsuario;
  final void Function(int index)? onRequestTab;

  @override
  State<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends State<TodosScreen> {
  DateTime mesActual = DateTime.now();

  final AgendaVisitasService _agendaService = AgendaVisitasService();
  late final VoidCallback _shellListener;

  /// mapa de fecha -> lista de clientes de ese día
  late Future<Map<DateTime, List<ClientePorDiaItem>>> _futureAgendaMes;

  String _filtro = 'Todos'; // Hoy | Mañana | Ayer | Todos

  late final VoidCallback _monthFilterListener;

  // --- Scroll to hoy ---
  final ScrollController _scrollController = ScrollController();
  final Map<DateTime, GlobalKey> _dayKeys = {};
  bool _didAutoScrollForMonth = false;

  @override
  void initState() {
    super.initState();

    // 1) Si ya hay filtro (viene desde Calendario), aplicalo
    final mf = todosMonthFilter.value;
    if (mf != null) {
      mesActual = DateTime(mf.year, mf.month, 1);
    }

    _futureAgendaMes = _cargarAgendaMes(mesActual);

    // 2) Escuchar cambios futuros del filtro global (desde Calendario, por ej.)
    _monthFilterListener = () {
      final mf = todosMonthFilter.value;
      if (mf == null) return;
      final nueva = DateTime(mf.year, mf.month, 1);
      if (nueva.year == mesActual.year && nueva.month == mesActual.month) {
        return;
      }

      setState(() {
        mesActual = nueva;
        _futureAgendaMes = _cargarAgendaMes(mesActual);
        _didAutoScrollForMonth = false; // reset para autoscroll
      });
    };
    todosMonthFilter.addListener(_monthFilterListener);

    // Escuchar cambios de pestaña del AppShell
    _shellListener = () {
      // Cuando el índice actual del shell sea el de Todos, recargamos
      if (shellState.value == kIndexTareas) {
        _refrescar(); // vuelve a pedir jornadas/agenda del mes actual
      }
    };
    shellState.addListener(_shellListener);
  }

  @override
  void dispose() {
    todosMonthFilter.removeListener(_monthFilterListener);
    _scrollController.dispose();
    shellState.removeListener(_shellListener); // 👈 nuevo
    super.dispose();
  }

  // ===== Carga de datos reales =====

  Future<Map<DateTime, List<ClientePorDiaItem>>> _cargarAgendaMes(
    DateTime mes,
  ) async {
    final dias = _todosLosDiasDelMes(mes);

    // Hacemos un request por día del mes al endpoint /clientes/agenda/visitas
    final results = await Future.wait(
      dias.map((fecha) async {
        try {
          final agenda = await _agendaService.obtenerClientesPorFecha(fecha);
          return MapEntry(_soloFecha(fecha), agenda.clientes);
        } catch (_) {
          // Si algún día falla, devolvemos lista vacía para esa fecha
          return MapEntry(_soloFecha(fecha), <ClientePorDiaItem>[]);
        }
      }),
    );

    final map = <DateTime, List<ClientePorDiaItem>>{};
    for (final entry in results) {
      map[entry.key] = entry.value;
    }
    return map;
  }

  void _cambiarMes(int delta) {
    setState(() {
      mesActual = DateTime(mesActual.year, mesActual.month + delta, 1);
      _futureAgendaMes = _cargarAgendaMes(mesActual);
      _didAutoScrollForMonth = false; // reset para autoscroll
    });

    // 3) Sincronizar el filtro global
    todosMonthFilter.value = MonthFilter(mesActual.year, mesActual.month);
  }

  Future<void> _refrescar() async {
    setState(() {
      _futureAgendaMes = _cargarAgendaMes(mesActual);
    });
    await _futureAgendaMes;
  }

  // ===== Helpers de fechas =====

  bool _esMismaFecha(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime _soloFecha(DateTime d) => DateTime(d.year, d.month, d.day);

  int _diasEnMes(DateTime d) => DateTime(d.year, d.month + 1, 0).day;

  List<DateTime> _todosLosDiasDelMes(DateTime mes) {
    final total = _diasEnMes(mes);
    return List.generate(total, (i) => DateTime(mes.year, mes.month, i + 1));
  }

  // Aplica filtro (Hoy/Ayer/Mañana/Todos) a la lista de DÍAS
  List<DateTime> _aplicarFiltroDias(List<DateTime> dias) {
    if (_filtro == 'Todos') return dias;

    final hoyDT = _soloFecha(DateTime.now());
    final ayerDT = _soloFecha(hoyDT.subtract(const Duration(days: 1)));
    final manianaDT = _soloFecha(hoyDT.add(const Duration(days: 1)));

    switch (_filtro) {
      case 'Hoy':
        return dias.where((d) => _esMismaFecha(d, hoyDT)).toList();
      case 'Ayer':
        return dias.where((d) => _esMismaFecha(d, ayerDT)).toList();
      case 'Mañana':
        return dias.where((d) => _esMismaFecha(d, manianaDT)).toList();
      default:
        return dias;
    }
  }

  // Intenta hacer scroll al bloque del día de hoy si el mes coincide
  void _autoScrollToHoySiCorresponde(List<DateTime> diasVisibles) {
    if (_didAutoScrollForMonth) return;

    final hoy = DateTime.now();
    if (hoy.year != mesActual.year || hoy.month != mesActual.month) {
      _didAutoScrollForMonth = true; // no aplica en este mes
      return;
    }

    final hoyKey = _dayKeys[_soloFecha(hoy)];
    if (hoyKey?.currentContext == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await Scrollable.ensureVisible(
          hoyKey!.currentContext!,
          duration: const Duration(milliseconds: 350),
          alignment: 0.08,
          curve: Curves.easeOutCubic,
        );
      } finally {
        _didAutoScrollForMonth = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final mesNombre = DateFormat.MMMM('es_AR').format(mesActual).toUpperCase();

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.background,
        elevation: 0,
        toolbarHeight: 0,
      ),
      // floatingActionButton: _buildIrAHoyFab(),
      body: Column(
        children: [
          // ======= Header =======
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, ${widget.nombreUsuario}!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: cs.onBackground,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DayFilterButtons(
                        selected: _filtro,
                        onFilterChanged: (nuevo) {
                          if (nuevo == 'Todos') {
                            setState(() {
                              _filtro = 'Todos';
                              _didAutoScrollForMonth = false;
                            });
                          } else {
                            // Hoy / Mañana / Ayer -> mandar a Home
                            homeDayFilter.value = nuevo;
                            widget.onRequestTab?.call(0);

                            // Al volver a Todos, queremos que el chip sea "Todos"
                            setState(() {
                              _filtro = 'Todos';
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    _PlusButton(
                      onPressed: () {
                        debugPrint('Nuevo desde +');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _MesLabel(
                      label: DateFormat.MMM('es_AR')
                          .format(
                            DateTime(mesActual.year, mesActual.month - 1, 1),
                          )
                          .toUpperCase(),
                      color: Colors.grey,
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      color: cs.onBackground,
                      onPressed: () => _cambiarMes(-1),
                    ),
                    Text(
                      mesNombre,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: cs.onBackground,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      color: cs.onBackground,
                      onPressed: () => _cambiarMes(1),
                    ),
                    _MesLabel(
                      label: DateFormat.MMM('es_AR')
                          .format(
                            DateTime(mesActual.year, mesActual.month + 1, 1),
                          )
                          .toUpperCase(),
                      color: Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Divider(color: cs.onBackground.withOpacity(0.25), thickness: 1),
              ],
            ),
          ),

          // ======= Lista: una JornadaCard por DÍA =======
          Expanded(
            child: RefreshIndicator(
              color: cs.primary,
              onRefresh: _refrescar,
              child: FutureBuilder<Map<DateTime, List<ClientePorDiaItem>>>(
                future: _futureAgendaMes,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(color: cs.onBackground),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final mapaClientes =
                      snapshot.data ?? <DateTime, List<ClientePorDiaItem>>{};

                  final todosLosDias = _todosLosDiasDelMes(mesActual);
                  final diasVisibles = _aplicarFiltroDias(todosLosDias);

                  // Asegurar key por día visible
                  for (final d in diasVisibles) {
                    final k = _soloFecha(d);
                    _dayKeys.putIfAbsent(
                      k,
                      () => GlobalKey(debugLabel: 'day_${k.toIso8601String()}'),
                    );
                  }

                  // Auto scroll a HOY si corresponde
                  _autoScrollToHoySiCorresponde(diasVisibles);

                  if (diasVisibles.isEmpty) {
                    return const Center(
                      child: Text('No hay días para mostrar'),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: diasVisibles.length,
                    itemBuilder: (context, i) {
                      final fecha = diasVisibles[i];
                      final key = _dayKeys[_soloFecha(fecha)];

                      final clientes = List<ClientePorDiaItem>.from(
                        mapaClientes[_soloFecha(fecha)] ??
                            const <ClientePorDiaItem>[],
                      );

                      // Convertimos a nombres para JornadaCard
                      final nombres = clientes
                          .map((c) => c.nombreCompleto)
                          .toList(growable: false);

                      return KeyedSubtree(
                        key: key,
                        child: JornadaCard(
                          fecha: fecha,
                          nombres: nombres,
                          onAddPressed: () {
                            debugPrint('Agregar cliente al $fecha');
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Botón opcional para ir a hoy manualmente
/*   Widget? _buildIrAHoyFab() {
    final hoy = DateTime.now();
    if (hoy.year != mesActual.year || hoy.month != mesActual.month) return null;

    return FloatingActionButton.extended(
      onPressed: () {
        final key = _dayKeys[_soloFecha(hoy)];
        final ctx = key?.currentContext;
        if (ctx != null) {
          Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 350),
            alignment: 0.08,
            curve: Curves.easeOutCubic,
          );
        }
      },
      icon: const Icon(Icons.today),
      label: const Text('Ir a hoy'),
    );
  } */
}

// ===== Widgets auxiliares (estilo UI del header) =====

class _PlusButton extends StatelessWidget {
  const _PlusButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        shape: const CircleBorder(),
        side: BorderSide(color: cs.onBackground, width: 2),
        padding: const EdgeInsets.all(12),
      ),
      child: Icon(Icons.add, color: cs.onBackground, size: 22),
    );
  }
}

class _MesLabel extends StatelessWidget {
  const _MesLabel({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 26,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
