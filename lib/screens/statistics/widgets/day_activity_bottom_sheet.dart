import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:spiritual_meter/utils/formatters.dart';

class DayActivityBottomSheet extends StatelessWidget {
  final DateTime selectedDay;
  final Duration prayerDuration;
  final Duration bibleReadingDuration;
  final ScrollController? scrollController;

  const DayActivityBottomSheet({
    super.key,
    required this.selectedDay,
    required this.prayerDuration,
    required this.bibleReadingDuration,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
            child: Row(
              children: [
                Text(
                  'Registro del ${dateFormat.format(selectedDay)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Tiempo orado:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      prayerDuration.inSeconds == 0
                          ? 'Sin registros'
                          : formatDuration(prayerDuration.inSeconds),
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Tiempo lectura bíblica:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      bibleReadingDuration.inSeconds == 0
                          ? 'Sin registros'
                          : formatDuration(bibleReadingDuration.inSeconds),
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
