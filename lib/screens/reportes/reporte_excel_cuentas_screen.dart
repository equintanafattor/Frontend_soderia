import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:frontend_soderia/core/net/api_client.dart';

const _diasSemana = [
  {'label': 'Todos', 'value': null},
  {'label': 'Lunes', 'value': 'lunes'},
  {'label': 'Martes', 'value': 'martes'},
  {'label': 'Miércoles', 'value': 'miercoles'},
  {'label': 'Jueves', 'value': 'jueves'},
  {'label': 'Viernes', 'value': 'viernes'},
  {'label': 'Sábado', 'value': 'sabado'},
  {'label': 'Domingo', 'value': 'domingo'},
];

class ReporteExcelCuentasScreen extends StatefulWidget {
  const ReporteExcelCuentasScreen({super.key});

  @override
  State<ReporteExcelCuentasScreen> createState() =>
      _ReporteExcelCuentasScreenState();
}

class _ReporteExcelCuentasScreenState
    extends State<ReporteExcelCuentasScreen> {
  final _now = DateTime.now();

  late int _mes;
  late int _anio;
  String? _dia; // null = todos
  bool _descargando = false;

  @override
  void initState() {
    super.initState();
    _mes = _now.month;
    _anio = _now.year;
  }

  String get _nombreMes =>
      DateFormat('MMMM', 'es_AR').format(DateTime(_anio, _mes));

  Future<void> _descargar() async {
    setState(() => _descargando = true);

    try {
      final queryParams = <String, dynamic>{
        'mes': _mes,
        'anio': _anio,
        if (_dia != null) 'dia': _dia,
      };

      final response = await ApiClient.dio.get(
        '/reportes/excel-cuentas',
        queryParameters: queryParams,
        options: Options(responseType: ResponseType.bytes),
      );

      // Guardar en directorio temporal y compartir
      final dir = await getTemporaryDirectory();
      final sufijo = _dia != null ? '_$_dia' : '';
      final fileName =
          'cuentas_${_anio}_${_mes.toString().padLeft(2, '0')}$sufijo.xlsx';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(response.data as List<int>);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Planilla de cuentas — $_nombreMes $_anio',
      );
    } on DioException catch (e) {
      if (!mounted) return;
      _mostrarError('Error al descargar: ${e.response?.data ?? e.message}');
    } catch (e) {
      if (!mounted) return;
      _mostrarError('Error inesperado: $e');
    } finally {
      if (mounted) setState(() => _descargando = false);
    }
  }

  void _mostrarError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _seleccionarMes() async {
    // Picker simple: año y mes con dos ListWheelScrollView
    int tempMes = _mes;
    int tempAnio = _anio;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Seleccionar mes'),
          content: SizedBox(
            height: 180,
            child: StatefulBuilder(
              builder: (ctx2, setInner) {
                return Row(
                  children: [
                    // Mes
                    Expanded(
                      flex: 3,
                      child: ListWheelScrollView.useDelegate(
                        itemExtent: 40,
                        physics: const FixedExtentScrollPhysics(),
                        controller: FixedExtentScrollController(
                          initialItem: tempMes - 1,
                        ),
                        onSelectedItemChanged: (i) =>
                            setInner(() => tempMes = i + 1),
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: 12,
                          builder: (_, i) => Center(
                            child: Text(
                              DateFormat('MMMM', 'es_AR')
                                  .format(DateTime(2000, i + 1)),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: tempMes == i + 1
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Año
                    Expanded(
                      flex: 2,
                      child: ListWheelScrollView.useDelegate(
                        itemExtent: 40,
                        physics: const FixedExtentScrollPhysics(),
                        controller: FixedExtentScrollController(
                          initialItem: tempAnio - 2024,
                        ),
                        onSelectedItemChanged: (i) =>
                            setInner(() => tempAnio = 2024 + i),
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: 5,
                          builder: (_, i) {
                            final y = 2024 + i;
                            return Center(
                              child: Text(
                                '$y',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: tempAnio == y
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (ok == true) {
      setState(() {
        _mes = tempMes;
        _anio = tempAnio;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final diaLabel = _dia == null
        ? 'Todos'
        : _diasSemana
              .firstWhere((d) => d['value'] == _dia)['label']
              .toString();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Planilla de cuentas',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Exporta el detalle de deudas y consumo mensual por cliente.',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 24),

          // Selector de mes
          _FilterRow(
            label: 'Período',
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: _seleccionarMes,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_month_outlined, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${_nombreMes[0].toUpperCase()}${_nombreMes.substring(1)} $_anio',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, size: 18),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Filtro de día
          _FilterRow(
            label: 'Día de visita',
            child: DropdownButton<String?>(
              value: _dia,
              underline: const SizedBox.shrink(),
              borderRadius: BorderRadius.circular(8),
              items: _diasSemana
                  .map(
                    (d) => DropdownMenuItem<String?>(
                      value: d['value'] as String?,
                      child: Text(d['label'].toString()),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _dia = v),
            ),
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _descargando ? null : _descargar,
              icon: _descargando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.download_outlined),
              label: Text(
                _descargando
                    ? 'Generando...'
                    : 'Descargar Excel — $diaLabel',
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final String label;
  final Widget child;

  const _FilterRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: cs.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: child,
        ),
      ],
    );
  }
}