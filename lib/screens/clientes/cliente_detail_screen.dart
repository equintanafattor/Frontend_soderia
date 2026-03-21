// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:frontend_soderia/core/navigation/app_shell_actions.dart';
import 'package:frontend_soderia/models/cuenta.dart';
import 'package:frontend_soderia/services/cliente_service.dart';
import 'package:frontend_soderia/utils/pedido_pdf.dart';
import 'package:frontend_soderia/utils/share_whatsapp.dart';
import 'package:printing/printing.dart';
import 'package:frontend_soderia/utils/estado_cuenta_pdf.dart';
import 'package:frontend_soderia/screens/clientes/cuenta/cliente_cuenta_add_screen.dart';
import 'package:frontend_soderia/services/documento_service.dart';
import 'package:frontend_soderia/utils/open_pdf.dart';
import 'package:frontend_soderia/utils/share_pdf.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:frontend_soderia/services/servicios_service.dart';
import '../../core/net/api_client.dart';
import 'package:frontend_soderia/services/medio_pago_service.dart';
import 'package:frontend_soderia/widgets/cliente/cliente_servicios_pendientes.dart';

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

  Future<void> _crearServicioDispenser() async {
    final montoCtrl = TextEditingController();
    bool loading = false;

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (dialogCtx, setStateDialog) {
            return AlertDialog(
              title: const Text('Crear alquiler de dispenser'),
              content: Column(
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
                    ),
                    enabled: !loading,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'El servicio se creará con el período actual pendiente. El cobro se realiza después desde servicios pendientes.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
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
                            await _serviciosService.crearAlquilerDispenser(
                              legajo: widget.legajo,
                              montoMensual: monto,
                            );

                            if (!mounted) return;

                            Navigator.of(dialogCtx).pop(true);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Servicio creado correctamente ✅',
                                ),
                              ),
                            );

                            _reload();
                          } on DioException catch (e) {
                            setStateDialog(() => loading = false);

                            if (!mounted) return;

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

                            if (!mounted) return;
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

    if (ok != true) return;
  }

  Future<void> _editarMontoServicio(ClienteServicioDto servicio) async {
    final montoCtrl = TextEditingController(
      text: servicio.montoMensual.toStringAsFixed(2),
    );
    bool actualizarPeriodos = true;
    bool loading = false;

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (dialogCtx, setStateDialog) {
            return AlertDialog(
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
                      : () => Navigator.of(dialogCtx).pop(),
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
                            await _serviciosService.actualizarMontoServicio(
                              idClienteServicio: servicio.idClienteServicio,
                              montoMensual: monto,
                              actualizarPeriodosNoPagados: actualizarPeriodos,
                            );

                            if (!mounted) return;

                            Navigator.of(dialogCtx).pop();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Monto actualizado correctamente ✅',
                                ),
                              ),
                            );

                            _reload();
                          } on DioException catch (e) {
                            setStateDialog(() => loading = false);

                            if (!mounted) return;

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

                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
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

  String _buildHistoricoSubtitle(Map h) {
    final obs = (h['observacion'] ?? '')?.toString() ?? '';
    final datos = h['datos'];

    if (datos is! Map) return obs;
    final cambios = datos['cambios'];
    if (cambios is! Map) return obs.isEmpty ? '' : obs;

    final List<String> lines = [];
    if (obs.isNotEmpty) {
      lines.add(obs);
    }

    // ========== PERSONA ==========
    final persona = cambios['persona'];
    if (persona is Map && persona['actualizados'] is Map) {
      final actualizados = persona['actualizados'] as Map;
      actualizados.forEach((campo, change) {
        if (change is Map) {
          final antes = change['antes'];
          final despues = change['despues'];
          lines.add('Persona.$campo: "$antes" → "$despues"');
        }
      });
    }

    // helper para obtener un "título" de cada item
    String _labelPrincipal(Map item, String tipo) {
      switch (tipo) {
        case 'direcciones':
          return (item['direccion'] ?? '')?.toString() ?? '';
        case 'telefonos':
          return (item['nro_telefono'] ?? '')?.toString() ?? '';
        case 'emails':
          return (item['mail'] ?? '')?.toString() ?? '';
        case 'cuentas':
          return (item['tipo_de_cuenta'] ?? '')?.toString() ?? '';
        default:
          return '';
      }
    }

    // helper genérico para colecciones 1–N con detalle
    void _appendColeccionDetalles(String key, String labelColeccion) {
      final col = cambios[key];
      if (col is! Map) return;

      final creados = (col['creados'] as List? ?? const []);
      final actualizados = (col['actualizados'] as List? ?? const []);
      final eliminados = (col['eliminados'] as List? ?? const []);

      // CREADOS
      for (final item in creados) {
        if (item is! Map) continue;
        final titulo = _labelPrincipal(item, key);
        if (titulo.isNotEmpty) {
          lines.add('$labelColeccion creado: $titulo');
        } else {
          lines.add('$labelColeccion creado');
        }
      }

      // ACTUALIZADOS
      for (final item in actualizados) {
        if (item is! Map) continue;
        final campos = item['campos'];
        if (campos is! Map) continue;
        final titulo = _labelPrincipal(item, key);
        final prefix = titulo.isNotEmpty
            ? '$labelColeccion ($titulo)'
            : labelColeccion;
        campos.forEach((campo, change) {
          if (change is Map) {
            final antes = change['antes'];
            final despues = change['despues'];
            lines.add('$prefix.$campo: "$antes" → "$despues"');
          }
        });
      }

      // ELIMINADOS
      for (final item in eliminados) {
        if (item is! Map) continue;
        final titulo = _labelPrincipal(item, key);
        final id = item.values.firstWhere((v) => v != null, orElse: () => null);
        if (titulo.isNotEmpty) {
          lines.add('$labelColeccion eliminado: $titulo');
        } else if (id != null) {
          lines.add('$labelColeccion eliminado (id=$id)');
        } else {
          lines.add('$labelColeccion eliminado');
        }
      }
    }

    // ========== COLECCIONES ==========
    _appendColeccionDetalles('direcciones', 'Dirección');
    _appendColeccionDetalles('telefonos', 'Teléfono');
    _appendColeccionDetalles('emails', 'Email');
    _appendColeccionDetalles('cuentas', 'Cuenta');

    // ========== DÍAS DE VISITA ==========
    final dias = cambios['dias_semanas'];
    if (dias is Map) {
      final antes = dias['antes'] as List? ?? const [];
      final despues = dias['despues'] as List? ?? const [];

      String _fmtDia(Map d) {
        final idDia = d['id_dia'];
        final turno = d['turno_visita'] ?? '';
        final orden = d['orden'];
        final base = 'día $idDia';
        final turnoTxt = turno.toString().isEmpty ? '' : ' ($turno)';
        final ordTxt = orden == null ? '' : ' [orden $orden]';
        return base + turnoTxt + ordTxt;
      }

      if (antes.isEmpty && despues.isNotEmpty) {
        lines.add(
          'Días de visita asignados: ' +
              despues.whereType<Map>().map(_fmtDia).join(', '),
        );
      } else if (antes.isNotEmpty && despues.isEmpty) {
        lines.add('Días de visita eliminados');
      } else if (antes.isNotEmpty || despues.isNotEmpty) {
        lines.add('Días de visita:');
        if (antes.isNotEmpty) {
          lines.add(
            '  Antes: ' + antes.whereType<Map>().map(_fmtDia).join(', '),
          );
        }
        if (despues.isNotEmpty) {
          lines.add(
            '  Después: ' + despues.whereType<Map>().map(_fmtDia).join(', '),
          );
        }
      }
    }

    return lines.join('\n');
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

            String _iniciales() {
              if (nombre.isNotEmpty) {
                final partes = nombre.split(' ');
                if (partes.length >= 2) {
                  return (partes[0][0] + partes[1][0]).toUpperCase();
                }
                return partes[0][0].toUpperCase();
              }
              return '?';
            }

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
                  _SectionCard(
                    title: 'Servicios',
                    child: servicioDispenserActivo == null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Sin servicios activos'),
                              const SizedBox(height: 8),
                              /* OutlinedButton.icon(
                                onPressed: () => _crearServicioDispenser(),
                                icon: const Icon(Icons.water_drop),
                                label: const Text('Crear alquiler dispenser'),
                              ), */
                            ],
                          )
                        : Column(
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
                                  'Monto mensual: \$${servicioDispenserActivo.montoMensual.toStringAsFixed(2)}\n'
                                  'Inicio: ${servicioDispenserActivo.fechaInicio.toIso8601String().split('T').first}',
                                ),
                                trailing: _EstadoChip(estado: 'ACTIVO'),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () => _editarMontoServicio(
                                      servicioDispenserActivo!,
                                    ),
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Editar monto'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),

                  // HEADER CARD
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            child: Text(
                              _iniciales(),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nombre.isEmpty ? 'Sin nombre' : nombre,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    _InfoChip(
                                      label: 'Legajo',
                                      value: widget.legajo.toString(),
                                    ),
                                    _InfoChip(label: 'DNI', value: dni),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (observacion.isNotEmpty)
                    _SectionCard(
                      title: 'Observaciones',
                      child: Text(observacion),
                    ),

                  // DATOS PERSONALES
                  _SectionCard(
                    title: 'Datos personales',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (telefonos.isEmpty)
                          const Text('Sin teléfonos')
                        else
                          ...telefonos.map((t0) {
                            final t = t0 as Map;
                            return ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.phone),
                              title: Text('${t['nro_telefono'] ?? ''}'.trim()),
                              subtitle:
                                  (t['observacion'] != null &&
                                      (t['observacion'] as String).isNotEmpty)
                                  ? Text('${t['observacion']}')
                                  : null,
                              trailing:
                                  (t['estado'] != null &&
                                      (t['estado'] as String).isNotEmpty)
                                  ? Text('${t['estado']}')
                                  : null,
                            );
                          }),
                      ],
                    ),
                  ),

                  // DIRECCIONES
                  _SectionCard(
                    title: 'Direcciones',
                    child: direcciones.isEmpty
                        ? const Text('Sin direcciones')
                        : Column(
                            children: direcciones.map((d0) {
                              final d = d0 as Map;
                              final entre =
                                  d['entre_calle1'] != null &&
                                      (d['entre_calle1'] as String).isNotEmpty
                                  ? 'Entre ${d['entre_calle1']} y ${d['entre_calle2'] ?? ''}'
                                  : null;
                              final sub = [d['localidad'], d['zona'], entre]
                                  .whereType<String>()
                                  .where((s) => s.isNotEmpty)
                                  .join(' · ');
                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.location_on_outlined),
                                title: Text('${d['direccion'] ?? '-'}'),
                                subtitle: sub.isEmpty ? null : Text(sub),
                              );
                            }).toList(),
                          ),
                  ),

                  // CUENTA
                  _SectionCard(
                    title: 'Cuentas',
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      tooltip: 'Crear nueva cuenta',
                      onPressed: () async {
                        final ok = await AppShellActions.push(
                          context,
                          '/cliente/cuenta/new',
                          arguments: {'legajo': widget.legajo},
                        );

                        if (ok == true && mounted) {
                          _changed = true;
                          _reload();
                        }
                      },
                    ),
                    child: cuentas.isEmpty
                        ? const Text('Sin cuentas')
                        : Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: cuentas.map((c) {
                              final tipo =
                                  (c.tipoDeCuenta != null &&
                                      c.tipoDeCuenta!.isNotEmpty)
                                  ? c.tipoDeCuenta!
                                  : 'Cuenta';

                              return _CuentaMiniCard(
                                tipo: tipo,
                                saldo: c.saldo,
                                deuda: c.deuda,
                                bidones: c.numeroBidones,
                                estado: c.estado,
                                onPdf: () async {
                                  final ultimos = pedidos
                                      .map<Map<String, dynamic>>((p0) {
                                        final p = Map<String, dynamic>.from(
                                          p0 as Map,
                                        );
                                        return {
                                          'fecha': p['fecha'],
                                          'id_pedido': p['id_pedido'],
                                          'total': _toDouble(p['total']),
                                        };
                                      })
                                      .toList();

                                  final pdfBytes = await generarEstadoCuentaPDF(
                                    nombreCliente: nombre,
                                    legajo: widget.legajo.toString(),
                                    fecha: DateTime.now(),
                                    deuda: c.deuda,
                                    saldoAFavor: c.saldo,
                                    ultimosPedidos: ultimos,
                                  );

                                  await Printing.layoutPdf(
                                    onLayout: (_) async => pdfBytes,
                                  );
                                },
                              );
                            }).toList(),
                          ),
                  ),

                  // PEDIDOS (desde endpoint aparte)
                  _SectionCard(
                    title: 'Últimos pedidos',
                    child: pedidos.isEmpty
                        ? const Text('Sin pedidos')
                        : Column(
                            children: pedidos.map((p0) {
                              final p = p0 as Map;
                              final id = (p['id_pedido'] as num?)?.toInt();
                              final fecha = (p['fecha'] ?? '').toString();

                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(
                                  Icons.shopping_bag_outlined,
                                ),
                                title: Text(
                                  id == null ? 'Pedido' : 'Pedido #$id',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(fecha),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (v) async {
                                    if (id == null) return;

                                    try {
                                      // genera (o devuelve existente)
                                      final doc = await _docService
                                          .generarComprobantePedido(id);
                                      final url =
                                          '${ApiClient.dio.options.baseUrl}${doc['url']}';

                                      if (v == 'ver') {
                                        await openPdf(url);
                                        return;
                                      }

                                      if (v == 'whatsapp') {
                                        if (phone == null) {
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'El cliente no tiene teléfono cargado',
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        await shareWhatsApp(
                                          phone: phone,
                                          message:
                                              'Hola!\nTe comparto el comprobante del pedido #$id:\n\n$url',
                                        );
                                      }
                                    } catch (e) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text('Error: $e')),
                                      );
                                    }
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: 'ver',
                                      child: Text('Ver comprobante'),
                                    ),
                                    PopupMenuItem(
                                      value: 'whatsapp',
                                      child: Text(
                                        'Compartir link por WhatsApp',
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ),

                  _SectionCard(
                    title: 'Comprobantes',
                    child: _ComprobantesClienteSection(
                      legajo: widget.legajo,
                      telefonos: telefonos.cast<Map>(),
                    ),
                  ),

                  // HISTÓRICO (desde endpoint aparte)
                  _SectionCard(
                    title: 'Histórico',
                    child: historicos.isEmpty
                        ? const Text('Sin eventos')
                        : Column(
                            children: historicos.map((h0) {
                              final h = h0 as Map;
                              final ev = h['evento'];
                              final evNombre = ev is Map
                                  ? (ev['nombre'] ?? 'Evento')
                                  : (ev?.toString() ?? 'Evento');

                              final subtitleText = _buildHistoricoSubtitle(h);

                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.history),
                                title: Text(evNombre),
                                subtitle: subtitleText.isEmpty
                                    ? null
                                    : Text(
                                        subtitleText,
                                        maxLines: 6,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                trailing: Text('${h['fecha'] ?? ''}'),
                              );
                            }).toList(),
                          ),
                  ),

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

                  OutlinedButton.icon(
                    onPressed: () => _crearServicioDispenser(),
                    icon: const Icon(Icons.water_drop),
                    label: const Text('Crear servicio dispenser'),
                  ),

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

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 11,
              color: cs.onPrimaryContainer.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              color: cs.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CuentaMiniCard extends StatelessWidget {
  final String tipo;
  final dynamic saldo;
  final dynamic deuda;
  final dynamic bidones;
  final dynamic estado;
  final VoidCallback onPdf;

  const _CuentaMiniCard({
    required this.tipo,
    required this.saldo,
    required this.deuda,
    required this.bidones,
    required this.estado,
    required this.onPdf,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: 240, // 👈 clave para que entren varias por fila
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        color: cs.surface,
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TÍTULO
              Text(
                tipo,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 6),
              Text('Deuda: ${deuda ?? 0}'),
              Text('Saldo: ${saldo ?? 0}'),
              Text('Bidones: ${bidones ?? 0}'),

              if (estado != null && estado.toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Estado: $estado',
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                ),

              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  tooltip: 'Estado de cuenta',
                  onPressed: onPdf,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComprobantesClienteSection extends StatefulWidget {
  final int legajo;
  final List<Map> telefonos;

  const _ComprobantesClienteSection({
    required this.legajo,
    required this.telefonos,
  });

  @override
  State<_ComprobantesClienteSection> createState() =>
      _ComprobantesClienteSectionState();
}

class _ComprobantesClienteSectionState
    extends State<_ComprobantesClienteSection> {
  final _service = DocumentoService();
  late Future<List<Map<String, dynamic>>> _futureDocs;

  @override
  void initState() {
    super.initState();
    _futureDocs = _service.listarPorCliente(widget.legajo);
  }

  // Si querés refrescar manualmente:
  void _refresh() {
    setState(() {
      _futureDocs = _service.listarPorCliente(widget.legajo);
    });
  }

  String? _telefonoParaWhatsapp() {
    if (widget.telefonos.isEmpty) return null;

    final principal = widget.telefonos.firstWhere(
      (t) => t['principal'] == true,
      orElse: () => {},
    );

    final raw =
        (principal.isNotEmpty
                ? principal['nro_telefono']
                : widget.telefonos.first['nro_telefono'])
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

  @override
  Widget build(BuildContext context) {
    final phone = _telefonoParaWhatsapp();

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _futureDocs,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(),
          );
        }

        if (snap.hasError) {
          return const Text('Error cargando comprobantes');
        }

        final docs = snap.data ?? [];
        final comprobantes = docs
            .where((d) => d['tipo_archivo'] == 'COMPROBANTE_PAGO')
            .toList();

        if (comprobantes.isEmpty) {
          return const Text('Sin comprobantes registrados');
        }

        return Column(
          children: comprobantes.map((d) {
            final fecha = d['fecha']?.toString().split('T').first ?? '';
            final url = '${ApiClient.dio.options.baseUrl}${d['url']}';

            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.picture_as_pdf),
              title: Text(d['nombre_archivo']),
              subtitle: Text(fecha),
              trailing: PopupMenuButton<String>(
                onSelected: (v) async {
                  if (v == 'ver') {
                    await openPdf(url);
                    return;
                  }

                  if (v == 'whatsapp') {
                    if (phone == null) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('El cliente no tiene teléfono cargado'),
                        ),
                      );
                      return;
                    }

                    // ✅ WEB: solo link
                    if (kIsWeb) {
                      await shareWhatsApp(
                        phone: phone,
                        message:
                            'Hola! \nTe comparto el comprobante de pago:\n\n$url',
                      );
                      return;
                    }

                    // ✅ MOBILE: acá iría adjunto (cuando lo pruebes en Android/iOS)
                    // await sharePdfFromUrlPrinting(url: url, filename: d['nombre_archivo']);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'ver',
                    child: Text('Ver comprobante'),
                  ),
                  PopupMenuItem(
                    value: 'whatsapp',
                    child: Text(
                      kIsWeb
                          ? 'Compartir link por WhatsApp'
                          : 'Compartir PDF por WhatsApp',
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
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

double _toDouble(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  if (v is String) {
    return double.tryParse(v.replaceAll(',', '.')) ?? 0;
  }
  return 0;
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
      case 'VENCIDO':
        bg = const Color(0xFFFFE5E5);
        fg = const Color(0xFFB00020);
        break;
      case 'PENDIENTE':
        bg = const Color(0xFFFFF3CD);
        fg = const Color(0xFF7A5A00);
        break;
      case 'PAGADO':
        bg = const Color(0xFFE7F7EE);
        fg = const Color(0xFF1B7F3A);
        break;
      case 'ACTIVO':
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
