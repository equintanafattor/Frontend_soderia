import 'package:flutter/material.dart';

class VentaTitleCliente extends StatelessWidget {
  final String nombre;
  final String direccion;

  const VentaTitleCliente({
    super.key,
    required this.nombre,
    required this.direccion,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          nombre,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (direccion.isNotEmpty)
          Text(direccion, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}