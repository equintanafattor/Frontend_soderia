import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/colors.dart';
import 'package:frontend_soderia/widgets/jornada_card.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final w = MediaQuery.of(context).size.width;

    // Padding más grande en pantallas anchas
    final horizontalPadding = w >= 900 ? 72.0 : (w >= 600 ? 48.0 : 20.0);

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        title: const Text('Test JornadaCard'),
        backgroundColor: cs.primary,      // AZUL
        foregroundColor: cs.onPrimary,    // BLANCO
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 24,
          ),
          children: [
            JornadaCard(
              fecha: DateTime(2025, 5, 1),
              nombres: const [
                'Silva Tamara',
                'Kreitzer Bernardo',
                'Brondani Gaston',
                'Quintana Emmanuel',
                'Luna Tristan',
                'Abasto Facundo',
                'Cliente Extra 1',
                'Cliente Extra 2',
                'Cliente Extra 3',
                'Cliente Extra 4',
                'Cliente Extra 5',
                'Cliente Extra 6',
              ],
            ),
            JornadaCard(
              fecha: DateTime(2025, 5, 2),
              nombres: const [
                'Emilio Fouces',
                'Ernesto Zapata',
                'Franco Colaspinto',
                'Fernando Filipuzzi',
                'Francisco Rodriguez',
                'Facundo Fumaneri',
                'Cliente 7',
                'Cliente 8',
              ],
            ),
          ],
        ),
      ),
    );
  }
}
