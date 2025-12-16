// ignore_for_file: deprecated_member_use

import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;

Future<Uint8List> generarEstadoCuentaPDF({
  required String nombreCliente,
  required String legajo,
  required DateTime fecha,
  required double deuda,
  required double saldoAFavor,
  List<Map<String, dynamic>>? ultimosPedidos,
}) async {
  final pdf = pw.Document();

  String _money(num v) => '\$${v.toStringAsFixed(0)}';

  pdf.addPage(
    pw.Page(
      build: (_) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'SODERÍA SAN MIGUEL',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              'Estado de cuenta',
              style: pw.TextStyle(fontSize: 14),
            ),

            pw.SizedBox(height: 16),

            pw.Text('Cliente: $nombreCliente'),
            pw.Text('Legajo: $legajo'),
            pw.Text('Fecha: ${fecha.toLocal()}'),

            pw.SizedBox(height: 20),

            pw.Text(
              'Resumen',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Divider(),

            pw.Text('Deuda actual: ${_money(deuda)}'),
            pw.Text('Saldo a favor: ${_money(saldoAFavor)}'),

            if (ultimosPedidos != null && ultimosPedidos.isNotEmpty) ...[
              pw.SizedBox(height: 20),
              pw.Text(
                'Últimos movimientos',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Table.fromTextArray(
                headers: ['Fecha', 'Pedido', 'Total'],
                data: ultimosPedidos.map((p) {
                  return [
                    p['fecha']?.toString() ?? '',
                    '#${p['id_pedido'] ?? ''}',
                    _money(p['total'] ?? 0),
                  ];
                }).toList(),
              ),
            ],

            pw.SizedBox(height: 30),
            pw.Text(
              'Documento generado automáticamente',
              style: pw.TextStyle(fontSize: 10),
            ),
          ],
        );
      },
    ),
  );

  return pdf.save();
}
