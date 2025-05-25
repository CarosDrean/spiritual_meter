import 'package:flutter/material.dart';
import 'package:spiritual_meter/utils/formatters.dart';

class Register extends StatelessWidget {
  final String text;
  final Duration duration;

  const Register({super.key, required this.text, required this.duration});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text(
          duration == 0 ? 'Sin registros' : formatDuration(duration.inSeconds),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
