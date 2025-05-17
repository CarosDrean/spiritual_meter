import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:spiritual_meter/src/core/constant.dart';
import 'package:spiritual_meter/src/data/database/database_helper.dart';
import 'package:spiritual_meter/src/presentation/widget/day_activity_bottom_sheet.dart';
import 'package:spiritual_meter/src/presentation/widget/statistic/weekly_chart_fl.dart';
import 'package:spiritual_meter/src/utils/formatters.dart';
import 'package:spiritual_meter/src/presentation/widget/app_section_card.dart';
import 'package:spiritual_meter/src/presentation/widget/statistic/monthly_calendar_view.dart';

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

  List<double> _prayerTimesLast7Days = List.filled(7, 0.0);
  List<double> _readingTimesLast7Days = List.filled(7, 0.0);

  @override
  void initState() {
    super.initState();
    _loadDailyStatistics();
    _loadTimesLast7Days();
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

  Future<Map<DateTime, Map<String, double>>> getTimesLast7Days() async {
    final today = DateTime.now();
    final startDate = DateTime(today.year, today.month, today.day).subtract(Duration(days: 6));
    final endDate = DateTime(today.year, today.month, today.day, 23, 59, 59);

    final logs = await _dbHelper.getActivityLogsByDateRange(startDate, endDate);

    final Map<DateTime, Map<String, double>> timesByDay = {};

    for (final log in logs) {
      final day = DateTime(log.endTime.year, log.endTime.month, log.endTime.day);

      timesByDay.putIfAbsent(day, () => {kActivityTypePrayer: 0.0, kActivityTypeBibleReading: 0.0});

      if (log.activityType == kActivityTypePrayer) {
        timesByDay[day]![kActivityTypePrayer] =
            (timesByDay[day]![kActivityTypePrayer] ?? 0) + log.durationInSeconds;
      } else if (log.activityType == kActivityTypeBibleReading) {
        timesByDay[day]![kActivityTypeBibleReading] =
            (timesByDay[day]![kActivityTypeBibleReading] ?? 0) + log.durationInSeconds;
      }
    }

    for (int i = 0; i < 7; i++) {
      final day = DateTime(today.year, today.month, today.day).subtract(Duration(days: i));
      timesByDay.putIfAbsent(day, () => {kActivityTypePrayer: 0.0, kActivityTypeBibleReading: 0.0});
    }

    return timesByDay;
  }

  Future<void> _loadTimesLast7Days() async {
    final timesByDay = await getTimesLast7Days();

    final sortedDays = timesByDay.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    List<double> prayerTimes = [];
    List<double> readingTimes = [];

    for (final day in sortedDays) {
      final prayer = (timesByDay[day]![kActivityTypePrayer] ?? 0.0) / 60;
      final reading = (timesByDay[day]![kActivityTypeBibleReading] ?? 0.0) / 60;

      prayerTimes.add(double.parse(prayer.toStringAsFixed(2)));
      readingTimes.add(double.parse(reading.toStringAsFixed(2)));
    }

    setState(() {
      _prayerTimesLast7Days = prayerTimes;
      _readingTimesLast7Days = readingTimes;
    });
  }

  List<DateTime> getLast7Days() {
    final today = DateTime.now();
    return List.generate(7, (index) {
      return DateTime(today.year, today.month, today.day).subtract(Duration(days: index));
    }).reversed.toList();
  }

  List<String> getLast7DaysLabels() {
    final days = getLast7Days();
    final formatter = DateFormat.E('es');
    return days.map((d) => formatter.format(d)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> last7DaysLabels = getLast7DaysLabels();

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
                  const SizedBox(height: 8),
                ],
              ),
            ),

            AppSectionCard(
              title: kStatisticsTitle,
              content: SizedBox(
                height: 200,
                child: PrayerReadingLineChart(
                  prayerTimes: _prayerTimesLast7Days,
                  readingTimes: _readingTimesLast7Days,
                  last7DaysLabels: last7DaysLabels,
                ),
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
                            builder: (
                              BuildContext context,
                              ScrollController scrollController,
                            ) {
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
