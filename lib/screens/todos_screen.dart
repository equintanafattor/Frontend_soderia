import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:frontend_soderia/core/colors.dart';
import 'package:frontend_soderia/models/jornada.dart';
import 'package:frontend_soderia/services/jornada_service.dart';
import 'package:frontend_soderia/widgets/day_filter_buttons.dart';
import 'package:frontend_soderia/widgets/jornada_card.dart';

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

  @override
  void initState() {
    super.initState();
    _futureJornadas = _service.obtenerJornadas(mesActual.year, mesActual.month);
  }

  void _cambiarMes(int delta) {
    setState(() {
      mesActual = DateTime(mesActual.year, mesActual.month + delta, 1);
      _futureJornadas = _service.obtenerJornadas(mesActual.year, mesActual.month);
    });
  }

  Future<void> _refrescar() async {
    setState(() {
      _futureJornadas = _service.obtenerJornadas(mesActual.year, mesActual.month);
    });
    await _futureJornadas;
  }

  // Helpers para filtrar por día
  bool _esMismaFecha(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<Jornada> _aplicarFiltro(List<Jornada> jornadas) {
    if (_filtro == 'Todos') return jornadas;

    final hoy = DateTime.now();
    final soloFechaHoy = DateTime(hoy.year, hoy.month, hoy.day);
    final ayer = soloFechaHoy.subtract(const Duration(days: 1));
    final maniana = soloFechaHoy.add(const Duration(days: 1));

    return jornadas.where((j) {
      final f = DateTime(j.fecha.year, j.fecha.month, j.fecha.day);
      switch (_filtro) {
        case 'Hoy':
          return _esMismaFecha(f, soloFechaHoy);
        case 'Ayer':
          return _esMismaFecha(f, ayer);
        case 'Mañana':
          return _esMismaFecha(f, maniana);
      }
      return true;
    }).toList();
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
        toolbarHeight: 0, // oculto; usamos header custom en el body
      ),
      body: Column(
        children: [
          // ======= Header estilo mock: saludo + filtros + botón "+" =======
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Saludo
                Text(
                  'Hola, ${widget.nombreUsuario}!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: cs.onBackground,
                  ),
                ),
                const SizedBox(height: 16),

                // Filtros + botón "+"
                Row(
                  children: [
                    // Botones (se expanden)
                    Expanded(
                      child: DayFilterButtons(
                        onFilterChanged: (nuevo) {
                          setState(() => _filtro = nuevo);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Botón "+"
                    _PlusButton(onPressed: () {
                      // TODO: acción del "+" en Todos (crear jornada / agregar cliente)
                      debugPrint('Nuevo desde +');
                    }),
                  ],
                ),
                const SizedBox(height: 16),

                // Selector de mes:  APR < MAY > JUN
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _MesLabel(
                      label: DateFormat.MMM('es_AR')
                          .format(DateTime(mesActual.year, mesActual.month - 1, 1))
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
                          .format(DateTime(mesActual.year, mesActual.month + 1, 1))
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

          // ======= Lista de jornadas =======
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
                      ),
                    );
                  }

                  final jornadas = (snapshot.data ?? const <Jornada>[])
                    ..sort((a, b) => a.fecha.compareTo(b.fecha));

                  final visibles = _aplicarFiltro(jornadas);

                  if (visibles.isEmpty) {
                    return const Center(child: Text('No hay jornadas para mostrar'));
                  }

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: visibles.length,
                    itemBuilder: (context, i) {
                      final j = visibles[i];
                      return JornadaCard(
                        fecha: j.fecha,
                        nombres: j.clientes,
                        onAddPressed: () {
                          debugPrint('Agregar cliente al ${j.fecha}');
                        },
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



