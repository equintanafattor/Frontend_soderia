import 'package:flutter/material.dart';

class VentaSelectorCuenta extends StatelessWidget {
  final List<Map<String, dynamic>> cuentas;
  final Map<String, dynamic>? cuentaSeleccionada;
  final bool modoLocalCliente;
  final VoidCallback onPickCuenta;

  const VentaSelectorCuenta({
    super.key,
    required this.cuentas,
    required this.cuentaSeleccionada,
    required this.modoLocalCliente,
    required this.onPickCuenta,
  });

  double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.replaceAll(',', '.')) ?? 0.0;
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    if (cuentas.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Card(
          child: ListTile(
            leading: Icon(Icons.warning_amber),
            title: Text('Este cliente no tiene cuentas'),
            subtitle: Text('Creá una cuenta para poder vender.'),
          ),
        ),
      );
    }

    final deuda = _toDouble(cuentaSeleccionada?['deuda']);
    final saldo = _toDouble(cuentaSeleccionada?['saldo']);
    final tipo = (cuentaSeleccionada?['tipo_de_cuenta'] ?? 'Cuenta').toString();
    final estado = (cuentaSeleccionada?['estado'] ?? '').toString();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Card(
        child: ListTile(
          leading: const Icon(Icons.account_balance_wallet_outlined),
          title: Text('Cuenta: $tipo'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Deuda: \$ ${deuda.toStringAsFixed(0)}  ·  '
                'Saldo: \$ ${saldo.toStringAsFixed(0)}',
              ),
              if (estado.isNotEmpty) Text('Estado: $estado'),
              if (cuentas.length > 1 && cuentaSeleccionada == null)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'Seleccioná una cuenta para continuar',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              if (modoLocalCliente)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'Datos cargados localmente',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
            ],
          ),
          trailing: cuentas.length <= 1
              ? null
              : OutlinedButton.icon(
                  onPressed: onPickCuenta,
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Cambiar'),
                ),
          onTap: cuentas.length > 1 ? onPickCuenta : null,
        ),
      ),
    );
  }
}
