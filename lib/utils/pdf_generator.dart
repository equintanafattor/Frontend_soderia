// ignore_for_file: deprecated_member_use

import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;

Future<Uint8List> generarComprobantePDF({
  required String nombreCliente,
  required String legajo,
  required DateTime fecha,
  required double deudaAnterior,
  required double totalVenta,
  required double montoPagado,
  required String medioPago,
  required List<Map<String, dynamic>> items,
}) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (ctx) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('SODERÍA SAN MIGUEL — COMPROBANTE DE PAGO',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),

            pw.SizedBox(height: 10),
            pw.Text('Cliente: $nombreCliente'),
            pw.Text('Legajo: $legajo'),
            pw.Text('Fecha: $fecha'),

            pw.SizedBox(height: 20),

            pw.Table.fromTextArray(
              headers: ['Producto', 'Cant.', 'P. unit.', 'Subtotal'],
              data: items.map((it) {
                return [
                  it['producto'],
                  it['cantidad'].toString(),
                  '\$${it['precioUnitario'].toStringAsFixed(0)}',
                  '\$${(it['cantidad'] * it['precioUnitario']).toStringAsFixed(0)}',
                ];
              }).toList(),
            ),

            pw.SizedBox(height: 20),

            pw.Text('Total venta: \$${totalVenta.toStringAsFixed(0)}'),
            pw.Text('Deuda anterior: \$${deudaAnterior.toStringAsFixed(0)}'),
            pw.Text('Monto pagado: \$${montoPagado.toStringAsFixed(0)}'),
            pw.Text('Medio de pago: $medioPago'),

            pw.SizedBox(height: 20),
            pw.Text('Gracias por su compra ❤️'),
          ],
        );
      },
    ),
  );

  return pdf.save();
}
