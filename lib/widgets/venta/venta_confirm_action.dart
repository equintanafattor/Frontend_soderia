import 'package:flutter/material.dart';

class VentaConfirmAction extends StatelessWidget {
  final bool enabled;
  final double total;
  final VoidCallback onConfirm;

  const VentaConfirmAction({
    super.key,
    required this.enabled,
    required this.total,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      return SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black12)],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: enabled ? onConfirm : null,
              icon: const Icon(Icons.check),
              label: Text(
                total > 0
                    ? 'Confirmar · \$${total.toStringAsFixed(0)}'
                    : 'Confirmar',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: enabled ? Colors.green : null,
                foregroundColor: enabled ? Colors.white : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: FloatingActionButton.extended(
        onPressed: enabled ? onConfirm : null,
        icon: const Icon(Icons.check),
        label: Text(
          total > 0 ? 'Confirmar · \$${total.toStringAsFixed(0)}' : 'Confirmar',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: enabled ? Colors.green : Colors.grey.shade400,
        foregroundColor: Colors.white,
      ),
    );
  }
}