import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _timerStartTimeKey = 'timerStartTime';
  static const _activeTimerTypeKey = 'activeTimerType';

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