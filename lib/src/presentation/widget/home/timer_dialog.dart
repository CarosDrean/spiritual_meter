import 'dart:async';

import 'package:flutter/material.dart';
import 'package:spiritual_meter/src/utils/formatters.dart';
import 'package:spiritual_meter/src/core/constant.dart';

typedef OnStopCallback = void Function(Duration finalDuration);

class TimerDialog extends StatefulWidget {
  final String title;
  final DateTime startTime;
  final OnStopCallback onStop;

  const TimerDialog({
    super.key,
    required this.title,
    required this.startTime,
    required this.onStop,
  });

  @override
  State<TimerDialog> createState() => _TimerDialogState();
}

class _TimerDialogState extends State<TimerDialog> {
  Timer? _ticker;
  late Duration _elapsed;

  @override
  void initState() {
    super.initState();
    _updateElapsed();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _updateElapsed());
  }

  void _updateElapsed() {
    setState(() {
      _elapsed = DateTime.now().difference(widget.startTime);
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatDuration(_elapsed.inSeconds),
            style: Theme.of(context).textTheme.displayLarge,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onStop(_elapsed);
            Navigator.of(context).pop();
          },
          child: const Text(kStopButtonText),
        ),
      ],
    );
  }
}
