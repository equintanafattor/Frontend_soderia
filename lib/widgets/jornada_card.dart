import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend_soderia/core/colors.dart'; // [PALETA] usamos tu paleta

/// Tarjeta que muestra una jornada de reparto:
/// - Columna izquierda con la fecha (día semana / día / mes)
/// - Centro con dos columnas de nombres (pares / impares)
/// - Tercera columna (derecha) reservada para el texto "X más..."
/// - Botón flotante "+" fijo abajo a la derecha
///
/// Decisiones de layout:
/// - La tercera columna tiene **ancho fijo** para que TODAS las filas
///   (no solo la primera) reserven el mismo espacio ⇒ las dos columnas
///   de nombres quedan perfectamente alineadas verticalmente.
/// - En cada fila de nombres se usa `CrossAxisAlignment.baseline` para
///   alinear los textos por línea base tipográfica (evita saltos por
///   mayúsculas/ascendentes).
///
/// [TIP] Este widget es “presentacional”; expone props para reusar en diferentes pantallas.
class JornadaCard extends StatelessWidget {
  /// Fecha que se renderiza en el bloque de la izquierda.
  final DateTime fecha;

  /// Lista completa de nombres para mostrar; se muestran hasta [maxVisibles]
  /// (repartidos en dos columnas), y el resto se indica como "X más...".
  final List<String> nombres;

  /// Callback del botón "+" (ej.: abrir diálogo para agregar cliente a este día).
  final VoidCallback? onAddPressed;

  /// Cantidad máxima de nombres visibles (se reparten en dos columnas).
  final int maxVisibles;

  /// Ancho de la tercera columna (derecha) donde va "X más...".
  /// Mantener constante en TODAS las filas para conservar alineación.
  final double colRestantesWidth;

  const JornadaCard({
    super.key,
    required this.fecha,
    required this.nombres,
    this.onAddPressed,
    this.maxVisibles = 6,
    this.colRestantesWidth = 120.0,
  });

  @override
  Widget build(BuildContext context) {
    // Formateo de fecha (en español Argentina)
    final diaSemana = DateFormat.E('es_AR').format(fecha).toUpperCase();
    final numeroDia = fecha.day.toString();
    final mes = DateFormat.MMM('es_AR').format(fecha).toUpperCase();

    // [RESPONSIVE] Ajustes sutiles para tablet vs. móvil/web angosto.
    final w = MediaQuery.of(context).size.width;
    final thirdW = w < 700 ? (colRestantesWidth - 30) : colRestantesWidth;
    final numeroSize = w < 700 ? 36.0 : 44.0;

    // Tomamos hasta [maxVisibles] nombres visibles y calculamos cuántos quedan.
    final visibles = nombres.take(maxVisibles).toList();
    final restantes = nombres.length - visibles.length;

    // Separar los visibles en dos columnas intercaladas: pares / impares.
    final columna1 = <String>[];
    final columna2 = <String>[];
    for (int i = 0; i < visibles.length; i++) {
      (i.isEven ? columna1 : columna2).add(visibles[i]);
    }

    // Generar las filas 2..n de nombres (sin el "X más...", pero
    // reservando el mismo ancho de la 3ª columna para mantener alineación).
    final filasRestantes = List<Widget>.generate(
      (columna1.length - 1).clamp(0, columna1.length),
      (i) {
        final idx = i + 1;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 40),
          child: Row(
            // Alineación por línea base tipográfica en ambas columnas de texto
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(child: _nombre(columna1[idx])),
              Expanded(
                child: (columna2.length > idx) ? _nombre(columna2[idx]) : const SizedBox(),
              ),
              // Placeholder de ancho fijo para la 3ª columna
              SizedBox(width: thirdW),
            ],
          ),
        );
      },
    );

    // Contenedor principal (fondo y esquinas redondeadas).
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.azul, // [PALETA] fondo azul #274F6E
        borderRadius: BorderRadius.circular(28),
      ),
      // Stack para poder "pegar" el botón + abajo a la derecha
      child: Stack(
        children: [
          // Fila principal: fecha | separador | (nombres + tercera columna)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 📅 Bloque de fecha (izquierda)
              SizedBox(
                width: 70,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(diaSemana, style: _estiloFechaTexto()),
                    Text(numeroDia, style: _estiloFechaNumero(numeroSize)),
                    Text(mes, style: _estiloFechaTexto()),
                  ],
                ),
              ),

              // Separador vertical entre fecha y nombres
              Container(
                width: 1,
                height: 90,
                color: AppColors.blanco.withOpacity(0.6), // [PALETA]
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),

              // 👥 Bloque central: dos columnas de nombres + tercera columna fija
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // --- Fila 1: dos nombres + "X más..." ---
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 40),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(child: columna1.isNotEmpty ? _nombre(columna1[0]) : const SizedBox()),
                          Expanded(child: columna2.isNotEmpty ? _nombre(columna2[0]) : const SizedBox()),
                          // Tercera columna con ancho fijo (muestra "X más..." si aplica)
                          SizedBox(
                            width: thirdW,
                            child: (restantes > 0)
                                ? Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      _restantesLabel(restantes),
                                      style: _estiloNombre().copyWith(
                                        color: AppColors.celeste, // [PALETA] “más…” en celeste
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),

                    // --- Filas 2..n: mismos anchos, sin texto en 3ª columna ---
                    ...filasRestantes,
                  ],
                ),
              ),
            ],
          ),

          // ➕ Botón fijo abajo a la derecha (no afecta el layout de las columnas)
          Positioned(
            right: 4,
            // [UX] Respetar SafeArea en móvil para no pisar el gesto de sistema.
            bottom: 4 + MediaQuery.of(context).padding.bottom,
            child: IconButton(
              iconSize: 28,
              splashRadius: 22,
              icon: const Icon(Icons.add_circle_outline, color: Colors.white), // [PALETA]
              onPressed: onAddPressed,
              tooltip: 'Agregar cliente a esta jornada',
            ),
          ),
        ],
      ),
    );
  }

  // ===== Estilos / helpers =====

  /// Títulos "JUE / MAY" (bloque fecha, arriba y abajo)
  static TextStyle _estiloFechaTexto() => const TextStyle(
        color: Colors.white, // [PALETA]
        fontWeight: FontWeight.bold,
        fontSize: 20,
      );

  /// Número grande del día (bloque fecha, centro)
  static TextStyle _estiloFechaNumero(double size) => TextStyle(
        fontSize: size, // [RESPONSIVE] ajustable segun ancho
        color: Colors.white, // [PALETA]
        fontWeight: FontWeight.bold,
      );

  /// Estilo de los nombres (ambas columnas)
  static TextStyle _estiloNombre() => const TextStyle(
        color: Colors.white, // [PALETA]
        fontWeight: FontWeight.w500,
        fontSize: 14.0,
      );

  /// [TIP] Nombres largos: no romper layout ni saltar de línea.
  Widget _nombre(String text) => Text(
        text,
        style: _estiloNombre(),
        overflow: TextOverflow.ellipsis,
        softWrap: false,
      );

  /// [TIP] Pluralización correcta para el texto de “más…”
  String _restantesLabel(int n) => n == 1 ? '1 más…' : '$n más…';
}


