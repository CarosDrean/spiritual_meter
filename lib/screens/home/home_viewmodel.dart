import 'dart:math';
import 'package:flutter/material.dart';

import 'package:spiritual_meter/models/activity_log.dart';
import 'package:spiritual_meter/services/database_helper.dart';
import 'package:spiritual_meter/services/notification_service.dart';
import 'package:spiritual_meter/services/preferences_service.dart';
import 'package:spiritual_meter/core/constant.dart';

class HomeViewModel extends ChangeNotifier {
  final DatabaseHelper _dbHelper;
  final NotificationService _notificationService;
  final PreferencesService _prefs = PreferencesService();
  final Random _random = Random();

  HomeViewModel({
    DatabaseHelper? dbHelper,
    NotificationService? notificationService,
  }) : _dbHelper = dbHelper ?? DatabaseHelper(),
       _notificationService = notificationService ?? NotificationService();

  bool isPrayerOn = false;
  bool isBibleReadingOn = false;

  DateTime? _timerStartTime;
  String? _activeTimerType;

  Duration todayPrayerDuration = Duration.zero;
  Duration todayBibleReadingDuration = Duration.zero;

  bool _isDialogShowing = false;

  DateTime? get timerStartTime => _timerStartTime;

  String? get activeTimerType => _activeTimerType;

  bool get isDialogShowing => _isDialogShowing;

  Future<void> loadRecordsToday() async {
    final now = DateTime.now();
    final logs = await _dbHelper.getDailyLogs(now);

    Duration prayerToday = Duration.zero;
    Duration readingToday = Duration.zero;

    for (var log in logs) {
      if (log.activityType == kActivityTypePrayer) {
        prayerToday += Duration(seconds: log.durationInSeconds);
      } else if (log.activityType == kActivityTypeBibleReading) {
        readingToday += Duration(seconds: log.durationInSeconds);
      }
    }

    todayPrayerDuration = prayerToday;
    todayBibleReadingDuration = readingToday;
    notifyListeners();
  }

  String getRandomMessage(List<String> messages) {
    return messages[_random.nextInt(messages.length)];
  }

  String getPrayerMessage(double minutes) {
    if (minutes == 0) {
      return getRandomMessage(kNoPrayerMessages);
    } else if (minutes < 30) {
      return getRandomMessage(kRedMessages);
    } else if (minutes < 60) {
      return getRandomMessage(kYellowMessages);
    } else {
      return getRandomMessage(kGreenMessages);
    }
  }

  void startPrayerTimer() {
    isPrayerOn = true;
    isBibleReadingOn = false;
    _timerStartTime = DateTime.now();
    _activeTimerType = kActivityTypePrayer;
    notifyListeners();
  }

  void startBibleReadingTimer() {
    isBibleReadingOn = true;
    isPrayerOn = false;
    _timerStartTime = DateTime.now();
    _activeTimerType = kActivityTypeBibleReading;
    notifyListeners();
  }

  void stopTimer() {
    isPrayerOn = false;
    isBibleReadingOn = false;
    _timerStartTime = null;
    _activeTimerType = null;
    notifyListeners();
  }

  Future<void> saveTimerState() async {
    if ((isPrayerOn || isBibleReadingOn) &&
        _timerStartTime != null &&
        _activeTimerType != null) {
      await _prefs.saveTimerState(_timerStartTime!, _activeTimerType!);
    } else {
      await _prefs.clearTimerState();
    }
  }

  Future<void> loadTimerState() async {
    final startTime = await _prefs.getTimerStartTime();
    final activeType = await _prefs.getActiveTimerType();

    if (startTime != null && activeType != null) {
      _timerStartTime = startTime;
      _activeTimerType = activeType;
      isPrayerOn = _activeTimerType == kActivityTypePrayer;
      isBibleReadingOn = _activeTimerType == kActivityTypeBibleReading;
      notifyListeners();
    } else {
      stopTimer();
    }
  }

  Future<void> clearTimerState() async {
    await _prefs.clearTimerState();
  }

  Future<void> showReminderNotification() async {
    String title = '';
    String body = '';

    if (isPrayerOn) {
      title = 'Oración en curso';
      body =
          'No olvides retomar tu tiempo de oración. ¡Aún puedes conectarte con Dios!';
    } else if (isBibleReadingOn) {
      title = 'Lectura bíblica en curso';
      body = 'No olvides seguir leyendo la Palabra. ¡Tu espíritu lo necesita!';
    }

    await _notificationService.showReminder(title, body);
  }

  Future<void> cancelReminderNotification() async {
    await _notificationService.cancelReminder();
  }

  void setDialogShowing(bool value) {
    _isDialogShowing = value;
    notifyListeners();
  }

  Future<void> saveLog(ActivityLog log) async {
    await _dbHelper.insertActivityLog(log);
  }
}
