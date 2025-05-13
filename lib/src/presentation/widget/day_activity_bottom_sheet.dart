import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spiritual_meter/src/core/constant.dart';
import 'package:spiritual_meter/src/data/database/database_helper.dart';
import 'package:spiritual_meter/src/utils/formatters.dart';

class DayActivityBottomSheet extends StatefulWidget {
  final DateTime selectedDay;
  final DatabaseHelper dbHelper;
  final ScrollController? scrollController;

  const DayActivityBottomSheet({
    super.key,
    required this.selectedDay,
    required this.dbHelper,
    this.scrollController,
  });

  @override
  State<DayActivityBottomSheet> createState() => _DayActivityBottomSheetState();
}

class _DayActivityBottomSheetState extends State<DayActivityBottomSheet> {
  Duration _todayPrayerDuration = Duration.zero;
  Duration _todayBibleReadingDuration = Duration.zero;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDailyStatistics();
  }

  Future<void> _loadDailyStatistics() async {
    setState(() {
      _isLoading = true;
    });

    final startOfDay = DateTime(
      widget.selectedDay.year,
      widget.selectedDay.month,
      widget.selectedDay.day,
    );
    final endOfDay = DateTime(
      widget.selectedDay.year,
      widget.selectedDay.month,
      widget.selectedDay.day,
      23,
      59,
      59,
      999,
    );

    final logs = await widget.dbHelper.getActivityLogsByDateRange(
      startOfDay,
      endOfDay,
    );

    Duration prayerToday = Duration.zero;
    Duration bibleReadingToday = Duration.zero;

    for (var log in logs) {
      if (log.activityType == kActivityTypePrayer) {
        prayerToday += Duration(seconds: log.durationInSeconds);
      } else if (log.activityType == kActivityTypeBibleReading) {
        bibleReadingToday += Duration(seconds: log.durationInSeconds);
      }
    }

    setState(() {
      _todayPrayerDuration = prayerToday;
      _todayBibleReadingDuration = bibleReadingToday;
      _isLoading = false;
    });
  }

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
                  'Registro del ${dateFormat.format(widget.selectedDay)}',
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
            child:
                _isLoading
                    ? Container(
                      alignment: Alignment.center,
                      height: 50,
                      child: const CircularProgressIndicator(),
                    )
                    : (!(_todayPrayerDuration > Duration.zero) &&
                        !(_todayBibleReadingDuration > Duration.zero))
                    ? Center(
                      child: Text(
                        'No hay actividades registradas para este día.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center, // Centra el texto
                      ),
                    )
                    : Column(
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
                              _todayPrayerDuration.inSeconds == 0
                                  ? 'Sin registros'
                                  : formatDuration(
                                    _todayPrayerDuration.inSeconds,
                                  ),
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
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
                              _todayBibleReadingDuration.inSeconds == 0
                                  ? 'Sin registros'
                                  : formatDuration(
                                    _todayBibleReadingDuration.inSeconds,
                                  ),
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
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
