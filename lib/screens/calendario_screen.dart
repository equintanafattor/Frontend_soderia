import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/colors.dart'; // ajustá la ruta si hace falta

class CalendarioScreen extends StatelessWidget {
  const CalendarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final meses = const [
      'Enero','Febrero','Marzo','Abril','Mayo','Junio',
      'Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'
    ];

    return Scaffold(
      backgroundColor: AppColors.fondoSuave,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Hola, Gastón!",
                style: TextStyle(
                  color: AppColors.azul,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Seleccioná un mes o buscá por cliente o fecha",
                style: TextStyle(color: AppColors.grisTexto, fontSize: 14),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: AppColors.azul, size: 28),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.blanco,
                      shape: const CircleBorder(),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Día, mes o cliente...',
                          hintStyle: const TextStyle(color: AppColors.grisTexto),
                          prefixIcon: const Icon(Icons.search, color: AppColors.grisTexto),
                          filled: true,
                          fillColor: AppColors.blanco,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40),
                            borderSide: const BorderSide(color: AppColors.bordeSuave),
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {/* abrir alta */},
                    icon: const Icon(Icons.add, color: AppColors.blanco),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.verde,
                      shape: const CircleBorder(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(color: AppColors.bordeSuave, thickness: 1),
              const SizedBox(height: 12),

              // ---------- Grid responsive ----------
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Ancho ideal por tarjeta (podés ajustarlo)
                    const minTileWidth = 260.0;
                    // Al menos 2 columnas, y tantas como quepan
                    final crossAxisCount = math.max(2, (constraints.maxWidth / minTileWidth).floor());
                    // Ajuste de relación ancho/alto para mantener proporciones
                    final childAspectRatio = _calcAspectRatio(constraints.maxWidth, crossAxisCount);

                    return GridView.builder(
                      itemCount: meses.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: childAspectRatio,
                      ),
                      itemBuilder: (_, i) => _MesCard(
                        nombre: meses[i],
                        color: _mesColor(i),
                        onTap: () {
                          // TODO: navegar al detalle del mes i
                        },
                      ),
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

  // Colores alternados en la grilla (mismo family que tu azul)
  static Color _mesColor(int i) {
    const shades = [
      AppColors.azul,
      Color(0xFF1E3A55),
      Color(0xFF2C4A63),
      Color(0xFF375C78),
      Color(0xFF436B8B),
      Color(0xFF517CA0),
    ];
    return shades[i % shades.length];
  }

  // Mantiene una altura cómoda según columnas y ancho disponible
  static double _calcAspectRatio(double maxWidth, int cols) {
    final tileWidth = (maxWidth - (12.0 * (cols - 1))) / cols;
    // Alto buscado ~ 180–220 px
    final desiredHeight = 200.0;
    return tileWidth / desiredHeight;
  }
}

class _MesCard extends StatelessWidget {
  final String nombre;
  final Color color;
  final VoidCallback onTap;

  const _MesCard({
    required this.nombre,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            SizedBox(height: 4),
            Text(
              // nombre del mes
              '',
              key: ValueKey('mes-nombre'), // evita warnings de const
            ),
          ],
        ),
      ),
    );
  }
}

