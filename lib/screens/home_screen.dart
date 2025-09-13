// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:frontend_soderia/widgets/day_filter_buttons.dart';
import 'package:frontend_soderia/widgets/visit_card.dart';
import 'package:frontend_soderia/screens/venta_screen.dart';

class HomeScreen extends StatefulWidget {
  final String nombreUsuario;
  final void Function(int index)? onRequestTab; // 👈 callback al shell

  const HomeScreen({super.key, required this.nombreUsuario, this.onRequestTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String filtroSeleccionado = 'Hoy';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final todasLasVisitas = [
      {
        'nombre': 'Juan Pérez',
        'direccion': 'Calle Falsa 123',
        'visitado': false,
        'dia': 'Hoy',
      },
      {
        'nombre': 'María López',
        'direccion': 'Av. Siempreviva 742',
        'visitado': true,
        'dia': 'Hoy',
      },
      {
        'nombre': 'Carlos García',
        'direccion': 'Ruta 9 km 15',
        'visitado': true,
        'dia': 'Mañana',
      },
    ];

    final visitasFiltradas = (filtroSeleccionado == 'Todos')
        ? todasLasVisitas
        : todasLasVisitas.where((v) => v['dia'] == filtroSeleccionado).toList();

    // 👇 OJO: ya NO hay Drawer aquí. El Drawer/Rail lo pone AppShell.
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
                onFilterChanged: (nuevoFiltro) {
                  setState(() => filtroSeleccionado = nuevoFiltro);

                  if (nuevoFiltro == 'Todos') {
                    // 👇 Pedimos al shell cambiar de pestaña (ej. índice 1 = TodosScreen)
                    widget.onRequestTab?.call(1);
                  }
                },
              ),

              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: visitasFiltradas.length,
                  itemBuilder: (context, index) {
                    final v = visitasFiltradas[index];

                    return VisitCard(
                      nombre: v['nombre'] as String,
                      direccion: v['direccion'] as String,
                      visitado: v['visitado'] as bool,
                      onTap: () {
                        // 🔔 Abrir pantalla de venta con los datos del cliente
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => VentaScreen(
                              nombreCliente: v['nombre'] as String,
                              direccion: v['direccion'] as String,
                              // Estos dos son mock por ahora: reemplazalos por tus datos reales
                              legajo: '00$index',
                              deuda: (v['visitado'] as bool) ? 0 : 25000,
                            ),
                          ),
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
