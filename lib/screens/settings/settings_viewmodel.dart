import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:spiritual_meter/core/constant.dart';
import 'package:spiritual_meter/models/notification_setting.dart';
import 'package:spiritual_meter/services/notification_service.dart';

class SettingsViewModel extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  List<NotificationSetting> _notifications = [];

  List<NotificationSetting> get notifications =>
      List.unmodifiable(_notifications);

  static const String _notificationsKey = 'staticNotifications';

  SettingsViewModel() {}

  Future<void> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_notificationsKey);

    List<NotificationSetting> loaded;
    if (jsonStr != null) {
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      loaded = jsonList.map((e) => NotificationSetting.fromJson(e)).toList();
    } else {
      loaded = _getDefaultNotifications();
    }

    _notifications = loaded;
    _sort();
    notifyListeners();
    await _saveNotifications();
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
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(
      _notifications.map((n) => n.toJson()).toList(),
    );
    await prefs.setString(_notificationsKey, json);
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
