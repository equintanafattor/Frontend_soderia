// ignore_for_file: deprecated_member_use

import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;

Future<Uint8List> generarComprobantePDF({
  required String nombreCliente,
  required String legajo,
  required DateTime fecha,
  required double deudaAnterior,
  required double saldoAFavorAnterior, // 👈 NUEVO
  required double totalVenta,
  required double montoPagado,
  required String medioPago,
  required List<Map<String, dynamic>> items,
}) async {
  final pdf = pw.Document();

  // ---- Cálculo de cuenta, mismo criterio que en el back ----
  final netoActual = deudaAnterior - saldoAFavorAnterior;
  final netoNuevo = netoActual + totalVenta - montoPagado;

  double deudaNueva;
  double saldoAFavorNuevo;

  if (netoNuevo >= 0) {
    // Sigue debiendo (o queda justo en 0)
    deudaNueva = netoNuevo;
    saldoAFavorNuevo = 0;
  } else {
    // No debe nada y pasa a tener saldo a favor
    deudaNueva = 0;
    saldoAFavorNuevo = -netoNuevo;
  }

  String _money(num v) => '\$${v.toStringAsFixed(0)}';

  pdf.addPage(
    pw.Page(
      build: (ctx) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'SODERÍA SAN MIGUEL — COMPROBANTE DE PAGO',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),

            pw.SizedBox(height: 10),
            pw.Text('Cliente: $nombreCliente'),
            pw.Text('Legajo: $legajo'),
            pw.Text('Fecha: $fecha'),

            pw.SizedBox(height: 20),

            // ---- Detalle de ítems ----
            pw.Table.fromTextArray(
              headers: ['Producto', 'Cant.', 'P. unit.', 'Subtotal'],
              data: items.map((it) {
                final cant = it['cantidad'] as int;
                final pu = (it['precioUnitario'] as num).toDouble();
                final subtotal = cant * pu;
                return [
                  it['producto']?.toString() ?? '',
                  cant.toString(),
                  _money(pu),
                  _money(subtotal),
                ];
              }).toList(),
            ),

            pw.SizedBox(height: 20),

            // ---- Resumen de cuenta ----
            pw.Text(
              'Resumen de cuenta',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text('Total venta: ${_money(totalVenta)}'),
            pw.Text('Deuda anterior: ${_money(deudaAnterior)}'),
            pw.Text('Saldo a favor anterior: ${_money(saldoAFavorAnterior)}'),
            pw.Text('Monto pagado: ${_money(montoPagado)}'),
            pw.Text('Medio de pago: $medioPago'),

            pw.SizedBox(height: 8),
            pw.Text(
              'Deuda actual: ${_money(deudaNueva)}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Saldo a favor actual: ${_money(saldoAFavorNuevo)}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),

            pw.SizedBox(height: 20),
            pw.Text('Gracias por su compra ❤️'),
          ],
        );
      },
    ),
  );

  return pdf.save();
}
