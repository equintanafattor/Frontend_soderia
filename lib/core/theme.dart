import 'package:flutter/material.dart';
import 'colors.dart';

final ThemeData soderiaTheme = ThemeData(
  useMaterial3: true,

  // Esquema principal (Material 3)
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.azul,            // Botones principales, AppBar
    onPrimary: AppColors.blanco,
    secondary: AppColors.verde,         // Accentos (chips, toggles)
    onSecondary: AppColors.blanco,
    tertiary: AppColors.celeste,        // Llamados de atención / info
    onTertiary: AppColors.negro,

    surface: AppColors.blanco,          // Cards, sheets
    onSurface: AppColors.negro,
    background: AppColors.fondoSuave,   // Fondo general de pantallas
    onBackground: AppColors.negro,

    error: const Color(0xFFB00020),
    onError: AppColors.blanco,
  ),

  scaffoldBackgroundColor: AppColors.fondoSuave,

  appBarTheme: const AppBarTheme(
    elevation: 0,
    centerTitle: false,
  ),

  textTheme: const TextTheme(
    headlineMedium: TextStyle(fontWeight: FontWeight.w700),
    titleMedium: TextStyle(fontWeight: FontWeight.w600),
    bodyMedium: TextStyle(height: 1.2),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.azul,
      foregroundColor: AppColors.blanco,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.azul,
      side: const BorderSide(color: AppColors.azul, width: 1.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    ),
  ),

  cardTheme: CardThemeData(
    color: AppColors.blanco,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    surfaceTintColor: AppColors.blanco,
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.blanco,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.bordeSuave),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.bordeSuave),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.celeste, width: 2),
    ),
    labelStyle: const TextStyle(color: AppColors.grisTexto),
  ),
);
