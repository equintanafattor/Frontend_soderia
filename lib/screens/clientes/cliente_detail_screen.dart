// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/navigation/app_shell_actions.dart';
import 'package:frontend_soderia/models/cuenta.dart';
import 'package:frontend_soderia/services/cliente_service.dart';
import 'package:frontend_soderia/services/documento_service.dart';
import 'package:frontend_soderia/services/servicios_service.dart';
import 'package:frontend_soderia/services/medio_pago_service.dart';
import 'package:frontend_soderia/widgets/cliente/cliente_servicios_pendientes.dart';
import 'package:frontend_soderia/widgets/cliente/cliente_servicios_section.dart';
import 'package:frontend_soderia/widgets/cliente/cliente_cuentas_section.dart';
import 'package:frontend_soderia/widgets/cliente/cliente_pedidos_section.dart';
import 'package:frontend_soderia/widgets/cliente/cliente_historico_section.dart';
import 'package:frontend_soderia/widgets/cliente/cliente_comprobantes_section.dart';
import 'package:frontend_soderia/widgets/cliente/cliente_header_card.dart';
import 'package:frontend_soderia/widgets/cliente/cliente_datos_personales_section.dart';
import 'package:frontend_soderia/widgets/cliente/cliente_direcciones_section.dart';

class ClienteDetailScreen extends StatefulWidget {
  final int legajo;
  const ClienteDetailScreen({super.key, required this.legajo});

  @override
  State<ClienteDetailScreen> createState() => _ClienteDetailScreenState();
}

class _ClienteDetailScreenState extends State<ClienteDetailScreen> {
  final _service = ClienteService();
  late Future<_ClienteFullData> _future;
  bool _changed = false;
  final _serviciosService = ServiciosService();
  final _docService = DocumentoService();
  final _medioPagoService = MedioPagoService();

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<_ClienteFullData> _loadData() async {
    final detalle = await _service.obtenerDetalleCliente(widget.legajo);
    final pedidos = await _service.listarPedidosCliente(
      widget.legajo,
      limit: 10,
    );
    final historicos = await _service.listarHistoricoCliente(
      widget.legajo,
      limit: 10,
    );
    final servicios = await _serviciosService.listarServiciosCliente(
      widget.legajo,
    );

    return _ClienteFullData(
      detalle: detalle,
      pedidos: pedidos,
      historicos: historicos,
      servicios: servicios,
    );
  }

  void _reload() {
    _changed = true;
    setState(() {
      _future = _loadData();
    });
  }

