// lib/utils/historico_cliente_formatter.dart

String buildHistoricoSubtitle(Map h) {
  final obs = (h['observacion'] ?? '')?.toString() ?? '';
  final datos = h['datos'];

  if (datos is! Map) return obs;
  final cambios = datos['cambios'];
  if (cambios is! Map) return obs.isEmpty ? '' : obs;

  final List<String> lines = [];
  if (obs.isNotEmpty) {
    lines.add(obs);
  }

  String labelPrincipal(Map item, String tipo) {
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

  void appendColeccionDetalles(String key, String labelColeccion) {
    final col = cambios[key];
    if (col is! Map) return;

    final creados = (col['creados'] as List? ?? const []);
    final actualizados = (col['actualizados'] as List? ?? const []);
    final eliminados = (col['eliminados'] as List? ?? const []);

    for (final item in creados) {
      if (item is! Map) continue;
      final titulo = labelPrincipal(item, key);
      if (titulo.isNotEmpty) {
        lines.add('$labelColeccion creado: $titulo');
      } else {
        lines.add('$labelColeccion creado');
      }
    }

    for (final item in actualizados) {
      if (item is! Map) continue;
      final campos = item['campos'];
      if (campos is! Map) continue;

      final titulo = labelPrincipal(item, key);
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

    for (final item in eliminados) {
      if (item is! Map) continue;
      final titulo = labelPrincipal(item, key);
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

  appendColeccionDetalles('direcciones', 'Dirección');
  appendColeccionDetalles('telefonos', 'Teléfono');
  appendColeccionDetalles('emails', 'Email');
  appendColeccionDetalles('cuentas', 'Cuenta');

  final dias = cambios['dias_semanas'];
  if (dias is Map) {
    final antes = dias['antes'] as List? ?? const [];
    final despues = dias['despues'] as List? ?? const [];

    String fmtDia(Map d) {
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
            despues.whereType<Map>().map(fmtDia).join(', '),
      );
    } else if (antes.isNotEmpty && despues.isEmpty) {
      lines.add('Días de visita eliminados');
    } else if (antes.isNotEmpty || despues.isNotEmpty) {
      lines.add('Días de visita:');
      if (antes.isNotEmpty) {
        lines.add('  Antes: ' + antes.whereType<Map>().map(fmtDia).join(', '));
      }
      if (despues.isNotEmpty) {
        lines.add(
          '  Después: ' + despues.whereType<Map>().map(fmtDia).join(', '),
        );
      }
    }
  }

  return lines.join('\n');
}
