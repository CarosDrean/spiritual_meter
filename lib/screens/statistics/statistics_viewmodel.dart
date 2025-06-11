import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:spiritual_meter/services/database_helper.dart';
import 'package:spiritual_meter/core/constant.dart';

class StatisticsViewModel extends ChangeNotifier {
  final DatabaseHelper dbHelper;

  Duration todayPrayerDuration = Duration.zero;
  Duration todayBibleReadingDuration = Duration.zero;

  Duration selectedDayPrayerDuration = Duration.zero;
  Duration selectedDayBibleReadingDuration = Duration.zero;

  DateTime focusedMonth = DateTime.now();
  Map<DateTime, Set<String>> activitiesByDay = {};

  List<double> prayerTimesLast7Days = List.filled(7, 0.0);
  List<double> readingTimesLast7Days = List.filled(7, 0.0);

  StatisticsViewModel({DatabaseHelper? dbHelper})
    : dbHelper = dbHelper ?? DatabaseHelper();

  Future<void> loadSelectedDayStatistics(DateTime selectedDay) async {
    final (prayer, reading) = await _getDurationsForDay(selectedDay);
    selectedDayPrayerDuration = prayer;
    selectedDayBibleReadingDuration = reading;
    notifyListeners();
  }

  Future<void> loadDailyStatistics() async {
    final (prayer, reading) = await _getDurationsForDay(DateTime.now());
    todayPrayerDuration = prayer;
    todayBibleReadingDuration = reading;
    notifyListeners();
  }

  Future<(Duration prayer, Duration bibleReading)> _getDurationsForDay(
    DateTime day,
  ) async {
    final logs = await dbHelper.getDailyLogs(day);

    Duration prayer = Duration.zero;
    Duration reading = Duration.zero;

    for (var log in logs) {
      if (log.activityType == kActivityTypePrayer) {
        prayer += Duration(seconds: log.durationInSeconds);
      } else if (log.activityType == kActivityTypeBibleReading) {
        reading += Duration(seconds: log.durationInSeconds);
      }
    }

    return (prayer, reading);
  }

  List<DateTime> getLast7Days() {
    final today = DateTime.now();
    return List.generate(7, (index) {
      return DateTime(
        today.year,
        today.month,
        today.day,
      ).subtract(Duration(days: index));
    }).reversed.toList();
  }

  List<String> getLast7DaysLabels() {
    final days = getLast7Days();
    final formatter = DateFormat.E('es');
    return days.map((d) => formatter.format(d)).toList();
  }

  void previousMonth() {
    focusedMonth = DateTime(focusedMonth.year, focusedMonth.month - 1, 1);
    loadActiveDaysForMonth(focusedMonth);
  }

  void nextMonth() {
    focusedMonth = DateTime(focusedMonth.year, focusedMonth.month + 1, 1);
    loadActiveDaysForMonth(focusedMonth);
  }

  Future<void> loadActiveDaysForMonth(DateTime month) async {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(
      month.year,
      month.month + 1,
      1,
    ).subtract(const Duration(seconds: 1));

    final logs = await dbHelper.getActivityLogsByDateRange(
      firstDayOfMonth,
      lastDayOfMonth,
    );

    final Map<DateTime, Set<String>> newActivitiesByDay = {};

    for (var log in logs) {
      final logDate = DateTime(
        log.endTime.year,
        log.endTime.month,
        log.endTime.day,
      );

      newActivitiesByDay.putIfAbsent(logDate, () => {});
      newActivitiesByDay[logDate]!.add(log.activityType);
    }

    activitiesByDay = newActivitiesByDay;
    notifyListeners();
  }

  Future<void> loadTimesLast7Days() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
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
