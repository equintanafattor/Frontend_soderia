// lib/widgets/cliente/cliente_servicios_section.dart

// ignore_for_file: deprecated_member_use

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend_soderia/services/servicios_service.dart';

class ClienteServiciosSection extends StatelessWidget {
  final int legajo;
  final List<ClienteServicioDto> servicios;
  final ServiciosService serviciosService;
  final VoidCallback onChanged;

  const ClienteServiciosSection({
    super.key,
    required this.legajo,
    required this.servicios,
    required this.serviciosService,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    ClienteServicioDto? servicioDispenserActivo;
    for (final s in servicios) {
      if (s.tipoServicio == 'ALQUILER_DISPENSER' && s.activo) {
        servicioDispenserActivo = s;
        break;
      }
    }

    return _SectionCard(
      title: 'Servicios',
      child: servicioDispenserActivo == null
          ? _EmptyServiciosState(
              onCrearServicio: () async {
                final ok = await _showCrearServicioDispenserDialog(
                  context,
                  legajo: legajo,
                  serviciosService: serviciosService,
                );
                if (ok == true) {
                  onChanged();
                }
              },
            )
          : _ServicioDispenserActivoCard(
              servicio: servicioDispenserActivo,
              onEditarMonto: () async {
                final ok = await _showEditarMontoServicioDialog(
                  context,
                  servicio: servicioDispenserActivo!,
                  serviciosService: serviciosService,
                );
                if (ok == true) {
                  onChanged();
                }
              },
            ),
    );
  }
}

class _EmptyServiciosState extends StatelessWidget {
  final Future<void> Function() onCrearServicio;

  const _EmptyServiciosState({required this.onCrearServicio});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sin servicios activos',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Este cliente no tiene servicios asociados.',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => onCrearServicio(),
            icon: const Icon(Icons.water_drop),
            label: const Text('Crear alquiler dispenser'),
          ),
        ],
      ),
    );
  }
}

class _ServicioDispenserActivoCard extends StatelessWidget {
  final ClienteServicioDto servicio;
  final Future<void> Function() onEditarMonto;

  const _ServicioDispenserActivoCard({
    required this.servicio,
    required this.onEditarMonto,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.water_drop_outlined),
          title: const Text(
            'Alquiler dispenser',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            'Monto mensual: \$${servicio.montoMensual.toStringAsFixed(2)}\n'
            'Inicio: ${servicio.fechaInicio.toIso8601String().split('T').first}',
          ),
          trailing: const _EstadoChip(estado: 'ACTIVO'),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () => onEditarMonto(),
              icon: const Icon(Icons.edit),
              label: const Text('Editar monto'),
            ),
          ],
        ),
      ],
    );
  }
}

Future<bool?> _showCrearServicioDispenserDialog(
  BuildContext context, {
  required int legajo,
  required ServiciosService serviciosService,
}) async {
  final montoCtrl = TextEditingController();
  bool loading = false;

  return showDialog<bool>(
    context: context,
    builder: (dialogCtx) {
      return StatefulBuilder(
        builder: (dialogCtx, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Crear alquiler de dispenser'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: montoCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Monto mensual',
                      hintText: 'Ej: 10000',
                      border: OutlineInputBorder(),
                    ),
                    enabled: !loading,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'El servicio se creará con el período actual pendiente. El cobro se realiza después desde servicios pendientes.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: loading
                    ? null
                    : () => Navigator.of(dialogCtx).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: loading
                    ? null
                    : () async {
                        final montoText = montoCtrl.text.trim().replaceAll(
                          ',',
                          '.',
                        );
                        final monto = double.tryParse(montoText);

                        if (monto == null || monto <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Ingresá un monto válido'),
                            ),
                          );
                          return;
                        }

                        setStateDialog(() => loading = true);

                        try {
                          await serviciosService.crearAlquilerDispenser(
                            legajo: legajo,
                            montoMensual: monto,
                          );

                          if (!context.mounted) return;

                          Navigator.of(dialogCtx).pop(true);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Servicio creado correctamente ✅'),
                            ),
                          );
                        } on DioException catch (e) {
                          setStateDialog(() => loading = false);

                          if (!context.mounted) return;

                          String msg = 'No se pudo crear el servicio';
                          final data = e.response?.data;
                          if (data is Map && data['detail'] != null) {
                            msg = data['detail'].toString();
                          }

                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(msg)));
                        } catch (e) {
                          setStateDialog(() => loading = false);

                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error creando servicio: $e'),
                            ),
                          );
                        }
                      },
                child: loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Crear servicio'),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<bool?> _showEditarMontoServicioDialog(
  BuildContext context, {
  required ClienteServicioDto servicio,
  required ServiciosService serviciosService,
}) async {
  final montoCtrl = TextEditingController(
    text: servicio.montoMensual.toStringAsFixed(2),
  );
  bool actualizarPeriodos = true;
  bool loading = false;

  return showDialog<bool>(
    context: context,
    builder: (dialogCtx) {
      return StatefulBuilder(
        builder: (dialogCtx, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Actualizar monto del servicio'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: montoCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Nuevo monto mensual',
                      border: OutlineInputBorder(),
                    ),
                    enabled: !loading,
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: actualizarPeriodos,
                    onChanged: loading
                        ? null
                        : (v) => setStateDialog(
                            () => actualizarPeriodos = v ?? true,
                          ),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text('Actualizar períodos no pagados'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: loading
                    ? null
                    : () => Navigator.of(dialogCtx).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: loading
                    ? null
                    : () async {
                        final monto = double.tryParse(
                          montoCtrl.text.trim().replaceAll(',', '.'),
                        );

                        if (monto == null || monto <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Ingresá un monto válido'),
                            ),
                          );
                          return;
                        }

                        setStateDialog(() => loading = true);

                        try {
                          await serviciosService.actualizarMontoServicio(
                            idClienteServicio: servicio.idClienteServicio,
                            montoMensual: monto,
                            actualizarPeriodosNoPagados: actualizarPeriodos,
                          );

                          if (!context.mounted) return;

                          Navigator.of(dialogCtx).pop(true);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Monto actualizado correctamente ✅',
                              ),
                            ),
                          );
                        } on DioException catch (e) {
                          setStateDialog(() => loading = false);

                          if (!context.mounted) return;

                          String msg = 'No se pudo actualizar el monto';
                          final data = e.response?.data;
                          if (data is Map && data['detail'] != null) {
                            msg = data['detail'].toString();
                          }

                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(msg)));
                        } catch (e) {
                          setStateDialog(() => loading = false);

                          if (!context.mounted) return;

                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      },
                child: loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar'),
              ),
            ],
          );
        },
      );
    },
  );
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _EstadoChip extends StatelessWidget {
  final String estado;

  const _EstadoChip({required this.estado});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Color bg;
    Color fg;

    switch (estado) {
      case 'ACTIVO':
        bg = const Color(0xFFE7F7EE);
        fg = const Color(0xFF1B7F3A);
        break;
      case 'PENDIENTE':
        bg = const Color(0xFFFFF3CD);
        fg = const Color(0xFF7A5A00);
        break;
      case 'VENCIDO':
        bg = const Color(0xFFFFE5E5);
        fg = const Color(0xFFB00020);
        break;
      case 'PAGADO':
        bg = const Color(0xFFE7F7EE);
        fg = const Color(0xFF1B7F3A);
        break;
      default:
        bg = cs.surfaceVariant;
        fg = cs.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withOpacity(0.25)),
      ),
      child: Text(
        estado,
        style: TextStyle(fontWeight: FontWeight.w700, color: fg, fontSize: 12),
      ),
    );
  }
}
