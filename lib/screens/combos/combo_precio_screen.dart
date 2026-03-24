// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/colors.dart';
import 'package:frontend_soderia/services/lista_precio_service.dart';

class ComboPrecioScreen extends StatefulWidget {
  final int idLista;
  final String nombreLista;

  const ComboPrecioScreen({
    super.key,
    required this.idLista,
    required this.nombreLista,
  });

  @override
  State<ComboPrecioScreen> createState() => _ComboPrecioScreenState();
}

class _ComboPrecioScreenState extends State<ComboPrecioScreen> {
  final _service = ListaPrecioService();

  late Future<List<dynamic>> _futureCombos;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    _futureCombos = _service.listarCombosConPrecio(widget.idLista);
  }

  // ------------------ helpers ------------------

  double _parsePrecio(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  Future<double?> _editarPrecio({
    required BuildContext context,
    double? precioInicial,
  }) {
    final ctrl = TextEditingController(
      text: precioInicial != null && precioInicial > 0
          ? precioInicial.toStringAsFixed(0)
          : '',
    );

    return showDialog<double>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Precio del combo'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            prefixText: '\$ ',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final v = double.tryParse(ctrl.text);
              Navigator.pop(context, v);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // ------------------ UI ------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.azul,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Precios de combos'),
            Text(widget.nombreLista, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _futureCombos,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(child: Text('Error cargando combos: ${snap.error}'));
          }

          final combos = snap.data ?? [];

          if (combos.isEmpty) {
            return const Center(child: Text('No hay combos cargados'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: combos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final c = combos[i] as Map<String, dynamic>;

              final int idCombo = c['id_combo'];
              final String nombre = (c['nombre'] ?? '').toString();
              final precioRaw = c['precio'];
              final double? precio = precioRaw == null
                  ? null
                  : _parsePrecio(precioRaw);

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.inventory_2),
                  title: Text(nombre),
                  subtitle: precio != null && precio > 0
                      ? Text('\$ ${precio.toStringAsFixed(0)}')
                      : const Text(
                          'Sin precio asignado',
                          style: TextStyle(color: Colors.red),
                        ),
                  trailing: FilledButton(
                    onPressed: () async {
                      final nuevo = await _editarPrecio(
                        context: context,
                        precioInicial: precio,
                      );

                      if (nuevo == null) return;

                      try {
                        await _service.upsertPrecioCombo(
                          idLista: widget.idLista,
                          idCombo: idCombo,
                          precio: nuevo,
                        );

                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Precio guardado')),
                        );

                        setState(_cargar);
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
                    child: Text(
                      precio == null || precio == 0 ? 'Asignar' : 'Editar',
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
