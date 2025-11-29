// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/navigation/app_shell_actions.dart';
import 'package:frontend_soderia/services/cliente_service.dart';

class ClienteDetailScreen extends StatefulWidget {
  final int legajo;
  const ClienteDetailScreen({super.key, required this.legajo});

  @override
  State<ClienteDetailScreen> createState() => _ClienteDetailScreenState();
}

class _ClienteDetailScreenState extends State<ClienteDetailScreen> {
  final _service = ClienteService();
  late Future<_ClienteFullData> _future;

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
    return _ClienteFullData(
      detalle: detalle,
      pedidos: pedidos,
      historicos: historicos,
    );
  }

  void _reload() {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cliente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final full = await _future;
              final data = full.detalle; // solo el detalle para el edit
              final result = await AppShellActions.push(
                context,
                '/cliente/edit',
                arguments: {'legajo': widget.legajo, 'data': data},
              );
              if (result != null && mounted) {
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
          final persona = (data['persona'] as Map?) ?? {};
          final nombre =
              '${persona['nombre'] ?? ''} ${persona['apellido'] ?? ''}'.trim();
          final dni = (persona['dni'] ?? data['dni'] ?? '-').toString();
          final observacion = (data['observacion'] ?? '').toString();

          final cuentas = (data['cuentas'] as List?) ?? const [];
          final direcciones = (data['direcciones'] as List?) ?? const [];
          final telefonos = (data['telefonos'] as List?) ?? const [];

          final pedidos = full.pedidos;
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
                  title: 'Cuenta',
                  child: cuentas.isEmpty
                      ? const Text('Sin cuenta')
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: cuentas.map((c0) {
                            final c = c0 as Map;
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              color: cs.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${c['tipo_de_cuenta'] ?? 'Cuenta'}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Saldo: ${c['saldo']}'),
                                    Text('Deuda: ${c['deuda']}'),
                                    Text('Bidones: ${c['numero_bidones']}'),
                                    if (c['estado'] != null)
                                      Text('Estado: ${c['estado']}'),
                                  ],
                                ),
                              ),
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
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.shopping_bag_outlined),
                              title: Text(
                                'Pedido #${p['id_pedido'] ?? ''}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text('${p['fecha'] ?? ''}'),
                              trailing: Text(
                                '${p['total'] ?? ''}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
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
              ],
            ),
          );
        },
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed: () {
              AppShellActions.push(
                context,
                '/venta',
                arguments: {'legajo': widget.legajo},
              );
            },
            icon: const Icon(Icons.point_of_sale),
            label: const Text('Iniciar venta fuera de recorrido'),
          ),
        ),
      ),
    );
  }
}

class _ClienteFullData {
  final Map<String, dynamic> detalle;
  final List<dynamic> pedidos;
  final List<dynamic> historicos;

  _ClienteFullData({
    required this.detalle,
    required this.pedidos,
    required this.historicos,
  });
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cs.surface,
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
