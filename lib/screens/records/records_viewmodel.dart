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

  Future<void> deleteActivity(int id) async {
    await dbHelper.deleteActivityLog(id);
    await loadActivityLogs();
  }
}
