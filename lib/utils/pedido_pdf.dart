// ignore_for_file: deprecated_member_use

import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;

String _money(dynamic v) {
  num n;
  if (v == null)
    n = 0;
  else if (v is num)
    n = v;
  else if (v is String)
    n = num.tryParse(v.replaceAll(',', '.')) ?? 0;
  else
    n = 0;
  return '\$${n.toStringAsFixed(0)}';
}

Future<Uint8List> generarPedidoPDF({
  required String nombreCliente,
  required String legajo,
  required DateTime fecha,
  required String estado,
  required String medioPago,
  required double total,
  required List<Map<String, dynamic>> items,
  String? observacion,
}) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (_) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'SODERÍA SAN MIGUEL — PEDIDO',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Cliente: $nombreCliente'),
            pw.Text('Legajo: $legajo'),
            pw.Text('Fecha: $fecha'),
            pw.Text('Estado: $estado'),
            pw.Text('Medio de pago: $medioPago'),
            if ((observacion ?? '').trim().isNotEmpty)
              pw.Text('Obs: ${observacion!.trim()}'),

            pw.SizedBox(height: 20),

            pw.Table.fromTextArray(
              headers: ['Producto', 'Cant.', 'P. unit.', 'Subtotal'],
              data: items.map((it) {
                final cant = (it['cantidad'] as num?)?.toDouble() ?? 0;
                final pu = (it['precioUnitario'] as num?)?.toDouble() ?? 0;
                final subtotal = cant * pu;

                return [
                  it['producto']?.toString() ?? '',
                  cant.toStringAsFixed(0),
                  _money(pu),
                  _money(subtotal),
                ];
              }).toList(),
            ),

            pw.SizedBox(height: 20),
            pw.Text(
              'Total: ${_money(total)}',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
          ],
        );
      },
    ),
  );

  return pdf.save();
}
