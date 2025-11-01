import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:frontend_soderia/core/colors.dart';
import 'package:frontend_soderia/models/jornada.dart';
import 'package:frontend_soderia/services/jornada_service.dart';
import 'package:frontend_soderia/widgets/day_filter_buttons.dart';
import 'package:frontend_soderia/widgets/jornada_card.dart';
import 'package:frontend_soderia/core/state/todos_filter.dart';

class TodosScreen extends StatefulWidget {
  const TodosScreen({super.key, this.nombreUsuario = 'Usuario'});

  final String nombreUsuario;

  @override
  State<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends State<TodosScreen> {
  DateTime mesActual = DateTime.now();
  final JornadaService _service = JornadaService();

  late Future<List<Jornada>> _futureJornadas;
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

    _futureJornadas = _service.obtenerJornadas(mesActual.year, mesActual.month);

    // 2) Escuchar cambios futuros del filtro global
    _monthFilterListener = () {
      final mf = todosMonthFilter.value;
      if (mf == null) return;
      final nueva = DateTime(mf.year, mf.month, 1);
      if (nueva.year == mesActual.year && nueva.month == mesActual.month)
        return;

      setState(() {
        mesActual = nueva;
        _futureJornadas = _service.obtenerJornadas(
          mesActual.year,
          mesActual.month,
        );
        _didAutoScrollForMonth = false; // reset para autoscroll
      });
    };
    todosMonthFilter.addListener(_monthFilterListener);
  }

  @override
  void dispose() {
    todosMonthFilter.removeListener(_monthFilterListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _cambiarMes(int delta) {
    setState(() {
      mesActual = DateTime(mesActual.year, mesActual.month + delta, 1);
      _futureJornadas = _service.obtenerJornadas(
        mesActual.year,
        mesActual.month,
      );
      _didAutoScrollForMonth = false; // reset para autoscroll
    });
    // 3) Sincronizar el filtro global
    todosMonthFilter.value = MonthFilter(mesActual.year, mesActual.month);
  }

  Future<void> _refrescar() async {
    setState(() {
      _futureJornadas = _service.obtenerJornadas(
        mesActual.year,
        mesActual.month,
      );
    });
    await _futureJornadas;
  }

  // ===== Helpers =====

  bool _esMismaFecha(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime _soloFecha(DateTime d) => DateTime(d.year, d.month, d.day);

  int _diasEnMes(DateTime d) => DateTime(d.year, d.month + 1, 0).day;

  List<DateTime> _todosLosDiasDelMes(DateTime mes) {
    final total = _diasEnMes(mes);
    return List.generate(total, (i) => DateTime(mes.year, mes.month, i + 1));
  }

  // Agrupa jornadas por día y aplana sus clientes en una sola lista por fecha.
  Map<DateTime, List<String>> _clientesPorDia(List<Jornada> jornadas) {
    final map = <DateTime, List<String>>{};
    for (final j in jornadas) {
      final f = _soloFecha(j.fecha);
      map.putIfAbsent(f, () => <String>[]).addAll(j.clientes);
    }
    // (Opcional) quitar duplicados preservando orden
    for (final entry in map.entries) {
      final seen = <String>{};
      entry.value.retainWhere((c) => seen.add(c));
    }
    return map;
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
      floatingActionButton: _buildIrAHoyFab(),
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
                        onFilterChanged: (nuevo) {
                          setState(() {
                            _filtro = nuevo;
                            if (_filtro == 'Todos')
                              _didAutoScrollForMonth = false;
                          });
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
              child: FutureBuilder<List<Jornada>>(
                future: _futureJornadas,
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

                  final jornadas = (snapshot.data ?? const <Jornada>[])
                    ..sort((a, b) => a.fecha.compareTo(b.fecha));

                  final mapaClientes = _clientesPorDia(jornadas);
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
                      final clientes = List<String>.from(
                        mapaClientes[_soloFecha(fecha)] ?? const <String>[],
                      );

                      return KeyedSubtree(
                        key: key, // clave para ensureVisible
                        child: JornadaCard(
                          fecha: fecha,
                          nombres: clientes,
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
  Widget? _buildIrAHoyFab() {
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
  }
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
