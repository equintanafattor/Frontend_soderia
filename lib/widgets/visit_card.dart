import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/colors.dart';
import 'package:frontend_soderia/core/enums/estado_visita.dart';

class VisitCard extends StatelessWidget {
  final String nombre;
  final String direccion;
  final EstadoVisita estado;
  final String? turnoVisita;
  final VoidCallback? onTap;

  const VisitCard({
    super.key,
    required this.nombre,
    required this.direccion,
    required this.estado,
    this.turnoVisita,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // ===== Derivamos UI desde el estado =====
    late final Color chipColor;
    late final String chipLabel;
    late final IconData leadIcon;

    switch (estado) {
      case EstadoVisita.visitado:
        chipColor = AppColors.verde;
        chipLabel = 'Visitado';
        leadIcon = Icons.check_circle;
        break;

      case EstadoVisita.noCompro:
        chipColor = Colors.grey;
        chipLabel = 'No compró';
        leadIcon = Icons.close;
        break;

      case EstadoVisita.postergado:
        chipColor = Colors.orange;
        chipLabel = 'Postergado';
        leadIcon = Icons.schedule;
        break;

      case EstadoVisita.pendiente:
      default:
        chipColor = AppColors.celeste;
        chipLabel = 'Pendiente';
        leadIcon = Icons.hourglass_empty;
        break;
    }

    final String turnoLabel = (turnoVisita ?? '').trim();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.bordeSuave),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ===== Ícono de estado =====
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: chipColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(leadIcon, color: chipColor),
            ),
            const SizedBox(width: 12),

            // ===== Nombre + turno + dirección =====
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre
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

                  // Turno (si existe)
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],

                  // Dirección
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
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // ===== Chip de estado =====
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: chipColor,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                chipLabel,
                style: const TextStyle(
                  color: AppColors.blanco,
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

