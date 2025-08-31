import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/colors.dart';
import 'package:frontend_soderia/widgets/day_filter_buttons.dart';
import 'package:frontend_soderia/widgets/visit_card.dart';
import 'package:frontend_soderia/screens/todos_screen.dart';

class HomeScreen extends StatefulWidget {
  final String nombreUsuario;

  const HomeScreen({super.key, required this.nombreUsuario});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String filtroSeleccionado = 'Hoy';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Mock temporal (después vendrá de la API)
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

    // FIX: clave 'dia' sin tilde
    final visitasFiltradas = (filtroSeleccionado == 'Todos')
        ? todasLasVisitas
        : todasLasVisitas.where((v) => v['dia'] == filtroSeleccionado).toList();

    return Scaffold(
      // Fondo toma el background del theme
      backgroundColor: cs.background,
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: Row(
          children: [
            // Drawer persistente en tablet/escritorio
            if (MediaQuery.of(context).size.width >= 600) _buildDrawer(context),
            // Contenido principal
            Expanded(
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
                        color: cs.onBackground, // texto según tema
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Filtros con tu paleta (usa OutlinedButtons con tema)
                    DayFilterButtons(
                      onFilterChanged: (nuevoFiltro) {
                        setState(() => filtroSeleccionado = nuevoFiltro);

                        if (nuevoFiltro == 'Todos') {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TodosScreen(
                                nombreUsuario: widget.nombreUsuario,
                              ),
                            ),
                          );
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
                            // Si tu VisitCard acepta colores, ideal usar cs.surface / cs.onSurface
                          );
                        },
                      ),
                    ),
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

Widget _buildDrawer(BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  return Drawer(
    width: 260,
    backgroundColor: cs.surface, // blanco del tema
    child: ListView(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
      children: [
        Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: cs.onSurface, // negro del tema
          ),
        ),
        const SizedBox(height: 20),
        _buildMenuItem(context, Icons.home, 'Inicio'),
        _buildMenuItem(context, Icons.calendar_today, 'Ver calendario'),
        _buildMenuItem(context, Icons.bar_chart, 'Reportes'),
        _buildMenuItem(context, Icons.group_add, 'Agregar usuarios'),
        _buildMenuItem(context, Icons.person_add_alt_1, 'Agregar cliente'),
        const SizedBox(height: 8),
        const Divider(),
        _buildMenuItem(context, Icons.logout, 'Cerrar sesión'),
      ],
    ),
  );
}

Widget _buildMenuItem(BuildContext context, IconData icon, String text) {
  // Íconos y texto con AZUL de tu paleta
  return ListTile(
    leading: Icon(icon, color: AppColors.azul),
    title: Text(
      text,
      style: const TextStyle(
        color: AppColors.azul,
        fontWeight: FontWeight.w600,
      ),
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    onTap: () {
      // TODO: navegación
      Navigator.pop(context);
    },
    hoverColor: AppColors.celeste.withOpacity(0.10),
    selectedTileColor: AppColors.celeste.withOpacity(0.12),
  );
}
