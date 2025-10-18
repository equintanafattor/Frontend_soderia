// destinations.dart
import 'package:flutter/material.dart';

class AppDestination {
  final IconData icon;
  final String label;
  const AppDestination({required this.icon, required this.label});
}

const kDestinations = <AppDestination>[
  AppDestination(icon: Icons.home,            label: 'Inicio'),
  AppDestination(icon: Icons.checklist,       label: 'Tareas'),
  AppDestination(icon: Icons.bar_chart,       label: 'Reportes'),
  AppDestination(icon: Icons.people,          label: 'Usuarios'),
  AppDestination(icon: Icons.person_search,   label: 'Clientes'),
  AppDestination(icon: Icons.calendar_month,  label: 'Calendario'), // 👈 NUEVO
];

// Para no “adivinar” índices en otras pantallas:
const int kIndexInicio      = 0;
const int kIndexTareas      = 1;
const int kIndexReportes    = 2;
const int kIndexUsuarios    = 3;
const int kIndexClientes    = 4;
const int kIndexCalendario  = 5; // 👈 NUEVO
