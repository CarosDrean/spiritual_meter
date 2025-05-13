import 'dart:async';

import 'package:flutter/material.dart';
import 'package:spiritual_meter/src/utils/formatters.dart';
import 'package:spiritual_meter/src/core/constant.dart';

typedef OnStopCallback = void Function(Duration finalDuration);

class TimerDialog extends StatefulWidget {
  final OnStopCallback onStop;
  final String title;
  final Duration? initialDuration;

  const TimerDialog({
    super.key,
    required this.onStop,
    required this.title,
    this.initialDuration,
  });

  @override
  State<TimerDialog> createState() => _TimerDialogState();
}

class _TimerDialogState extends State<TimerDialog> {
  Timer? _timer;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _duration = widget.initialDuration ?? Duration.zero;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _duration = _duration + const Duration(seconds: 1);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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
            formatDuration(_duration.inSeconds),
            style: Theme.of(context).textTheme.displayLarge,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onStop(_duration);
            Navigator.of(context).pop();
          },
          child: const Text(kStopButtonText),
        ),
      ],
    );
  }
}
