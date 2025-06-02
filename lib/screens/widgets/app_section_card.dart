import 'package:flutter/material.dart';

class AppSectionCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget content;
  final Widget? bottomButton;

  const AppSectionCard({
    super.key,
    required this.title,
    this.icon,
    required this.content,
    this.bottomButton,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                ],
                Text(title, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
          const Divider(
            height: 1,
            thickness: 0.8,
            color: Colors.grey,
            indent: 0,
            endIndent: 0,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
            child: content, // Aquí se inserta el contenido principal
          ),

          if (bottomButton != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: bottomButton!,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
