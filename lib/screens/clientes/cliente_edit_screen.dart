// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:frontend_soderia/services/cliente_service.dart';
import 'package:frontend_soderia/widgets/common/frecuencia_modal.dart';


class ClienteEditScreen extends StatefulWidget {
  final int legajo;
  final Map<String, dynamic> data;

  const ClienteEditScreen({
    super.key,
    required this.legajo,
    required this.data,
  });

  @override
  State<ClienteEditScreen> createState() => _ClienteEditScreenState();
}

class _ClienteEditScreenState extends State<ClienteEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ClienteService();

  late TextEditingController _nombreCtrl;
  late TextEditingController _apellidoCtrl;
  late TextEditingController _dniCtrl;
  late TextEditingController _observacionCtrl;

  // Listas editables
  final List<_DireccionFormData> _direcciones = [];
  final List<_TelefonoFormData> _telefonos = [];
  final List<_EmailFormData> _emails = [];

  final Map<String, Map<String, dynamic>> _frecuenciaConfig = {};

  // Frecuencia (días y turno)
  final Set<String> _diasSeleccionados = {}; // 'lun','mar',...
  String? _turnoVisita; // 'manana','tarde','noche', null
  static const Map<int, String> _codigoDiaPorId = {
    1: 'lun',
    2: 'mar',
    3: 'mie',
    4: 'jue',
    5: 'vie',
    6: 'sab',
    7: 'dom',
  };

  static const Map<String, int> _idDiaPorCodigo = {
    'lun': 1,
    'mar': 2,
    'mie': 3,
    'jue': 4,
    'vie': 5,
    'sab': 6,
    'dom': 7,
  };

  bool _saving = false;

  Future<void> _agregarDiaConConfig(String dia) async {
    final idDia = _idDiaPorCodigo[dia];
    if (idDia == null) return;

    // Traer clientes del día (para "después de")
    List<Map<String, dynamic>> clientesDelDia = [];
    try {
      final list = await _service.listarClientesPorIdDia(idDia);
      clientesDelDia = List<Map<String, dynamic>>.from(list);
    } catch (_) {}

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => FrecuenciaModal(
        idDia: idDia,
        clientesDelDia: clientesDelDia,
        onConfirm: (modo, turno, refCliente) {
          _frecuenciaConfig[dia] = {
            'modo': modo,
            'turno': turno,
            'ref': refCliente,
          };
        },
      ),
    );

    if (confirmed == true) {
      setState(() => _diasSeleccionados.add(dia));
    }
  }

  @override
  void initState() {
    super.initState();

    // Persona
    final persona = (widget.data['persona'] as Map?) ?? {};
    _nombreCtrl = TextEditingController(text: persona['nombre'] ?? '');
    _apellidoCtrl = TextEditingController(text: persona['apellido'] ?? '');
    _dniCtrl = TextEditingController(
      text: (persona['dni'] ?? widget.data['dni'] ?? '').toString(),
    );
    _observacionCtrl = TextEditingController(
      text: widget.data['observacion']?.toString() ?? '',
    );

    // Direcciones
    final direcciones = (widget.data['direcciones'] as List?) ?? const [];
    if (direcciones.isEmpty) {
      _direcciones.add(_DireccionFormData.empty());
    } else {
      for (final d0 in direcciones) {
        final d = d0 as Map;
        _direcciones.add(_DireccionFormData.fromMap(d));
      }
    }

    // Teléfonos
    final telefonos = (widget.data['telefonos'] as List?) ?? const [];
    if (telefonos.isEmpty) {
      _telefonos.add(_TelefonoFormData.empty());
    } else {
      for (final t0 in telefonos) {
        final t = t0 as Map;
        _telefonos.add(_TelefonoFormData.fromMap(t));
      }
    }

    // Emails
    final emails = (widget.data['emails'] as List?) ?? const [];
    if (emails.isEmpty) {
      _emails.add(_EmailFormData.empty());
    } else {
      for (final e0 in emails) {
        final e = e0 as Map;
        _emails.add(_EmailFormData.fromMap(e));
      }
    }

    // ===== Frecuencia (días + turno) =====

    // 1) Intentar usar dias_visita si viene (hoy viene vacío, pero lo soportamos igual)
    final diasVisita = widget.data['dias_visita'];
    if (diasVisita is List) {
      for (final d in diasVisita) {
        if (d is String) {
          _diasSeleccionados.add(d); // ej: "lun"
        } else if (d is Map && d['value'] is String) {
          _diasSeleccionados.add((d['value'] as String).toLowerCase());
        }
      }
    }

    // 2) Si no vino nada en dias_visita, usamos dias_semanas con id_dia
    if (_diasSeleccionados.isEmpty) {
      final diasSemanas = widget.data['dias_semanas'];
      if (diasSemanas is List) {
        for (final row in diasSemanas) {
          if (row is! Map) continue;

          // id_dia -> 'lun','mar',...
          final idDia = row['id_dia'];
          if (idDia is int) {
            final code = _codigoDiaPorId[idDia];
            if (code != null) {
              _diasSeleccionados.add(code);
            }
          }

          // turno_visita (lo tomamos del primero que tenga valor)
          final turno = row['turno_visita'];
          if (_turnoVisita == null && turno is String && turno.isNotEmpty) {
            _turnoVisita = turno; // "manana", "tarde", "noche"
          }
        }
      }
    }

    // 3) Si además el detalle trae turno_visita a nivel raíz, lo dejamos pisar
    final turnoRoot = widget.data['turno_visita'];
    if (turnoRoot is String && turnoRoot.isNotEmpty) {
      _turnoVisita = turnoRoot;
    }

    // Si querés, podrías agregar logs:
    // debugPrint('map diasId: $_diasId');
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _dniCtrl.dispose();
    _observacionCtrl.dispose();
    for (final d in _direcciones) {
      d.dispose();
    }
    for (final t in _telefonos) {
      t.dispose();
    }
    for (final e in _emails) {
      e.dispose();
    }
    super.dispose();
  }

  String _iniciales() {
    final nombre = _nombreCtrl.text.trim();
    final apellido = _apellidoCtrl.text.trim();
    if (nombre.isEmpty && apellido.isEmpty) return '?';

    if (nombre.isNotEmpty && apellido.isNotEmpty) {
      return (nombre[0] + apellido[0]).toUpperCase();
    }
    final solo = (nombre.isNotEmpty ? nombre : apellido);
    return solo[0].toUpperCase();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final dniParsed = int.tryParse(_dniCtrl.text.trim());

      // 1) persona
      final personaPayload = <String, dynamic>{
        'nombre': _nombreCtrl.text.trim(),
        'apellido': _apellidoCtrl.text.trim(),
        'dni': dniParsed,
      };

      // 2) direcciones
      final direccionesPayload = _direcciones
          .map((d) => d.toPayload())
          .where(
            (m) =>
                (m['direccion']?.toString().trim().isNotEmpty ?? false) ||
                (m['localidad']?.toString().trim().isNotEmpty ?? false),
          )
          .toList();

      // 3) teléfonos
      final telefonosPayload = _telefonos
          .map((t) => t.toPayload())
          .where(
            (m) => (m['nro_telefono']?.toString().trim().isNotEmpty ?? false),
          )
          .toList();

      // 4) emails
      final emailsPayload = _emails
          .map((e) => e.toPayload())
          .where((m) => (m['mail']?.toString().trim().isNotEmpty ?? false))
          .toList();

      // 5) días de visita -> dias_semanas
      // Orden fijo de días para que siempre salgan ordenados
      const ordenDias = ['lun', 'mar', 'mie', 'jue', 'vie', 'sab', 'dom'];
      final seleccionadosOrdenados = ordenDias
          .where((d) => _diasSeleccionados.contains(d))
          .toList();

      final List<Map<String, dynamic>> diasSemanasPayload = [];
      int orden = 1;
      for (final code in seleccionadosOrdenados) {
        final idDia = _idDiaPorCodigo[code];
        if (idDia == null) continue;

        diasSemanasPayload.add({
          'id_dia': idDia,
          'turno_visita': _turnoVisita, // puede ser null
          'orden': orden,
        });
        orden++;
      }

      // 6) payload UNIFICADO para ClienteDetalleUpdate
      final payloadDetalle = <String, dynamic>{
        'persona': personaPayload,
        'direcciones': direccionesPayload,
        'telefonos': telefonosPayload,
        'emails': emailsPayload,
        'dias_semanas': diasSemanasPayload,
        'observacion': _observacionCtrl.text.trim().isEmpty
            ? null
            : _observacionCtrl.text.trim(),
      };

      // 7) Una sola llamada al back
      await _service.actualizarClienteDetalle(widget.legajo, payloadDetalle);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente actualizado correctamente')),
      );
      Navigator.of(context).pop(true); // que el detail recargue desde el back
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _toggleDia(String dia) {
    if (_diasSeleccionados.contains(dia)) {
      // quitar día
      setState(() {
        _diasSeleccionados.remove(dia);
        _frecuenciaConfig.remove(dia);
      });
    } else {
      // agregar día → abrir modal
      _agregarDiaConConfig(dia);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar cliente'),
        actions: [
          TextButton.icon(
            onPressed: _saving ? null : _guardar,
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: const Text('Guardar'),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          child: Container(
            color: cs.surfaceVariant.withOpacity(0.2),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // HEADER
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
                                '${_nombreCtrl.text.trim()} ${_apellidoCtrl.text.trim()}'
                                    .trim(),
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
                                  _InfoChip(label: 'DNI', value: _dniCtrl.text),
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

                // DATOS PERSONALES
                _SectionCard(
                  title: 'Datos personales',
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nombreCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nombre',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Ingresá el nombre';
                          }
                          return null;
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _apellidoCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Apellido',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Ingresá el apellido';
                          }
                          return null;
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _dniCtrl,
                        decoration: const InputDecoration(
                          labelText: 'DNI',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Ingresá el DNI';
                          }
                          if (int.tryParse(v.trim()) == null) {
                            return 'DNI inválido';
                          }
                          return null;
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),

                // OBSERVACIONES
                _SectionCard(
                  title: 'Observaciones',
                  child: TextFormField(
                    controller: _observacionCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Notas internas sobre el cliente...',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 4,
                  ),
                ),

                // DIRECCIONES
                _SectionCard(
                  title: 'Direcciones',
                  child: Column(
                    children: [
                      ..._direcciones.asMap().entries.map((entry) {
                        final index = entry.key;
                        final d = entry.value;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: d.direccion,
                                  decoration: const InputDecoration(
                                    labelText: 'Dirección',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: d.localidad,
                                  decoration: const InputDecoration(
                                    labelText: 'Localidad',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: d.zona,
                                  decoration: const InputDecoration(
                                    labelText: 'Zona',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: d.entre1,
                                        decoration: const InputDecoration(
                                          labelText: 'Entre calle 1',
                                          border: OutlineInputBorder(),
                                          isDense: true,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextFormField(
                                        controller: d.entre2,
                                        decoration: const InputDecoration(
                                          labelText: 'Entre calle 2',
                                          border: OutlineInputBorder(),
                                          isDense: true,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: d.observacion,
                                  decoration: const InputDecoration(
                                    labelText: 'Observación',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    icon: const Icon(Icons.delete),
                                    label: const Text('Eliminar dirección'),
                                    onPressed: _direcciones.length == 1
                                        ? null
                                        : () {
                                            setState(() {
                                              final removed = _direcciones
                                                  .removeAt(index);
                                              removed.dispose();
                                            });
                                          },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar dirección'),
                          onPressed: () {
                            setState(() {
                              _direcciones.add(_DireccionFormData.empty());
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // TELÉFONOS
                _SectionCard(
                  title: 'Teléfonos',
                  child: Column(
                    children: [
                      ..._telefonos.asMap().entries.map((entry) {
                        final index = entry.key;
                        final t = entry.value;
                        return Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: t.numero,
                                decoration: const InputDecoration(
                                  labelText: 'Número',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                controller: t.estado,
                                decoration: const InputDecoration(
                                  labelText: 'Estado',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: _telefonos.length == 1
                                  ? null
                                  : () {
                                      setState(() {
                                        final removed = _telefonos.removeAt(
                                          index,
                                        );
                                        removed.dispose();
                                      });
                                    },
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar teléfono'),
                          onPressed: () {
                            setState(() {
                              _telefonos.add(_TelefonoFormData.empty());
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // EMAILS
                _SectionCard(
                  title: 'Emails',
                  child: Column(
                    children: [
                      ..._emails.asMap().entries.map((entry) {
                        final index = entry.key;
                        final e = entry.value;
                        return Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: e.mail,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: _emails.length == 1
                                  ? null
                                  : () {
                                      setState(() {
                                        final removed = _emails.removeAt(index);
                                        removed.dispose();
                                      });
                                    },
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar email'),
                          onPressed: () {
                            setState(() {
                              _emails.add(_EmailFormData.empty());
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // FRECUENCIA
                _SectionCard(
                  title: 'Frecuencia',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _DiaChip(
                            label: 'Lun',
                            value: 'lun',
                            selected: _diasSeleccionados.contains('lun'),
                            onTap: () {
                              if (_diasSeleccionados.contains('lun')) {
                                // Ya estaba seleccionado → reconfigurar (volver a abrir modal)
                                _agregarDiaConConfig('lun');
                              } else {
                                // Día nuevo → abrir modal y agregar
                                _toggleDia('lun');
                              }
                            },
                          ),
                          _DiaChip(
                            label: 'Mar',
                            value: 'mar',
                            selected: _diasSeleccionados.contains('mar'),
                            onTap: () {
                              if (_diasSeleccionados.contains('mar')) {
                                // Ya estaba seleccionado → reconfigurar (volver a abrir modal)
                                _agregarDiaConConfig('mar');
                              } else {
                                // Día nuevo → abrir modal y agregar
                                _toggleDia('mar');
                              }
                            },
                          ),
                          _DiaChip(
                            label: 'Mié',
                            value: 'mie',
                            selected: _diasSeleccionados.contains('mie'),
                            onTap: () {
                              if (_diasSeleccionados.contains('mie')) {
                                // Ya estaba seleccionado → reconfigurar (volver a abrir modal)
                                _agregarDiaConConfig('mie');
                              } else {
                                // Día nuevo → abrir modal y agregar
                                _toggleDia('mie');
                              }
                            },
                          ),
                          _DiaChip(
                            label: 'Jue',
                            value: 'jue',
                            selected: _diasSeleccionados.contains('jue'),
                            onTap: () {
                              if (_diasSeleccionados.contains('jue')) {
                                // Ya estaba seleccionado → reconfigurar (volver a abrir modal)
                                _agregarDiaConConfig('jue');
                              } else {
                                // Día nuevo → abrir modal y agregar
                                _toggleDia('jue');
                              }
                            },
                          ),
                          _DiaChip(
                            label: 'Vie',
                            value: 'vie',
                            selected: _diasSeleccionados.contains('vie'),
                            onTap: () {
                              if (_diasSeleccionados.contains('vie')) {
                                // Ya estaba seleccionado → reconfigurar (volver a abrir modal)
                                _agregarDiaConConfig('vie');
                              } else {
                                // Día nuevo → abrir modal y agregar
                                _toggleDia('vie');
                              }
                            },
                          ),
                          _DiaChip(
                            label: 'Sáb',
                            value: 'sab',
                            selected: _diasSeleccionados.contains('sab'),
                            onTap: () {
                              if (_diasSeleccionados.contains('sab')) {
                                // Ya estaba seleccionado → reconfigurar (volver a abrir modal)
                                _agregarDiaConConfig('sab');
                              } else {
                                // Día nuevo → abrir modal y agregar
                                _toggleDia('sab');
                              }
                            },
                          ),
                          _DiaChip(
                            label: 'Dom',
                            value: 'dom',
                            selected: _diasSeleccionados.contains('dom'),
                            onTap: () {
                              if (_diasSeleccionados.contains('dom')) {
                                // Ya estaba seleccionado → reconfigurar (volver a abrir modal)
                                _agregarDiaConConfig('dom');
                              } else {
                                // Día nuevo → abrir modal y agregar
                                _toggleDia('dom');
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _turnoVisita,
                        decoration: const InputDecoration(
                          labelText: 'Turno de visita',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: null,
                            child: Text('Sin especificar'),
                          ),
                          DropdownMenuItem(
                            value: 'manana',
                            child: Text('Mañana'),
                          ),
                          DropdownMenuItem(
                            value: 'tarde',
                            child: Text('Tarde'),
                          ),
                          DropdownMenuItem(
                            value: 'noche',
                            child: Text('Noche'),
                          ),
                        ],
                        onChanged: (v) {
                          setState(() {
                            _turnoVisita = v;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==== Helpers internos ====

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

// Modelos de formulario

class _DireccionFormData {
  final int? idDireccion;
  final TextEditingController localidad;
  final TextEditingController direccion;
  final TextEditingController zona;
  final TextEditingController entre1;
  final TextEditingController entre2;
  final TextEditingController observacion;

  _DireccionFormData({
    required this.idDireccion,
    required this.localidad,
    required this.direccion,
    required this.zona,
    required this.entre1,
    required this.entre2,
    required this.observacion,
  });

  factory _DireccionFormData.empty() => _DireccionFormData(
    idDireccion: null,
    localidad: TextEditingController(),
    direccion: TextEditingController(),
    zona: TextEditingController(),
    entre1: TextEditingController(),
    entre2: TextEditingController(),
    observacion: TextEditingController(),
  );

  factory _DireccionFormData.fromMap(Map d) => _DireccionFormData(
    idDireccion: d['id_direccion'] as int?,
    localidad: TextEditingController(text: d['localidad']?.toString() ?? ''),
    direccion: TextEditingController(text: d['direccion']?.toString() ?? ''),
    zona: TextEditingController(text: d['zona']?.toString() ?? ''),
    entre1: TextEditingController(text: d['entre_calle1']?.toString() ?? ''),
    entre2: TextEditingController(text: d['entre_calle2']?.toString() ?? ''),
    observacion: TextEditingController(
      text: d['observacion']?.toString() ?? '',
    ),
  );

  Map<String, dynamic> toPayload() {
    final map = <String, dynamic>{
      'localidad': localidad.text.trim().isEmpty ? null : localidad.text.trim(),
      'direccion': direccion.text.trim().isEmpty ? null : direccion.text.trim(),
      'zona': zona.text.trim().isEmpty ? null : zona.text.trim(),
      'entre_calle1': entre1.text.trim().isEmpty ? null : entre1.text.trim(),
      'entre_calle2': entre2.text.trim().isEmpty ? null : entre2.text.trim(),
      'observacion': observacion.text.trim().isEmpty
          ? null
          : observacion.text.trim(),
    };
    if (idDireccion != null) {
      map['id_direccion'] = idDireccion;
    }
    return map;
  }

  void dispose() {
    localidad.dispose();
    direccion.dispose();
    zona.dispose();
    entre1.dispose();
    entre2.dispose();
    observacion.dispose();
  }
}

class _TelefonoFormData {
  final int? idTelefono;
  final TextEditingController numero;
  final TextEditingController estado;

  _TelefonoFormData({
    required this.idTelefono,
    required this.numero,
    required this.estado,
  });

  factory _TelefonoFormData.empty() => _TelefonoFormData(
    idTelefono: null,
    numero: TextEditingController(),
    estado: TextEditingController(),
  );

  factory _TelefonoFormData.fromMap(Map t) => _TelefonoFormData(
    idTelefono: t['id_telefono'] as int?,
    numero: TextEditingController(text: t['nro_telefono']?.toString() ?? ''),
    estado: TextEditingController(text: t['estado']?.toString() ?? ''),
  );

  Map<String, dynamic> toPayload() {
    final map = <String, dynamic>{
      'nro_telefono': numero.text.trim().isEmpty ? null : numero.text.trim(),
      'estado': estado.text.trim().isEmpty ? null : estado.text.trim(),
    };
    if (idTelefono != null) {
      map['id_telefono'] = idTelefono;
    }
    return map;
  }

  void dispose() {
    numero.dispose();
    estado.dispose();
  }
}

class _EmailFormData {
  final int? idMail;
  final TextEditingController mail;

  _EmailFormData({required this.idMail, required this.mail});

  factory _EmailFormData.empty() =>
      _EmailFormData(idMail: null, mail: TextEditingController());

  factory _EmailFormData.fromMap(Map e) => _EmailFormData(
    idMail: e['id_mail'] as int?,
    mail: TextEditingController(text: e['mail']?.toString() ?? ''),
  );

  Map<String, dynamic> toPayload() {
    final map = <String, dynamic>{
      'mail': mail.text.trim().isEmpty ? null : mail.text.trim(),
    };
    if (idMail != null) {
      map['id_mail'] = idMail;
    }
    return map;
  }

  void dispose() {
    mail.dispose();
  }
}

class _DiaChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _DiaChip({
    Key? key,
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}
