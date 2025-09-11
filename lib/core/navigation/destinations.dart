import 'package:flutter/material.dart';

class AppDestination {
  final String label; 
  final IconData icon; 
  final String route; // util si usas rutas renombradas

  const AppDestination(this.label, this.icon, this.route);
}

const kDestinations = <AppDestination>[
    AppDestination('Inicio', Icons.home, '/home'),
    AppDestination('Calendario', Icons.calendar_today, '/calendar'),
    AppDestination('Reportes', Icons.bar_chart, '/reports'),
    AppDestination('Usuarios', Icons.group, '/users'),
    AppDestination('Clientes', Icons.person, '/clients'),
];