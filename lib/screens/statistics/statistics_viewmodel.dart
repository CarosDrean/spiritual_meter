import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:spiritual_meter/services/database_helper.dart';
import 'package:spiritual_meter/core/constant.dart';

class StatisticsViewModel extends ChangeNotifier {
  final DatabaseHelper dbHelper;

  Duration todayPrayerDuration = Duration.zero;
  Duration todayBibleReadingDuration = Duration.zero;

  DateTime focusedMonth = DateTime.now();

  List<double> prayerTimesLast7Days = List.filled(7, 0.0);
  List<double> readingTimesLast7Days = List.filled(7, 0.0);

  StatisticsViewModel({DatabaseHelper? dbHelper})
    : dbHelper = dbHelper ?? DatabaseHelper();

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

  Future<void> loadDailyStatistics() async {
    final now = DateTime.now();
    final logs = await dbHelper.getDailyLogs(now);

    Duration prayer = Duration.zero;
    Duration reading = Duration.zero;

    for (final log in logs) {
      if (log.activityType == kActivityTypePrayer) {
        prayer += Duration(seconds: log.durationInSeconds);
      } else if (log.activityType == kActivityTypeBibleReading) {
        reading += Duration(seconds: log.durationInSeconds);
      }
    }

    todayPrayerDuration = prayer;
    todayBibleReadingDuration = reading;
    notifyListeners();
  }

  void previousMonth() {
    focusedMonth = DateTime(focusedMonth.year, focusedMonth.month - 1, 1);
    notifyListeners();
  }

  void nextMonth() {
    focusedMonth = DateTime(focusedMonth.year, focusedMonth.month + 1, 1);
    notifyListeners();
  }

  Future<void> loadTimesLast7Days() async {
    final today = DateTime.now();
    final start = today.subtract(const Duration(days: 6));
    final end = DateTime(today.year, today.month, today.day, 23, 59, 59);
    final logs = await dbHelper.getActivityLogsByDateRange(start, end);

    final Map<DateTime, Map<String, double>> grouped = {};

    for (final log in logs) {
      final date = DateTime(
        log.endTime.year,
        log.endTime.month,
        log.endTime.day,
      );
      grouped.putIfAbsent(
        date,
        () => {kActivityTypePrayer: 0, kActivityTypeBibleReading: 0},
      );

      grouped[date]![log.activityType] =
          (grouped[date]![log.activityType] ?? 0) + log.durationInSeconds;
    }

    final List<DateTime> last7Days =
        List.generate(
          7,
          (i) => DateTime(
            today.year,
            today.month,
            today.day,
          ).subtract(Duration(days: i)),
        ).reversed.toList();

    prayerTimesLast7Days =
        last7Days.map((day) {
          return (grouped[day]?[kActivityTypePrayer] ?? 0.0) / 60;
        }).toList();

    readingTimesLast7Days =
        last7Days.map((day) {
          return (grouped[day]?[kActivityTypeBibleReading] ?? 0.0) / 60;
        }).toList();

    notifyListeners();
  }
}
