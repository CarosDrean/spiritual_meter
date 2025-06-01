import 'dart:convert';
import 'model.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiritual_meter/core/constant.dart';
import 'package:spiritual_meter/services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  List<StaticNotificationSetting> _staticNotifications = [];
  static const String _notificationsKey = 'staticNotifications';

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? notificationsJson = prefs.getString(_notificationsKey);

    List<StaticNotificationSetting> loadedNotifications;

    if (notificationsJson != null) {
      final List<dynamic> jsonList = jsonDecode(notificationsJson);
      loadedNotifications =
          jsonList
              .map((json) => StaticNotificationSetting.fromJson(json))
              .toList();
    } else {
      loadedNotifications = [
        StaticNotificationSetting(
          id: 'prayer_morning',
          type: kActivityTypePrayer,
          timeOfDay: const TimeOfDay(hour: 7, minute: 0),
          label: 'Oración de Mañana',
          isEnabled: true,
        ),
        StaticNotificationSetting(
          id: 'prayer_noon',
          type: kActivityTypePrayer,
          timeOfDay: const TimeOfDay(hour: 12, minute: 30),
          label: 'Oración de Mediodía',
          isEnabled: false,
        ),
        StaticNotificationSetting(
          id: 'prayer_night',
          type: kActivityTypePrayer,
          timeOfDay: const TimeOfDay(hour: 20, minute: 0),
          label: 'Oración de Noche',
          isEnabled: true,
        ),
        StaticNotificationSetting(
          id: 'bible_reading_daily',
          type: kActivityTypeBibleReading,
          timeOfDay: const TimeOfDay(hour: 9, minute: 15),
          label: 'Lectura Bíblica Diaria',
          isEnabled: true,
        ),
      ];
    }

    setState(() {
      _staticNotifications = loadedNotifications;
      _sortNotifications();
    });

    await _saveNotifications();
    _programInitialNotifications();
  }

  Future<void> _programInitialNotifications() async {
    for (var notification in _staticNotifications) {
      final int notificationId = notification.id.hashCode;
      if (notification.isEnabled) {
        await _notificationService.scheduleNotification(
          id: notificationId,
          title: 'Recordatorio de ${notification.label}',
          body: notification.type == kActivityTypePrayer
              ? 'Es hora de tu oración diaria.'
              : 'Es hora de tu lectura bíblica.',
          time: notification.timeOfDay,
          payload: notification.id,
        );
      } else {
        await _notificationService.cancelNotification(notificationId);
      }
    }
  }

  Future<void> _saveNotifications() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String notificationsJson = jsonEncode(
      _staticNotifications.map((n) => n.toJson()).toList(),
    );
    await prefs.setString(_notificationsKey, notificationsJson);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(dt);
  }

  void _sortNotifications() {
    _staticNotifications.sort((a, b) {
      final aTime = a.timeOfDay.hour * 60 + a.timeOfDay.minute;
      final bTime = b.timeOfDay.hour * 60 + b.timeOfDay.minute;
      return aTime.compareTo(bTime);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primaryColor = Theme.of(context).primaryColor;
    final bodySmallColor = textTheme.bodySmall!.color!;
    final titleLargeColor = textTheme.titleLarge!.color!;

    if (_staticNotifications.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notificaciones')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _staticNotifications.length,
        itemBuilder: (context, index) {
          final notification = _staticNotifications[index];
          final int notificationId = notification.id.hashCode;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            child: ListTile(
              leading: Icon(
                notification.type == kActivityTypePrayer
                    ? Icons.self_improvement
                    : Icons.book,
                color: notification.isEnabled ? primaryColor : bodySmallColor,
              ),
              title: Text(
                '${_formatTimeOfDay(notification.timeOfDay)} - ${notification.label}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color:
                      notification.isEnabled ? titleLargeColor : bodySmallColor,
                ),
              ),
              subtitle: Text(
                notification.type == kActivityTypePrayer
                    ? 'Oración'
                    : 'Lectura Bíblica',
                style: TextStyle(
                  color:
                      notification.isEnabled
                          ? bodySmallColor
                          : bodySmallColor.withAlpha(77),
                ),
              ),
              trailing: Switch(
                value: notification.isEnabled,
                onChanged: (bool value) async {
                  setState(() {
                    _staticNotifications[index] = notification.copyWith(
                      isEnabled: value,
                    );
                  });
                  await _saveNotifications();

                  if (value) {
                    await _notificationService.scheduleNotification(
                      id: notificationId,
                      title: 'Recordatorio de ${notification.label}',
                      body: notification.type == kActivityTypePrayer
                          ? 'Es hora de tu oración diaria.'
                          : 'Es hora de tu lectura bíblica.',
                      time: notification.timeOfDay,
                      payload: notification.id,
                    );
                  } else {
                    await _notificationService.cancelNotification(notificationId);
                  }
                },
              ),
              onTap: () async {
                final newTime = await showTimePicker(
                  context: context,
                  initialTime: notification.timeOfDay,
                  builder: (BuildContext context, Widget? child) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        alwaysUse24HourFormat: false,
                        textScaler: const TextScaler.linear(0.9),
                      ),
                      child: child!,
                    );
                  },
                );
                if (newTime != null) {
                  setState(() {
                    _staticNotifications[index] = notification.copyWith(
                      timeOfDay: newTime,
                    );
                    _sortNotifications();
                  });
                  await _saveNotifications();

                  if (notification.isEnabled) {
                    await _notificationService.scheduleNotification(
                      id: notificationId,
                      title: 'Recordatorio de ${notification.label}',
                      body: notification.type == kActivityTypePrayer
                          ? 'Es hora de tu oración diaria.'
                          : 'Es hora de tu lectura bíblica.',
                      time: newTime,
                      payload: notification.id,
                    );
                  }
                }
              },
            ),
          );
        },
      ),
    );
  }
}
