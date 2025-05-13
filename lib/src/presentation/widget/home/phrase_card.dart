import 'package:flutter/material.dart';

import '../../../core/constant.dart';

class PhraseCard extends StatelessWidget {
  final String phrase;
  final VoidCallback onAddPhrase;

  const PhraseCard({
    super.key,
    required this.phrase,
    required this.onAddPhrase,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Margen consistente de la tarjeta
      child: Column( // La Card ahora contiene directamente una Column
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de la frase con su propio Padding
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0), // Padding para el título
            child: Text(
              kPhraseTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          // Divisor que ahora ocupa todo el ancho de la Card
          const Divider(
            height: 1,
            thickness: 0.8,
            color: Colors.grey,
            indent: 0, // Asegura que no haya sangría
            endIndent: 0, // Asegura que no haya sangría
          ),
          // Contenedor de la frase con su propio Padding
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0), // Padding para el contenedor de la frase
            child: Container(
              padding: const EdgeInsets.all(12.0),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                phrase,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Botón con su propio Padding
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0), // Padding para el botón
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onAddPhrase,
                child: const Text(kAddPhraseButtonText),
              ),
            ),
          ),
        ],
      ),
    );
  }
}