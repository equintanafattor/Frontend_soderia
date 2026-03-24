import 'package:flutter/material.dart';

/// Guarda el índice de pestaña activa del AppShell y permite cambiarlo globalmente.
class ShellState extends ValueNotifier<int> {
  ShellState(int value) : super(value);
  void selectTab(int index) => value = index; 
}

/// Instancia global (importala donde la necesites).
final shellState = ShellState(0);