import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:spiritual_meter/core/constant.dart';
import 'package:spiritual_meter/models/notification_setting.dart';
import 'package:spiritual_meter/services/notification_service.dart';
import 'package:spiritual_meter/services/preferences_service.dart';

class SettingsViewModel extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  final PreferencesService _prefsService = PreferencesService();

  List<NotificationSetting> _notifications = [];

  List<NotificationSetting> get notifications =>
      List.unmodifiable(_notifications);

  SettingsViewModel() {}

  Future<void> loadNotifications() async {
    final loaded = await _prefsService.loadNotifications();

    if (loaded != null && loaded.isNotEmpty) {
      _notifications = loaded;
    } else {
      _notifications = _getDefaultNotifications();
    }

    _sort();
    notifyListeners();
    _programAllNotifications();
  }

  List<NotificationSetting> _getDefaultNotifications() => [
    NotificationSetting(
      id: 'prayer_morning',
      type: kActivityTypePrayer,
      timeOfDay: const TimeOfDay(hour: 7, minute: 0),
      label: 'Oración de Mañana',
      isEnabled: true,
    ),
    NotificationSetting(
      id: 'prayer_noon',
      type: kActivityTypePrayer,
      timeOfDay: const TimeOfDay(hour: 12, minute: 30),
      label: 'Oración de Mediodía',
      isEnabled: false,
    ),
    NotificationSetting(
      id: 'prayer_night',
      type: kActivityTypePrayer,
      timeOfDay: const TimeOfDay(hour: 20, minute: 0),
      label: 'Oración de Noche',
      isEnabled: true,
    ),
    NotificationSetting(
      id: 'bible_reading_daily',
      type: kActivityTypeBibleReading,
      timeOfDay: const TimeOfDay(hour: 9, minute: 15),
      label: 'Lectura Bíblica Diaria',
      isEnabled: true,
    ),
  ];

  void _sort() {
    _notifications.sort((a, b) {
      final aMinutes = a.timeOfDay.hour * 60 + a.timeOfDay.minute;
      final bMinutes = b.timeOfDay.hour * 60 + b.timeOfDay.minute;
      return aMinutes.compareTo(bMinutes);
    });
  }

  Future<void> _saveNotifications() async {
    await _prefsService.saveNotifications(_notifications);
  }

  Future<void> _programAllNotifications() async {
    for (var n in _notifications) {
      final id = n.id.hashCode;
      if (n.isEnabled) {
        await _notificationService.scheduleNotification(
          id: id,
          title: 'Recordatorio de ${n.label}',
          body:
              n.type == kActivityTypePrayer
                  ? 'Es hora de tu oración diaria.'
                  : 'Es hora de tu lectura bíblica.',
          time: n.timeOfDay,
          payload: n.id,
        );
      } else {
        await _notificationService.cancelNotification(id);
      }
    }
  }

  Future<void> toggleNotification(String id, bool enabled) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1) return;

    final List<NotificationSetting> updatedList = List.from(_notifications);
    updatedList[index] = updatedList[index].copyWith(isEnabled: enabled);

    _notifications = updatedList;

    notifyListeners();
    await _saveNotifications();

    final notif = _notifications[index];
    if (enabled) {
      await _notificationService.scheduleNotification(
        id: notif.id.hashCode,
        title: 'Recordatorio de ${notif.label}',
        body:
            notif.type == kActivityTypePrayer
                ? 'Es hora de tu oración diaria.'
                : 'Es hora de tu lectura bíblica.',
        time: notif.timeOfDay,
        payload: notif.id,
      );
    } else {
      await _notificationService.cancelNotification(notif.id.hashCode);
    }
  }

  Future<void> updateTime(String id, TimeOfDay newTime) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1) return;

    final List<NotificationSetting> updatedList = List.from(_notifications);
    final updated = updatedList[index].copyWith(timeOfDay: newTime);
    updatedList[index] = updated;

    _notifications = updatedList;

    _sort();
    notifyListeners();
    await _saveNotifications();

    if (updated.isEnabled) {
      await _notificationService.scheduleNotification(
        id: updated.id.hashCode,
        title: 'Recordatorio de ${updated.label}',
        body:
            updated.type == kActivityTypePrayer
                ? 'Es hora de tu oración diaria.'
                : 'Es hora de tu lectura bíblica.',
        time: newTime,
        payload: updated.id,
      );
    }
  }
}
