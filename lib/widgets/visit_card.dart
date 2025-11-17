import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/colors.dart';

class VisitCard extends StatelessWidget {
  final String nombre;
  final String direccion;
  final bool visitado;
  final String? turnoVisita; // 👈 nuevo
  final VoidCallback? onTap;

  const VisitCard({
    super.key,
    required this.nombre,
    required this.direccion,
    required this.visitado,
    this.turnoVisita, // 👈 nuevo
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final Color chipColor = visitado ? AppColors.verde : AppColors.celeste;
    final Color chipText = AppColors.blanco;
    final String chipLabel = visitado ? 'Visitado' : 'Pendiente';
    final IconData leadIcon = visitado ? Icons.check_circle : Icons.schedule;

    final String turnoLabel = (turnoVisita ?? '').trim();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surface, // fondo blanco del tema
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.bordeSuave),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Ícono de estado
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: chipColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(leadIcon, color: chipColor),
            ),
            const SizedBox(width: 12),

            // Nombre + turno + dirección
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre (título)
                  Text(
                    nombre,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Turno de visita (si viene)
                  if (turnoLabel.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: AppColors.grisTexto,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Turno $turnoLabel',
                          style: const TextStyle(
                            color: AppColors.grisTexto,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],

                  // Dirección (subtítulo) si no está vacía
                  if (direccion.isNotEmpty)
                    Row(
                      children: [
                        const Icon(
                          Icons.place,
                          size: 16,
                          color: AppColors.grisTexto,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            direccion,
                            style: const TextStyle(
                              color: AppColors.grisTexto,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: false,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Chip de estado
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: chipColor,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                chipLabel,
                style: TextStyle(
                  color: chipText,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