  Future<void> _eliminar() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar cliente'),
        content: Text(
          '¿Seguro que querés eliminar al cliente ${widget.legajo}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await _service.borrarCliente(widget.legajo);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cliente eliminado')));
        Navigator.of(context).pop(true); // para que la lista refresque
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _changed);
        return false; // ⛔ evitamos el pop automático
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cliente'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final full = await _future;
                final data = full.detalle;

                final result = await AppShellActions.push(
                  context,
                  '/cliente/edit',
                  arguments: {'legajo': widget.legajo, 'data': data},
                );
                if (result == true && mounted) {
                  _changed = true;
                  _reload();
                }
              },
            ),
            IconButton(icon: const Icon(Icons.delete), onPressed: _eliminar),
          ],
        ),
        body: FutureBuilder<_ClienteFullData>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(child: Text('Error: ${snap.error}'));
            }
            if (!snap.hasData) {
              return const Center(child: Text('Sin datos'));
            }

            final full = snap.data!;
            final data = full.detalle;
            final servicios = full.servicios;

            ClienteServicioDto? servicioDispenserActivo;
            for (final s in servicios) {
              if (s.tipoServicio == 'ALQUILER_DISPENSER' && s.activo) {
                servicioDispenserActivo = s;
                break;
              }
            }

            final persona = (data['persona'] as Map?) ?? {};

            final nombre =
                '${persona['nombre'] ?? ''} ${persona['apellido'] ?? ''}'
                    .trim();
            final dni = (persona['dni'] ?? data['dni'] ?? '-').toString();
            final observacion = (data['observacion'] ?? '').toString();

            final cuentasRaw = (data['cuentas'] as List?) ?? const [];

            final cuentas = cuentasRaw
                .map((c) => Cuenta.fromJson(c as Map<String, dynamic>))
                .toList();

            final Cuenta? cuentaPrincipal = cuentas.isNotEmpty
                ? cuentas.first
                : null;

            final double deudaActual = cuentaPrincipal?.deuda ?? 0;
            final double saldoActual = cuentaPrincipal?.saldo ?? 0;

            final direcciones = (data['direcciones'] as List?) ?? const [];
            final telefonos = (data['telefonos'] as List?) ?? const [];
            final pedidos = full.pedidos;
            final phone = _telefonoParaWhatsappFrom(telefonos);
            final historicos = full.historicos;

            return Container(
              color: cs.surfaceVariant.withOpacity(0.2),
              child: ListView(
                padding: const EdgeInsets.all(16),

                children: [
                  ClienteServiciosPendientes(
                    legajo: widget.legajo,
                    serviciosService: _serviciosService,
                    medioPagoService: _medioPagoService,
                    cuentas: cuentas,
                    onChanged: _reload,
                  ),
                  ClienteServiciosSection(
                    legajo: widget.legajo,
                    servicios: servicios,
                    serviciosService: _serviciosService,
                    onChanged: _reload,
                  ),

                  // HEADER CARD
                  ClienteHeaderCard(
                    nombre: nombre,
                    legajo: widget.legajo,
                    dni: dni,
                  ),
                  const SizedBox(height: 16),

                  if (observacion.isNotEmpty)
                    _SectionCard(
                      title: 'Observaciones',
                      child: Text(observacion),
                    ),

                  // DATOS PERSONALES
                  ClienteDatosPersonalesSection(telefonos: telefonos),

                  // DIRECCIONES
                  ClienteDireccionesSection(direcciones: direcciones),

                  // CUENTA
                  ClienteCuentasSection(
                    legajo: widget.legajo,
                    nombreCliente: nombre,
                    cuentas: cuentas,
                    pedidos: pedidos,
                    onChanged: _reload,
                  ),

                  // PEDIDOS (desde endpoint aparte)
                  ClientePedidosSection(
                    pedidos: pedidos,
                    phone: phone,
                    documentoService: _docService,
                  ),

                  // COMPROBANTES
                  ClienteComprobantesSection(
                    legajo: widget.legajo,
                    telefonos: telefonos.cast<Map>(),
                  ),

                  // HISTÓRICO (desde endpoint aparte)
                  ClienteHistoricoSection(historicos: historicos),

                  const SizedBox(height: 24),

                  FilledButton.icon(
                    onPressed: cuentas.isEmpty
                        ? null
                        : () async {
                            final ok = await AppShellActions.push(
                              context,
                              '/pago',
                              arguments: {
                                'legajo': widget.legajo,
                                'id_empresa': 1,
                                'deuda': deudaActual,
                                'saldo': saldoActual,
                                'id_cuenta': cuentaPrincipal?.idCuenta,
                                'cuentas': cuentas,
                              },
                            );

                            if (ok == true && mounted) {
                              _reload();
                            }
                          },
                    icon: const Icon(Icons.payments),
                    label: const Text('Registrar pago'),
                  ),

                  const SizedBox(height: 8),

                  /* OutlinedButton.icon(
                    onPressed: () => _crearServicioDispenser(),
                    icon: const Icon(Icons.water_drop),
                    label: const Text('Crear servicio dispenser'),
                  ), */
                  const SizedBox(height: 8),

                  OutlinedButton.icon(
                    onPressed: () async {
                      final ok = await AppShellActions.push(
                        context,
                        '/venta',
                        arguments: {'legajo': widget.legajo},
                      );

                      if (ok == true && mounted) {
                        _reload();
                      }
                    },
                    icon: const Icon(Icons.point_of_sale),
                    label: const Text('Iniciar venta fuera de recorrido'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ClienteFullData {
  final Map<String, dynamic> detalle;
  final List<dynamic> pedidos;
  final List<dynamic> historicos;
  final List<ClienteServicioDto> servicios;

  _ClienteFullData({
    required this.detalle,
    required this.pedidos,
    required this.historicos,
    required this.servicios,
  });
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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


// HELPERS

// helper local (ponelo cerca de _toDouble o arriba del build)
String? _telefonoParaWhatsappFrom(List telefonos) {
  if (telefonos.isEmpty) return null;

  final principal = telefonos.firstWhere(
    (t) => (t as Map)['principal'] == true,
    orElse: () => {},
  );

  final raw =
      ((principal is Map && principal.isNotEmpty)
              ? principal['nro_telefono']
              : (telefonos.first as Map)['nro_telefono'])
          ?.toString();

  if (raw == null || raw.trim().isEmpty) return null;

  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('549')) return digits;
  if (digits.startsWith('54')) return '549${digits.substring(2)}';

  var d = digits;
  if (d.startsWith('0')) d = d.substring(1);
  if (d.startsWith('15')) d = d.substring(2);
  return '549$d';
}



