import 'package:flutter/material.dart';
import 'package:spiritual_meter/models/activity_log.dart';
import 'package:spiritual_meter/services/database_helper.dart';

class RecordViewModel extends ChangeNotifier {
  final DatabaseHelper dbHelper;
  List<ActivityLog> _logs = [];

  List<ActivityLog> get logs => _logs;

  RecordViewModel({DatabaseHelper? dbHelper})
    : dbHelper = dbHelper ?? DatabaseHelper();

  Future<void> loadActivityLogs() async {
    _logs = await dbHelper.getActivityLogs();
    notifyListeners();
  }

  String capitalize(String text) =>
      text.isNotEmpty ? '${text[0].toUpperCase()}${text.substring(1)}' : text;

  Future<void> deleteActivity(int id) async {
    await dbHelper.deleteActivityLog(id);
    await loadActivityLogs();
  }

  Map<DateTime, List<ActivityLog>> groupLogsByDay(List<ActivityLog> logs) {
    final Map<DateTime, List<ActivityLog>> groupedLogs = {};

    for (var log in logs) {
      final date = DateTime(log.endTime.year, log.endTime.month, log.endTime.day);
      groupedLogs.putIfAbsent(date, () => []).add(log);
    }

    final sortedKeys = groupedLogs.keys.toList()..sort((a, b) => b.compareTo(a));

    return {
      for (var key in sortedKeys) key: groupedLogs[key]!,
    };
  }
}
