import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiritual_meter/models/notification_setting.dart';

class PreferencesService {
  static final PreferencesService _instance = PreferencesService._internal();

  factory PreferencesService() {
    return _instance;
  }

  PreferencesService._internal();

  static const _timerStartTimeKey = 'timerStartTime';
  static const _activeTimerTypeKey = 'activeTimerType';

  static const String _notificationsKey = 'staticNotifications';

  Future<void> saveNotifications(List<NotificationSetting> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(notifications.map((n) => n.toJson()).toList());
    await prefs.setString(_notificationsKey, json);
  }

  Future<List<NotificationSetting>?> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_notificationsKey);

    if (jsonStr != null) {
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      final loadedNotifications = jsonList.map((e) => NotificationSetting.fromJson(e)).toList();
      return loadedNotifications;
    }

    return null;
  }

  Future<void> saveTimerState(DateTime startTime, String activityType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_timerStartTimeKey, startTime.toIso8601String());
    await prefs.setString(_activeTimerTypeKey, activityType);
  }

  Future<void> clearTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_timerStartTimeKey);
    await prefs.remove(_activeTimerTypeKey);
  }

  Future<DateTime?> getTimerStartTime() async {
    final prefs = await SharedPreferences.getInstance();
    final start = prefs.getString(_timerStartTimeKey);
    return start != null ? DateTime.parse(start) : null;
  }

  Future<String?> getActiveTimerType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeTimerTypeKey);
  }
}