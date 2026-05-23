import 'package:flutter/material.dart';

class VentaHeaderInfo extends StatelessWidget {
  final String legajo;
  final double deuda;
  final double saldoAFavor;

  const VentaHeaderInfo({
    super.key,
    required this.legajo,
    required this.deuda,
    required this.saldoAFavor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _InfoItem(label: 'Legajo', value: legajo),
          _InfoItem(
            label: 'Deuda',
            value: '\$ ${deuda.toStringAsFixed(0)}',
            valueStyle: TextStyle(
              color: deuda > 0 ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          _InfoItem(
            label: 'Saldo a favor',
            value: '\$ ${saldoAFavor.toStringAsFixed(0)}',
            valueStyle: const TextStyle(
              color: Colors.teal,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _InfoItem({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ', style: TextStyle(color: cs.onSurfaceVariant)),
        Text(
          value,
          style: valueStyle ?? const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}