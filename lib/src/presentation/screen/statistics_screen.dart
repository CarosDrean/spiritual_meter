import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:spiritual_meter/src/core/constant.dart';
import 'package:spiritual_meter/src/data/database/database_helper.dart';
import 'package:spiritual_meter/src/presentation/widget/day_activity_bottom_sheet.dart';
import 'package:spiritual_meter/src/utils/formatters.dart';
import 'package:spiritual_meter/src/presentation/widget/app_section_card.dart';
import 'package:spiritual_meter/src/presentation/widget/statistic/monthly_calendar_view.dart';
import 'package:spiritual_meter/src/presentation/widget/statistic/weekly_chart.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Duration _todayPrayerDuration = Duration.zero;
  Duration _todayBibleReadingDuration = Duration.zero;

  DateTime _focusedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadDailyStatistics();
  }

  Future<void> _loadDailyStatistics() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final logs = await _dbHelper.getActivityLogsByDateRange(
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
    });
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppSectionCard(
              title: 'Registro dia',
              content: Column(
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
                            : formatDuration(_todayPrayerDuration.inSeconds),
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
                        _todayBibleReadingDuration.inSeconds == 0
                            ? 'Sin registros'
                            : formatDuration(
                              _todayBibleReadingDuration.inSeconds,
                            ),
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              bottomButton: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Navegar a agregar registro (Inicio)'),
                    ),
                  );
                  // Navigator.of(context).pop();
                },
                child: const Text('Agregar Registro'),
              ),
            ),

            AppSectionCard(
              title: kStatisticsTitle,
              content: const SizedBox(
                height: 200,
                child: WeeklyChartPlaceholder(),
              ),
            ),

            AppSectionCard(
              title: 'Registro del mes',
              content: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_left),
                        onPressed: _previousMonth,
                      ),
                      Text(
                        DateFormat('MMMM - yyyy', 'es').format(_focusedMonth),
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_right),
                        onPressed: _nextMonth,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  MonthlyCalendarView(
                    focusedMonth: _focusedMonth,
                    onDaySelected: (selectedDay) {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (BuildContext context) {
                          return DraggableScrollableSheet(
                            initialChildSize: 0.3,
                            minChildSize: 0.2,
                            maxChildSize: 0.5,
                            expand: false,
                            builder: (BuildContext context, ScrollController scrollController) {
                              return DayActivityBottomSheet(
                                selectedDay: selectedDay,
                                dbHelper: _dbHelper,
                                scrollController: scrollController,
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
